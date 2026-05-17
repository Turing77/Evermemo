import 'package:shared_preferences/shared_preferences.dart';
import '../database/thought_db.dart';
import '../models/thought.dart';
import 'supabase_service.dart';

class SyncService {
  static const _lastSyncKey = 'last_sync_time';

  // 全量同步：登录后调用
  static Future<void> fullSync() async {
    final supabase = SupabaseService.instance;
    if (!supabase.isLoggedIn) return;

    final prefs = await SharedPreferences.getInstance();
    final lastSyncStr = prefs.getString(_lastSyncKey);
    final lastSync =
        lastSyncStr != null ? DateTime.parse(lastSyncStr) : DateTime(2000);

    // 1. 拉取云端变更
    await _pullFromCloud(lastSync);

    // 2. 推送本地变更
    await _pushToCloud(lastSync);

    // 3. 更新同步时间
    await prefs.setString(_lastSyncKey, DateTime.now().toUtc().toIso8601String());
  }

  // 推送本地变更到云端（增删改后调用）
  static Future<void> pushChanges() async {
    final supabase = SupabaseService.instance;
    if (!supabase.isLoggedIn) return;

    final prefs = await SharedPreferences.getInstance();
    final lastSyncStr = prefs.getString(_lastSyncKey);
    final lastSync =
        lastSyncStr != null ? DateTime.parse(lastSyncStr) : DateTime(2000);

    await _pushToCloud(lastSync);
    await prefs.setString(_lastSyncKey, DateTime.now().toUtc().toIso8601String());
  }

  // 拉取云端变更到本地
  static Future<void> pullChanges() async {
    final supabase = SupabaseService.instance;
    if (!supabase.isLoggedIn) return;

    final prefs = await SharedPreferences.getInstance();
    final lastSyncStr = prefs.getString(_lastSyncKey);
    final lastSync =
        lastSyncStr != null ? DateTime.parse(lastSyncStr) : DateTime(2000);

    await _pullFromCloud(lastSync);
    await prefs.setString(_lastSyncKey, DateTime.now().toUtc().toIso8601String());
  }

  static Future<void> _pullFromCloud(DateTime since) async {
    final supabase = SupabaseService.instance;
    final cloudData = await supabase.fetchThoughts(since: since);

    final cloudThoughts = cloudData.map((map) {
      // 转换 Supabase 字段名为本地字段名
      return Thought.fromSupabaseMap(map);
    }).toList();

    if (cloudThoughts.isNotEmpty) {
      await ThoughtDatabase.instance.upsertFromCloud(cloudThoughts);
    }
  }

  static Future<void> _pushToCloud(DateTime since) async {
    final supabase = SupabaseService.instance;
    final userId = supabase.currentUser!.id;

    final localChanges =
        await ThoughtDatabase.instance.getUpdatedSince(since);

    if (localChanges.isEmpty) return;

    final cloudData = localChanges.map((t) {
      final map = t.toSupabaseMap();
      map['user_id'] = userId;
      return map;
    }).toList();

    await supabase.upsertThoughts(cloudData);
  }
}
