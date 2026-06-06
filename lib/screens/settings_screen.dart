import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../database/thought_db.dart';
import '../providers/settings_provider.dart';
import '../utils/theme.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    SettingsNotifier.loadSettings(ref);
  }

  String _getFontSizeLabel(int size) {
    switch (size) {
      case 0:
        return '小';
      case 1:
        return '标准';
      case 2:
        return '大';
      default:
        return '标准';
    }
  }

  String _getThemeLabel(int mode) {
    switch (mode) {
      case 0:
        return '深色';
      case 1:
        return '浅色';
      default:
        return '深色';
    }
  }

  Future<void> _pickReminderTime() async {
    final c = AppColors.of(context);
    final hour = ref.read(reminderHourProvider);
    final minute = ref.read(reminderMinuteProvider);

    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: hour, minute: minute),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: c.surface,
              hourMinuteColor: c.surfaceVariant,
              hourMinuteTextColor: c.textPrimary,
              dayPeriodColor: c.surfaceVariant,
              dayPeriodTextColor: c.textPrimary,
              dialHandColor: c.accent,
              dialBackgroundColor: c.surfaceVariant,
              dialTextColor: c.textPrimary,
              entryModeIconColor: c.textSecondary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      ref.read(reminderHourProvider.notifier).state = picked.hour;
      ref.read(reminderMinuteProvider.notifier).state = picked.minute;
      await SettingsNotifier.saveReminder(
          picked.hour, picked.minute, ref.read(reminderEnabledProvider));
    }
  }

  void _showFontSizePicker() {
    final c = AppColors.of(context);
    final current = ref.read(fontSizeProvider);
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '字体大小',
              style: TextStyle(
                fontSize: AppFont.scale(context, ref, 17),
                fontWeight: FontWeight.w600,
                color: c.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ...[0, 1, 2].map((size) {
              final labels = ['小', '标准', '大'];
              final sizes = [
                AppFont.scale(context, ref, 14),
                AppFont.scale(context, ref, 16),
                AppFont.scale(context, ref, 18),
              ];
              return ListTile(
                title: Text(
                  labels[size],
                  style: TextStyle(
                    fontSize: sizes[size],
                    color: c.textPrimary,
                    fontWeight: current == size ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                trailing: current == size
                    ? Icon(Icons.check_rounded, color: c.accent)
                    : null,
                onTap: () {
                  ref.read(fontSizeProvider.notifier).state = size;
                  SettingsNotifier.saveFontSize(size);
                  Navigator.pop(ctx);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showThemePicker() {
    final c = AppColors.of(context);
    final current = ref.read(themeModeProvider);
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '主题模式',
              style: TextStyle(
                fontSize: AppFont.scale(context, ref, 17),
                fontWeight: FontWeight.w600,
                color: c.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.dark_mode_outlined,
                  color: c.textSecondary),
              title: Text('深色',
                  style: TextStyle(color: c.textPrimary)),
              trailing: current == 0
                  ? Icon(Icons.check_rounded, color: c.accent)
                  : null,
              onTap: () {
                ref.read(themeModeProvider.notifier).state = 0;
                SettingsNotifier.saveThemeMode(0);
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: Icon(Icons.light_mode_outlined,
                  color: c.textSecondary),
              title: Text('浅色',
                  style: TextStyle(color: c.textPrimary)),
              trailing: current == 1
                  ? Icon(Icons.check_rounded, color: c.accent)
                  : null,
              onTap: () {
                ref.read(themeModeProvider.notifier).state = 1;
                SettingsNotifier.saveThemeMode(1);
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportThoughts() async {
    final thoughts = await ThoughtDatabase.instance.getAllThoughts();
    if (thoughts.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('还没有想法可以导出'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    final buffer = StringBuffer();
    buffer.writeln('常记 - 想法导出');
    buffer.writeln('导出时间：${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}');
    buffer.writeln('共 ${thoughts.length} 条记录');
    buffer.writeln('${'=' * 40}');
    buffer.writeln();

    for (final thought in thoughts) {
      buffer.writeln('【${DateFormat('yyyy-MM-dd HH:mm').format(thought.createdAt)}】');
      if (thought.tag != null && thought.tag!.isNotEmpty) {
        buffer.writeln('标签：${thought.tag}');
      }
      buffer.writeln(thought.content);
      buffer.writeln();
    }

    await Share.share(buffer.toString(), subject: '常记 - 想法导出');
  }

  Future<void> _backupData() async {
    final thoughts = await ThoughtDatabase.instance.getAllThoughts();
    if (thoughts.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('还没有数据可以备份'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    // 生成 JSON 格式备份
    final buffer = StringBuffer();
    buffer.writeln('{"app":"Evermemo","version":"1.0.0","exported_at":"${DateTime.now().toIso8601String()}","count":${thoughts.length},"thoughts":[');
    for (int i = 0; i < thoughts.length; i++) {
      final t = thoughts[i];
      buffer.write('{');
      buffer.write('"id":"${t.id}",');
      buffer.write('"content":"${t.content.replaceAll('"', '\\"').replaceAll('\n', '\\n')}",');
      buffer.write('"tag":${t.tag != null ? '"${t.tag}"' : 'null'},');
      buffer.write('"is_favorite":${t.isFavorite},');
      buffer.write('"note":${t.note != null ? '"${t.note}"' : 'null'},');
      buffer.write('"created_at":${t.createdAt.millisecondsSinceEpoch}');
      buffer.write('}');
      if (i < thoughts.length - 1) buffer.write(',');
    }
    buffer.writeln(']}');

    await Share.share(buffer.toString(), subject: '常记数据备份');
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final bodyFont = AppFont.body(context, ref);
    final reminderHour = ref.watch(reminderHourProvider);
    final reminderMinute = ref.watch(reminderMinuteProvider);
    final reminderEnabled = ref.watch(reminderEnabledProvider);
    final fontSize = ref.watch(fontSizeProvider);
    final themeMode = ref.watch(themeModeProvider);

    final reminderText = reminderEnabled
        ? '每天 ${reminderHour.toString().padLeft(2, '0')}:${reminderMinute.toString().padLeft(2, '0')}'
        : '已关闭';

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
                  Expanded(
                    child: Center(
                      child: Text(
                        '设置',
                        style: TextStyle(
                          fontSize: AppFont.scale(context, ref, 17),
                          fontWeight: FontWeight.w600,
                          color: c.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 提醒设置
                    _buildSectionTitle('提醒设置'),
                    _buildSwitchItem(
                      Icons.notifications_outlined,
                      '每日提醒',
                      reminderText,
                      reminderEnabled,
                      (value) {
                        ref.read(reminderEnabledProvider.notifier).state = value;
                        SettingsNotifier.saveReminder(
                            reminderHour, reminderMinute, value);
                      },
                      onTap: _pickReminderTime,
                    ),
                    const SizedBox(height: 24),
                    // 显示
                    _buildSectionTitle('显示'),
                    _buildTapItem(
                      Icons.dark_mode_outlined,
                      '主题模式',
                      _getThemeLabel(themeMode),
                      _showThemePicker,
                    ),
                    _buildTapItem(
                      Icons.text_fields_outlined,
                      '字体大小',
                      _getFontSizeLabel(fontSize),
                      _showFontSizePicker,
                    ),
                    const SizedBox(height: 24),
                    // 数据
                    _buildSectionTitle('数据'),
                    _buildTapItem(
                      Icons.cloud_upload_outlined,
                      '数据备份',
                      '导出 JSON',
                      _backupData,
                    ),
                    _buildTapItem(
                      Icons.file_download_outlined,
                      '导出全部想法',
                      '分享文本',
                      _exportThoughts,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    final c = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: AppFont.scale(context, ref, 13),
          fontWeight: FontWeight.w500,
          color: c.textTertiary,
        ),
      ),
    );
  }

  Widget _buildSwitchItem(IconData icon, String title, String subtitle,
      bool value, ValueChanged<bool> onChanged,
      {VoidCallback? onTap}) {
    final c = AppColors.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 2),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: c.textSecondary),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: AppFont.scale(context, ref, 15),
                color: c.textPrimary,
              ),
            ),
            const Spacer(),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: AppFont.scale(context, ref, 14),
                color: c.textTertiary,
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 28,
              child: Switch(
                value: value,
                onChanged: onChanged,
                activeColor: c.accent,
                inactiveTrackColor: c.surfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTapItem(
      IconData icon, String title, String subtitle, VoidCallback onTap) {
    final c = AppColors.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 2),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: c.textSecondary),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: AppFont.scale(context, ref, 15),
                color: c.textPrimary,
              ),
            ),
            const Spacer(),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: AppFont.scale(context, ref, 14),
                color: c.textTertiary,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right_rounded,
                size: 20, color: c.textTertiary),
          ],
        ),
      ),
    );
  }
}
