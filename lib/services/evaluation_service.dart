import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ai_proxy_service.dart';
import '../models/ai_feedback.dart';
import '../models/mission_evaluation.dart';
import '../models/civilization_reasoning_profile.dart';

// ───────────────────────────────────────────────────────────────
//  Data classes for submission feedback
// ───────────────────────────────────────────────────────────────

/// 初始提交的形成性反馈（无数字评分）
class InitialMissionFeedback {
  final String feedbackText;
  final String discovery;
  final String improvement;
  final String nextPrompt;

  const InitialMissionFeedback({
    required this.feedbackText,
    required this.discovery,
    required this.improvement,
    required this.nextPrompt,
  });
}

/// 评价维度级别（统一 0-25 量表）

// ───────────────────────────────────────────────────────────────
//  Abstract service interface (injectable, replaceable)
// ───────────────────────────────────────────────────────────────

abstract class EvaluationService {
  Future<InitialMissionFeedback> evaluateInitial(
    Map<int, String> answers,
  );

  Future<FinalMissionEvaluation> evaluateFinal({
    required Map<int, String> answers,
    required int evidenceCount,
    required int mapDiscoveryCount,
    required int readingEvidenceCount,
  });
}

// ───────────────────────────────────────────────────────────────
//  Local (deterministic, heuristic-based) implementation
// ───────────────────────────────────────────────────────────────

class LocalEvaluationService implements EvaluationService {
  @override
  Future<InitialMissionFeedback> evaluateInitial(
    Map<int, String> answers,
  ) async {
    // Count which steps have meaningful content
    final completedSteps = <int>{};
    final hasLocation = <String>{};
    final hasCausal = <String>{};
    final hasPersonal = <String>{};

    for (int i = 1; i <= 5; i++) {
      final text = (answers[i] ?? '').trim();
      if (text.length >= 6) {
        completedSteps.add(i);
      }
      // Check for geographic keywords
      for (final kw in _geographicKeywords) {
        if (text.contains(kw)) hasLocation.add(kw);
      }
      // Check for causal connectors
      for (final kw in _causalKeywords) {
        if (text.contains(kw)) hasCausal.add(kw);
      }
      // Check for personal explanation expressions
      for (final kw in _personalKeywords) {
        if (text.contains(kw)) hasPersonal.add(kw);
      }
    }

    final allFive = completedSteps.length >= 5;
    final hasGeo = hasLocation.isNotEmpty;
    final hasCausalWords = hasCausal.isNotEmpty;
    final hasPersonalExpr = hasPersonal.isNotEmpty;

    // Build feedback text
    final discoveries = <String>[];
    if (allFive) {
      discoveries.add('你已经完成了全部五步思考。');
    } else {
      discoveries.add('你已经开始思考高加索的文明意义。');
    }
    if (hasGeo) {
      discoveries.add('你提到了具体的地理位置，这有助于文明定位。');
    }
    if (hasCausalWords) {
      discoveries.add('你使用了因果分析，这让你的思考更有逻辑。');
    }

    final improvements = <String>[];
    if (!hasGeo) {
      improvements.add('可以加入黑海、里海或高加索山脉作为地理证据。');
    }
    if (!hasCausalWords) {
      improvements.add('尝试使用"因为"、"所以"等词语连接因果。');
    }
    if (!hasPersonalExpr) {
      improvements.add('在第5步中，尝试用"我认为"来总结你的观点。');
    }
    if (improvements.isEmpty) {
      improvements.add('可以补充更多来自地图或阅读的证据来丰富你的解释。');
    }

    final feedbackText = [
      '✅ 发现：',
      ...discoveries,
      '',
      '💪 可以加强：',
      ...improvements,
      '',
      '🤔 再想一想：',
      '这些地理条件为什么会促进不同人群和文明的往来？',
    ].join('\n');

    return InitialMissionFeedback(
      feedbackText: feedbackText,
      discovery: discoveries.join('\n'),
      improvement: improvements.join('\n'),
      nextPrompt: '这些地理条件为什么会促进不同人群和文明的往来？',
    );
  }

