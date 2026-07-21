import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../components/veggie_status_card.dart';
import '../components/civilization_map_card.dart';
import '../components/mission_card.dart';

/// 首页 Dashboard
///
/// ┌──────────────────────────────────────────────────────────┐
/// │  Welcome Header              [Veggie Status]        │
/// ├──────────────────────────────────────────────────────────┤
/// │                                                          │
/// │              Civilization Map Card                        │
/// │         (古地图背景 + 文明节点 + 连接线)                  │
/// │                                                          │
/// ├──────────────────────────────────────────────────────────┤
/// │  Mission 1    │  Mission 2    │  Mission 3              │
/// └──────────────────────────────────────────────────────────┘
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
              _buildMissionsSection(),
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
        // 左侧：品牌 + 问候
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
        // 右侧：Veggie 状态卡
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
        // ── 区域标题行 ──
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
        // ── 地图卡片 ──
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
  Widget _buildMissionsSection() {
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
            final cards = MissionItem.todayMissions
                .map((m) => MissionCard(mission: m))
                .toList();
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
