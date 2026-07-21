import 'mission_evaluation.dart';

/// 正式任务成果快照 — 由最终提交成功后创建
///
/// 只有 completed 阶段才更新此快照。
/// MyMap 必须读取此快照，不得直接读取 stepAnswersProvider。
class MissionResultSnapshot {
  final String missionId;
  final String regionId;
  final Map<int, String> answers;
  final List<String> evidenceIds;
  final int mapDiscoveryCount;
  final int readingEvidenceCount;
  final String personalExplanation;
  final FinalMissionEvaluation evaluation;
  final DateTime submittedAt;
  final int submissionVersion;

  const MissionResultSnapshot({
    required this.missionId,
    this.regionId = 'caucasus',
    required this.answers,
    this.evidenceIds = const [],
    this.mapDiscoveryCount = 0,
    this.readingEvidenceCount = 0,
    required this.personalExplanation,
    required this.evaluation,
    required this.submittedAt,
    required this.submissionVersion,
  });
}
