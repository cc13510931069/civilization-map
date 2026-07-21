import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../theme/app_typography.dart';
import '../data/typography_state.dart';
import '../components/text_size_control.dart';

/// 个人中心 — 显示与阅读设置
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(32, 24, 32, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 标题 ──
            Text('显示与阅读设置',
                style: TextStyle(
                  color: AppTheme.paper,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'PingFang SC',
                )),
            const SizedBox(height: 24),

            // ── App 字体大小 ──
            Text('App 字体大小',
                style: TextStyle(
                  color: AppTheme.paper.withAlpha(180),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'PingFang SC',
                )),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: AppTextSize.values.map((size) {
                final active = ref.watch(appTextSizeProvider) == size;
                return GestureDetector(
                  onTap: () =>
                      ref.read(appTextSizeProvider.notifier).state = size,
                  child: Container(
                    width: 150,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color:
                          active ? AppTheme.shimmerGold : AppTheme.surfaceDark,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: active
                            ? AppTheme.gold.withAlpha(80)
                            : AppTheme.divider,
                        width: 0.5,
                      ),
                    ),
                    child: Row(children: [
                      Icon(active ? Icons.check_circle : Icons.circle_outlined,
                          color: active
                              ? AppTheme.gold
                              : AppTheme.paper.withAlpha(80),
                          size: 18),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(size.label,
                              style: TextStyle(
                                color: active ? AppTheme.gold : AppTheme.paper,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'PingFang SC',
                              )),
                          Text('${(size.scale * 100).toInt()}%',
                              style: TextStyle(
                                color: AppTheme.paper.withAlpha(100),
                                fontSize: 12,
                                fontFamily: 'PingFang SC',
                              )),
                        ],
                      ),
                    ]),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // ── 当前预览 ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.divider, width: 0.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Icon(Icons.preview, color: AppTheme.gold, size: 16),
                    const SizedBox(width: 8),
                    Text('预览',
                        style: TextStyle(
                          color: AppTheme.paper.withAlpha(140),
                          fontSize: 13,
                          fontFamily: 'PingFang SC',
                        )),
                  ]),
                  const SizedBox(height: 12),
                  // 用 typography provider 渲染不同大小的文字
                  Consumer(builder: (context, ref, _) {
                    final t = ref.watch(appTypographyProvider);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('标题 (${t.title1.toInt()}px)',
                            style: t.title1Style()),
                        const SizedBox(height: 6),
                        Text('正文 (${t.body.toInt()}px)', style: t.bodyStyle()),
                        const SizedBox(height: 6),
                        Text('标注 (${t.label.toInt()}px)',
                            style: t.labelStyle()),
                        const SizedBox(height: 6),
                        Text('说明 (${t.caption.toInt()}px)',
                            style: t.captionStyle()),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
