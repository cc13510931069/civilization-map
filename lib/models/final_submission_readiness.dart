/// 最终提交条件模型
class SubmissionRequirement {
  final String id;
  final String label;
  final bool completed;
  final String? actionLabel;
  final String? actionRoute;

  const SubmissionRequirement({
    required this.id,
    required this.label,
    required this.completed,
    this.actionLabel,
    this.actionRoute,
  });
}

/// 共享纯规则函数 — 唯一最终提交规则来源
FinalSubmissionEligibility evaluateFinalSubmissionEligibility({
  required Map<int, String> answers,
  required int mapEvidenceCount,
  required int readingEvidenceCount,
  required bool isSubmitting,
}) {
  final allStepsValid =
      [1, 2, 3, 4, 5].every((s) => ((answers[s] ?? '').trim().length >= 6));
  final hasAnyEvidence = (mapEvidenceCount + readingEvidenceCount) > 0;
  final hasMapEvidence = mapEvidenceCount > 0;
  final hasReadingEvidence = readingEvidenceCount > 0;

  final canSubmit = !isSubmitting && allStepsValid && hasAnyEvidence;

  FinalSubmissionBlockReason? primaryBlockReason;
  if (isSubmitting) {
    primaryBlockReason = FinalSubmissionBlockReason.submissionInProgress;
  } else if (!allStepsValid) {
    primaryBlockReason = FinalSubmissionBlockReason.incompleteSteps;
  } else if (!hasAnyEvidence) {
    primaryBlockReason = FinalSubmissionBlockReason.missingEvidence;
  }

  return FinalSubmissionEligibility(
    allStepsValid: allStepsValid,
    hasAnyEvidence: hasAnyEvidence,
    hasMapEvidence: hasMapEvidence,
    hasReadingEvidence: hasReadingEvidence,
    mapEvidenceCount: mapEvidenceCount,
    readingEvidenceCount: readingEvidenceCount,
    isSubmitting: isSubmitting,
    canSubmit: canSubmit,
    primaryBlockReason: primaryBlockReason,
  );
}

/// 最终提交阻塞原因
enum FinalSubmissionBlockReason {
  incompleteSteps,
  missingEvidence,
  submissionInProgress,
}

/// 最终提交规则评估结果
class FinalSubmissionEligibility {
  final bool allStepsValid;
  final bool hasAnyEvidence;
  final bool hasMapEvidence;
  final bool hasReadingEvidence;
  final int mapEvidenceCount;
  final int readingEvidenceCount;
  final bool isSubmitting;
  final bool canSubmit;
  final FinalSubmissionBlockReason? primaryBlockReason;

  const FinalSubmissionEligibility({
    required this.allStepsValid,
    required this.hasAnyEvidence,
    required this.hasMapEvidence,
    required this.hasReadingEvidence,
    required this.mapEvidenceCount,
    required this.readingEvidenceCount,
    required this.isSubmitting,
    required this.canSubmit,
    this.primaryBlockReason,
  });

  /// 统一的阻塞原因中文文案
  String? get primaryBlockingMessage {
    switch (primaryBlockReason) {
      case FinalSubmissionBlockReason.incompleteSteps:
        return '请完善全部五步思考后再提交。';
      case FinalSubmissionBlockReason.missingEvidence:
        return '请先收集至少一条地图或阅读证据。';
      case FinalSubmissionBlockReason.submissionInProgress:
        return 'Veggie正在评价，请稍候。';
      case null:
        return null;
    }
  }
}

/// 最终提交准备状态（用于UI展示）
class FinalSubmissionReadiness {
  final List<SubmissionRequirement> requirements;
  final bool canSubmit;
  final String? primaryBlockingReason;
  final String veggieMessage;
  final bool hasMapEvidence;
  final bool hasReadingEvidence;

  const FinalSubmissionReadiness({
    required this.requirements,
    required this.canSubmit,
    this.primaryBlockingReason,
    required this.veggieMessage,
    required this.hasMapEvidence,
    required this.hasReadingEvidence,
  });

  int get completedCount => requirements.where((r) => r.completed).length;
  int get totalCount => requirements.length;
  int get remainingCount => totalCount - completedCount;
}

/// 证据来源统计
class EvidenceSourceCounts {
  final int mapCount;
  final int readingCount;
  final int totalCount;

  const EvidenceSourceCounts({
    required this.mapCount,
    required this.readingCount,
  }) : totalCount = mapCount + readingCount;
}

/// 统计证据来源（地图 vs 阅读）
/// [evidence] 来自 missionEvidenceProvider 的键值对
/// 非 'reading:' 前缀的键视为地图证据
// TODO: 未来 MissionEvidence 具有明确 source/type 字段后，移除 ID 前缀推断
EvidenceSourceCounts countMissionEvidenceSources(Map<String, String> evidence) {
  int readingCount = 0;
  int mapCount = 0;
  for (final key in evidence.keys) {
    if (key.startsWith('reading:')) {
      readingCount++;
    } else {
      mapCount++;
    }
  }
  return EvidenceSourceCounts(mapCount: mapCount, readingCount: readingCount);
}
