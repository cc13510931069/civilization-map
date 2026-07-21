import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Veggie 状态卡 — 欢迎顶栏右侧
///
/// 显示 AI 小狗助手的在线状态和简短问候。
class VeggieStatusCard extends StatelessWidget {
  const VeggieStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── 小狗头像 ──
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.shimmerGold,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.pets, color: AppTheme.gold, size: 22),
          ),
          const SizedBox(width: 12),
          // ── 状态文字 ──
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Veggie / 菜狗',
                style: TextStyle(
                  color: AppTheme.paper,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'PingFang SC',
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppTheme.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'AI 助手已就绪',
                    style: TextStyle(
                      color: AppTheme.green,
                      fontSize: 12,
                      fontFamily: 'PingFang SC',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
