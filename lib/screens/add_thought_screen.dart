import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'dart:async';
import '../database/thought_db.dart';
import '../models/thought.dart';
import '../providers/thought_provider.dart';
import '../utils/theme.dart';

class AddThoughtScreen extends ConsumerStatefulWidget {
  final Thought? thought;

  const AddThoughtScreen({super.key, this.thought});

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
  List<String> _existingImagePaths = [];

  bool get _isEditMode => widget.thought != null;

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
    if (_isEditMode) {
      final thought = widget.thought!;
      _contentController.text = thought.content;
      _selectedTag = thought.tag;
      _audioPath = thought.audioPath;
      _existingImagePaths = thought.imagePathList;
    } else {
      Future.delayed(const Duration(milliseconds: 300), () {
        _focusNode.requestFocus();
      });
    }
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

    // 合并已有图片路径和新选图片路径
    final allImagePaths = [
      ..._existingImagePaths,
      ..._pickedImages.map((f) => f.path),
    ];
    final imagePaths = allImagePaths.isNotEmpty ? allImagePaths.join(',') : null;

    if (_isEditMode) {
      ref.read(thoughtListProvider.notifier).updateThought(
            widget.thought!.copyWith(
              content: content,
              tag: _selectedTag,
              imagePaths: imagePaths,
              audioPath: _audioPath,
              updatedAt: DateTime.now(),
            ),
          );
    } else {
      ref.read(thoughtListProvider.notifier).addThought(
            content,
            tag: _selectedTag,
            imagePaths: imagePaths,
            audioPath: _audioPath,
          );
    }

    _animController.reverse().then((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditMode ? '已更新这一念' : '已收好这一念'),
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
    final c = AppColors.of(context);
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: c.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          '新建标签',
          style: TextStyle(
            fontSize: AppFont.scale(context, ref, 17),
            fontWeight: FontWeight.w600,
            color: c.textPrimary,
          ),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: TextStyle(color: c.textPrimary, fontSize: AppFont.scale(context, ref, 15)),
          decoration: InputDecoration(
            hintText: '输入标签名称',
            hintStyle: TextStyle(color: c.textTertiary),
            filled: true,
            fillColor: c.surfaceVariant,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('取消',
                style: TextStyle(color: c.textSecondary)),
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
            child: Text('确定',
                style: TextStyle(
                    color: c.accent, fontWeight: FontWeight.w600)),
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
    final c = AppColors.of(context);
    final bodyFont = AppFont.body(context, ref);
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: c.background,
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
                            child: Text(
                              '取消',
                              style: TextStyle(
                                color: c.textSecondary,
                                fontSize: AppFont.scale(context, ref, 15),
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            _isEditMode ? '编辑想法' : '写下一念',
                            style: TextStyle(
                              fontSize: AppFont.scale(context, ref, 17),
                              fontWeight: FontWeight.w600,
                              color: c.textPrimary,
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: _save,
                            child: Text(
                              '完成',
                              style: TextStyle(
                                color: c.accent,
                                fontSize: AppFont.scale(context, ref, 15),
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
                                color: c.surface,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: TextField(
                                controller: _contentController,
                                focusNode: _focusNode,
                                maxLines: null,
                                maxLength: 500,
                                style: TextStyle(
                                  fontSize: AppFont.scale(context, ref, 16),
                                  height: 1.7,
                                  color: c.textPrimary,
                                ),
                                decoration: InputDecoration(
                                  hintText: _isEditMode ? '修改你的想法…' : '此刻，你想记录什么？',
                                  hintStyle: TextStyle(
                                    color: c.textTertiary,
                                    fontSize: AppFont.scale(context, ref, 16),
                                  ),
                                  border: InputBorder.none,
                                  counterStyle: TextStyle(
                                    color: c.textTertiary,
                                    fontSize: AppFont.scale(context, ref, 12),
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
                                      style: TextStyle(
                                        color: c.textTertiary,
                                        fontSize: AppFont.scale(context, ref, 12),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        // 图片预览（已有图片 + 新选图片）
                        if (_existingImagePaths.isNotEmpty ||
                            _pickedImages.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 80,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: _existingImagePaths.length +
                                  _pickedImages.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 8),
                              itemBuilder: (context, index) {
                                final isExisting =
                                    index < _existingImagePaths.length;
                                final path = isExisting
                                    ? _existingImagePaths[index]
                                    : _pickedImages[index -
                                            _existingImagePaths.length]
                                        .path;
                                return Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        path,
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            Container(
                                          width: 80,
                                          height: 80,
                                          decoration: BoxDecoration(
                                            color: c.surfaceVariant,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Icon(
                                            Icons.image_outlined,
                                            color: c.textTertiary,
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
                                            if (isExisting) {
                                              _existingImagePaths
                                                  .removeAt(index);
                                            } else {
                                              _pickedImages.removeAt(index -
                                                  _existingImagePaths.length);
                                            }
                                          });
                                        },
                                        child: Container(
                                          width: 20,
                                          height: 20,
                                          decoration: BoxDecoration(
                                            color: c.danger,
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
                                  ? c.danger.withValues(alpha: 0.1)
                                  : c.accent.withValues(alpha: 0.1),
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
                                      ? c.danger
                                      : c.accent,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  _isRecording
                                      ? '录音中 ${_formatRecordTime(_recordSeconds)}'
                                      : '已录音',
                                  style: TextStyle(
                                    fontSize: AppFont.scale(context, ref, 14),
                                    color: _isRecording
                                        ? c.danger
                                        : c.accent,
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
                                    child: Icon(Icons.close,
                                        size: 18,
                                        color: c.textTertiary),
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
                                            : c.surface,
                                        borderRadius:
                                            BorderRadius.circular(20),
                                        border: Border.all(
                                          color: isSelected
                                              ? color
                                              : c.divider,
                                          width: isSelected ? 1.5 : 1,
                                        ),
                                      ),
                                      child: Text(
                                        tag,
                                        style: TextStyle(
                                          fontSize: AppFont.scale(context, ref, 13),
                                          fontWeight: isSelected
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                          color: isSelected
                                              ? color
                                              : c.textSecondary,
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
                                      color: c.surfaceVariant,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: c.divider,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.add_rounded,
                                            size: 14,
                                            color: c.textTertiary),
                                        const SizedBox(width: 4),
                                        Text(
                                          '新标签',
                                          style: TextStyle(
                                            fontSize: AppFont.scale(context, ref, 13),
                                            color: c.textTertiary,
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
    final c = AppColors.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive
              ? c.danger.withValues(alpha: 0.15)
              : c.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 18,
                color: isActive
                    ? c.danger
                    : c.textSecondary),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: AppFont.scale(context, ref, 13),
                color: isActive
                    ? c.danger
                    : c.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
