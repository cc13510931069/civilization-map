import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../data/typography_state.dart';

/// 精读营独立阅读字号与行距控制
class ReadingTextControl extends ConsumerWidget {
  const ReadingTextControl({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fontSize = ref.watch(readingFontSizeProvider);
    final lineHeight = ref.watch(readingLineHeightProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.divider, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              if (fontSize > 18) {
                ref.read(readingFontSizeProvider.notifier).state = fontSize - 4;
              }
            },
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(6),
              ),
              alignment: Alignment.center,
              child: Text('A-',
                  style: TextStyle(
                    color: fontSize <= 18
                        ? AppTheme.paper.withAlpha(80)
                        : AppTheme.gold,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  )),
            ),
          ),
          const SizedBox(width: 8),
          Text('${fontSize.toInt()}px',
              style: TextStyle(
                color: AppTheme.paper,
                fontSize: 13,
                fontFamily: 'PingFang SC',
              )),
          const SizedBox(width: 6),
          _buildDot(ref, lineHeight, '1.45', fontSize, 1.45),
          _buildDot(ref, lineHeight, '1.65', fontSize, 1.65),
          _buildDot(ref, lineHeight, '1.85', fontSize, 1.85),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              if (fontSize < 30) {
                ref.read(readingFontSizeProvider.notifier).state = fontSize + 4;
              }
            },
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(6),
              ),
              alignment: Alignment.center,
              child: Text('A+',
                  style: TextStyle(
                    color: fontSize >= 30
                        ? AppTheme.paper.withAlpha(80)
                        : AppTheme.gold,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  )),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(WidgetRef ref, double current, String label, double fontSize,
      double value) {
    final active = (current - value).abs() < 0.01;
    return GestureDetector(
      onTap: () => ref.read(readingLineHeightProvider.notifier).state = value,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: active ? AppTheme.gold.withAlpha(40) : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        alignment: Alignment.center,
        child: Text('T',
            style: TextStyle(
              color: active ? AppTheme.gold : AppTheme.paper.withAlpha(120),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            )),
      ),
    );
  }
}