  @override
  Future<FinalMissionEvaluation> evaluateFinal({
    required Map<int, String> answers,
    required int evidenceCount,
    required int mapDiscoveryCount,
    required int readingEvidenceCount,
  }) async {
    int locationScore = 0;
    int evidenceScore = 0;
    int causalityScore = 0;
    int explanationScore = 0;

    // ── Location & Knowledge (0-25) ──
    // Step 1 completeness + geographic keyword presence
    final step1 = (answers[1] ?? '').trim();
    final step2 = (answers[2] ?? '').trim();
    int geoHits = 0;
    for (final kw in _geographicKeywords) {
      if (step1.contains(kw)) geoHits++;
      if (step2.contains(kw)) geoHits++;
    }
    locationScore = (step1.length >= 10 ? 8 : 0) +
        (step2.length >= 10 ? 7 : 0) +
        (geoHits >= 3
            ? 10
            : geoHits >= 1
                ? 5
                : 0);
    locationScore = locationScore.clamp(0, 25);

    // ── Evidence Usage (0-25) ──
    evidenceScore = (mapDiscoveryCount * 5).clamp(0, 12) +
        (readingEvidenceCount * 4).clamp(0, 8) +
        (evidenceCount >= 3
            ? 5
            : evidenceCount >= 1
                ? 2
                : 0);
    evidenceScore = evidenceScore.clamp(0, 25);

    // ── Causality & Logic (0-25) ──
    int causalHits = 0;
    for (int i = 1; i <= 5; i++) {
      final text = (answers[i] ?? '');
      for (final kw in _causalKeywords) {
        if (text.contains(kw)) {
          causalHits++;
          break;
        }
      }
    }
    causalityScore = (causalHits * 4).clamp(0, 12) +
        ((answers[3] ?? '').trim().length >= 10 ? 7 : 0) +
        ((answers[4] ?? '').trim().length >= 10 ? 6 : 0);
    causalityScore = causalityScore.clamp(0, 25);

    // ── Personal Explanation (0-25) ──
    final step5 = (answers[5] ?? '').trim();
    int personalHits = 0;
    for (final kw in _personalKeywords) {
      if (step5.contains(kw)) personalHits++;
    }
    explanationScore = (step5.length >= 20
            ? 10
            : step5.length >= 10
                ? 5
                : 0) +
        (personalHits >= 1 ? 8 : 0) +
        ((answers.values.any((t) => t.trim().length >= 30) ? 7 : 0));
    explanationScore = explanationScore.clamp(0, 25);

    final totalScore =
        locationScore + evidenceScore + causalityScore + explanationScore;

    final profile = CivilizationReasoningProfile(
      geographicUnderstanding: locationScore,
      evidenceUsage: evidenceScore,
      historicalCausality: causalityScore,
      personalExplanation: explanationScore,
    );

    return FinalMissionEvaluation(
      locationScore: locationScore,
      evidenceScore: evidenceScore,
      causalityScore: causalityScore,
      explanationScore: explanationScore,
      totalScore: totalScore,
      profile: profile,
      locationLevel: scoreToLevel(locationScore),
      evidenceLevel: scoreToLevel(evidenceScore),
      causalityLevel: scoreToLevel(causalityScore),
      explanationLevel: scoreToLevel(explanationScore),
    );
  }
}

/// Geographic/place keyword set for heuristic scoring
const List<String> _geographicKeywords = [
  '高加索',
  '欧亚',
  '黑海',
  '里海',
  '高加索山脉',
  '欧洲',
  '亚洲',
  '交界',
  '通道',
  '丝路',
  '丝绸之路',
  '俄罗斯',
  '格鲁吉亚',
  '亚美尼亚',
  '阿塞拜疆',
  '博斯普鲁斯',
  '第比利斯',
  '巴库',
  '埃里温',
];

/// Causal connector keyword set
const List<String> _causalKeywords = [
  '因为',
  '所以',
  '因此',
  '由于',
  '导致',
  '使得',
  '从而',
  '这说明',
  '但是',
  '同时',
  '影响',
  '促进',
  '阻碍',
  '形成',
  '产生',
  '引发',
];

/// Personal explanation expression keyword set
const List<String> _personalKeywords = [
  '我认为',
  '我发现',
  '我的解释是',
  '在我看来',
  '这说明',
  '我理解',
  '我的感悟',
  '我的看法',
  '我觉得',
  '我相信',
];

// ───────────────────────────────────────────────────────────────
//  Fake implementations for testing
// ───────────────────────────────────────────────────────────────

class FakeEvaluationService implements EvaluationService {
  final Duration delay;
  final InitialMissionFeedback? initialFeedback;
  final FinalMissionEvaluation? finalEvaluation;

  const FakeEvaluationService({
    this.delay = Duration.zero,
    this.initialFeedback,
    this.finalEvaluation,
  });

  @override
  Future<InitialMissionFeedback> evaluateInitial(
    Map<int, String> answers,
  ) async {
    if (delay > Duration.zero) await Future.delayed(delay);
    return initialFeedback ??
        const InitialMissionFeedback(
          feedbackText: '发现：你已经完成了思考。｜可以加强：可以补充更多证据。｜再想一想：为什么会这样？',
          discovery: '你已经开始了思考。',
          improvement: '可以补充更多证据。',
          nextPrompt: '为什么会这样？',
        );
  }

  @override
  Future<FinalMissionEvaluation> evaluateFinal({
    required Map<int, String> answers,
    required int evidenceCount,
    required int mapDiscoveryCount,
    required int readingEvidenceCount,
  }) async {
    if (delay > Duration.zero) await Future.delayed(delay);
    return finalEvaluation ??
        const FinalMissionEvaluation(
          locationScore: 15,
          evidenceScore: 12,
          causalityScore: 15,
          explanationScore: 12,
          totalScore: 54,
        );
  }
}

