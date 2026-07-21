import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// 地图缩放控制组件 — 放置在地图右下角
///
/// ┌──────────┐
/// │    ＋    │  放大
/// ├──────────┤
/// │   100%   │  当前比例
/// ├──────────┤
/// │    －    │  缩小
/// ├──────────┤
/// │  回到全图 │  或「全图」
/// └──────────┘
class MapZoomControls extends StatelessWidget {
  final double zoomPercent;
  final double minZoomPercent;
  final double maxZoomPercent;
  final VoidCallback? onZoomIn;
  final VoidCallback? onZoomOut;
  final VoidCallback? onResetView;

  const MapZoomControls({
    super.key,
    required this.zoomPercent,
    this.minZoomPercent = 10,
    this.maxZoomPercent = 400,
    this.onZoomIn,
    this.onZoomOut,
    this.onResetView,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildButton(Icons.add, '放大', onZoomIn),
        const SizedBox(height: 1),
        _buildDisplay(),
        const SizedBox(height: 1),
        _buildButton(Icons.remove, '缩小', onZoomOut),
        const SizedBox(height: 1),
        _buildSmallButton('回到全图', Icons.fit_screen, onResetView),
      ],
    );
  }

  Widget _buildButton(IconData icon, String tooltip, VoidCallback? onTap) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppTheme.surfaceLight,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.divider, width: 0.5),
          ),
          child: Icon(icon, color: AppTheme.gold, size: 20),
        ),
      ),
    );
  }

  Widget _buildSmallButton(String label, IconData icon, VoidCallback? onTap) {
    return Tooltip(
      message: label,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minWidth: 44),
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: AppTheme.shimmerGold,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.gold.withAlpha(60), width: 0.5),
          ),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(label,
                  style: TextStyle(
                      color: AppTheme.gold,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'PingFang SC')),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDisplay() {
    final text = zoomPercent < 100
        ? '${zoomPercent.toInt()}%'
        : '${zoomPercent.toInt()}%';
    final color = zoomPercent >= 95 && zoomPercent <= 105
        ? AppTheme.green
        : AppTheme.gold;
    return Container(
      width: 44,
      height: 36,
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.divider, width: 0.5),
      ),
      alignment: Alignment.center,
      child: Text(text,
          style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              fontFamily: 'PingFang SC')),
    );
  }
}
