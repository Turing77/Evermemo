import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/thought_provider.dart';
import '../services/supabase_service.dart';
import '../utils/theme.dart';
import '../utils/animations.dart';
import 'settings_screen.dart';
import 'about_screen.dart';
import 'tag_manage_screen.dart';
import 'favorites_screen.dart';
import 'login_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 监听 thoughtListProvider 以自动刷新
    final thoughtsAsync = ref.watch(thoughtListProvider);

    final thoughtCount = thoughtsAsync.when(
      data: (list) => list.length,
      loading: () => 0,
      error: (_, __) => 0,
    );
    final favoriteCount = thoughtsAsync.when(
      data: (list) => list.where((t) => t.isFavorite).length,
      loading: () => 0,
      error: (_, __) => 0,
    );
    // 连续天数从 provider 获取
    final consecutiveDays = ref.watch(consecutiveDaysProvider);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text(
              '我的',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.edit_note_rounded,
                      size: 36,
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '常记',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Evermemo',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '把今日一念，留给来日回望。',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildStatCard('想法', '$thoughtCount')),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const FavoritesScreen()),
                    ),
                    child: _buildStatCard('收藏', '$favoriteCount'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                    child: _buildStatCard(
                        '连续天数',
                        consecutiveDays.when(
                          data: (days) => '$days',
                          loading: () => '-',
                          error: (_, __) => '0',
                        ))),
              ],
            ),
            const SizedBox(height: 24),
            _buildMenuItem(
              Icons.settings_outlined,
              '设置',
              () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen())),
            ),
            _buildMenuItem(
              Icons.label_outline_rounded,
              '标签管理',
              () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const TagManageScreen())),
            ),
            _buildMenuItem(
              Icons.info_outline_rounded,
              '关于常记',
              () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const AboutScreen())),
            ),
            const SizedBox(height: 24),
            // 账号信息
            if (SupabaseService.instance.isLoggedIn) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '账号',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      SupabaseService.instance.currentUser?.email ?? '',
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => _showLogoutDialog(context),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: Text(
                      '退出登录',
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.danger,
                      ),
                    ),
                  ),
                ),
              ),
            ] else ...[
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: Text(
                      '登录 / 注册',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.background,
                      ),
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('退出登录',
            style: TextStyle(color: AppColors.textPrimary)),
        content: const Text('退出后本地数据会保留，云端同步将停止。',
            style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消',
                style: TextStyle(color: AppColors.textTertiary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await SupabaseService.instance.signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  buildFadeRoute(const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text('退出', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 2),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: AppColors.textSecondary),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right_rounded,
                size: 20, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}
