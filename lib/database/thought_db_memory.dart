import 'dart:math';
import '../models/thought.dart';
import 'thought_db.dart';

ThoughtDatabaseBase createDatabase() => ThoughtDatabaseMemory();

class ThoughtDatabaseMemory implements ThoughtDatabaseBase {
  final List<Thought> _thoughts = [];

  @override
  Future<void> insertThought(Thought thought) async {
    _thoughts.removeWhere((t) => t.id == thought.id);
    _thoughts.add(thought);
  }

  @override
  Future<void> updateThought(Thought thought) async {
    final index = _thoughts.indexWhere((t) => t.id == thought.id);
    if (index != -1) {
      _thoughts[index] = thought;
    }
  }

  @override
  Future<List<Thought>> getAllThoughts() async {
    final sorted = List<Thought>.from(_thoughts);
    sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted;
  }

  @override
  Future<Thought?> getRandomThought() async {
    if (_thoughts.isEmpty) return null;
    return _thoughts[Random().nextInt(_thoughts.length)];
  }

  @override
  Future<void> deleteThought(String id) async {
    _thoughts.removeWhere((t) => t.id == id);
  }

  @override
  Future<int> getThoughtCount() async {
    return _thoughts.length;
  }

  @override
  Future<void> toggleFavorite(String id) async {
    final index = _thoughts.indexWhere((t) => t.id == id);
    if (index != -1) {
      final t = _thoughts[index];
      _thoughts[index] = t.copyWith(isFavorite: !t.isFavorite);
    }
  }

  @override
  Future<List<Thought>> getFavoriteThoughts() async {
    return _thoughts.where((t) => t.isFavorite).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<List<Thought>> searchThoughts(String query) async {
    final q = query.toLowerCase();
    return _thoughts
        .where((t) =>
            t.content.toLowerCase().contains(q) ||
            (t.tag?.toLowerCase().contains(q) ?? false) ||
            (t.note?.toLowerCase().contains(q) ?? false))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<List<Thought>> getThoughtsByTag(String tag) async {
    return _thoughts.where((t) => t.tag == tag).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<List<Thought>> getThoughtsByDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return _thoughts
        .where((t) =>
            t.createdAt.isAfter(startOfDay) && t.createdAt.isBefore(endOfDay))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<int> getFavoriteCount() async {
    return _thoughts.where((t) => t.isFavorite).length;
  }

  @override
  Future<List<String>> getDistinctTags() async {
    final tags = _thoughts
        .where((t) => t.tag != null && t.tag!.isNotEmpty)
        .map((t) => t.tag!)
        .toSet()
        .toList();
    tags.sort();
    return tags;
  }

  @override
  Future<int> getConsecutiveDays() async {
    if (_thoughts.isEmpty) return 0;
    final dates = _thoughts
        .map((t) => DateTime(t.createdAt.year, t.createdAt.month, t.createdAt.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    int consecutive = 0;
    DateTime? prevDate;

    for (final date in dates) {
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
    return _thoughts.where((t) => t.updatedAt.isAfter(since)).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  @override
  Future<void> upsertFromCloud(List<Thought> thoughts) async {
    for (final thought in thoughts) {
      _thoughts.removeWhere((t) => t.id == thought.id);
      _thoughts.add(thought);
    }
  }
}
