import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../models/evidence_type.dart';
import '../models/highlighted_evidence.dart';
import '../data/reading_state.dart';
import '../services/reading_assistant_service.dart';

/// Veggie 阅读导师面板
///
/// 右侧常驻面板，非聊天窗口。
/// 功能：展示阅读任务、已标记证据、Veggie 引导提示。
class ReadingAIPanel extends ConsumerWidget {
  const ReadingAIPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final evidence = ref.watch(readingEvidenceProvider);
    final completed = ref.watch(completedTasksProvider);
    final hint = ref.watch(veggieHintProvider);

    return Container(
      width: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark.withAlpha(230),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.divider, width: 0.5),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Veggie 头部 ──
            _buildHeader(context),
            const SizedBox(height: 16),

            // ── 阅读任务 ──
            _buildTasksSection(completed),
            const SizedBox(height: 16),

            // ── 已标记证据 ──
            _buildEvidenceSection(evidence),
            const SizedBox(height: 16),

            // ── Veggie 提示 ──
            _buildHintSection(context, hint, evidence.length, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(children: [
      Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppTheme.shimmerGold,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.pets, color: AppTheme.gold, size: 18),
      ),
      const SizedBox(width: 10),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Veggie',
              style: TextStyle(
                color: AppTheme.paper,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                fontFamily: 'PingFang SC',
              )),
          Text('· 文明导师',
              style: TextStyle(
                color: AppTheme.paper.withAlpha(120),
                fontSize: 11,
                fontFamily: 'PingFang SC',
              )),
        ],
      ),
    ]);
  }

  Widget _buildTasksSection(Set<ReadingTask> completed) {
    final allTasks = defaultReadingTasks;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Icon(Icons.menu_book, color: AppTheme.gold, size: 14),
          const SizedBox(width: 6),
          Text('当前阅读任务',
              style: TextStyle(
                color: AppTheme.paper,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                fontFamily: 'PingFang SC',
              )),
        ]),
        const SizedBox(height: 10),
        ...allTasks.map((task) {
          final done = completed.contains(task);
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(children: [
              Icon(
                done ? Icons.check_circle : Icons.radio_button_unchecked,
                color: done ? AppTheme.green : AppTheme.paper.withAlpha(100),
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(task.label,
                  style: TextStyle(
                    color:
                        done ? AppTheme.green : AppTheme.paper.withAlpha(160),
                    fontSize: 12,
                    fontFamily: 'PingFang SC',
                  )),
            ]),
          );
        }),
      ],
    );
  }

  Widget _buildEvidenceSection(List<HighlightedEvidence> evidence) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Icon(Icons.lightbulb_outline, color: AppTheme.gold, size: 14),
          const SizedBox(width: 6),
          Text('已标记证据 (${evidence.length})',
              style: TextStyle(
                color: AppTheme.paper,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                fontFamily: 'PingFang SC',
              )),
        ]),
        const SizedBox(height: 8),
        if (evidence.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text('阅读时选中文本，标记为证据。',
                style: TextStyle(
                  color: AppTheme.paper.withAlpha(80),
                  fontSize: 12,
                  fontFamily: 'PingFang SC',
                )),
          )
        else
          ...evidence.map((e) => _buildEvidenceItem(e)),
      ],
    );
  }

  Widget _buildEvidenceItem(HighlightedEvidence e) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.divider, width: 0.3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(e.text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppTheme.paper.withAlpha(200),
                fontSize: 12,
                height: 1.4,
                fontFamily: 'PingFang SC',
              )),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: _typeColor(e.type).withAlpha(25),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(e.type.label,
                style: TextStyle(
                  color: _typeColor(e.type),
                  fontSize: 10,
                  fontFamily: 'PingFang SC',
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildHintSection(
      BuildContext context, String hint, int evidenceCount, WidgetRef ref) {
    final showAction = evidenceCount >= 4;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(color: AppTheme.divider, height: 1),
        const SizedBox(height: 12),
        Row(children: [
          Icon(Icons.pets, color: AppTheme.gold, size: 14),
          const SizedBox(width: 6),
          Text('Veggie 提示',
              style: TextStyle(
                color: AppTheme.gold,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                fontFamily: 'PingFang SC',
              )),
        ]),
        const SizedBox(height: 8),
        Text(hint,
            style: TextStyle(
              color: AppTheme.paper.withAlpha(180),
              fontSize: 12,
              height: 1.6,
              fontFamily: 'PingFang SC',
            )),
        if (showAction) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 36,
            child: ElevatedButton.icon(
              onPressed: () {
                context.go('/mission');
              },
              icon: const Icon(Icons.psychology, size: 16),
              label: Text('前往思考实验室',
                  style: TextStyle(
                    color: AppTheme.background,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'PingFang SC',
                  )),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.gold,
                foregroundColor: AppTheme.background,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Color _typeColor(EvidenceType type) {
    switch (type) {
      case EvidenceType.geographic:
        return AppTheme.gold;
      case EvidenceType.historical:
        return const Color(0xFF5B9BD5);
      case EvidenceType.people:
        return AppTheme.green;
      case EvidenceType.change:
        return const Color(0xFFD9A441);
    }
  }
}
