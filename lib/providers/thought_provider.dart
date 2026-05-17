import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../database/thought_db.dart';
import '../models/thought.dart';
import '../services/sync_service.dart';

final thoughtListProvider =
    StateNotifierProvider<ThoughtListNotifier, AsyncValue<List<Thought>>>(
        (ref) {
  return ThoughtListNotifier();
});

final randomThoughtProvider = FutureProvider<Thought?>((ref) async {
  return await ThoughtDatabase.instance.getRandomThought();
});

final thoughtCountProvider = FutureProvider<int>((ref) async {
  return await ThoughtDatabase.instance.getThoughtCount();
});

final favoriteCountProvider = FutureProvider<int>((ref) async {
  return await ThoughtDatabase.instance.getFavoriteCount();
});

final distinctTagsProvider = FutureProvider<List<String>>((ref) async {
  return await ThoughtDatabase.instance.getDistinctTags();
});

final consecutiveDaysProvider = FutureProvider<int>((ref) async {
  return await ThoughtDatabase.instance.getConsecutiveDays();
});

// 搜索关键词
final searchQueryProvider = StateProvider<String>((ref) => '');

// 选中的标签筛选
final selectedTagProvider = StateProvider<String?>((ref) => null);

// 选中的日期
final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

// 搜索结果
final searchResultsProvider =
    FutureProvider.family<List<Thought>, String>((ref, query) async {
  if (query.isEmpty) return [];
  return await ThoughtDatabase.instance.searchThoughts(query);
});

// 按标签筛选
final thoughtsByTagProvider =
    FutureProvider.family<List<Thought>, String>((ref, tag) async {
  return await ThoughtDatabase.instance.getThoughtsByTag(tag);
});

// 按日期筛选
final thoughtsByDateProvider =
    FutureProvider.family<List<Thought>, DateTime>((ref, date) async {
  return await ThoughtDatabase.instance.getThoughtsByDate(date);
});

// 收藏列表
final favoriteThoughtsProvider = FutureProvider<List<Thought>>((ref) async {
  return await ThoughtDatabase.instance.getFavoriteThoughts();
});

class ThoughtListNotifier extends StateNotifier<AsyncValue<List<Thought>>> {
  ThoughtListNotifier() : super(const AsyncValue.loading()) {
    loadThoughts();
  }

  Future<void> loadThoughts() async {
    try {
      final thoughts = await ThoughtDatabase.instance.getAllThoughts();
      state = AsyncValue.data(thoughts);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addThought(
    String content, {
    String? tag,
    String? imagePaths,
    String? audioPath,
  }) async {
    final thought = Thought(
      id: const Uuid().v4(),
      content: content,
      tag: tag,
      imagePaths: imagePaths,
      audioPath: audioPath,
      createdAt: DateTime.now(),
    );
    await ThoughtDatabase.instance.insertThought(thought);
    await loadThoughts();
    SyncService.pushChanges();
  }

  Future<void> updateThought(Thought thought) async {
    await ThoughtDatabase.instance.updateThought(thought);
    await loadThoughts();
    SyncService.pushChanges();
  }

  Future<void> deleteThought(String id) async {
    await ThoughtDatabase.instance.deleteThought(id);
    await loadThoughts();
    SyncService.pushChanges();
  }

  Future<void> toggleFavorite(String id) async {
    await ThoughtDatabase.instance.toggleFavorite(id);
    await loadThoughts();
    SyncService.pushChanges();
  }
}
