import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../models/civilization_region.dart';

/// 文明信息卡片
///
/// 点击地图节点后浮出的信息面板。
/// 显示文明名称、描述、进入探索按钮。
/// 注意：此组件只包含内容，不包含 Positioned 定位。
/// 定位由父级 WorldMapScreen 自适应处理。
class CivilizationInfoCard extends StatelessWidget {
  final CivilizationRegion? region;
  final VoidCallback? onDismiss;

  const CivilizationInfoCard({super.key, this.region, this.onDismiss});

  @override
  Widget build(BuildContext context) {
    if (region == null || region!.id.isEmpty) return const SizedBox.shrink();

    final r = region!;

    return Material(
      color: Colors.transparent,
      child: Container(
        width: 260,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: r.isHighlighted
                ? AppTheme.gold.withAlpha(100)
                : AppTheme.divider,
            width: 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.background.withAlpha(150),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── 顶部：标题 + 关闭 ──
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: r.isHighlighted
                        ? AppTheme.shimmerGold
                        : AppTheme.surfaceLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.public,
                    color: r.isHighlighted
                        ? AppTheme.gold
                        : AppTheme.paper.withAlpha(160),
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    r.name,
                    style: TextStyle(
                      color: AppTheme.paper,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'PingFang SC',
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: onDismiss,
                  child: Icon(
                    Icons.close,
                    color: AppTheme.paper.withAlpha(120),
                    size: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            // ── 英文名 ──
            Text(
              r.nameEn,
              style: TextStyle(
                color: AppTheme.paper.withAlpha(100),
                fontSize: 12,
                fontFamily: 'PingFang SC',
              ),
            ),
            const SizedBox(height: 16),
            // ── 描述（可滚动） ──
            Flexible(
              child: SingleChildScrollView(
                child: Text(
                  r.description,
                  style: TextStyle(
                    color: AppTheme.paper.withAlpha(200),
                    fontSize: 13,
                    height: 1.7,
                    fontFamily: 'PingFang SC',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // ── 进入探索按钮 ──
            SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton.icon(
                onPressed: () {
                  onDismiss?.call();
                  context.go(r.route);
                },
                icon: const Icon(Icons.explore, size: 18),
                label: Text(
                  '进入探索',
                  style: TextStyle(
                    color: AppTheme.background,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'PingFang SC',
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.gold,
                  foregroundColor: AppTheme.background,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
