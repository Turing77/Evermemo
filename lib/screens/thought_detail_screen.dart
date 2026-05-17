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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          '确认删除',
          style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary),
        ),
        content: const Text(
          '删除后无法恢复，确定要删除这条想法吗？',
          style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              ref.read(thoughtListProvider.notifier).deleteThought(_thought.id);
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // go back
            },
            child: const Text('删除',
                style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }

  void _edit() {
    Navigator.push(
      context,
      buildSlideRoute(const AddThoughtScreen()),
    );
  }

  void _share() {
    Share.share(_thought.content);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          size: 18, color: AppColors.textPrimary),
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
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.more_horiz_rounded,
                          size: 20, color: AppColors.textPrimary),
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
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // 正文
                    Text(
                      _thought.content,
                      style: const TextStyle(
                        fontSize: 17,
                        height: 1.8,
                        color: AppColors.textPrimary,
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
                            fontSize: 13,
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
                                  color: AppColors.surfaceVariant,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.image_outlined,
                                    color: AppColors.textTertiary),
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
                          color: AppColors.accent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.play_circle_outline,
                                size: 28, color: AppColors.accent),
                            SizedBox(width: 12),
                            Text(
                              '语音记录',
                              style: TextStyle(
                                fontSize: 15,
                                color: AppColors.accent,
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
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '备注',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textTertiary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _thought.note!,
                              style: const TextStyle(
                                fontSize: 14,
                                height: 1.6,
                                color: AppColors.textSecondary,
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
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(
                  top: BorderSide(color: AppColors.divider, width: 0.5),
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
                        : AppColors.textSecondary,
                    _toggleFavorite,
                  ),
                  _buildBottomAction(
                      Icons.share_outlined, '分享', AppColors.textSecondary,
                      _share),
                  _buildBottomAction(
                      Icons.edit_outlined, '编辑', AppColors.textSecondary,
                      _edit),
                  _buildBottomAction(
                      Icons.delete_outline, '删除', AppColors.danger, _delete),
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
              style: TextStyle(fontSize: 11, color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoreMenu() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                    ? AppColors.danger
                    : AppColors.textPrimary),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: isDestructive
                    ? AppColors.danger
                    : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
