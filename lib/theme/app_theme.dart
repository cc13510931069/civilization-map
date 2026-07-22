import 'package:flutter/material.dart';

/// 文明地图 HD 应用主题体系
///
/// 配色：深蓝背景、金色点缀、纸质暖白文字、绿色辅助
/// 字体偏好：PingFang SC（iOS 系统中文）→ 系统后备
import '../theme/app_typography.dart';


class AppTheme {
  AppTheme._();

  // ── 品牌色板 ──
  static const Color background = Color(0xFF071C2C);
  static const Color gold = Color(0xFFD9A441);
  static const Color paper = Color(0xFFF3E7C8);
  static const Color green = Color(0xFF4E8B57);

  // 衍生色
  static const Color surfaceDark = Color(0xFF0A2342);
  static const Color surfaceLight = Color(0xFF102C4A);
  static const Color divider = Color(0x1AF3E7C8);
  static const Color shimmerGold = Color(0x33D9A441);

  static ThemeData darkTheme({AppTypography? typography}) {
    final t = typography ?? const AppTypography();
    final ColorScheme colorScheme = ColorScheme.dark(
      primary: gold,
      onPrimary: background,
      secondary: green,
      onSecondary: paper,
      surface: surfaceDark,
      onSurface: paper,
      surfaceContainerLowest: background,
      surfaceContainerLow: surfaceDark,
      surfaceContainer: surfaceLight,
      surfaceContainerHigh: const Color(0xFF1A3A5C),
      surfaceContainerHighest: const Color(0xFF1E4064),
      outline: divider,
      outlineVariant: const Color(0x0DF3E7C8),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      fontFamily: 'PingFang SC',

      // ── AppBar ──
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        backgroundColor: Colors.transparent,
        foregroundColor: paper,
        titleTextStyle: TextStyle(
          color: paper,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          fontFamily: 'PingFang SC',
        ),
      ),

      // ── 导航栏 ──
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        backgroundColor: surfaceDark,
        indicatorColor: shimmerGold,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              color: gold,
              fontSize: 12,
              fontFamily: 'PingFang SC',
            );
          }
          return TextStyle(
            color: paper.withAlpha(180),
            fontSize: 12,
            fontFamily: 'PingFang SC',
          );
        }),
      ),

      // ── 文本主题 ──
      textTheme: TextTheme(
        displayLarge:
            _txt(color: paper, weight: FontWeight.w300, size: t.display),
        displayMedium:
            _txt(color: paper, weight: FontWeight.w300, size: t.title1),
        displaySmall:
            _txt(color: paper, weight: FontWeight.w400, size: t.title1),
        headlineLarge:
            _txt(color: paper, weight: FontWeight.w600, size: t.title1),
        headlineMedium:
            _txt(color: paper, weight: FontWeight.w600, size: t.title1),
        headlineSmall:
            _txt(color: paper, weight: FontWeight.w600, size: t.title2),
        titleLarge: _txt(color: paper, weight: FontWeight.w600, size: t.title1),
        titleMedium:
            _txt(color: paper, weight: FontWeight.w500, size: t.cardTitle),
        titleSmall: _txt(color: paper, weight: FontWeight.w500, size: t.body),
        bodyLarge: _txt(color: paper, weight: FontWeight.w400, size: t.body),
        bodyMedium: _txt(color: paper, weight: FontWeight.w400, size: t.label),
        bodySmall: _txt(color: paper, weight: FontWeight.w400, size: t.caption),
        labelLarge: _txt(color: paper, weight: FontWeight.w500, size: t.button),
        labelMedium: _txt(color: paper, weight: FontWeight.w500, size: t.label),
        labelSmall:
            _txt(color: paper, weight: FontWeight.w500, size: t.caption),
      ),

      // ── 分隔线 ──
      dividerTheme: DividerThemeData(
        color: divider,
        thickness: 0.5,
        space: 0,
      ),

      // ── 卡片 ──
      cardTheme: CardThemeData(
        color: surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: divider, width: 0.5),
        ),
      ),

      iconTheme: IconThemeData(color: paper.withAlpha(200), size: t.title2),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: gold,
        foregroundColor: background,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  static TextStyle _txt({
    required Color color,
    required FontWeight weight,
    required double size,
  }) {
    return TextStyle(
      fontFamily: 'PingFang SC',
      color: color,
      fontWeight: weight,
      fontSize: size,
    );
  }
}
