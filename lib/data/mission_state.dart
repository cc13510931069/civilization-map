import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ai_feedback.dart';
import '../models/civilization_reasoning_profile.dart';
import '../models/mission_evaluation.dart';
import '../models/exploration_progress.dart';
import 'reading_state.dart';
import '../services/evaluation_service.dart';
import '../services/step_coaching_service.dart';
import '../models/mission_result_snapshot.dart';
import '../models/final_submission_readiness.dart';

// ───────────────────────────────────────────────────────────────
//  最终提交准备状态
// ───────────────────────────────────────────────────────────────

final finalSubmissionReadinessProvider =
    Provider<FinalSubmissionReadiness>((ref) {
  final answers = ref.watch(stepAnswersProvider);
  final evidence = ref.watch(missionEvidenceProvider);
  final stage = ref.watch(missionSubmissionProvider).stage;
  final explorationProgress =
      ref.watch(explorationProgressProvider).forRegion('caucasus');
  final readingEvidence = ref.watch(readingEvidenceProvider);
  final counts = countMissionEvidenceSources(evidence);

  final isSubmitting = stage == MissionSubmissionStage.submittingInitial ||
      stage == MissionSubmissionStage.submittingFinal;

  final eligibility = evaluateFinalSubmissionEligibility(
    answers: answers,
    mapEvidenceCount: counts.mapCount,
    readingEvidenceCount: counts.readingCount,
    isSubmitting: isSubmitting,
  );

  final mapCollected = explorationProgress.collectedIds.isNotEmpty;
  final hasReading = readingEvidence.isNotEmpty;

  final requirements = <SubmissionRequirement>[
    SubmissionRequirement(
      id: 'steps',
      label: '五步思考全部填写',
      completed: eligibility.allStepsValid,
      actionLabel: eligibility.allStepsValid ? null : '去填写',
      actionRoute: eligibility.allStepsValid ? null : 'scroll:steps',
    ),
    SubmissionRequirement(
      id: 'evidence',
      label: '至少收集一条支持解释的证据',
      completed: eligibility.hasAnyEvidence,
    ),
  ];

  final String? primaryBlockingReason =
      eligibility.isSubmitting ? null : eligibility.primaryBlockingMessage;

  String veggieMessage;
  if (eligibility.canSubmit) {
    veggieMessage = '所有条件已满足，可以提交你的文明解释了！';
  } else if (!eligibility.allStepsValid) {
    veggieMessage = '请先完成全部五步思考，再收集证据来支持你的结论。';
  } else if (!eligibility.hasAnyEvidence) {
    veggieMessage = '你的五步思考已经完成。现在从地图探索或精读营中选择一条证据，就可以提交最终评价。';
  } else if (eligibility.hasMapEvidence && !eligibility.hasReadingEvidence) {
    veggieMessage = '你已经有一条地图证据，可以提交最终评价。也可以继续阅读，让解释更丰富。';
  } else if (!eligibility.hasMapEvidence && eligibility.hasReadingEvidence) {
    veggieMessage = '你已经有一条阅读证据，可以提交最终评价。也可以继续探索地图，补充空间观察。';
  } else {
    veggieMessage = '你的证据很丰富，现在可以提交最终评价。';
  }

  return FinalSubmissionReadiness(
    requirements: requirements,
    canSubmit: eligibility.canSubmit,
    primaryBlockingReason: primaryBlockingReason,
    veggieMessage: veggieMessage,
    hasMapEvidence: mapCollected,
    hasReadingEvidence: hasReading,
  );
});
//  当前任务});
//  当前任务
// ───────────────────────────────────────────────────────────────

class Mission {
  final String id;
  final String question;
  final String regionId;
  final String subtitle;

  const Mission({
    required this.id,
    required this.question,
    this.regionId = 'caucasus',
    this.subtitle = '基于收集的证据，完成五步文明解释',
  });
}

final currentMissionProvider = Provider<Mission>((ref) {
  return const Mission(
    id: 'caucasus-mission-1',
    question: '为什么高加索成为文明交汇区域？',
  );
});

// ───────────────────────────────────────────────────────────────
//  五步回答内容
// ───────────────────────────────────────────────────────────────

class StepAnswersNotifier extends StateNotifier<Map<int, String>> {
  StepAnswersNotifier() : super({});

  void updateAnswer(int step, String text) {
    state = Map.from(state)..[step] = text;
  }

