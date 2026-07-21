import 'civilization_reasoning_profile.dart';

/// 最终提交的四项能力评价（统一 0-25 量表）
///
/// 全项目唯一 FinalMissionEvaluation 定义。
/// 其他文件统一 import 本文件。
class FinalMissionEvaluation {
  final int locationScore; // 位置与知识 (0-25)
  final int evidenceScore; // 证据使用 (0-25)
  final int causalityScore; // 因果与逻辑 (0-25)
  final int explanationScore; // 个人解释 (0-25)
  final int totalScore; // 总分 (0-100)
  final CivilizationReasoningProfile? profile;
  final String locationLevel;
  final String evidenceLevel;
  final String causalityLevel;
  final String explanationLevel;

  const FinalMissionEvaluation({
    required this.locationScore,
    required this.evidenceScore,
    required this.causalityScore,
    required this.explanationScore,
    required this.totalScore,
    this.profile,
    this.locationLevel = '发展中',
    this.evidenceLevel = '发展中',
    this.causalityLevel = '发展中',
    this.explanationLevel = '发展中',
  });
}

/// 评价维度级别（统一 0-25 量表，全项目唯一来源）
String scoreToLevel(int score) {
  if (score >= 22) return '深入';
  if (score >= 16) return '清晰';
  if (score >= 10) return '发展中';
  return '起步';
}
