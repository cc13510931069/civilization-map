import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../theme/app_typography.dart';
import '../data/typography_state.dart';

/// 全局字体大小控制 — 显示当前档位，点击切换下一档
class TextSizeControl extends ConsumerWidget {
  const TextSizeControl({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(appTextSizeProvider);
    final typography = ref.watch(appTypographyProvider);
    final next =
        AppTextSize.values[(current.index + 1) % AppTextSize.values.length];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.text_fields, color: AppTheme.gold, size: 16),
        const SizedBox(width: 8),
        Text('App 字体：',
            style: TextStyle(
              color: AppTheme.paper.withAlpha(160),
              fontSize: 13,
              fontFamily: 'PingFang SC',
            )),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => ref.read(appTextSizeProvider.notifier).state = next,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.shimmerGold,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text('${current.label}  ${typography.body.toInt()}px',
                style: TextStyle(
                  color: current.scale >= 1.3 ? AppTheme.paper : AppTheme.gold,
                  fontSize: 12,
                  fontFamily: 'PingFang SC',
                )),
          ),
        ),
      ],
    );
  }
}
