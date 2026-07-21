import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_typography.dart';

/// 全局字体档位
final appTextSizeProvider =
    StateProvider<AppTextSize>((ref) => AppTextSize.comfortable);

/// 当前 AppTypography（依赖字体档位）
final appTypographyProvider = Provider<AppTypography>((ref) {
  final size = ref.watch(appTextSizeProvider);
  return AppTypography(scale: size.scale);
});

/// 精读营正文字号（px）
final readingFontSizeProvider = StateProvider<double>((ref) => 22);

/// 精读营行距倍数
final readingLineHeightProvider = StateProvider<double>((ref) => 1.65);