  String answerFor(int step) => state[step] ?? '';
  bool hasAnswer(int step) => (state[step] ?? '').trim().isNotEmpty;
  int get answeredCount =>
      state.values.where((t) => t.trim().isNotEmpty).length;
  bool get allAnswered => [1, 2, 3, 4, 5].every((s) => hasAnswer(s));
}

final stepAnswersProvider =
    StateNotifierProvider<StepAnswersNotifier, Map<int, String>>(
  (ref) => StepAnswersNotifier(),
);

// ───────────────────────────────────────────────────────────────
//  当前活跃步骤
// ───────────────────────────────────────────────────────────────

final activeStepProvider = StateProvider<int>((ref) => 1);

// ───────────────────────────────────────────────────────────────
//  AI 反馈（每步一条）
// ───────────────────────────────────────────────────────────────

final stepFeedbacksProvider = StateProvider<Map<int, AiFeedback>>((ref) => {});

void addStepFeedback(WidgetRef ref, int step, AiFeedback feedback) {
  final current = ref.read(stepFeedbacksProvider);
  ref.read(stepFeedbacksProvider.notifier).state = {
    ...current,
    step: feedback,
  };
}

bool hasStepFeedback(WidgetRef ref, int step) {
  return ref.read(stepFeedbacksProvider).containsKey(step);
}

// ───────────────────────────────────────────────────────────────
//  评价画像（已完成的最终评价）
// ───────────────────────────────────────────────────────────────

final reasoningProfileProvider =
    StateProvider<CivilizationReasoningProfile?>((ref) => null);

// ───────────────────────────────────────────────────────────────
//  已收集的证据（从探索进度读取）
// ───────────────────────────────────────────────────────────────

final missionEvidenceProvider = Provider<Map<String, String>>((ref) {
  final progress = ref.watch(explorationProgressProvider).forRegion('caucasus');
  final readingEvidence = ref.watch(readingEvidenceProvider);
  final collected = progress.collectedIds;
  final allPoints = DiscoveryPoint.caucasus;

  final result = <String, String>{};
  for (final point in allPoints) {
    if (collected.contains(point.id)) {
      result[point.id] = point.name;
    }
  }
  for (final ev in readingEvidence) {
    final short =
        ev.text.length > 25 ? '${ev.text.substring(0, 25)}...' : ev.text;
    result['reading:${ev.id}'] = short;
  }
  return result;
});

/// 地图证据（探索发现）数量
final mapEvidenceCountProvider = Provider<int>((ref) {
  final progress = ref.watch(explorationProgressProvider).forRegion('caucasus');
  return progress.collectedIds.length;
});

// ───────────────────────────────────────────────────────────────
//  提交状态机
// ───────────────────────────────────────────────────────────────

/// 提交阶段
enum MissionSubmissionStage {
  draft,
  submittingInitial,
  initialFeedback,
  revisionReady,
  submittingFinal,
  completed,
  failure,
}

/// 提交失败的来源
enum MissionSubmissionAttempt { initial, finalEvaluation }

/// 验证结果
class MissionValidationResult {
  final bool isValid;
  final List<int> missingSteps;
  final String? message;

  const MissionValidationResult({
    this.isValid = false,
    this.missingSteps = const [],
    this.message,
  });
}

/// 提交状态
class MissionSubmissionState {
  final MissionSubmissionStage stage;
  final String? initialFeedbackText;
  final FinalMissionEvaluation? finalEvaluation;
  final String? errorMessage;
  final Map<int, String> lastSubmittedAnswers;
  final int submissionVersion;
  final bool hasUnsavedChanges;
  final DateTime? submittedAt;
  final String? previousFeedbackText;
  final MissionSubmissionAttempt? failedAttempt;

  const MissionSubmissionState({
    this.stage = MissionSubmissionStage.draft,
    this.initialFeedbackText,
    this.finalEvaluation,
    this.errorMessage,
    this.lastSubmittedAnswers = const {},
    this.submissionVersion = 0,
    this.hasUnsavedChanges = false,
    this.submittedAt,
    this.previousFeedbackText,
    this.failedAttempt,
  });

