import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../models/thought.dart';
import '../providers/thought_provider.dart';
import '../utils/theme.dart';
import '../utils/animations.dart';
import 'add_thought_screen.dart';

class ThoughtDetailScreen extends ConsumerStatefulWidget {
  final Thought thought;

  const ThoughtDetailScreen({super.key, required this.thought});

  @override
  ConsumerState<ThoughtDetailScreen> createState() =>
      _ThoughtDetailScreenState();
}

class _ThoughtDetailScreenState extends ConsumerState<ThoughtDetailScreen> {
  late Thought _thought;

  @override
  void initState() {
    super.initState();
    _thought = widget.thought;
  }

  void _toggleFavorite() {
    ref.read(thoughtListProvider.notifier).toggleFavorite(_thought.id);
    setState(() {
      _thought = _thought.copyWith(isFavorite: !_thought.isFavorite);
    });
  }

  void _delete() {
    final c = AppColors.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: c.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          '确认删除',
          style: TextStyle(
              fontSize: AppFont.scale(context, ref, 17),
              fontWeight: FontWeight.w600,
              color: c.textPrimary),
        ),
        content: Text(
          '删除后无法恢复，确定要删除这条想法吗？',
          style: TextStyle(fontSize: AppFont.scale(context, ref, 15), color: c.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('取消',
                style: TextStyle(color: c.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              ref.read(thoughtListProvider.notifier).deleteThought(_thought.id);
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // go back
            },
            child: Text('删除',
                style: TextStyle(color: c.danger)),
          ),
        ],
      ),
    );
  }

  Future<void> _edit() async {
    await Navigator.push(
      context,
      buildSlideRoute(AddThoughtScreen(thought: _thought)),
    );
    // 编辑返回后，从 provider 获取最新数据刷新详情
    final thoughts = ref.read(thoughtListProvider).valueOrNull;
    if (thoughts != null) {
      final updated = thoughts.where((t) => t.id == _thought.id).firstOrNull;
      if (updated != null && mounted) {
        setState(() {
          _thought = updated;
        });
      }
    }
  }

  void _share() {
    Share.share(_thought.content);
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: Column(
          children: [
            // 顶部栏
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: c.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.arrow_back_ios_new_rounded,
                          size: 18, color: c.textPrimary),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => _buildMoreMenu(),
                      );
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: c.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.more_horiz_rounded,
                          size: 20, color: c.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // 内容
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 时间
                    Text(
                      DateFormat('yyyy年MM月dd日 HH:mm')
                          .format(_thought.createdAt),
                      style: TextStyle(
                        fontSize: AppFont.scale(context, ref, 13),
                        color: c.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // 正文
                    Text(
                      _thought.content,
                      style: TextStyle(
                        fontSize: AppFont.scale(context, ref, 17),
                        height: 1.8,
                        color: c.textPrimary,
                      ),
                    ),
                    if (_thought.tag != null &&
                        _thought.tag!.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.getTagColor(_thought.tag!)
                              .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '#${_thought.tag}',
                          style: TextStyle(
                            fontSize: AppFont.scale(context, ref, 13),
                            color: AppColors.getTagColor(_thought.tag!),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                    // 图片展示
                    if (_thought.imagePathList.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _thought.imagePathList.map((path) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              path,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: c.surfaceVariant,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(Icons.image_outlined,
                                    color: c.textTertiary),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                    // 语音展示
                    if (_thought.audioPath != null &&
                        _thought.audioPath!.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: c.accent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.play_circle_outline,
                                size: 28, color: c.accent),
                            const SizedBox(width: 12),
                            Text(
                              '语音记录',
                              style: TextStyle(
                                fontSize: AppFont.scale(context, ref, 15),
                                color: c.accent,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (_thought.note != null &&
                        _thought.note!.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: c.surfaceVariant,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '备注',
                              style: TextStyle(
                                fontSize: AppFont.scale(context, ref, 12),
                                color: c.textTertiary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _thought.note!,
                              style: TextStyle(
                                fontSize: AppFont.scale(context, ref, 14),
                                height: 1.6,
                                color: c.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            // 底部操作栏
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              decoration: BoxDecoration(
                color: c.surface,
                border: Border(
                  top: BorderSide(color: c.divider, width: 0.5),
                ),
              ),
              child: Row(
                children: [
                  _buildBottomAction(
                    _thought.isFavorite
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    '收藏',
                    _thought.isFavorite
                        ? const Color(0xFFFFD666)
                        : c.textSecondary,
                    _toggleFavorite,
                  ),
                  _buildBottomAction(
                      Icons.share_outlined, '分享', c.textSecondary,
                      _share),
                  _buildBottomAction(
                      Icons.edit_outlined, '编辑', c.textSecondary,
                      _edit),
                  _buildBottomAction(
                      Icons.delete_outline, '删除', c.danger, _delete),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomAction(
      IconData icon, String label, Color color, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: AppFont.scale(context, ref, 11), color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoreMenu() {
    final c = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildMenuItem(Icons.edit_outlined, '编辑', _edit),
          _buildMenuItem(Icons.share_outlined, '分享', _share),
          _buildMenuItem(Icons.delete_outline, '删除', _delete,
              isDestructive: true),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String label, VoidCallback onTap,
      {bool isDestructive = false}) {
    final c = AppColors.of(context);
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        child: Row(
          children: [
            Icon(icon,
                size: 22,
                color: isDestructive
                    ? c.danger
                    : c.textPrimary),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: AppFont.scale(context, ref, 16),
                color: isDestructive
                    ? c.danger
                    : c.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
