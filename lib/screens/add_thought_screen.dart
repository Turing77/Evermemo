import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'dart:async';
import '../database/thought_db.dart';
import '../providers/thought_provider.dart';
import '../utils/theme.dart';

class AddThoughtScreen extends ConsumerStatefulWidget {
  const AddThoughtScreen({super.key});

  @override
  ConsumerState<AddThoughtScreen> createState() => _AddThoughtScreenState();
}

class _AddThoughtScreenState extends ConsumerState<AddThoughtScreen>
    with SingleTickerProviderStateMixin {
  final _contentController = TextEditingController();
  final _focusNode = FocusNode();
  String? _selectedTag;
  late AnimationController _animController;
  List<String> _allTags = [];
  final List<XFile> _pickedImages = [];

  // 录音相关
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  String? _audioPath;
  int _recordSeconds = 0;
  Timer? _recordTimer;

  final List<String> _presetTags = [
    '灵感',
    '心情',
    '想法',
    '待办',
    '生活',
    '读书',
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..forward();
    _loadTags();
    Future.delayed(const Duration(milliseconds: 300), () {
      _focusNode.requestFocus();
    });
  }

  Future<void> _loadTags() async {
    final tags = await ThoughtDatabase.instance.getDistinctTags();
    if (mounted) {
      setState(() {
        _allTags = tags;
      });
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    _focusNode.dispose();
    _animController.dispose();
    _recordTimer?.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }

  void _save() {
    final content = _contentController.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('先写下一点什么吧'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final imagePaths =
        _pickedImages.isNotEmpty ? _pickedImages.map((f) => f.path).join(',') : null;

    ref.read(thoughtListProvider.notifier).addThought(
          content,
          tag: _selectedTag,
          imagePaths: imagePaths,
          audioPath: _audioPath,
        );

    _animController.reverse().then((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('已收好这一念'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    try {
      final images = await picker.pickMultiImage(imageQuality: 80);
      if (images.isNotEmpty) {
        setState(() {
          _pickedImages.addAll(images);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('选择图片失败: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      // 停止录音
      final path = await _audioRecorder.stop();
      _recordTimer?.cancel();
      if (mounted) {
        setState(() {
          _isRecording = false;
          _audioPath = path;
          _recordSeconds = 0;
        });
      }
    } else {
      // 开始录音
      try {
        if (await _audioRecorder.hasPermission()) {
          await _audioRecorder.start(const RecordConfig(), path: 'voice_note.m4a');
          if (mounted) {
            setState(() {
              _isRecording = true;
              _recordSeconds = 0;
            });
          }
          _recordTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
            if (mounted) {
              setState(() {
                _recordSeconds++;
              });
            }
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('录音失败: $e'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  void _showAddTagDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          '新建标签',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
          decoration: InputDecoration(
            hintText: '输入标签名称',
            hintStyle: const TextStyle(color: AppColors.textTertiary),
            filled: true,
            fillColor: AppColors.surfaceVariant,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                setState(() {
                  _selectedTag = name;
                  if (!_allTags.contains(name)) {
                    _allTags.add(name);
                  }
                });
              }
              Navigator.pop(ctx);
            },
            child: const Text('确定',
                style: TextStyle(
                    color: AppColors.accent, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  List<String> get _displayTags {
    final Set<String> seen = {};
    final List<String> result = [];
    for (final tag in _presetTags) {
      if (seen.add(tag)) result.add(tag);
    }
    for (final tag in _allTags) {
      if (seen.add(tag)) result.add(tag);
    }
    return result;
  }

  String _formatRecordTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              children: [
                // 顶部栏
                SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, -0.5),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: _animController,
                    curve: Curves.easeOutCubic,
                  )),
                  child: FadeTransition(
                    opacity: _animController,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                      child: Row(
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              '取消',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          const Spacer(),
                          const Text(
                            '写下一念',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: _save,
                            child: const Text(
                              '完成',
                              style: TextStyle(
                                color: AppColors.accent,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // 内容区
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 输入框
                        SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.3),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: _animController,
                            curve: const Interval(0.2, 1.0,
                                curve: Curves.easeOutCubic),
                          )),
                          child: FadeTransition(
                            opacity: CurvedAnimation(
                              parent: _animController,
                              curve: const Interval(0.2, 1.0),
                            ),
                            child: Container(
                              width: double.infinity,
                              constraints: const BoxConstraints(minHeight: 160),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: TextField(
                                controller: _contentController,
                                focusNode: _focusNode,
                                maxLines: null,
                                maxLength: 500,
                                style: const TextStyle(
                                  fontSize: 16,
                                  height: 1.7,
                                  color: AppColors.textPrimary,
                                ),
                                decoration: const InputDecoration(
                                  hintText: '此刻，你想记录什么？',
                                  hintStyle: TextStyle(
                                    color: AppColors.textTertiary,
                                    fontSize: 16,
                                  ),
                                  border: InputBorder.none,
                                  counterStyle: TextStyle(
                                    color: AppColors.textTertiary,
                                    fontSize: 12,
                                  ),
                                ),
                                buildCounter: (context,
                                    {required currentLength,
                                    required isFocused,
                                    maxLength}) {
                                  return Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      '$currentLength/$maxLength',
                                      style: const TextStyle(
                                        color: AppColors.textTertiary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        // 已选图片预览
                        if (_pickedImages.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 80,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: _pickedImages.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 8),
                              itemBuilder: (context, index) {
                                return Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        _pickedImages[index].path,
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            Container(
                                          width: 80,
                                          height: 80,
                                          decoration: BoxDecoration(
                                            color: AppColors.surfaceVariant,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: const Icon(
                                            Icons.image_outlined,
                                            color: AppColors.textTertiary,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 4,
                                      right: 4,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _pickedImages.removeAt(index);
                                          });
                                        },
                                        child: Container(
                                          width: 20,
                                          height: 20,
                                          decoration: const BoxDecoration(
                                            color: AppColors.danger,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.close,
                                              size: 12, color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                        // 录音状态
                        if (_isRecording || _audioPath != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: _isRecording
                                  ? AppColors.danger.withValues(alpha: 0.1)
                                  : AppColors.accent.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _isRecording
                                      ? Icons.mic
                                      : Icons.mic_none_outlined,
                                  size: 20,
                                  color: _isRecording
                                      ? AppColors.danger
                                      : AppColors.accent,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  _isRecording
                                      ? '录音中 ${_formatRecordTime(_recordSeconds)}'
                                      : '已录音',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: _isRecording
                                        ? AppColors.danger
                                        : AppColors.accent,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const Spacer(),
                                if (_audioPath != null && !_isRecording)
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _audioPath = null;
                                      });
                                    },
                                    child: const Icon(Icons.close,
                                        size: 18,
                                        color: AppColors.textTertiary),
                                  ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                        // 功能按钮
                        SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.3),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: _animController,
                            curve: const Interval(0.3, 1.0,
                                curve: Curves.easeOutCubic),
                          )),
                          child: FadeTransition(
                            opacity: CurvedAnimation(
                              parent: _animController,
                              curve: const Interval(0.3, 1.0),
                            ),
                            child: Row(
                              children: [
                                _buildActionButton(
                                  Icons.image_outlined,
                                  '图片',
                                  onTap: _pickImage,
                                ),
                                const SizedBox(width: 16),
                                _buildActionButton(
                                  _isRecording
                                      ? Icons.stop_circle_outlined
                                      : Icons.mic_outlined,
                                  _isRecording ? '停止' : '语音',
                                  onTap: _toggleRecording,
                                  isActive: _isRecording,
                                ),
                                const SizedBox(width: 16),
                                _buildActionButton(
                                  Icons.label_outline_rounded,
                                  '标签',
                                  onTap: _showAddTagDialog,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // 标签选择
                        SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.3),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: _animController,
                            curve: const Interval(0.4, 1.0,
                                curve: Curves.easeOutCubic),
                          )),
                          child: FadeTransition(
                            opacity: CurvedAnimation(
                              parent: _animController,
                              curve: const Interval(0.4, 1.0),
                            ),
                            child: Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                ..._displayTags.map((tag) {
                                  final isSelected = _selectedTag == tag;
                                  final color = AppColors.getTagColor(tag);
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedTag =
                                            isSelected ? null : tag;
                                      });
                                    },
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? color.withValues(alpha: 0.15)
                                            : AppColors.surface,
                                        borderRadius:
                                            BorderRadius.circular(20),
                                        border: Border.all(
                                          color: isSelected
                                              ? color
                                              : AppColors.divider,
                                          width: isSelected ? 1.5 : 1,
                                        ),
                                      ),
                                      child: Text(
                                        tag,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: isSelected
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                          color: isSelected
                                              ? color
                                              : AppColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                                GestureDetector(
                                  onTap: _showAddTagDialog,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceVariant,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: AppColors.divider,
                                      ),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.add_rounded,
                                            size: 14,
                                            color: AppColors.textTertiary),
                                        SizedBox(width: 4),
                                        Text(
                                          '新标签',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: AppColors.textTertiary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButton(IconData icon, String label,
      {VoidCallback? onTap, bool isActive = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.danger.withValues(alpha: 0.15)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 18,
                color: isActive
                    ? AppColors.danger
                    : AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: isActive
                    ? AppColors.danger
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
