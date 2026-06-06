import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';

/// 字体大小辅助工具
/// fontSize: 0=小, 1=标准, 2=大
/// 基准 body 字号: 小=14, 标准=16, 大=18
class AppFont {
  /// 根据设置返回 body 基准字号
  static double body(BuildContext context, WidgetRef ref) {
    final size = ref.watch(fontSizeProvider);
    switch (size) {
      case 0: return 14;
      case 2: return 18;
      default: return 16;
    }
  }

  /// 按比例缩放字号（基于标准 16 的比例）
  /// [base] 是标准模式下的字号
  static double scale(BuildContext context, WidgetRef ref, double base) {
    return base * body(context, ref) / 16;
  }
}

/// 动态颜色代理，根据当前主题亮度返回深色或浅色颜色
class AppColorSet {
  final Color background;
  final Color surface;
  final Color surfaceVariant;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color accent;
  final Color accentSecondary;
  final Color danger;
  final Color divider;

  const AppColorSet({
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.accent,
    required this.accentSecondary,
    required this.danger,
    required this.divider,
  });

  static const dark = AppColorSet(
    background: Color(0xFF0B0F10),
    surface: Color(0xFF171B1F),
    surfaceVariant: Color(0xFF20252A),
    textPrimary: Color(0xFFF4F7F6),
    textSecondary: Color(0xFF9CA3A8),
    textTertiary: Color(0xFF6F777D),
    accent: Color(0xFF8DDDBF),
    accentSecondary: Color(0xFF6EA8FE),
    danger: Color(0xFFFF6B6B),
    divider: Color(0xFF2A2F34),
  );

  static const light = AppColorSet(
    background: Color(0xFFF7F9F8),
    surface: Color(0xFFFFFFFF),
    surfaceVariant: Color(0xFFEFF3F0),
    textPrimary: Color(0xFF1A1F1D),
    textSecondary: Color(0xFF5F6B66),
    textTertiary: Color(0xFF9BA8A2),
    accent: Color(0xFF2E9E7A),
    accentSecondary: Color(0xFF4A8FE7),
    danger: Color(0xFFE85454),
    divider: Color(0xFFE2E8E5),
  );
}

class AppColors {
  // 深色主题颜色（保持向后兼容）
  static const Color background = Color(0xFF0B0F10);
  static const Color surface = Color(0xFF171B1F);
  static const Color surfaceVariant = Color(0xFF20252A);
  static const Color textPrimary = Color(0xFFF4F7F6);
  static const Color textSecondary = Color(0xFF9CA3A8);
  static const Color textTertiary = Color(0xFF6F777D);
  static const Color accent = Color(0xFF8DDDBF);
  static const Color accentSecondary = Color(0xFF6EA8FE);
  static const Color danger = Color(0xFFFF6B6B);
  static const Color divider = Color(0xFF2A2F34);

  // 标签颜色
  static const List<Color> tagColors = [
    Color(0xFF8DDDBF),
    Color(0xFF6EA8FE),
    Color(0xFFFFB07C),
    Color(0xFFC5A3FF),
    Color(0xFFFF8A9E),
    Color(0xFF7ED8C4),
    Color(0xFFFFD666),
    Color(0xFF92C5F7),
  ];

  /// 根据当前主题返回对应的颜色集
  static AppColorSet of(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? AppColorSet.dark : AppColorSet.light;
  }

  static Color getTagColor(String tag) {
    final index = tag.hashCode.abs() % tagColors.length;
    return tagColors[index];
  }
}

class AppTheme {
  static ThemeData get darkTheme {
    const d = AppColorSet.dark;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: d.accent,
        secondary: d.accentSecondary,
        surface: d.surface,
        error: d.danger,
        onPrimary: d.background,
        onSecondary: d.background,
        onSurface: d.textPrimary,
        onError: d.textPrimary,
      ),
      scaffoldBackgroundColor: d.background,
      textTheme: TextTheme(
        headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: d.textPrimary),
        headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: d.textPrimary),
        headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: d.textPrimary),
        bodyLarge: TextStyle(fontSize: 16, color: d.textPrimary, height: 1.6),
        bodyMedium: TextStyle(fontSize: 14, color: d.textSecondary),
        bodySmall: TextStyle(fontSize: 12, color: d.textTertiary),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: d.textPrimary),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: d.textPrimary),
        iconTheme: IconThemeData(color: d.textPrimary),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: d.surface,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: d.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: d.accent, width: 1.5),
        ),
        hintStyle: TextStyle(color: d.textTertiary, fontSize: 15),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: d.surfaceVariant,
        contentTextStyle: TextStyle(color: d.textPrimary, fontSize: 14),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: d.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: d.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      dividerTheme: DividerThemeData(color: d.divider, thickness: 0.5),
      iconTheme: IconThemeData(color: d.textSecondary),
    );
  }

  static ThemeData get lightTheme {
    const l = AppColorSet.light;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: l.accent,
        secondary: l.accentSecondary,
        surface: l.surface,
        error: l.danger,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: l.textPrimary,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: l.background,
      textTheme: TextTheme(
        headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: l.textPrimary),
        headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: l.textPrimary),
        headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: l.textPrimary),
        bodyLarge: TextStyle(fontSize: 16, color: l.textPrimary, height: 1.6),
        bodyMedium: TextStyle(fontSize: 14, color: l.textSecondary),
        bodySmall: TextStyle(fontSize: 12, color: l.textTertiary),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: l.textPrimary),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: l.textPrimary),
        iconTheme: IconThemeData(color: l.textPrimary),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: l.surface,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: l.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: l.accent, width: 1.5),
        ),
        hintStyle: TextStyle(color: l.textTertiary, fontSize: 15),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: l.surface,
        contentTextStyle: TextStyle(color: l.textPrimary, fontSize: 14),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: l.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: l.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      dividerTheme: DividerThemeData(color: l.divider, thickness: 0.5),
      iconTheme: IconThemeData(color: l.textSecondary),
    );
  }
}
