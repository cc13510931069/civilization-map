import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/data/mission_state.dart';
import '../lib/models/civilization_reasoning_profile.dart';
import '../lib/models/exploration_progress.dart';
import '../lib/models/mission_result_snapshot.dart';
import '../lib/services/evaluation_service.dart';
import '../lib/models/mission_evaluation.dart';
import '../lib/services/step_coaching_service.dart';
import '../lib/theme/app_theme.dart';
import '../lib/screens/mission_screen.dart';
import '../lib/models/thinking_step.dart';

// ── Test helpers ──

void fillFive(ProviderContainer c) {
  c.read(stepAnswersProvider.notifier)
    ..updateAnswer(1, '高加索位于欧亚交界处，在黑海与里海之间。')
    ..updateAnswer(2, '高加索山脉横亘其中，既是屏障也是桥梁。')
    ..updateAnswer(3, '多个民族和帝国在这里活动。')
    ..updateAnswer(4, '历史上有战争、迁移和融合。')
    ..updateAnswer(5, '我认为高加索因其地理位置成为文明交汇点。');
}

void addEvidence(ProviderContainer c) {
  c
      .read(explorationProgressProvider.notifier)
      .collectDiscovery('caucasus', 'black-sea');
}

FinalMissionEvaluation makeEval(
    {int loc = 15, int ev = 12, int caus = 15, int exp = 12}) {
  String l(int s) => s >= 22
      ? '深入'
      : s >= 16
          ? '清晰'
          : s >= 10
              ? '发展中'
              : '起步';
  return FinalMissionEvaluation(
    locationScore: loc,
    evidenceScore: ev,
    causalityScore: caus,
    explanationScore: exp,
    totalScore: loc + ev + caus + exp,
    profile: CivilizationReasoningProfile(
        geographicUnderstanding: loc,
        evidenceUsage: ev,
        historicalCausality: caus,
        personalExplanation: exp),
    locationLevel: l(loc),
    evidenceLevel: l(ev),
    causalityLevel: l(caus),
    explanationLevel: l(exp),
  );
}

ProviderContainer makeContainer({List<Override>? extra}) {
  return ProviderContainer(overrides: [
    evaluationServiceProvider.overrideWithValue(const FakeEvaluationService()),
    if (extra != null) ...extra,
  ]);
}

