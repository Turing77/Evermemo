import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../database/thought_db.dart';
import '../models/thought.dart';
import '../providers/thought_provider.dart';
import '../utils/theme.dart';
import '../utils/animations.dart';
import 'add_thought_screen.dart';
import 'thought_detail_screen.dart';
import 'favorites_screen.dart';
import 'tag_manage_screen.dart';
import 'settings_screen.dart';
import 'about_screen.dart';

class TodayScreen extends ConsumerStatefulWidget {
  const TodayScreen({super.key});

  @override
  ConsumerState<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends ConsumerState<TodayScreen> {
  Thought? _randomThought;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadRandomThought();
  }

  Future<void> _loadRandomThought() async {
    setState(() => _isLoading = true);
    final thought = await ThoughtDatabase.instance.getRandomThought();
    if (mounted) {
      setState(() {
        _randomThought = thought;
        _isLoading = false;
      });
    }
  }

  String _getDateText() {
    final now = DateTime.now();
    final weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    return '${now.month}月${now.day}日 · ${weekdays[now.weekday - 1]}';
  }

  void _showMenu() {
    final c = AppColors.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 拖拽指示条
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: c.textTertiary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            _buildMenuTile(
              Icons.star_outline_rounded,
              '我的收藏',
              () {
                Navigator.pop(ctx);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const FavoritesScreen()));
              },
            ),
            _buildMenuTile(
              Icons.label_outline_rounded,
              '标签管理',
              () {
                Navigator.pop(ctx);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const TagManageScreen()));
              },
            ),
            _buildMenuTile(
              Icons.settings_outlined,
              '设置',
              () {
                Navigator.pop(ctx);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()));
              },
            ),
            _buildMenuTile(
              Icons.info_outline_rounded,
              '关于常记',
              () {
                Navigator.pop(ctx);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const AboutScreen()));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuTile(IconData icon, String title, VoidCallback onTap) {
    final c = AppColors.of(context);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 22, color: c.textSecondary),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: c.textPrimary,
              ),
            ),
            const Spacer(),
            Icon(Icons.chevron_right_rounded,
                size: 20, color: c.textTertiary),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final bodyFont = AppFont.body(context, ref);
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 顶部栏
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: _showMenu,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: c.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.menu_rounded,
                        size: 20, color: c.textSecondary),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                            buildSlideRoute(const AddThoughtScreen()))
                        .then((_) => _loadRandomThought());
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: c.accent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.add_rounded,
                        size: 22, color: c.background),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // 标题区域
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '常记',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: c.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getDateText(),
                  style: TextStyle(
                    fontSize: 14,
                    color: c.textTertiary,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  '今日回想',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: c.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // 核心卡片
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _isLoading
                  ? Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: c.accent,
                        ),
                      ),
                    )
                  : _randomThought != null
                      ? AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          child: _buildRecallCard(_randomThought!),
                        )
                      : _buildEmptyCard(),
            ),
          ),
          // 底部按钮
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                              buildSlideRoute(const AddThoughtScreen()))
                          .then((_) => _loadRandomThought());
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: c.accent,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Center(
                        child: Text(
                          '写下一念',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: c.background,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: _loadRandomThought,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: c.surfaceVariant,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Center(
                        child: Text(
                          '随机一念',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: c.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecallCard(Thought thought) {
    final c = AppColors.of(context);
    return GestureDetector(
      key: ValueKey(thought.id),
      onTap: () {
        Navigator.push(
          context,
          buildSlideRoute(ThoughtDetailScreen(thought: thought)),
        ).then((_) => _loadRandomThought());
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  Icons.format_quote_rounded,
                  size: 28,
                  color: c.accent.withValues(alpha: 0.5),
                ),
                const Spacer(),
                if (thought.tag != null && thought.tag!.isNotEmpty)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.getTagColor(thought.tag!)
                          .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      thought.tag!,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.getTagColor(thought.tag!),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              thought.content,
              style: TextStyle(
                fontSize: 16,
                height: 1.8,
                color: c.textPrimary,
              ),
              maxLines: 6,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            Text(
              DateFormat('yyyy年MM月dd日').format(thought.createdAt),
              style: TextStyle(
                fontSize: 12,
                color: c.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCard() {
    final c = AppColors.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.edit_note_rounded,
            size: 48,
            color: c.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            '还没有记录',
            style: TextStyle(
              fontSize: 16,
              color: c.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '写下你的第一念吧',
            style: TextStyle(
              fontSize: 13,
              color: c.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