  MissionSubmissionState copyWith({
    MissionSubmissionStage? stage,
    String? initialFeedbackText,
    FinalMissionEvaluation? finalEvaluation,
    String? errorMessage,
    Map<int, String>? lastSubmittedAnswers,
    int? submissionVersion,
    bool? hasUnsavedChanges,
    DateTime? submittedAt,
    String? previousFeedbackText,
    MissionSubmissionAttempt? failedAttempt,
    bool clearInitialFeedback = false,
    bool clearFinalEvaluation = false,
    bool clearError = false,
  }) {
    return MissionSubmissionState(
      stage: stage ?? this.stage,
      initialFeedbackText: clearInitialFeedback
          ? null
          : (initialFeedbackText ?? this.initialFeedbackText),
      finalEvaluation: clearFinalEvaluation
          ? null
          : (finalEvaluation ?? this.finalEvaluation),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      lastSubmittedAnswers: lastSubmittedAnswers ?? this.lastSubmittedAnswers,
      submissionVersion: submissionVersion ?? this.submissionVersion,
      hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
      submittedAt: submittedAt ?? this.submittedAt,
      previousFeedbackText: previousFeedbackText ?? this.previousFeedbackText,
      failedAttempt: failedAttempt ?? this.failedAttempt,
    );
  }
}

class MissionSubmissionNotifier extends StateNotifier<MissionSubmissionState> {
  final Ref _ref;

  MissionSubmissionNotifier(this._ref) : super(const MissionSubmissionState());

  /// 验证五步回答
  MissionValidationResult validateAnswers(Map<int, String> answers) {
    final missing = <int>[];
    for (int i = 1; i <= 5; i++) {
      final text = (answers[i] ?? '').trim();
      if (text.length < 6) {
        missing.add(i);
      }
    }
    if (missing.isEmpty) {
      return const MissionValidationResult(isValid: true);
    }
    return MissionValidationResult(
      isValid: false,
      missingSteps: missing,
      message: '请完善以下步骤后再提交：步骤 ${missing.join("、")}',
    );
  }

  /// 获取当前答案（从 Provider 读取）
  Map<int, String> _currentAnswers() {
    return _ref.read(stepAnswersProvider);
  }

  /// 初步提交
  Future<void> submitInitial() async {
    if (state.stage == MissionSubmissionStage.submittingInitial ||
        state.stage == MissionSubmissionStage.completed ||
        state.stage == MissionSubmissionStage.submittingFinal) {
      return; // prevent double submit
    }

    final answers = _currentAnswers();
    final validation = validateAnswers(answers);
    if (!validation.isValid) {
      state = state.copyWith(
        stage: MissionSubmissionStage.draft,
        errorMessage: validation.message,
      );
      return;
    }

    state = state.copyWith(
      stage: MissionSubmissionStage.submittingInitial,
      clearError: true,
    );

    try {
      final service = _ref.read(evaluationServiceProvider);
      final feedback = await service.evaluateInitial(answers);

      state = state.copyWith(
        stage: MissionSubmissionStage.initialFeedback,
        initialFeedbackText: feedback.feedbackText,
        lastSubmittedAnswers: Map.from(answers),
        hasUnsavedChanges: false,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        stage: MissionSubmissionStage.failure,
        errorMessage: '提交失败：${e.toString()}',
        hasUnsavedChanges: false,
        failedAttempt: MissionSubmissionAttempt.initial,
      );
    }
  }

