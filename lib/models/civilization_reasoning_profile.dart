/// 文明解释能力画像
///
/// 跟踪学生在四项核心维度的表现。
/// 100 分制，每项维度有不同满分上限。
class CivilizationReasoningProfile {
  /// 地理理解（满分 25）
  final int geographicUnderstanding;

  /// 证据使用（满分 25）
  final int evidenceUsage;

  /// 历史因果分析（满分 30）
  final int historicalCausality;

  /// 个人解释（满分 20）
  final int personalExplanation;

  const CivilizationReasoningProfile({
    this.geographicUnderstanding = 0,
    this.evidenceUsage = 0,
    this.historicalCausality = 0,
    this.personalExplanation = 0,
  });

  /// 总分（满分 100）
  int get total =>
      geographicUnderstanding +
      evidenceUsage +
      historicalCausality +
      personalExplanation;

  /// 获取某一维度的星级（满分 5 星）
  static double toStarRating(int score, int max) {
    return (score / max) * 5;
  }

  /// 维度中文名
  static const Map<String, String> dimensionLabels = {
    'geographicUnderstanding': '地理定位',
    'evidenceUsage': '证据使用',
    'historicalCausality': '因果分析',
    'personalExplanation': '观点表达',
  };
}

/// 单次评价结果
class EvaluationResult {
  final CivilizationReasoningProfile profile;
  final Map<int, int> stepScores; // stepNumber -> score

  const EvaluationResult({
    required this.profile,
    required this.stepScores,
  });
}
