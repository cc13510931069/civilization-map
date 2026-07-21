import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/exploration_progress.dart';

/// 发现点信息卡片
///
/// 点击地图上的探索点后浮出。
/// 显示证据类型、名称和详细解释。
/// 正文支持滚动，适合长文本和 extraLarge 字体。
class DiscoveryCard extends StatelessWidget {
  final DiscoveryPoint point;
  final bool isCollected;
  final VoidCallback onCollect;
  final VoidCallback? onDismiss;

  const DiscoveryCard({
    super.key,
    required this.point,
    required this.isCollected,
    required this.onCollect,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final typeColor = _typeColor(point.type);

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isCollected
                ? AppTheme.green.withAlpha(80)
                : AppTheme.gold.withAlpha(60),
            width: 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.background.withAlpha(180),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── 顶部：类型标签 + 关闭 ──
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: typeColor.withAlpha(30),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    point.type,
                    style: TextStyle(
                      color: typeColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'PingFang SC',
                    ),
                  ),
                ),
                const Spacer(),
                if (onDismiss != null)
                  GestureDetector(
                    onTap: onDismiss,
                    child: Icon(Icons.close,
                        color: AppTheme.paper.withAlpha(100), size: 16),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            // ── 名称 ──
            Row(
              children: [
                _buildIcon(),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    point.name,
                    style: TextStyle(
                      color: AppTheme.paper,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'PingFang SC',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // ── 解释文字（可滚动，适配长文本和放大字体） ──
            Flexible(
              child: SingleChildScrollView(
                child: Text(
                  point.explanation,
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
            // ── 收集按钮 ──
            SizedBox(
              width: double.infinity,
              height: 38,
              child: ElevatedButton.icon(
                onPressed: isCollected ? null : onCollect,
                icon: Icon(
                  isCollected ? Icons.check_circle : Icons.explore,
                  size: 18,
                ),
                label: Text(
                  isCollected ? '已收集' : '收集证据',
                  style: TextStyle(
                    color: isCollected ? AppTheme.green : AppTheme.background,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'PingFang SC',
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isCollected ? AppTheme.surfaceLight : AppTheme.gold,
                  disabledBackgroundColor: AppTheme.surfaceLight,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    switch (point.id) {
      case 'black-sea':
        return Icon(Icons.water_drop, color: AppTheme.gold, size: 22);
      case 'caucasus-mountains':
        return Icon(Icons.terrain, color: AppTheme.gold, size: 22);
      case 'caspian-sea':
        return Icon(Icons.sailing, color: AppTheme.gold, size: 22);
      default:
        return Icon(Icons.explore, color: AppTheme.gold, size: 22);
    }
  }

  Color _typeColor(String type) {
    switch (type) {
      case '地理位置证据':
        return AppTheme.gold;
      case '自然环境证据':
        return AppTheme.green;
      case '交通交流证据':
        return const Color(0xFF5B9BD5);
      default:
        return AppTheme.paper;
    }
  }
}
