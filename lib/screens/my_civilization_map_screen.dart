import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../models/exploration_progress.dart';
import '../models/civilization_explanation.dart';
import '../models/civilization_reasoning_profile.dart';
import '../models/civilization_map_project.dart';
import '../data/mission_state.dart';
import '../data/reading_state.dart';
import '../components/civilization_canvas.dart';
import '../components/explanation_section_card.dart';
import '../components/project_export_card.dart';
import '../components/reasoning_profile_card.dart';

/// 我的文明地图 — 数字文明展板
class MyCivilizationMapScreen extends ConsumerWidget {
  const MyCivilizationMapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress =
        ref.watch(explorationProgressProvider).forRegion('caucasus');
    final readingEvidence = ref.watch(readingEvidenceProvider);
    final snapshot = ref.watch(missionResultSnapshotProvider);
    final stepAnswers = snapshot?.answers ?? <int, String>{};
    final profile = snapshot?.evaluation.profile;

    final discovered = DiscoveryPoint.caucasus
        .where((p) => progress.isCollected(p.id))
        .toList();
    final allPoints = DiscoveryPoint.caucasus.length;

    final project = CivilizationMapProject(
      regionId: 'caucasus',
      discoveredPoints: discovered,
      readingEvidences: readingEvidence,
      thinkingSteps: stepAnswers,
      profile: profile,
    );

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(project),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildLeftPanel(project, allPoints),
                    const SizedBox(width: 12),
                    _buildCenterPanel(project),
                    const SizedBox(width: 12),
                    _buildRightPanel(context, project, profile),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(CivilizationMapProject project) {
    return Container(
      padding: const EdgeInsets.fromLTRB(32, 20, 32, 16),
      child: Row(children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppTheme.shimmerGold,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.map, color: AppTheme.gold, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('我的文明地图',
                  style: TextStyle(
                    color: AppTheme.paper,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'PingFang SC',
                  )),
              const SizedBox(height: 2),
              Text('${project.regionName} · 文明研究作品集',
                  style: TextStyle(
                    color: AppTheme.paper.withAlpha(140),
                    fontSize: 14,
                    fontFamily: 'PingFang SC',
                  )),
            ],
          ),
        ),
      ]),
    );
  }

  // ── 左侧：文明地图 ──
  Widget _buildLeftPanel(CivilizationMapProject project, int totalPoints) {
    return SizedBox(
      width: 220,
      child: Column(
        children: [
          CivilizationCanvas(
            regionName: project.regionName,
            discoveredPoints: project.discoveredPoints,
            totalDiscoveryCount: project.discoveryCount,
            readingEvidenceCount: project.readingEvidenceCount,
          ),
          const SizedBox(height: 12),
          // ── 完整性提示 ──
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.shimmerGold,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('探索进度',
                    style: TextStyle(
                      color: AppTheme.gold,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'PingFang SC',
                    )),
                const SizedBox(height: 6),
                Text('区域发现 ${project.discoveryCount}/$totalPoints',
                    style: TextStyle(
                      color: AppTheme.paper.withAlpha(160),
                      fontSize: 11,
                      fontFamily: 'PingFang SC',
                    )),
                Text('阅读证据 ${project.readingEvidenceCount}',
                    style: TextStyle(
                      color: AppTheme.paper.withAlpha(160),
                      fontSize: 11,
                      fontFamily: 'PingFang SC',
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 中央：解释作品 ──
  Widget _buildCenterPanel(CivilizationMapProject project) {
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(Icons.auto_awesome, color: AppTheme.gold, size: 16),
              const SizedBox(width: 8),
              Text('我的解释作品',
                  style: TextStyle(
                    color: AppTheme.paper,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'PingFang SC',
                  )),
              const Spacer(),
              Text('${project.stepsCompleted}/5',
                  style: TextStyle(
                    color: AppTheme.paper.withAlpha(100),
                    fontSize: 13,
                    fontFamily: 'PingFang SC',
                  )),
            ]),
            const SizedBox(height: 12),
            ...ExplanationModule.all.map((module) {
              final content = project.thinkingSteps[module.stepNumber] ?? '';
              final isComplete = content.trim().isNotEmpty;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: ExplanationSectionCard(
                  module: module,
                  content: content,
                  isComplete: isComplete,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // ── 右侧：Veggie 导师 + 画像 + 导出 ──
  Widget _buildRightPanel(
    BuildContext context,
    CivilizationMapProject project,
    CivilizationReasoningProfile? profile,
  ) {
    return SizedBox(
      width: 280,
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildVeggieFeedback(project),
            const SizedBox(height: 12),
            if (profile != null) ...[
              ReasoningProfileCard(profile: profile),
              const SizedBox(height: 12),
            ],
            ProjectExportCard(
              completeness: project.completeness,
              onSave: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('作品已保存',
                        style: TextStyle(fontFamily: 'PingFang SC')),
                    backgroundColor: AppTheme.green,
                  ),
                );
              },
              onExportCard: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('作品卡生成功能即将上线',
                        style: TextStyle(fontFamily: 'PingFang SC')),
                    backgroundColor: AppTheme.gold,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVeggieFeedback(CivilizationMapProject project) {
    final items = <String>[];
    if (project.discoveryCount > 0) items.add('✓ 地理位置与发现证据');
    if (project.readingEvidenceCount > 0) items.add('✓ 阅读证据与历史素材');
    if (project.stepsCompleted >= 3) items.add('✓ 部分文明解释');
    if (project.stepsCompleted >= 5) items.add('✓ 完整文明解释');
    if (project.hasProfile) items.add('✓ 能力画像评估');

    final improvements = <String>[];
    if (project.discoveryCount == 0) improvements.add('△ 完成高加索区域探索');
    if (project.readingEvidenceCount == 0) improvements.add('△ 在精读营中收集证据');
    if (project.stepsCompleted < 5) improvements.add('△ 完善五步文明解释');
    if (!project.hasProfile) improvements.add('△ 完成思考实验室获得画像');

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
          // ── Veggie 头部 ──
          Row(children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppTheme.shimmerGold,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.pets, color: AppTheme.gold, size: 16),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Veggie',
                    style: TextStyle(
                      color: AppTheme.paper,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'PingFang SC',
                    )),
                Text('· 作品指导老师',
                    style: TextStyle(
                      color: AppTheme.paper.withAlpha(100),
                      fontSize: 11,
                      fontFamily: 'PingFang SC',
                    )),
              ],
            ),
          ]),
          const SizedBox(height: 14),
          // ── 已包含 ──
          if (items.isNotEmpty) ...[
            Text('你的作品已经包含：',
                style: TextStyle(
                  color: AppTheme.paper.withAlpha(160),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'PingFang SC',
                )),
            const SizedBox(height: 6),
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(item,
                      style: TextStyle(
                        color: AppTheme.green.withAlpha(200),
                        fontSize: 12,
                        fontFamily: 'PingFang SC',
                      )),
                )),
            const SizedBox(height: 12),
          ],
          // ── 可加强 ──
          if (improvements.isNotEmpty) ...[
            Text('可以进一步：',
                style: TextStyle(
                  color: AppTheme.paper.withAlpha(160),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'PingFang SC',
                )),
            const SizedBox(height: 6),
            ...improvements.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(item,
                      style: TextStyle(
                        color: AppTheme.gold.withAlpha(200),
                        fontSize: 12,
                        fontFamily: 'PingFang SC',
                      )),
                )),
          ],
          if (items.isEmpty && improvements.isEmpty)
            Text('开始探索后，Veggie 将为你提供作品指导。',
                style: TextStyle(
                  color: AppTheme.paper.withAlpha(80),
                  fontSize: 12,
                  height: 1.5,
                  fontFamily: 'PingFang SC',
                )),
        ],
      ),
    );
  }
}
