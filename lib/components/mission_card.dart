import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// 今日任务数据
class MissionItem {
  final int id;
  final String title;
  final String subtitle;
  final bool isCompleted;

  const MissionItem({
    required this.id,
    required this.title,
    required this.subtitle,
    this.isCompleted = false,
  });

  static const List<MissionItem> todayMissions = [
    MissionItem(
      id: 1,
      title: '找到高加索的位置',
      subtitle: '在世界地图上定位高加索地区',
    ),
    MissionItem(
      id: 2,
      title: '阅读第26章',
      subtitle: '高加索文明 — 丝路交汇处',
    ),
    MissionItem(
      id: 3,
      title: '完成文明解释',
      subtitle: '用一段话描述高加索的文明特征',
    ),
  ];
}

/// 今日任务卡片
///
/// 显示单个文明探索任务，带编号和完成状态。
class MissionCard extends StatelessWidget {
  final MissionItem mission;

  const MissionCard({super.key, required this.mission});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: mission.isCompleted
              ? AppTheme.green.withAlpha(80)
              : AppTheme.divider,
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          // ── 编号圆环 ──
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: mission.isCompleted
                    ? AppTheme.green
                    : AppTheme.gold.withAlpha(120),
                width: 1.5,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              '${mission.id}',
              style: TextStyle(
                color: mission.isCompleted ? AppTheme.green : AppTheme.gold,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: 'PingFang SC',
              ),
            ),
          ),
          const SizedBox(width: 14),
          // ── 任务详情 ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  mission.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppTheme.paper,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'PingFang SC',
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  mission.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppTheme.paper.withAlpha(140),
                    fontSize: 12,
                    fontFamily: 'PingFang SC',
                  ),
                ),
              ],
            ),
          ),
          if (mission.isCompleted)
            const Icon(Icons.check_circle, color: AppTheme.green, size: 20),
        ],
      ),
    );
  }
}
