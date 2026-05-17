import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseService get instance => _instance!;

  late final SupabaseClient client;

  SupabaseService._();

  static bool _initialized = false;
  static bool get isConfigured => _initialized;

  static Future<void> initialize() async {
    const url = 'https://tkmfbzlvbiiqmauijwzo.supabase.co';
    const anonKey = 'sb_publishable_VwBy3A3Hnu53tCgzM770ig_dvLboAJd';

    // 未配置时跳过初始化，应用仍可离线使用
    if (url.contains('YOUR_PROJECT') || anonKey == 'YOUR_ANON_KEY') {
      _instance = SupabaseService._();
      return;
    }

    await Supabase.initialize(url: url, anonKey: anonKey);
    _instance = SupabaseService._();
    _instance!.client = Supabase.instance.client;
    _initialized = true;
  }

  // === 认证 ===

  User? get currentUser => _initialized ? client.auth.currentUser : null;

  bool get isLoggedIn => currentUser != null;

  Future<AuthResponse> signUp(String email, String password) async {
    if (!_initialized) throw Exception('Supabase 未配置');
    return await client.auth.signUp(email: email, password: password);
  }

  Future<AuthResponse> signIn(String email, String password) async {
    if (!_initialized) throw Exception('Supabase 未配置');
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    if (!_initialized) return;
    await client.auth.signOut();
  }

  // === 数据操作 ===

  Future<List<Map<String, dynamic>>> fetchThoughts(
      {DateTime? since}) async {
    final baseQuery = client
        .from('thoughts')
        .select()
        .eq('user_id', currentUser!.id);

    final result = since == null
        ? await baseQuery.order('created_at', ascending: false)
        : await baseQuery
            .gte('updated_at', since.toUtc().toIso8601String())
            .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(result);
  }

  Future<void> upsertThoughts(List<Map<String, dynamic>> thoughts) async {
    if (thoughts.isEmpty) return;
    await client.from('thoughts').upsert(thoughts);
  }

  Future<void> deleteThought(String id) async {
    await client.from('thoughts').delete().eq('id', id);
  }

  Future<void> deleteAllUserThoughts() async {
    await client.from('thoughts').delete().eq('user_id', currentUser!.id);
  }
}
