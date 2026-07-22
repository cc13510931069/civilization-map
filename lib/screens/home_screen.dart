import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../components/veggie_status_card.dart';
import '../components/civilization_map_card.dart';
import '../components/mission_card.dart';
import '../data/home_task_state.dart';

/// 首页 Dashboard
///
/// ┌─────────────────────────────────────────────────────────────┐
/// │  Welcome Header                     [Veggie Status]        │
/// ├─────────────────────────────────────────────────────────────┤
/// │                                                             │
/// │              Civilization Map Card                           │
/// │         (古地图背景 + 文明节点 + 连接线)                      │
/// │                                                             │
/// ├─────────────────────────────────────────────────────────────┤
/// │  今日任务区域                                                │
/// │  ┌──────┐  ┌──────┐  ┌──────┐                              │
/// │  │ 地图  │  │ 阅读  │  │Mission│                             │
/// │  └──────┘  └──────┘  └──────┘                              │
/// └─────────────────────────────────────────────────────────────┘
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mapStatus = ref.watch(homeMapTaskStatusProvider);
    final readingStatus = ref.watch(homeReadingTaskStatusProvider);
    final missionStatus = ref.watch(homeMissionTaskStatusProvider);
    final recommendedTask = ref.watch(currentRecommendedHomeTaskProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 20, 32, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ═══════════════════════════════════════════
              //  1. 顶部欢迎区域
              // ═══════════════════════════════════════════
              _buildWelcomeHeader(),
              const SizedBox(height: 20),

              // ═══════════════════════════════════════════
              //  2. 中央文明地图工作区
              // ═══════════════════════════════════════════
              Expanded(
                child: _buildMapSection(context),
              ),
              const SizedBox(height: 20),

              // ═══════════════════════════════════════════
              //  3. 今日任务区域
              // ═══════════════════════════════════════════
              _buildMissionsSection(
                context,
                ref,
                mapStatus,
                readingStatus,
                missionStatus,
                recommendedTask,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  //  欢迎区域
  // ─────────────────────────────────────────────────────────────
  Widget _buildWelcomeHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '文明的地图 HD',
                style: TextStyle(
                  color: AppTheme.gold,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'PingFang SC',
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '欢迎回来，探索者。',
                style: TextStyle(
                  color: AppTheme.paper.withAlpha(180),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'PingFang SC',
                ),
              ),
            ],
          ),
        ),
        const VeggieStatusCard(),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  //  地图工作区
  // ─────────────────────────────────────────────────────────────
  Widget _buildMapSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Icon(Icons.map_outlined, color: AppTheme.gold, size: 18),
              const SizedBox(width: 8),
              Text(
                '文明旅程地图',
                style: TextStyle(
                  color: AppTheme.paper,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'PingFang SC',
                ),
              ),
              const Spacer(),
              Text(
                '探索 4 个文明区域',
                style: TextStyle(
                  color: AppTheme.paper.withAlpha(120),
                  fontSize: 13,
                  fontFamily: 'PingFang SC',
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: const CivilizationMapCard(),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  //  今日任务
  // ─────────────────────────────────────────────────────────────
  Widget _buildMissionsSection(
    BuildContext context,
    WidgetRef ref,
    HomeCivilizationTaskStatus mapStatus,
    HomeCivilizationTaskStatus readingStatus,
    HomeCivilizationTaskStatus missionStatus,
    int? recommendedTask,
  ) {
    final cards = MissionItem.todayMissions.map((m) {
      final status = m.id == 1
          ? mapStatus
          : m.id == 2
              ? readingStatus
              : missionStatus;
      final isRecommended = recommendedTask == m.id;
      VoidCallback? onTap;
      switch (m.id) {
        case 1:
          onTap = () => context.go('/world-map',
              extra: <String, dynamic>{'focusRegionId': 'caucasus'});
        case 2:
          onTap = () => context.go('/reading-camp',
              extra: <String, dynamic>{'focusChapter': 26});
        case 3:
          onTap = () => context.go('/mission');
      }
      return MissionCard(
        key: ValueKey('home-mission-$m.id'),
        mission: m,
        status: status,
        isRecommended: isRecommended,
        onTap: onTap,
      );
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── 标题行 ──
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Icon(Icons.flag_outlined, color: AppTheme.gold, size: 18),
              const SizedBox(width: 8),
              Text(
                '今日文明任务',
                style: TextStyle(
                  color: AppTheme.paper,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'PingFang SC',
                ),
              ),
            ],
          ),
        ),
        // ── 任务卡片行（响应式）──
        LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            if (w >= 800) {
              return SizedBox(
                height: 120,
                child: Row(
                  children: cards
                      .asMap()
                      .entries
                      .map((e) => Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: e.key == 0 ? 0 : 6,
                                right: e.key == cards.length - 1 ? 0 : 6,
                              ),
                              child: e.value,
                            ),
                          ))
                      .toList(),
                ),
              );
            } else if (w >= 560) {
              return Column(
                children: [
                  SizedBox(
                    height: 120,
                    child: Row(
                      children: cards
                          .take(2)
                          .toList()
                          .asMap()
                          .entries
                          .map((e) => Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    left: e.key == 0 ? 0 : 6,
                                    right: e.key == 1 ? 0 : 6,
                                  ),
                                  child: e.value,
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(height: 120, child: cards[2]),
                ],
              );
            } else {
              return Column(
                children: cards
                    .map((c) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: SizedBox(height: 120, child: c),
                        ))
                    .toList(),
              );
            }
          },
        ),
      ],
    );
  }
}
