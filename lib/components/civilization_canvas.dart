import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/exploration_progress.dart';

/// 文明地图展板 — 左侧地图区域
///
/// 显示学生探索的文明区域概览：
/// 简化地图 + 发现点标注 + 证据统计。
class CivilizationCanvas extends StatelessWidget {
  final String regionName;
  final List<DiscoveryPoint> discoveredPoints;
  final int totalDiscoveryCount;
  final int readingEvidenceCount;

  const CivilizationCanvas({
    super.key,
    required this.regionName,
    required this.discoveredPoints,
    required this.totalDiscoveryCount,
    required this.readingEvidenceCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark.withAlpha(200),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.divider, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 区域标题 ──
          Row(children: [
            Icon(Icons.public, color: AppTheme.gold, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(regionName,
                  style: TextStyle(
                    color: AppTheme.paper,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'PingFang SC',
                  )),
            ),
          ]),
          const SizedBox(height: 12),

          // ── 简化地图 ──
          Container(
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF0D2A3A),
                  const Color(0xFF081A28),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
              border:
                  Border.all(color: AppTheme.gold.withAlpha(30), width: 0.5),
            ),
            child: Stack(
              children: [
                // 海洋
                Positioned(
                  left: 8,
                  top: 10,
                  child: Text('🌊',
                      style: TextStyle(
                          fontSize: 14, color: AppTheme.paper.withAlpha(60))),
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Text('🌊',
                      style: TextStyle(
                          fontSize: 14, color: AppTheme.paper.withAlpha(60))),
                ),
                // 山脉
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('⛰️', style: TextStyle(fontSize: 32)),
                      const SizedBox(height: 4),
                      Text('大高加索山脉',
                          style: TextStyle(
                            color: AppTheme.paper.withAlpha(120),
                            fontSize: 10,
                            fontFamily: 'PingFang SC',
                          )),
                    ],
                  ),
                ),
                // 发现点标注
                if (discoveredPoints.isNotEmpty)
                  Positioned(
                    left: 4,
                    bottom: 4,
                    child: Text(
                        discoveredPoints.map((p) => '${p.name}').join(' · '),
                        style: TextStyle(
                          color: AppTheme.green.withAlpha(180),
                          fontSize: 9,
                          fontFamily: 'PingFang SC',
                        )),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── 统计信息 ──
          _buildStatRow(
              Icons.explore, '探索发现', '$totalDiscoveryCount', AppTheme.gold),
          const SizedBox(height: 6),
          _buildStatRow(
              Icons.menu_book, '阅读证据', '$readingEvidenceCount', AppTheme.green),
        ],
      ),
    );
  }

  Widget _buildStatRow(IconData icon, String label, String value, Color color) {
    return Row(children: [
      Icon(icon, color: color, size: 14),
      const SizedBox(width: 8),
      Text(label,
          style: TextStyle(
            color: AppTheme.paper.withAlpha(160),
            fontSize: 12,
            fontFamily: 'PingFang SC',
          )),
      const Spacer(),
      Text(value,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          )),
    ]);
  }
}
