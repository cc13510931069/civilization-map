import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/mission_state.dart';
import '../models/final_submission_readiness.dart';
import '../theme/app_theme.dart';

/// 最终提交准备条件卡片
class FinalSubmissionReadinessCard extends ConsumerWidget {
  final VoidCallback? onMapAction;
  final VoidCallback? onReadingAction;

  const FinalSubmissionReadinessCard({
    super.key,
    this.onMapAction,
    this.onReadingAction,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readiness = ref.watch(finalSubmissionReadinessProvider);
    final requirements = readiness.requirements;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: readiness.canSubmit
              ? AppTheme.gold.withAlpha(80)
              : AppTheme.divider.withAlpha(60),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header row
          Row(
            children: [
              Text(
                '最终提交准备',
                style: TextStyle(
                  color: AppTheme.paper,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '已完成 ${readiness.completedCount} / ${readiness.totalCount}',
                style: TextStyle(
                  color: readiness.canSubmit
                      ? AppTheme.gold
                      : AppTheme.paper.withAlpha(160),
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Requirements list
          ...requirements.map((req) => _buildRequirementRow(context, req)),
          // Evidence info (informational, not a hard requirement)
          if (readiness.hasMapEvidence || readiness.hasReadingEvidence)
            Padding(
              padding: const EdgeInsets.only(left: 30, top: 4),
              child: Text(
                _evidenceInfoText(readiness),
                style: TextStyle(
                  color: AppTheme.paper.withAlpha(150),
                  fontSize: 12,
                ),
              ),
            ),
          // Alternative action buttons when evidence missing
          if (!readiness.requirements
              .any((r) => r.id == 'evidence' && r.completed))
            Padding(
              padding: const EdgeInsets.only(left: 30, top: 6),
              child: Wrap(
                spacing: 8,
                children: [
                  ActionChip(
                    avatar: const Icon(Icons.map, size: 14),
                    label: const Text('去地图探索', style: TextStyle(fontSize: 12)),
                    onPressed: () => onMapAction?.call(),
                    backgroundColor: AppTheme.surfaceLight.withAlpha(50),
                    side: BorderSide(
                        color: AppTheme.divider.withAlpha(80), width: 0.5),
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.menu_book, size: 14),
                    label: const Text('去精读营', style: TextStyle(fontSize: 12)),
                    onPressed: () => onReadingAction?.call(),
                    backgroundColor: AppTheme.surfaceLight.withAlpha(50),
                    side: BorderSide(
                        color: AppTheme.divider.withAlpha(80), width: 0.5),
                  ),
                ],
              ),
            ),
          // Veggie message
          if (readiness.veggieMessage.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight.withAlpha(30),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.pets,
                    size: 16,
                    color: AppTheme.gold.withAlpha(180),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      readiness.veggieMessage,
                      style: TextStyle(
                        color: AppTheme.paper.withAlpha(200),
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _evidenceInfoText(FinalSubmissionReadiness r) {
    if (r.hasMapEvidence && r.hasReadingEvidence) {
      return '已有地图证据和阅读证据共2类。';
    } else if (r.hasMapEvidence) {
      return '已有地图发现证据。';
    } else if (r.hasReadingEvidence) {
      return '已有阅读证据。';
    }
    return '';
  }

  Widget _buildRequirementRow(BuildContext context, SubmissionRequirement req) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          // Status icon
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: req.completed
                  ? AppTheme.gold.withAlpha(50)
                  : AppTheme.surfaceLight.withAlpha(30),
              border: Border.all(
                color: req.completed
                    ? AppTheme.gold
                    : AppTheme.paper.withAlpha(80),
                width: 1.5,
              ),
            ),
            child: Center(
              child: req.completed
                  ? const Icon(Icons.check, size: 12, color: AppTheme.gold)
                  : const SizedBox.shrink(),
            ),
          ),
          const SizedBox(width: 10),
          // Label
          Expanded(
            child: Text(
              req.label,
              style: TextStyle(
                color: req.completed
                    ? AppTheme.paper
                    : AppTheme.paper.withAlpha(180),
                fontSize: 14,
              ),
            ),
          ),
          // Action button (for steps)
          if (req.id == 'steps' && req.actionLabel != null && !req.completed)
            TextButton(
              onPressed: () {
                // Scroll to steps
              },
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                foregroundColor: AppTheme.gold,
              ),
              child: Text(
                req.actionLabel!,
                style: const TextStyle(fontSize: 13),
              ),
            ),
        ],
      ),
    );
  }
}