  Future<void> submitFinal() async {
    if (state.stage == MissionSubmissionStage.submittingInitial ||
        state.stage == MissionSubmissionStage.completed ||
        state.stage == MissionSubmissionStage.submittingFinal) {
      return;
    }

    final answers = _currentAnswers();
    final currentStage = state.stage;
    final isSubmitting =
        currentStage == MissionSubmissionStage.submittingInitial ||
            currentStage == MissionSubmissionStage.submittingFinal;
    final evidence = _ref.read(missionEvidenceProvider);
    final counts = countMissionEvidenceSources(evidence);

    final eligibility = evaluateFinalSubmissionEligibility(
      answers: answers,
      mapEvidenceCount: counts.mapCount,
      readingEvidenceCount: counts.readingCount,
      isSubmitting: isSubmitting,
    );

    if (!eligibility.canSubmit) {
      state = state.copyWith(
        errorMessage: eligibility.primaryBlockingMessage,
      );
      return;
    }

    state = state.copyWith(
      stage: MissionSubmissionStage.submittingFinal,
      clearError: true,
    );

    try {
      final service = _ref.read(evaluationServiceProvider);

      final evaluation = await service.evaluateFinal(
        answers: answers,
        evidenceCount: evidence.length,
        mapDiscoveryCount: counts.mapCount,
        readingEvidenceCount: counts.readingCount,
      );

      // Save profile
      if (evaluation.profile != null) {
        _ref.read(reasoningProfileProvider.notifier).state = evaluation.profile;
      }

      final newVersion = state.submissionVersion + 1;
      final snapshot = MissionResultSnapshot(
        missionId: _ref.read(currentMissionProvider).id,
        answers: Map.from(answers),
        evidenceIds: evidence.keys.toList(),
        mapDiscoveryCount: counts.mapCount,
        readingEvidenceCount: counts.readingCount,
        personalExplanation: (answers[5] ?? '').trim(),
        evaluation: evaluation,
        submittedAt: DateTime.now(),
        submissionVersion: newVersion,
      );
      _ref.read(missionResultSnapshotProvider.notifier).state = snapshot;

      state = state.copyWith(
        stage: MissionSubmissionStage.completed,
        finalEvaluation: evaluation,
        lastSubmittedAnswers: Map.from(answers),
        hasUnsavedChanges: false,
        submissionVersion: newVersion,
        submittedAt: snapshot.submittedAt,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        stage: MissionSubmissionStage.failure,
        errorMessage: '提交失败：${e.toString()}',
        failedAttempt: MissionSubmissionAttempt.finalEvaluation,
      );
    }
  }

  /// 根据失败来源重新提交
  Future<void> retrySubmission() async {
    final attempt = state.failedAttempt;
    if (attempt == null) {
      state = state.copyWith(
        errorMessage: '没有需要重试的提交。',
      );
      return;
    }
    if (attempt == MissionSubmissionAttempt.initial) {
      await submitInitial();
    } else {
      await submitFinal();
    }
  }

  /// 标记答案已修改（任何步骤变更或证据增减）
  void markModified() {
    if (state.stage == MissionSubmissionStage.completed ||
        state.stage == MissionSubmissionStage.initialFeedback) {
      state = state.copyWith(
        stage: MissionSubmissionStage.revisionReady,
        hasUnsavedChanges: true,
        previousFeedbackText: state.initialFeedbackText,
      );
    } else if (state.stage == MissionSubmissionStage.draft) {
      // no stage change, just mark
    } else if (state.stage == MissionSubmissionStage.failure) {
      // stay in failure until explicitly retried
    }
  }

  /// 重置为草稿（用于测试）
  void reset() {
    state = const MissionSubmissionState();
  }
}

final missionSubmissionProvider =
    StateNotifierProvider<MissionSubmissionNotifier, MissionSubmissionState>(
  (ref) => MissionSubmissionNotifier(ref),
);

// ───────────────────────────────────────────────────────────────
//  是否可提交初步思考
// ───────────────────────────────────────────────────────────────

final canSubmitInitialProvider = Provider<bool>((ref) {
  final answers = ref.watch(stepAnswersProvider);
  final stage = ref.watch(missionSubmissionProvider).stage;
  final coaching = ref.watch(stepCoachingProvider);
  if (stage == MissionSubmissionStage.submittingInitial ||
      stage == MissionSubmissionStage.submittingFinal) {
    return false;
  }
  final allStepsValid =
      [1, 2, 3, 4, 5].every((s) => ((answers[s] ?? '').trim().length >= 6));
  final hasSkipped =
      coaching.values.any((s) => s.stage == StepCoachingStage.skipped);
  return allStepsValid && !hasSkipped;
});

// ───────────────────────────────────────────────────────────────
//  是否可提交完善后的解释
// ───────────────────────────────────────────────────────────────

final canSubmitFinalProvider = Provider<bool>((ref) {
  final answers = ref.watch(stepAnswersProvider);
  final evidence = ref.watch(missionEvidenceProvider);
  final stage = ref.watch(missionSubmissionProvider).stage;
  if (stage == MissionSubmissionStage.submittingInitial ||
      stage == MissionSubmissionStage.submittingFinal) {
    return false;
  }
  final allStepsValid =
      [1, 2, 3, 4, 5].every((s) => ((answers[s] ?? '').trim().length >= 6));
  if (!allStepsValid) return false;
  if (evidence.isEmpty) return false;
  final step5 = (answers[5] ?? '').trim();
  return step5.length >= 6;
});

