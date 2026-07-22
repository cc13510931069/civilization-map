import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../data/home_task_state.dart';

/// 今日任务数据
class MissionItem {
  final int id;
  final String title;
  final String subtitle;

  const MissionItem({
    required this.id,
    required this.title,
    required this.subtitle,
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
/// 显示单个文明探索任务，带编号、完成状态和导航点击。
class MissionCard extends StatelessWidget {
  final MissionItem mission;
  final HomeCivilizationTaskStatus status;
  final bool isRecommended;
  final VoidCallback? onTap;

  const MissionCard({
    super.key,
    required this.mission,
    required this.status,
    this.isRecommended = false,
    this.onTap,
  });

  String get _statusLabel {
    switch (status) {
      case HomeCivilizationTaskStatus.notStarted:
        return '未开始';
      case HomeCivilizationTaskStatus.inProgress:
        return isRecommended ? '下一步' : '进行中';
      case HomeCivilizationTaskStatus.completed:
        return '已完成';
    }
  }

  Color get _statusColor {
    switch (status) {
      case HomeCivilizationTaskStatus.notStarted:
        return AppTheme.paper.withAlpha(120);
      case HomeCivilizationTaskStatus.inProgress:
        return isRecommended ? AppTheme.gold : AppTheme.paper.withAlpha(180);
      case HomeCivilizationTaskStatus.completed:
        return AppTheme.green;
    }
  }

  Color get _borderColor {
    if (status == HomeCivilizationTaskStatus.completed) {
      return AppTheme.green.withAlpha(80);
    }
    if (isRecommended) {
      return AppTheme.gold.withAlpha(80);
    }
    return AppTheme.divider;
  }

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isRecommended ? AppTheme.surfaceLight : AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _borderColor,
          width: isRecommended ? 1.0 : 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // ── 编号圆环 ──
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: status == HomeCivilizationTaskStatus.completed
                        ? AppTheme.green
                        : AppTheme.gold.withAlpha(120),
                    width: 1.5,
                  ),
                ),
                alignment: Alignment.center,
                child: status == HomeCivilizationTaskStatus.completed
                    ? const Icon(Icons.check, color: AppTheme.green, size: 18)
                    : Text(
                        '${mission.id}',
                        style: TextStyle(
                          color: status == HomeCivilizationTaskStatus.completed
                              ? AppTheme.green
                              : AppTheme.gold,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'PingFang SC',
                        ),
                      ),
              ),
              const SizedBox(width: 8),
              // ── 状态标签 ──
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _statusColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _statusLabel,
                  style: TextStyle(
                    color: _statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'PingFang SC',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // ── 任务标题 ──
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
          // ── 任务副标题 ──
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
    );

    return Semantics(
      button: true,
      label: '${mission.title} - $_statusLabel',
      child: GestureDetector(
        onTap: onTap,
        child: card,
      ),
    );
  }
}
