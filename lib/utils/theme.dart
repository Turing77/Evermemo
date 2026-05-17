import 'package:flutter/material.dart';

class AppColors {
  // 基础背景
  static const Color background = Color(0xFF0B0F10);
  // 一级卡片
  static const Color surface = Color(0xFF171B1F);
  // 二级卡片
  static const Color surfaceVariant = Color(0xFF20252A);
  // 主文字
  static const Color textPrimary = Color(0xFFF4F7F6);
  // 次级文字
  static const Color textSecondary = Color(0xFF9CA3A8);
  // 弱文字
  static const Color textTertiary = Color(0xFF6F777D);
  // 主强调色
  static const Color accent = Color(0xFF8DDDBF);
  // 辅助强调色
  static const Color accentSecondary = Color(0xFF6EA8FE);
  // 危险色
  static const Color danger = Color(0xFFFF6B6B);
  // 分隔线
  static const Color divider = Color(0xFF2A2F34);

  // 标签颜色（适合深色背景）
  static const List<Color> tagColors = [
    Color(0xFF8DDDBF), // accent
    Color(0xFF6EA8FE), // accentSecondary
    Color(0xFFFFB07C), // 暖橙
    Color(0xFFC5A3FF), // 淡紫
    Color(0xFFFF8A9E), // 玫红
    Color(0xFF7ED8C4), // 青绿
    Color(0xFFFFD666), // 金黄
    Color(0xFF92C5F7), // 天蓝
  ];

  static Color getTagColor(String tag) {
    final index = tag.hashCode.abs() % tagColors.length;
    return tagColors[index];
  }
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accent,
        secondary: AppColors.accentSecondary,
        surface: AppColors.surface,
        error: AppColors.danger,
        onPrimary: AppColors.background,
        onSecondary: AppColors.background,
        onSurface: AppColors.textPrimary,
        onError: AppColors.textPrimary,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: AppColors.textPrimary,
          height: 1.6,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: AppColors.textTertiary,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: AppColors.surface,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
        hintStyle: const TextStyle(
          color: AppColors.textTertiary,
          fontSize: 15,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceVariant,
        contentTextStyle: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 0.5,
      ),
      iconTheme: const IconThemeData(
        color: AppColors.textSecondary,
      ),
    );
  }
}
