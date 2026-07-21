import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/civilization_region.dart';

/// 文明地图节点
///
/// 在古地图背景上标记文明区域的圆点 + 标签。
/// 高亮节点（高加索）显示金色光晕 +「探索中」徽章。
class CivilizationNode extends StatelessWidget {
  final CivilizationRegion region;
  final double scale;
  const CivilizationNode({
    super.key,
    required this.region,
    this.scale = 1.0,
  });
  @override
  Widget build(BuildContext context) {
    final dotSize = (region.isHighlighted ? 20.0 : 14.0) * scale;
    return SizedBox(
      width: 120 * scale,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (region.isHighlighted) _buildPulseRing(dotSize),
          // ── 节点圆点 ──
          Container(
            width: dotSize,
            height: dotSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: region.isHighlighted
                  ? AppTheme.gold
                  : AppTheme.paper.withAlpha(180),
              boxShadow: region.isHighlighted
                  ? [
                      BoxShadow(
                        color: AppTheme.gold.withAlpha(100),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: AppTheme.paper.withAlpha(40),
                        blurRadius: 4,
                      ),
                    ],
            ),
          ),
          SizedBox(height: 6 * scale),
          // ── 标签 ──
          Text(
            region.name,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.paper,
              fontSize: (region.isHighlighted ? 15 : 13) * scale,
              fontWeight:
                  region.isHighlighted ? FontWeight.w600 : FontWeight.w400,
              fontFamily: 'PingFang SC',
              shadows: [
                Shadow(
                  color: AppTheme.background.withAlpha(180),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          if (region.isActive)
            Container(
              margin: const EdgeInsets.only(top: 3),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.gold,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '探索中',
                style: TextStyle(
                  color: AppTheme.background,
                  fontSize: 10 * scale,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'PingFang SC',
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 脉冲光环（金色呼吸动画）
  Widget _buildPulseRing(double dotSize) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(seconds: 2),
      builder: (context, value, child) {
        final radius = dotSize / 2 + 8 + value * 16;
        return Container(
          width: radius * 2,
          height: radius * 2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppTheme.gold.withAlpha((1.0 - value) * 120 ~/ 1),
              width: 1.5,
            ),
          ),
          child: child,
        );
      },
      onEnd: () {},
      child: SizedBox.shrink(),
    );
  }
}
