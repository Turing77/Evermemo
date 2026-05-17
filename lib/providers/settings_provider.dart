import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 提醒时间（小时和分钟）
final reminderHourProvider = StateProvider<int>((ref) => 20);
final reminderMinuteProvider = StateProvider<int>((ref) => 0);
final reminderEnabledProvider = StateProvider<bool>((ref) => true);

// 字体大小：0=小, 1=标准, 2=大
final fontSizeProvider = StateProvider<int>((ref) => 1);

// 主题模式：0=深色, 1=浅色
final themeModeProvider = StateProvider<int>((ref) => 0);

class SettingsNotifier {
  static const _keyReminderHour = 'reminder_hour';
  static const _keyReminderMinute = 'reminder_minute';
  static const _keyReminderEnabled = 'reminder_enabled';
  static const _keyFontSize = 'font_size';
  static const _keyThemeMode = 'theme_mode';

  static Future<void> loadSettings(WidgetRef ref) async {
    final prefs = await SharedPreferences.getInstance();
    ref.read(reminderHourProvider.notifier).state =
        prefs.getInt(_keyReminderHour) ?? 20;
    ref.read(reminderMinuteProvider.notifier).state =
        prefs.getInt(_keyReminderMinute) ?? 0;
    ref.read(reminderEnabledProvider.notifier).state =
        prefs.getBool(_keyReminderEnabled) ?? true;
    ref.read(fontSizeProvider.notifier).state =
        prefs.getInt(_keyFontSize) ?? 1;
    ref.read(themeModeProvider.notifier).state =
        prefs.getInt(_keyThemeMode) ?? 0;
  }

  static Future<void> saveReminder(int hour, int minute, bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyReminderHour, hour);
    await prefs.setInt(_keyReminderMinute, minute);
    await prefs.setBool(_keyReminderEnabled, enabled);
  }

  static Future<void> saveFontSize(int size) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyFontSize, size);
  }

  static Future<void> saveThemeMode(int mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyThemeMode, mode);
  }
}