// ───────────────────────────────────────────────────────────────
//  最终评价结果（供 MyMap 读取）
// ───────────────────────────────────────────────────────────────

final missionFinalEvaluationProvider = Provider<FinalMissionEvaluation?>((ref) {
  final submission = ref.watch(missionSubmissionProvider);
  if (submission.stage == MissionSubmissionStage.completed) {
    return submission.finalEvaluation;
  }
  return null;
});

// ───────────────────────────────────────────────────────────────
//  完成状态（供 MyMap 读取）
// ───────────────────────────────────────────────────────────────

final missionCompletedProvider = Provider<bool>((ref) {
  return ref.watch(missionSubmissionProvider).stage ==
      MissionSubmissionStage.completed;
});

// ───────────────────────────────────────────────────────────────
//  正式成果快照（只在最终提交成功后写入）
// ───────────────────────────────────────────────────────────────

final missionResultSnapshotProvider =
    StateProvider<MissionResultSnapshot?>((ref) => null);

// ───────────────────────────────────────────────────────────────
//  单步辅导（StepCoachingNotifier）
// ───────────────────────────────────────────────────────────────

/// 将证据条目转换为 StepCoachingEvidence
StepCoachingEvidence _convertEvidence(MapEntry<String, String> entry) {
  final isReading = entry.key.startsWith('reading:');
  return StepCoachingEvidence(
    id: entry.key,
    type: isReading ? '阅读证据' : '地图发现',
    text: entry.value,
    source: isReading ? '精读营' : '探索地图',
  );
}

class StepCoachingNotifier extends StateNotifier<Map<int, StepCoachingState>> {
  final Ref _ref;

  StepCoachingNotifier(this._ref)
      : super({for (int i = 1; i <= 5; i++) i: StepCoachingState(step: i)});

  Future<void> submitStep(int step, String question, String answer) async {
    final existing = state[step] ?? StepCoachingState(step: step);
    if (existing.stage == StepCoachingStage.submitting) return;

    state = {
      ...state,
      step: existing.copyWith(
        stage: StepCoachingStage.submitting,
        submittedAnswer: answer,
      ),
    };

    try {
      final service = _ref.read(stepCoachingServiceProvider);
      final evidence = _ref.read(missionEvidenceProvider);
      final evidenceList = evidence.entries.map(_convertEvidence).toList();
      final revisionNum = existing.revisionNumber + 1;

      final feedback = await service.evaluateStep(
        step: step,
        question: question,
        answer: answer,
        evidence: evidenceList,
        revisionNumber: revisionNum,
      );

      state = {
        ...state,
        step: existing.copyWith(
          stage: StepCoachingStage.feedbackReady,
          latestFeedback: feedback,
          revisionNumber: revisionNum,
          clearHint: true,
        ),
      };
    } catch (e) {
      state = {
        ...state,
        step: existing.copyWith(
          stage: StepCoachingStage.failure,
          errorMessage: e.toString(),
        ),
      };
    }
  }

  void requestHint(int step) {
    final existing = state[step] ?? StepCoachingState(step: step);
    final newLevel = existing.currentHintLevel + 1;
    final service = _ref.read(stepCoachingServiceProvider);
    final hint = service.getHint(step: step, hintLevel: newLevel);
    state = {
      ...state,
      step: existing.copyWith(
        stage: StepCoachingStage.hintShown,
        currentHintLevel: newLevel,
        latestHint: hint,
      ),
    };
  }

  void skipStep(int step) {
    final existing = state[step] ?? StepCoachingState(step: step);
    state = {
      ...state,
      step: existing.copyWith(stage: StepCoachingStage.skipped),
    };
  }

  void unskipStep(int step) {
    final existing = state[step] ?? StepCoachingState(step: step);
    state = {
      ...state,
      step: existing.copyWith(stage: StepCoachingStage.drafting),
    };
  }

  void markModified(int step) {
    final existing = state[step] ?? StepCoachingState(step: step);
    if (existing.stage == StepCoachingStage.feedbackReady) {
      state = {
        ...state,
        step: existing.copyWith(
          stage: StepCoachingStage.needsRevision,
          hasChangesAfterFeedback: true,
        ),
      };
    }
  }
}

final stepCoachingProvider =
    StateNotifierProvider<StepCoachingNotifier, Map<int, StepCoachingState>>(
  (ref) => StepCoachingNotifier(ref),
);
