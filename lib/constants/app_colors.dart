/// 暖棕色 + 米白色 默认主题
/// 后续深色/其他主题在 [AppTheme] 扩展，不改现有页面布局
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ===== 默认暖棕主题 =====
  static const Color warmBrown = Color(0xFF8B5A2B);       // 主色：暖棕
  static const Color warmBrownLight = Color(0xFFB08968);  // 浅暖棕
  static const Color warmBrownDark = Color(0xFF5C3A1E);   // 深暖棕
  static const Color creamWhite = Color(0xFFFDF8F0);      // 底色：米白
  static const Color creamDark = Color(0xFFF2E9DA);       // 次级米白
  static const Color accentGold = Color(0xFFC89B5B);      // 点缀金
  static const Color textPrimary = Color(0xFF3E2723);     // 主文字：深棕黑
  static const Color textSecondary = Color(0xFF795548);   // 次文字
  static const Color divider = Color(0xFFD7C4A8);         // 分隔线

  // ===== 交互组件配色 =====
  static const Color expandTag = Color(0xFF6C8E6A);       // 展开标签：墨绿
  static const Color shatterTag = Color(0xFFA0522D);      // 碎裂标签：赭石
  static const Color pageBreakTag = Color(0xFF8B5A2B);    // 分页标记

  // ===== 功能色 =====
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFA726);
  static const Color error = Color(0xFFE57373);
}

/// 主题切换预留：当前只实现默认暖棕，深色后续迭代
enum AppThemeMode { warmBrown, dark, inkBlue }

ThemeData buildTheme(AppThemeMode mode) {
  switch (mode) {
    case AppThemeMode.warmBrown:
      return _buildWarmBrownTheme();
    case AppThemeMode.dark:
    case AppThemeMode.inkBlue:
      // 预留：后续迭代
      return _buildWarmBrownTheme();
  }
}

ThemeData _buildWarmBrownTheme() {
  const seed = AppColors.warmBrown;
  final scheme = ColorScheme.fromSeed(
    seedColor: seed,
    brightness: Brightness.light,
    surface: AppColors.creamWhite,
    onSurface: AppColors.textPrimary,
    primary: AppColors.warmBrown,
    onPrimary: Colors.white,
    secondary: AppColors.accentGold,
    onSecondary: Colors.white,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.creamWhite,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.warmBrown,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.divider, width: 0.5),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.warmBrown, width: 1.5),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.warmBrown,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.warmBrownDark,
        side: const BorderSide(color: AppColors.warmBrown),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.warmBrown,
      foregroundColor: Colors.white,
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.divider,
      thickness: 1,
      space: 16,
    ),
  );
}