void main() {
  // ══════════════════════════════════════════════════════════
  // A. Mission validation
  // ══════════════════════════════════════════════════════════
  group('A. Mission validation', () {
    testWidgets('A1 Empty blocks initial submit', (tester) async {
      final c = ProviderContainer();
      addTearDown(() => c.dispose());
      expect(c.read(canSubmitInitialProvider), isFalse);
    });
    testWidgets('A2 Partial blocks initial submit', (tester) async {
      final c = ProviderContainer();
      addTearDown(() => c.dispose());
      c.read(stepAnswersProvider.notifier).updateAnswer(1, 'a');
      expect(c.read(canSubmitInitialProvider), isFalse);
    });
    testWidgets('A3 Spaces treated as empty', (tester) async {
      final c = ProviderContainer();
      addTearDown(() => c.dispose());
      c.read(stepAnswersProvider.notifier).updateAnswer(1, '   \n  ');
      expect(c.read(canSubmitInitialProvider), isFalse);
    });
    testWidgets('A4 Five valid enables submit', (tester) async {
      final c = makeContainer();
      addTearDown(() => c.dispose());
      fillFive(c);
      expect(c.read(canSubmitInitialProvider), isTrue);
    });
    testWidgets('A5 Skipped blocks submit', (tester) async {
      final c = makeContainer();
      addTearDown(() => c.dispose());
      fillFive(c);
      c.read(stepCoachingProvider.notifier).skipStep(1);
      expect(c.read(canSubmitInitialProvider), isFalse);
    });
    testWidgets('A6 Skipped text >6 still blocks', (tester) async {
      final c = makeContainer();
      addTearDown(() => c.dispose());
      fillFive(c);
      c
          .read(stepAnswersProvider.notifier)
          .updateAnswer(1, 'long enough text here');
      c.read(stepCoachingProvider.notifier).skipStep(1);
      expect(c.read(canSubmitInitialProvider), isFalse);
    });
  });

  // ══════════════════════════════════════════════════════════
  // B. Initial submission
  // ══════════════════════════════════════════════════════════
  group('B. Initial submission', () {
    testWidgets('B7 Submit goes to submittingInitial', (tester) async {
      final c = makeContainer();
      addTearDown(() => c.dispose());
      fillFive(c);
      c.read(missionSubmissionProvider.notifier).submitInitial();
      expect(c.read(missionSubmissionProvider).stage,
          MissionSubmissionStage.submittingInitial);
    });
    testWidgets('B8 Success goes to initialFeedback', (tester) async {
      final c = makeContainer();
      addTearDown(() => c.dispose());
      fillFive(c);
      c.read(missionSubmissionProvider.notifier).submitInitial();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1));
      expect(c.read(missionSubmissionProvider).stage,
          MissionSubmissionStage.initialFeedback);
    });
    testWidgets('B9 Initial has no final score', (tester) async {
      final c = makeContainer();
      addTearDown(() => c.dispose());
      fillFive(c);
      c.read(missionSubmissionProvider.notifier).submitInitial();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1));
      expect(c.read(missionSubmissionProvider).finalEvaluation, isNull);
    });
    testWidgets('B10 Initial feedback contains discovery', (tester) async {
      final c = makeContainer();
      addTearDown(() => c.dispose());
      fillFive(c);
      c.read(missionSubmissionProvider.notifier).submitInitial();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1));
      expect(c.read(missionSubmissionProvider).initialFeedbackText,
          contains('发现'));
    });
    testWidgets('B11 Initial feedback contains improvement', (tester) async {
      final c = makeContainer();
      addTearDown(() => c.dispose());
      fillFive(c);
      c.read(missionSubmissionProvider.notifier).submitInitial();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1));
      expect(c.read(missionSubmissionProvider).initialFeedbackText,
          contains('可以加强'));
    });
    testWidgets('B12 Initial feedback contains next prompt', (tester) async {
      final c = makeContainer();
      addTearDown(() => c.dispose());
      fillFive(c);
      c.read(missionSubmissionProvider.notifier).submitInitial();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1));
      expect(c.read(missionSubmissionProvider).initialFeedbackText,
          contains('再想一想'));
    });
    testWidgets('B13 Initial needs no evidence', (tester) async {
      final c = makeContainer();
      addTearDown(() => c.dispose());
      fillFive(c);
      expect(c.read(canSubmitInitialProvider), isTrue);
    });
  });

  // ══════════════════════════════════════════════════════════
  // C. Final submission
  // ══════════════════════════════════════════════════════════
  group('C. Final submission', () {
    testWidgets('C14 No evidence blocks final', (tester) async {
      final c = makeContainer();
      addTearDown(() => c.dispose());
      fillFive(c);
      expect(c.read(canSubmitFinalProvider), isFalse);
    });
    testWidgets('C15 With evidence final enabled', (tester) async {
      final c = makeContainer();
      addTearDown(() => c.dispose());
      fillFive(c);
      addEvidence(c);
      expect(c.read(canSubmitFinalProvider), isTrue);
    });
    testWidgets('C16 Final submit reaches completed', (tester) async {
      final c = ProviderContainer(overrides: [
        evaluationServiceProvider.overrideWithValue(
            FakeEvaluationService(finalEvaluation: makeEval())),
      ]);
      addTearDown(() => c.dispose());
      fillFive(c);
      addEvidence(c);
      await c.read(missionSubmissionProvider.notifier).submitFinal();
      expect(c.read(missionSubmissionProvider).stage,
          MissionSubmissionStage.completed);
    });
    testWidgets('C17 Scores in 0-25', (tester) async {
      final c = ProviderContainer(overrides: [
        evaluationServiceProvider.overrideWithValue(
            FakeEvaluationService(finalEvaluation: makeEval())),
      ]);
      addTearDown(() => c.dispose());
      fillFive(c);
      addEvidence(c);
      await c.read(missionSubmissionProvider.notifier).submitFinal();
      final e = c.read(missionSubmissionProvider).finalEvaluation!;
      expect(e.locationScore, inInclusiveRange(0, 25));
      expect(e.evidenceScore, inInclusiveRange(0, 25));
      expect(e.causalityScore, inInclusiveRange(0, 25));
      expect(e.explanationScore, inInclusiveRange(0, 25));
    });
    testWidgets('C18 Total equals sum', (tester) async {
      final c = ProviderContainer(overrides: [
        evaluationServiceProvider.overrideWithValue(
            FakeEvaluationService(finalEvaluation: makeEval())),
      ]);
      addTearDown(() => c.dispose());
      fillFive(c);
      addEvidence(c);
      await c.read(missionSubmissionProvider.notifier).submitFinal();
      final e = c.read(missionSubmissionProvider).finalEvaluation!;
      expect(
          e.totalScore,
          e.locationScore +
              e.evidenceScore +
              e.causalityScore +
              e.explanationScore);
    });
  });

  // ══════════════════════════════════════════════════════════
  // D. Failure and retry
  // ══════════════════════════════════════════════════════════
  group('D. Failure and retry', () {
    testWidgets('D19 Initial failure records attempt', (tester) async {
      final c = ProviderContainer(overrides: [
        evaluationServiceProvider
            .overrideWithValue(const FailingEvaluationService()),
      ]);
      addTearDown(() => c.dispose());
      fillFive(c);
      c.read(missionSubmissionProvider.notifier).submitInitial();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1));
      expect(c.read(missionSubmissionProvider).failedAttempt,
          MissionSubmissionAttempt.initial);
    });
    testWidgets('D20 Initial failure keeps answers', (tester) async {
      final c = ProviderContainer(overrides: [
        evaluationServiceProvider
            .overrideWithValue(const FailingEvaluationService()),
      ]);
      addTearDown(() => c.dispose());
      fillFive(c);
      c.read(missionSubmissionProvider.notifier).submitInitial();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1));
      expect(c.read(stepAnswersProvider).length, 5);
    });
    testWidgets('D21 Final failure records attempt', (tester) async {
      final c = ProviderContainer(overrides: [
        evaluationServiceProvider
            .overrideWithValue(const FailingEvaluationService()),
      ]);
      addTearDown(() => c.dispose());
      fillFive(c);
      addEvidence(c);
      c.read(missionSubmissionProvider.notifier).submitFinal();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1));
      expect(c.read(missionSubmissionProvider).failedAttempt,
          MissionSubmissionAttempt.finalEvaluation);
    });
    testWidgets('D22 Final failure keeps answers', (tester) async {
      final c = ProviderContainer(overrides: [
        evaluationServiceProvider
            .overrideWithValue(const FailingEvaluationService()),
      ]);
      addTearDown(() => c.dispose());
      fillFive(c);
      addEvidence(c);
      c.read(missionSubmissionProvider.notifier).submitFinal();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1));
      expect(c.read(stepAnswersProvider).length, 5);
    });
    testWidgets('D23 Final failure no version increment', (tester) async {
      final c = ProviderContainer(overrides: [
        evaluationServiceProvider
            .overrideWithValue(const FailingEvaluationService()),
      ]);
      addTearDown(() => c.dispose());
      fillFive(c);
      addEvidence(c);
      expect(c.read(missionSubmissionProvider).submissionVersion, 0);
      c.read(missionSubmissionProvider.notifier).submitFinal();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1));
      expect(c.read(missionSubmissionProvider).submissionVersion, 0);
    });
  });

  // ══════════════════════════════════════════════════════════
  // E. Snapshot
  // ══════════════════════════════════════════════════════════
  group('E. Snapshot', () {
    testWidgets('E24 Draft no snapshot', (tester) async {
      final c = ProviderContainer();
      addTearDown(() => c.dispose());
      fillFive(c);
      expect(c.read(missionResultSnapshotProvider), isNull);
    });
    testWidgets('E25 Initial no snapshot', (tester) async {
      final c = makeContainer();
      addTearDown(() => c.dispose());
      fillFive(c);
      c.read(missionSubmissionProvider.notifier).submitInitial();
      expect(c.read(missionResultSnapshotProvider), isNull);
    });
    testWidgets('E26 Final creates snapshot', (tester) async {
      final c = ProviderContainer(overrides: [
        evaluationServiceProvider.overrideWithValue(
            FakeEvaluationService(finalEvaluation: makeEval())),
      ]);
      addTearDown(() => c.dispose());
      fillFive(c);
      addEvidence(c);
      await c.read(missionSubmissionProvider.notifier).submitFinal();
      expect(c.read(missionResultSnapshotProvider), isNotNull);
    });
    testWidgets('E27 Snapshot has answers', (tester) async {
      final c = ProviderContainer(overrides: [
        evaluationServiceProvider.overrideWithValue(
            FakeEvaluationService(finalEvaluation: makeEval())),
      ]);
      addTearDown(() => c.dispose());
      fillFive(c);
      addEvidence(c);
      await c.read(missionSubmissionProvider.notifier).submitFinal();
      expect(c.read(missionResultSnapshotProvider)!.answers.length, 5);
    });
    testWidgets('E28 Snapshot has evaluation', (tester) async {
      final c = ProviderContainer(overrides: [
        evaluationServiceProvider.overrideWithValue(
            FakeEvaluationService(finalEvaluation: makeEval())),
      ]);
      addTearDown(() => c.dispose());
      fillFive(c);
      addEvidence(c);
      await c.read(missionSubmissionProvider.notifier).submitFinal();
      expect(c.read(missionResultSnapshotProvider)!.evaluation.totalScore,
          greaterThan(0));
    });
    testWidgets('E29 Draft changes keep old snapshot', (tester) async {
      final c = ProviderContainer(overrides: [
        evaluationServiceProvider.overrideWithValue(
            FakeEvaluationService(finalEvaluation: makeEval())),
      ]);
      addTearDown(() => c.dispose());
      fillFive(c);
      addEvidence(c);
      await c.read(missionSubmissionProvider.notifier).submitFinal();
      final snap1 = c.read(missionResultSnapshotProvider)!;
      c.read(stepAnswersProvider.notifier).updateAnswer(1, 'modified');
      expect(
          c.read(missionResultSnapshotProvider)!.answers[1], snap1.answers[1]);
    });
  });

  // ══════════════════════════════════════════════════════════
  // F. Step coaching
  // ══════════════════════════════════════════════════════════
  group('F. Step coaching', () {
    testWidgets('F30 Step1 question', (tester) async {
      final svc = FakeStepCoachingService();
      final c = ProviderContainer(
          overrides: [stepCoachingServiceProvider.overrideWithValue(svc)]);
      addTearDown(() => c.dispose());
      await c
          .read(stepCoachingProvider.notifier)
          .submitStep(1, '在哪里？', '高加索在欧亚之间。');
      expect(svc.lastQuestion, '在哪里？');
    });
    testWidgets('F31 Step2 question', (tester) async {
      final svc = FakeStepCoachingService();
      final c = ProviderContainer(
          overrides: [stepCoachingServiceProvider.overrideWithValue(svc)]);
      addTearDown(() => c.dispose());
      await c
          .read(stepCoachingProvider.notifier)
          .submitStep(2, '有什么条件？', '有山脉。');
      expect(svc.lastQuestion, '有什么条件？');
    });
    testWidgets('F32 Step3 question', (tester) async {
      final svc = FakeStepCoachingService();
      final c = ProviderContainer(
          overrides: [stepCoachingServiceProvider.overrideWithValue(svc)]);
      addTearDown(() => c.dispose());
      await c
          .read(stepCoachingProvider.notifier)
          .submitStep(3, '谁在那里活动？', '多个民族。');
      expect(svc.lastQuestion, '谁在那里活动？');
    });
    testWidgets('F33 Step4 question', (tester) async {
      final svc = FakeStepCoachingService();
      final c = ProviderContainer(
          overrides: [stepCoachingServiceProvider.overrideWithValue(svc)]);
      addTearDown(() => c.dispose());
      await c
          .read(stepCoachingProvider.notifier)
          .submitStep(4, '发生了什么变化？', '历史变化。');
      expect(svc.lastQuestion, '发生了什么变化？');
    });
    testWidgets('F34 Step5 question', (tester) async {
      final svc = FakeStepCoachingService();
      final c = ProviderContainer(
          overrides: [stepCoachingServiceProvider.overrideWithValue(svc)]);
      addTearDown(() => c.dispose());
      await c
          .read(stepCoachingProvider.notifier)
          .submitStep(5, '我的解释是什么？', '因为地理位置。');
      expect(svc.lastQuestion, '我的解释是什么？');
    });
    testWidgets('F35 Service receives answer', (tester) async {
      final svc = FakeStepCoachingService();
      final c = ProviderContainer(
          overrides: [stepCoachingServiceProvider.overrideWithValue(svc)]);
      addTearDown(() => c.dispose());
      await c
          .read(stepCoachingProvider.notifier)
          .submitStep(1, '', '高加索在欧亚交界处。');
      expect(svc.lastAnswer, '高加索在欧亚交界处。');
    });
    testWidgets('F36 First revision is 1', (tester) async {
      final svc = FakeStepCoachingService();
      final c = ProviderContainer(
          overrides: [stepCoachingServiceProvider.overrideWithValue(svc)]);
      addTearDown(() => c.dispose());
      await c.read(stepCoachingProvider.notifier).submitStep(1, '', 'test');
      expect(svc.lastRevisionNumber, 1);
    });
    testWidgets('F37 Second revision is 2', (tester) async {
      final svc = FakeStepCoachingService();
      final c = ProviderContainer(
          overrides: [stepCoachingServiceProvider.overrideWithValue(svc)]);
      addTearDown(() => c.dispose());
      await c.read(stepCoachingProvider.notifier).submitStep(1, '', 'first');
      await c.read(stepCoachingProvider.notifier).submitStep(1, '', 'second');
      expect(svc.lastRevisionNumber, 2);
    });
    testWidgets('F38 Third revision is 3', (tester) async {
      final svc = FakeStepCoachingService();
      final c = ProviderContainer(
          overrides: [stepCoachingServiceProvider.overrideWithValue(svc)]);
      addTearDown(() => c.dispose());
      await c.read(stepCoachingProvider.notifier).submitStep(1, '', 't1');
      await c.read(stepCoachingProvider.notifier).submitStep(1, '', 't2');
      await c.read(stepCoachingProvider.notifier).submitStep(1, '', 't3');
      expect(svc.lastRevisionNumber, 3);
    });
    testWidgets('F39 Hint no revision change', (tester) async {
      final c = ProviderContainer();
      addTearDown(() => c.dispose());
      c.read(stepCoachingProvider.notifier).requestHint(1);
      expect(c.read(stepCoachingProvider)[1]?.revisionNumber, 0);
    });
    testWidgets('F40 Skip no revision change', (tester) async {
      final c = ProviderContainer();
      addTearDown(() => c.dispose());
      c.read(stepCoachingProvider.notifier).skipStep(1);
      expect(c.read(stepCoachingProvider)[1]?.revisionNumber, 0);
    });
    testWidgets('F41 Coaching does not create snapshot', (tester) async {
      final c = makeContainer();
      addTearDown(() => c.dispose());
      await c.read(stepCoachingProvider.notifier).submitStep(1, '', 'test');
      expect(c.read(missionResultSnapshotProvider), isNull);
    });
    testWidgets('F42 Coaching does not increase version', (tester) async {
      final c = makeContainer();
      addTearDown(() => c.dispose());
      await c.read(stepCoachingProvider.notifier).submitStep(1, '', 'test');
      expect(c.read(missionSubmissionProvider).submissionVersion, 0);
    });
  });

  // ══════════════════════════════════════════════════════════
  // G. Hints and skip
  // ══════════════════════════════════════════════════════════
  group('G. Hints and skip', () {
    testWidgets('G43 First hint level 1', (tester) async {
      final c = ProviderContainer();
      addTearDown(() => c.dispose());
      c.read(stepCoachingProvider.notifier).requestHint(1);
      expect(c.read(stepCoachingProvider)[1]?.currentHintLevel, 1);
    });
    testWidgets('G44 Second hint level 2', (tester) async {
      final c = ProviderContainer();
      addTearDown(() => c.dispose());
      c.read(stepCoachingProvider.notifier).requestHint(1);
      c.read(stepCoachingProvider.notifier).requestHint(1);
      expect(c.read(stepCoachingProvider)[1]?.currentHintLevel, 2);
    });
    testWidgets('G45 Third hint level 3', (tester) async {
      final c = ProviderContainer();
      addTearDown(() => c.dispose());
      c.read(stepCoachingProvider.notifier).requestHint(1);
      c.read(stepCoachingProvider.notifier).requestHint(1);
      c.read(stepCoachingProvider.notifier).requestHint(1);
      expect(c.read(stepCoachingProvider)[1]?.currentHintLevel, 3);
    });
    testWidgets('G46 Skip preserves draft', (tester) async {
      final c = ProviderContainer();
      addTearDown(() => c.dispose());
      c.read(stepAnswersProvider.notifier).updateAnswer(1, '草稿内容');
      c.read(stepCoachingProvider.notifier).skipStep(1);
      expect(c.read(stepAnswersProvider)[1], '草稿内容');
      expect(c.read(stepCoachingProvider)[1]?.stage, StepCoachingStage.skipped);
    });
    testWidgets('G47 Unskip restores drafting', (tester) async {
      final c = ProviderContainer();
      addTearDown(() => c.dispose());
      c.read(stepCoachingProvider.notifier).skipStep(1);
      c.read(stepCoachingProvider.notifier).unskipStep(1);
      expect(
          c.read(stepCoachingProvider)[1]?.stage, StepCoachingStage.drafting);
    });
    testWidgets('G48 Hint does not write to answers', (tester) async {
      final c = ProviderContainer();
      addTearDown(() => c.dispose());
      c.read(stepCoachingProvider.notifier).requestHint(1);
      expect(c.read(stepAnswersProvider)[1], isNull);
    });
  });

  // ══════════════════════════════════════════════════════════
  // H. Multi-round submission
  // ══════════════════════════════════════════════════════════
  group('H. Multi-round', () {
    testWidgets('H49 Version 1', (tester) async {
      final c = ProviderContainer(overrides: [
        evaluationServiceProvider.overrideWithValue(
            FakeEvaluationService(finalEvaluation: makeEval())),
      ]);
      addTearDown(() => c.dispose());
      fillFive(c);
      addEvidence(c);
      await c.read(missionSubmissionProvider.notifier).submitFinal();
      expect(c.read(missionResultSnapshotProvider)!.submissionVersion, 1);
    });
    testWidgets('H50 Version 2', (tester) async {
      final c = ProviderContainer(overrides: [
        evaluationServiceProvider.overrideWithValue(
            FakeEvaluationService(finalEvaluation: makeEval())),
      ]);
      addTearDown(() => c.dispose());
      fillFive(c);
      addEvidence(c);
      await c.read(missionSubmissionProvider.notifier).submitFinal();
      expect(c.read(missionResultSnapshotProvider)!.submissionVersion, 1);
      c.read(stepAnswersProvider.notifier).updateAnswer(1, 'modified for v2');
      c.read(missionSubmissionProvider.notifier).markModified();
      expect(c.read(missionSubmissionProvider).stage,
          MissionSubmissionStage.revisionReady);
      await c.read(missionSubmissionProvider.notifier).submitFinal();
      expect(c.read(missionResultSnapshotProvider)!.submissionVersion, 2);
      expect(
          c.read(missionResultSnapshotProvider)!.answers[1], 'modified for v2');
    });
    testWidgets('H51 Version 3', (tester) async {
      final c = ProviderContainer(overrides: [
        evaluationServiceProvider.overrideWithValue(
            FakeEvaluationService(finalEvaluation: makeEval())),
      ]);
      addTearDown(() => c.dispose());
      fillFive(c);
      addEvidence(c);
      for (int v = 1; v <= 3; v++) {
        c.read(stepAnswersProvider.notifier).updateAnswer(5, 'v$v answer');
        if (v > 1) {
          c.read(missionSubmissionProvider.notifier).markModified();
          expect(c.read(missionSubmissionProvider).stage,
              MissionSubmissionStage.revisionReady);
        }
        await c.read(missionSubmissionProvider.notifier).submitFinal();
        expect(c.read(missionResultSnapshotProvider)!.submissionVersion, v);
      }
      expect(c.read(missionResultSnapshotProvider)!.answers[5], 'v3 answer');
    });
  });

  // ══════════════════════════════════════════════════════════
  // I. Evidence conversion
  // ══════════════════════════════════════════════════════════
  group('I. Evidence', () {
    testWidgets('I52 Map evidence type', (tester) async {
      final c = makeContainer();
      addTearDown(() => c.dispose());
      addEvidence(c);
      final ev = c.read(missionEvidenceProvider);
      expect(ev.keys.where((k) => !k.startsWith('reading:')), isNotEmpty);
    });
    testWidgets('I53 Map+reading evidence', (tester) async {
      final c = ProviderContainer(overrides: [
        evaluationServiceProvider
            .overrideWithValue(const FakeEvaluationService()),
      ]);
      addTearDown(() => c.dispose());
      addEvidence(c);
      final ev = c.read(missionEvidenceProvider);
      expect(ev.isNotEmpty, true);
    });
  });

  // ══════════════════════════════════════════════════════════
  // J. Layout
  // ══════════════════════════════════════════════════════════
  group('J. Layout', () {
    testWidgets('J54 1366x1024 no overflow', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1366, 1024));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(ProviderScope(
          child: MaterialApp(
              theme: AppTheme.darkTheme(), home: const MissionScreen())));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
    testWidgets('J55 Submit button exists', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1366, 1024));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(ProviderScope(
          child: MaterialApp(
              theme: AppTheme.darkTheme(), home: const MissionScreen())));
      await tester.pump();
      expect(find.text('提交本步思考'), findsWidgets);
    });
    testWidgets('J56 1194x834 no overflow', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1194, 834));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(ProviderScope(
          child: MaterialApp(
              theme: AppTheme.darkTheme(), home: const MissionScreen())));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });
}
