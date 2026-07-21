import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';

/// AI 助手面板显示/隐藏状态
final aiPanelVisibleProvider = StateProvider<bool>((ref) => true);

/// 右侧 Veggie 助手面板
///
/// iPad 横屏常驻，固定宽 320px，可折叠。
/// 以 Veggie 小狗形象提供 AI 对话辅助。
class AIPanel extends ConsumerWidget {
  const AIPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visible = ref.watch(aiPanelVisibleProvider);

    if (!visible) return const SizedBox.shrink();

    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        border: Border(
          left: BorderSide(color: AppTheme.divider, width: 0.5),
        ),
      ),
      child: Column(
        children: [
          // ── 面板头部 ──
          _buildHeader(context, ref),
          // ── 面板内容（占位） ──
          Expanded(child: _buildPlaceholderContent(context)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppTheme.divider, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          // ── Veggie 头像 ──
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppTheme.shimmerGold,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.pets, color: AppTheme.gold, size: 16),
          ),
          const SizedBox(width: 8),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Veggie',
                style: TextStyle(
                  color: AppTheme.paper,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'PingFang SC',
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 5,
                    height: 5,
                    decoration: const BoxDecoration(
                      color: AppTheme.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '在线',
                    style: TextStyle(
                      color: AppTheme.green,
                      fontSize: 10,
                      fontFamily: 'PingFang SC',
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          // ── 关闭按钮 ──
          GestureDetector(
            onTap: () {
              ref.read(aiPanelVisibleProvider.notifier).state = false;
            },
            child: Container(
              width: 24,
              height: 24,
              alignment: Alignment.center,
              child: Icon(
                Icons.close,
                color: AppTheme.paper.withAlpha(120),
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderContent(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Veggie 大图标 ──
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.gold.withAlpha(50),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.pets,
                color: AppTheme.gold.withAlpha(160),
                size: 36,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Veggie 将在这里\n陪您一同探索文明',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.paper.withAlpha(140),
                fontSize: 14,
                height: 1.6,
                fontFamily: 'PingFang SC',
              ),
            ),
            const SizedBox(height: 24),
            // ── 爪子印装饰 ──
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) {
                return Padding(
                  padding: EdgeInsets.only(left: i > 0 ? 8 : 0),
                  child: Icon(
                    Icons.pets,
                    color: AppTheme.gold.withAlpha(30 + i * 10),
                    size: 18 - i * 2.0,
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
