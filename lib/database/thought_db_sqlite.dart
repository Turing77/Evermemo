import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/thought.dart';
import 'thought_db.dart';

ThoughtDatabaseBase createDatabase() => ThoughtDatabaseSqlite();

class ThoughtDatabaseSqlite implements ThoughtDatabaseBase {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('mind_vault.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: 4,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE thoughts (
        id TEXT PRIMARY KEY,
        content TEXT NOT NULL,
        tag TEXT,
        is_favorite INTEGER DEFAULT 0,
        note TEXT,
        image_paths TEXT,
        audio_path TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
          'ALTER TABLE thoughts ADD COLUMN is_favorite INTEGER DEFAULT 0');
      await db.execute('ALTER TABLE thoughts ADD COLUMN note TEXT');
    }
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE thoughts ADD COLUMN image_paths TEXT');
      await db.execute('ALTER TABLE thoughts ADD COLUMN audio_path TEXT');
    }
    if (oldVersion < 4) {
      await db.execute('ALTER TABLE thoughts ADD COLUMN updated_at INTEGER');
      // 用 created_at 填充已有记录的 updated_at
      await db.execute('UPDATE thoughts SET updated_at = created_at WHERE updated_at IS NULL');
    }
  }

  @override
  Future<void> insertThought(Thought thought) async {
    final db = await database;
    await db.insert('thoughts', thought.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> updateThought(Thought thought) async {
    final db = await database;
    final map = thought.toMap();
    map['updated_at'] = DateTime.now().millisecondsSinceEpoch;
    await db.update('thoughts', map,
        where: 'id = ?', whereArgs: [thought.id]);
  }

  @override
  Future<List<Thought>> getAllThoughts() async {
    final db = await database;
    final result = await db.query('thoughts', orderBy: 'created_at DESC');
    return result.map((map) => Thought.fromMap(map)).toList();
  }

  @override
  Future<Thought?> getRandomThought() async {
    final db = await database;
    final result =
        await db.rawQuery('SELECT * FROM thoughts ORDER BY RANDOM() LIMIT 1');
    if (result.isEmpty) return null;
    return Thought.fromMap(result.first);
  }

  @override
  Future<void> deleteThought(String id) async {
    final db = await database;
    await db.delete('thoughts', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<int> getThoughtCount() async {
    final db = await database;
    final result =
        await db.rawQuery('SELECT COUNT(*) as count FROM thoughts');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  @override
  Future<void> toggleFavorite(String id) async {
    final db = await database;
    await db.rawUpdate(
      'UPDATE thoughts SET is_favorite = CASE WHEN is_favorite = 1 THEN 0 ELSE 1 END, updated_at = ? WHERE id = ?',
      [DateTime.now().millisecondsSinceEpoch, id],
    );
  }

  @override
  Future<List<Thought>> getFavoriteThoughts() async {
    final db = await database;
    final result = await db.query(
      'thoughts',
      where: 'is_favorite = 1',
      orderBy: 'created_at DESC',
    );
    return result.map((map) => Thought.fromMap(map)).toList();
  }

  @override
  Future<List<Thought>> searchThoughts(String query) async {
    final db = await database;
    final result = await db.query(
      'thoughts',
      where: 'content LIKE ? OR tag LIKE ? OR note LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'created_at DESC',
    );
    return result.map((map) => Thought.fromMap(map)).toList();
  }

  @override
  Future<List<Thought>> getThoughtsByTag(String tag) async {
    final db = await database;
    final result = await db.query(
      'thoughts',
      where: 'tag = ?',
      whereArgs: [tag],
      orderBy: 'created_at DESC',
    );
    return result.map((map) => Thought.fromMap(map)).toList();
  }

  @override
  Future<List<Thought>> getThoughtsByDate(DateTime date) async {
    final db = await database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    final result = await db.query(
      'thoughts',
      where: 'created_at >= ? AND created_at < ?',
      whereArgs: [
        startOfDay.millisecondsSinceEpoch,
        endOfDay.millisecondsSinceEpoch,
      ],
      orderBy: 'created_at DESC',
    );
    return result.map((map) => Thought.fromMap(map)).toList();
  }

  @override
  Future<int> getFavoriteCount() async {
    final db = await database;
    final result = await db
        .rawQuery('SELECT COUNT(*) as count FROM thoughts WHERE is_favorite = 1');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  @override
  Future<List<String>> getDistinctTags() async {
    final db = await database;
    final result = await db.rawQuery(
      "SELECT DISTINCT tag FROM thoughts WHERE tag IS NOT NULL AND tag != '' ORDER BY tag",
    );
    return result.map((map) => map['tag'] as String).toList();
  }

  @override
  Future<int> getConsecutiveDays() async {
    final db = await database;
    final result = await db.rawQuery(
      "SELECT DISTINCT date(created_at / 1000, 'unixepoch', 'localtime') as day FROM thoughts ORDER BY day DESC",
    );
    if (result.isEmpty) return 0;

    int consecutive = 0;
    DateTime? prevDate;

    for (final row in result) {
      final dayStr = row['day'] as String;
      final date = DateTime.parse(dayStr);

      if (prevDate == null) {
        final today = DateTime.now();
        final todayDate = DateTime(today.year, today.month, today.day);
        final diff = todayDate.difference(date).inDays;
        if (diff > 1) break;
        consecutive = 1;
        prevDate = date;
      } else {
        final diff = prevDate.difference(date).inDays;
        if (diff == 1) {
          consecutive++;
          prevDate = date;
        } else {
          break;
        }
      }
    }
    return consecutive;
  }

  @override
  Future<List<Thought>> getUpdatedSince(DateTime since) async {
    final db = await database;
    final result = await db.query(
      'thoughts',
      where: 'updated_at > ?',
      whereArgs: [since.millisecondsSinceEpoch],
      orderBy: 'updated_at DESC',
    );
    return result.map((map) => Thought.fromMap(map)).toList();
  }

  @override
  Future<void> upsertFromCloud(List<Thought> thoughts) async {
    final db = await database;
    final batch = db.batch();
    for (final thought in thoughts) {
      batch.insert('thoughts', thought.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }
}