class FailingEvaluationService implements EvaluationService {
  const FailingEvaluationService();

  @override
  Future<InitialMissionFeedback> evaluateInitial(
    Map<int, String> answers,
  ) async {
    throw Exception('模拟服务失败');
  }

  @override
  Future<FinalMissionEvaluation> evaluateFinal({
    required Map<int, String> answers,
    required int evidenceCount,
    required int mapDiscoveryCount,
    required int readingEvidenceCount,
  }) async {
    throw Exception('模拟服务失败');
  }
}

// ───────────────────────────────────────────────────────────────
//  Riverpod provider for DI
// ───────────────────────────────────────────────────────────────

final evaluationServiceProvider = Provider<EvaluationService>((ref) {
  return LocalEvaluationService();
});

// ───────────────────────────────────────────────────────────────
//  Legacy static methods (backward compatible, per-step feedback)
// ───────────────────────────────────────────────────────────────

class LegacyEvaluator {
  LegacyEvaluator._();

  /// Per-step feedback generation (used by existing per-step submission)
  static AiFeedback evaluateStep(int stepNumber, String answer) {
    final feedbacks = _stepFeedbacks[stepNumber];
    if (feedbacks == null || feedbacks.length < 2) {
      return _defaultFeedback(stepNumber);
    }
    final length = answer.trim().length;
    final index = length > 20 ? 0 : 1;
    return AiFeedback(
      stepNumber: stepNumber,
      discovery: feedbacks[0],
      improvement: feedbacks[1],
      nextPrompt: _nextPrompts[stepNumber] ?? '',
    );
  }

  /// Legacy profile calculation
  static EvaluationResult calculateProfile(Map<int, String> answers) {
    final stepScores = <int, int>{};
    for (int step = 1; step <= 5; step++) {
      final text = answers[step] ?? '';
      final length = text.trim().length;
      int score;
      if (length > 80) {
        score = (step == 1 || step == 2) ? 22 : 26;
      } else if (length > 40) {
        score = (step == 1 || step == 2) ? 16 : 20;
      } else if (length > 15) {
        score = (step == 1 || step == 2) ? 10 : 14;
      } else {
        score = 4;
      }
      stepScores[step] = score.clamp(0, 30);
    }
    final profile = CivilizationReasoningProfile(
      geographicUnderstanding: (stepScores[1] ?? 0).clamp(0, 25),
      evidenceUsage: (stepScores[2] ?? 0).clamp(0, 25),
      historicalCausality:
          ((stepScores[3] ?? 0) + (stepScores[4] ?? 0) ~/ 2).clamp(0, 30),
      personalExplanation: (stepScores[5] ?? 0).clamp(0, 20),
    );
    return EvaluationResult(profile: profile, stepScores: stepScores);
  }

  static const Map<int, List<String>> _stepFeedbacks = {
    1: [
      '你发现了高加索位于黑海与里海之间的关键地理位置，这是理解其文明交汇作用的基础。',
      '可以更具体地描述高加索的地理位置——它位于哪两个海域之间？',
    ],
    2: [
      '你分析了山脉作为屏障与桥梁的双重作用，以及气候和交通条件对文明交流的影响。',
      '可以加入对高加索山脉如何影响民族迁移和贸易路线的分析。',
    ],
    3: [
      '你提到了多个民族和帝国在高加索的活动，展现了人群互动对文明塑造的重要性。',
      '可以进一步思考：哪些具体的商人或帝国在这里留下了文化痕迹？',
    ],
    4: [
      '你梳理了高加索历史上的战争、迁移和融合，对理解其动态演变很有帮助。',
      '可以加入从古代到近现代的时间线索，让变化脉络更清晰。',
    ],
    5: [
      '你的综合解释展现了良好的文明理解能力——将地理位置、人群互动和历史变化串联在了一起。',
      '可以再提炼一个核心论点，让解释更具说服力。',
    ],
  };

  static const Map<int, String> _nextPrompts = {
    1: '高加索的地理位置如何影响其与周边文明的交流？',
    2: '这里的自然环境如何塑造了当地民族的生活方式？',
    3: '为什么这里能形成多民族共存的格局？',
    4: '丝路贸易对高加索的民族文化格局产生了什么影响？',
    5: '如果能向别人解释高加索文明，你会用哪一句话总结？',
  };

  static AiFeedback _defaultFeedback(int step) {
    return AiFeedback(
      stepNumber: step,
      discovery: '你已经开始思考第 $step 步了。',
      improvement: '尝试结合收集到的证据来展开分析。',
      nextPrompt: '这一步的核心问题是什么？试着回答它。',
    );
  }
}
