import '../models/thought.dart';

// Conditional import for SQLite
import 'thought_db_sqlite.dart' if (dart.library.html) 'thought_db_memory.dart';

abstract class ThoughtDatabaseBase {
  Future<void> insertThought(Thought thought);
  Future<void> updateThought(Thought thought);
  Future<List<Thought>> getAllThoughts();
  Future<Thought?> getRandomThought();
  Future<void> deleteThought(String id);
  Future<int> getThoughtCount();
  Future<void> toggleFavorite(String id);
  Future<List<Thought>> getFavoriteThoughts();
  Future<List<Thought>> searchThoughts(String query);
  Future<List<Thought>> getThoughtsByTag(String tag);
  Future<List<Thought>> getThoughtsByDate(DateTime date);
  Future<int> getFavoriteCount();
  Future<List<String>> getDistinctTags();
  Future<int> getConsecutiveDays();
  Future<List<Thought>> getUpdatedSince(DateTime since);
  Future<void> upsertFromCloud(List<Thought> thoughts);
}

class ThoughtDatabase {
  static final ThoughtDatabase instance = ThoughtDatabase._();
  late final ThoughtDatabaseBase _impl;

  ThoughtDatabase._() {
    _impl = createDatabase();
  }

  Future<void> insertThought(Thought thought) => _impl.insertThought(thought);
  Future<void> updateThought(Thought thought) => _impl.updateThought(thought);
  Future<List<Thought>> getAllThoughts() => _impl.getAllThoughts();
  Future<Thought?> getRandomThought() => _impl.getRandomThought();
  Future<void> deleteThought(String id) => _impl.deleteThought(id);
  Future<int> getThoughtCount() => _impl.getThoughtCount();
  Future<void> toggleFavorite(String id) => _impl.toggleFavorite(id);
  Future<List<Thought>> getFavoriteThoughts() => _impl.getFavoriteThoughts();
  Future<List<Thought>> searchThoughts(String query) =>
      _impl.searchThoughts(query);
  Future<List<Thought>> getThoughtsByTag(String tag) =>
      _impl.getThoughtsByTag(tag);
  Future<List<Thought>> getThoughtsByDate(DateTime date) =>
      _impl.getThoughtsByDate(date);
  Future<int> getFavoriteCount() => _impl.getFavoriteCount();
  Future<List<String>> getDistinctTags() => _impl.getDistinctTags();
  Future<int> getConsecutiveDays() => _impl.getConsecutiveDays();
  Future<List<Thought>> getUpdatedSince(DateTime since) =>
      _impl.getUpdatedSince(since);
  Future<void> upsertFromCloud(List<Thought> thoughts) =>
      _impl.upsertFromCloud(thoughts);
}
