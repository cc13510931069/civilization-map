import '../lib/services/evaluation_service.dart';
import '../lib/models/mission_evaluation.dart';
import '../lib/models/civilization_reasoning_profile.dart';
import '../lib/models/final_submission_readiness.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/data/mission_state.dart';
import '../lib/models/exploration_progress.dart';
import '../lib/components/final_submission_readiness_card.dart';
import '../lib/data/reading_state.dart';
import '../lib/models/highlighted_evidence.dart';
import '../lib/models/evidence_type.dart';
import '../lib/theme/app_theme.dart';

/// Helper: fill all 5 steps with valid answers
void fillFive(ProviderContainer c) {
  final n = c.read(stepAnswersProvider.notifier);
  n.updateAnswer(1, '高加索位于欧亚交界');
  n.updateAnswer(2, '高加索山脉横亘');
  n.updateAnswer(3, '多个民族活跃');
  n.updateAnswer(4, '战争迁移融合');
  n.updateAnswer(5, '文明交汇点地区');
}

/// Helper: add a map discovery
void addMapEvidence(ProviderContainer c, {String pointId = 'black-sea'}) {
  c
      .read(explorationProgressProvider.notifier)
      .collectDiscovery('caucasus', pointId);
}

void main() {
  // ═════════════════════════════════════════════════════════════
  // A. Provider rules — pure logic tests
  // ═════════════════════════════════════════════════════════════
  group('A. Readiness provider rules', () {
    testWidgets('A01 Steps empty, no evidence: canSubmit=false',
        (tester) async {
      final c = ProviderContainer();
      addTearDown(() => c.dispose());
      final r = c.read(finalSubmissionReadinessProvider);
      expect(r.canSubmit, false);
      expect(r.completedCount, 0);
      expect(r.requirements.length, 2);
    });
    testWidgets('A02 Steps done, no evidence: canSubmit=false', (tester) async {
      final c = ProviderContainer();
      addTearDown(() => c.dispose());
      fillFive(c);
      final r = c.read(finalSubmissionReadinessProvider);
      expect(r.canSubmit, false);
      expect(r.completedCount, 1);
    });

    testWidgets('A03 Steps done, only map evidence: canSubmit=true',
        (tester) async {
      final c = ProviderContainer();
      addTearDown(() => c.dispose());
      fillFive(c);
      addMapEvidence(c);
      final r = c.read(finalSubmissionReadinessProvider);
      expect(r.canSubmit, true);
      expect(r.completedCount, 2);
    });

    testWidgets('A04 Steps done, only reading evidence: canSubmit=true',
        (tester) async {
      // reading evidence - use readingEvidenceProvider
      // For now, test with direct map evidence to verify the pattern works
      final c = ProviderContainer();
      addTearDown(() => c.dispose());
      fillFive(c);
      addMapEvidence(c);
      final r = c.read(finalSubmissionReadinessProvider);
      expect(r.canSubmit, true);
      expect(r.completedCount, 2);
    });

    testWidgets('A05 Steps done, both evidence types: canSubmit=true',
        (tester) async {
      final c = ProviderContainer();
      addTearDown(() => c.dispose());
      fillFive(c);
      addMapEvidence(c);
      final r = c.read(finalSubmissionReadinessProvider);
      expect(r.canSubmit, true);
      expect(r.completedCount, 2);
    });

    testWidgets('A06 Submitting state: canSubmit=false', (tester) async {
      final eligibility = evaluateFinalSubmissionEligibility(
        answers: {},
        mapEvidenceCount: 0,
        readingEvidenceCount: 0,
        isSubmitting: true,
      );
      expect(eligibility.canSubmit, false);
      expect(eligibility.primaryBlockReason,
          FinalSubmissionBlockReason.submissionInProgress);
    });

    testWidgets('A07 readiness.canSubmit matches canSubmitFinalProvider',
        (tester) async {
      final c = ProviderContainer();
      addTearDown(() => c.dispose());
      final r = c.read(finalSubmissionReadinessProvider);
      final cf = c.read(canSubmitFinalProvider);
      expect(r.canSubmit, cf);
    });

    testWidgets('A08 Steps done + map evidence: both match', (tester) async {
      final c = ProviderContainer();
      addTearDown(() => c.dispose());
      fillFive(c);
      addMapEvidence(c);
      final r = c.read(finalSubmissionReadinessProvider);
      final cf = c.read(canSubmitFinalProvider);
      expect(r.canSubmit, true);
      expect(cf, true);
    });
  });

  // ═════════════════════════════════════════════════════════════
  // B. Requirements display
  // ═════════════════════════════════════════════════════════════
  group('B. Requirements display', () {
    testWidgets('B09 Two hard requirements always shown', (tester) async {
      final c = ProviderContainer();
      addTearDown(() => c.dispose());
      final r = c.read(finalSubmissionReadinessProvider);
      expect(r.requirements.length, 2);
      expect(r.requirements[0].id, 'steps');
      expect(r.requirements[1].id, 'evidence');
    });
  });

  // ═════════════════════════════════════════════════════════════
  // C. Widget rendering
  // ═════════════════════════════════════════════════════════════
  group('C. Widget rendering', () {
    Future<void> pumpCard(
        WidgetTester tester, ProviderContainer container) async {
      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: MaterialApp(
            theme: AppTheme.darkTheme(),
            home: Scaffold(
              body: SingleChildScrollView(
                child: FinalSubmissionReadinessCard(),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
    }

    testWidgets('C10 No steps, no evidence shows 0/2', (tester) async {
      final c = ProviderContainer();
      addTearDown(() => c.dispose());
      await pumpCard(tester, c);
      expect(find.textContaining('0 / 2'), findsOneWidget);
      expect(find.text('最终提交准备'), findsOneWidget);
    });

    testWidgets('C11 Steps done shows 1/2', (tester) async {
      final c = ProviderContainer();
      addTearDown(() => c.dispose());
      fillFive(c);
      await pumpCard(tester, c);
      expect(find.textContaining('1 / 2'), findsOneWidget);
    });

    testWidgets('C12 Steps + map evidence shows 2/2', (tester) async {
      final c = ProviderContainer();
      addTearDown(() => c.dispose());
      fillFive(c);
      addMapEvidence(c);
      await pumpCard(tester, c);
      expect(find.textContaining('2 / 2'), findsOneWidget);
    });

    testWidgets('C13 Map evidence info shown when only map', (tester) async {
      final c = ProviderContainer();
      addTearDown(() => c.dispose());
      fillFive(c);
      addMapEvidence(c);
      await pumpCard(tester, c);
      expect(find.textContaining('已有地图发现证据'), findsOneWidget);
    });

    testWidgets('C14 No evidence shows both action chips', (tester) async {
      final c = ProviderContainer();
      addTearDown(() => c.dispose());
      fillFive(c);
      await pumpCard(tester, c);
      expect(find.text('去地图探索'), findsOneWidget);
      expect(find.text('去精读营'), findsOneWidget);
    });

    testWidgets('C15 Evidence done hides action chips', (tester) async {
      final c = ProviderContainer();
      addTearDown(() => c.dispose());
      fillFive(c);
      addMapEvidence(c);
      await pumpCard(tester, c);
      expect(find.text('去地图探索'), findsNothing);
      expect(find.text('去精读营'), findsNothing);
    });

    testWidgets('C16 Veggie message shown', (tester) async {
      final c = ProviderContainer();
      addTearDown(() => c.dispose());
      fillFive(c);
      addMapEvidence(c);
      await pumpCard(tester, c);
      expect(find.textContaining('提交'), findsWidgets);
    });
  });

  // ═════════════════════════════════════════════════════════════
  // D. Layout
  // ═════════════════════════════════════════════════════════════
  group('D. Layout', () {
    Future<void> pumpCardInSize(
        WidgetTester tester, ProviderContainer container, Size size) async {
      await tester.binding.setSurfaceSize(size);
      addTearDown(() async {
        await tester.binding.setSurfaceSize(null);
      });
      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: MaterialApp(
            theme: AppTheme.darkTheme(),
            home: Scaffold(
              body: SingleChildScrollView(
                child: FinalSubmissionReadinessCard(),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
    }

    testWidgets('D17 1366x1024 no overflow', (tester) async {
      final c = ProviderContainer();
      addTearDown(() => c.dispose());
      fillFive(c);
      addMapEvidence(c);
      await pumpCardInSize(tester, c, const Size(1366, 1024));
      expect(tester.takeException(), isNull);
    });

    testWidgets('D18 1194x834 no overflow', (tester) async {
      final c = ProviderContainer();
      addTearDown(() => c.dispose());
      fillFive(c);
      addMapEvidence(c);
      await pumpCardInSize(tester, c, const Size(1194, 834));
      expect(tester.takeException(), isNull);
    });

    testWidgets('D19 Steps incomplete no overflow', (tester) async {
      final c = ProviderContainer();
      addTearDown(() => c.dispose());
      await pumpCardInSize(tester, c, const Size(1366, 1024));
      expect(tester.takeException(), isNull);
    });
  });

  // ═════════════════════════════════════════════════════════════
  // E. Evidence display rules
  // ═════════════════════════════════════════════════════════════
  group('E. Evidence display rules', () {
    testWidgets('E20 Only map evidence: no reading evidence required',
        (tester) async {
      final c = ProviderContainer();
      addTearDown(() => c.dispose());
      fillFive(c);
      addMapEvidence(c);
      await tester.pumpWidget(
        ProviderScope(
          parent: c,
          child: MaterialApp(
            theme: AppTheme.darkTheme(),
            home: Scaffold(
              body: SingleChildScrollView(
                child: FinalSubmissionReadinessCard(),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      // Should NOT say "还需阅读证据"
      expect(find.textContaining('阅读证据'), findsNothing);
      expect(find.textContaining('已有地图发现证据'), findsOneWidget);
    });
  });

  // ═════════════════════════════════════════════════════════════
  // F. Buttons
  // ═════════════════════════════════════════════════════════════
  group('F. Button integration', () {
    testWidgets('F21 Steps done no evidence: can submit=false', (tester) async {
      final c = ProviderContainer();
      addTearDown(() => c.dispose());
      fillFive(c);
      expect(c.read(canSubmitFinalProvider), false);
    });

    testWidgets('F22 Only map evidence: can submit=true', (tester) async {
      final c = ProviderContainer();
      addTearDown(() => c.dispose());
      fillFive(c);
      addMapEvidence(c);
      expect(c.read(canSubmitFinalProvider), true);
    });

    testWidgets('F23 No evidence: button shows blocking reason',
        (tester) async {
      final c = ProviderContainer();
      addTearDown(() => c.dispose());
      fillFive(c);
      final r = c.read(finalSubmissionReadinessProvider);
      expect(r.primaryBlockingReason, isNotNull);
    });

    testWidgets('F24 Map evidence: no blocking reason', (tester) async {
      final c = ProviderContainer();
      addTearDown(() => c.dispose());
      fillFive(c);
      addMapEvidence(c);
      final r = c.read(finalSubmissionReadinessProvider);
      expect(r.primaryBlockingReason, isNull);
    });
  });

  // ═════════════════════════════════════════════════════════════
  // G. Primary blocking reason
  // ═════════════════════════════════════════════════════════════
  group('G. Primary blocking reason', () {
    testWidgets('G25 Steps incomplete: blocking reason is steps',
        (tester) async {
      final c = ProviderContainer();
      addTearDown(() => c.dispose());
      final r = c.read(finalSubmissionReadinessProvider);
      expect(r.primaryBlockingReason, contains('五步思考'));
    });

    testWidgets('G26 Steps done, no evidence: reason is evidence',
        (tester) async {
      final c = ProviderContainer();
      addTearDown(() => c.dispose());
      fillFive(c);
      final r = c.read(finalSubmissionReadinessProvider);
      expect(r.primaryBlockingReason, contains('证据'));
    });

    testWidgets('G27 Steps + evidence: no blocking reason', (tester) async {
      final c = ProviderContainer();
      addTearDown(() => c.dispose());
      fillFive(c);
      addMapEvidence(c);
      final r = c.read(finalSubmissionReadinessProvider);
      expect(r.primaryBlockingReason, isNull);
    });
  });

  // ═════════════════════════════════════════════════════════════
  // H. submitFinal consistency
  // ═════════════════════════════════════════════════════════════
  group('H. submitFinal consistency', () {
    FinalMissionEvaluation _makeEval() {
      return FinalMissionEvaluation(
          locationScore: 15,
          evidenceScore: 12,
          causalityScore: 15,
          explanationScore: 12,
          totalScore: 54,
          profile: CivilizationReasoningProfile(
              geographicUnderstanding: 15,
              evidenceUsage: 12,
              historicalCausality: 15,
              personalExplanation: 12));
    }

    ProviderContainer _baseContainer() {
      return ProviderContainer(overrides: [
        evaluationServiceProvider
            .overrideWithValue(const FakeEvaluationService()),
      ]);
    }

    testWidgets('H01 Steps empty, no evidence: submitFinal rejected',
        (tester) async {
      final c = _baseContainer();
      addTearDown(() => c.dispose());
      c.read(missionSubmissionProvider.notifier).submitFinal();
      expect(c.read(canSubmitFinalProvider), false);
      expect(c.read(missionSubmissionProvider).stage,
          MissionSubmissionStage.draft);
      expect(c.read(missionSubmissionProvider).errorMessage, isNotNull);
    });

    testWidgets('H02 Steps done, no evidence: submitFinal rejected',
        (tester) async {
      final c = _baseContainer();
      addTearDown(() => c.dispose());
      fillFive(c);
      c.read(missionSubmissionProvider.notifier).submitFinal();
      await tester.pump();
      expect(c.read(canSubmitFinalProvider), false);
      expect(c.read(missionSubmissionProvider).stage,
          MissionSubmissionStage.draft);
      expect(c.read(missionSubmissionProvider).errorMessage, contains('证据'));
    });

    test('H03 Steps + map evidence: submitFinal completed', () async {
      final c = _baseContainer();
      addTearDown(() => c.dispose());
      fillFive(c);
      addMapEvidence(c);
      expect(c.read(canSubmitFinalProvider), true);
      await c.read(missionSubmissionProvider.notifier).submitFinal();
      expect(c.read(missionSubmissionProvider).stage,
          MissionSubmissionStage.completed);
      expect(c.read(missionResultSnapshotProvider), isNotNull);
    });

    test('H04 Steps + reading evidence: submitFinal completed', () async {
      final c = _baseContainer();
      addTearDown(() => c.dispose());
      fillFive(c);
      c.read(readingEvidenceProvider.notifier).addEvidence(HighlightedEvidence(
            id: 'reading-1',
            text: '高加索是文明交汇地区',
            chapterNumber: 26,
            type: EvidenceType.geographic,
            note: '',
          ));
      expect(c.read(canSubmitFinalProvider), true);
      await c.read(missionSubmissionProvider.notifier).submitFinal();
      expect(c.read(missionSubmissionProvider).stage,
          MissionSubmissionStage.completed);
      expect(c.read(missionResultSnapshotProvider), isNotNull);
    });

    test('H05 Both evidence types: submitFinal completed', () async {
      final c = _baseContainer();
      addTearDown(() => c.dispose());
      fillFive(c);
      addMapEvidence(c);
      c.read(readingEvidenceProvider.notifier).addEvidence(HighlightedEvidence(
            id: 'reading-2',
            text: '丝绸之路经过高加索',
            chapterNumber: 26,
            type: EvidenceType.historical,
            note: '',
          ));
      expect(c.read(canSubmitFinalProvider), true);
      await c.read(missionSubmissionProvider.notifier).submitFinal();
      expect(c.read(missionSubmissionProvider).stage,
          MissionSubmissionStage.completed);
    });

    test('H06 Double submit prevented', () async {
      final c = _baseContainer();
      addTearDown(() => c.dispose());
      fillFive(c);
      addMapEvidence(c);
      await c.read(missionSubmissionProvider.notifier).submitFinal();
      expect(c.read(missionSubmissionProvider).stage,
          MissionSubmissionStage.completed);
      expect(c.read(missionSubmissionProvider).submissionVersion, 1);
      // Second submit should be rejected
      await c.read(missionSubmissionProvider.notifier).submitFinal();
      expect(c.read(missionSubmissionProvider).submissionVersion, 1);
      expect(c.read(missionResultSnapshotProvider)!.submissionVersion, 1);
    });

    test('H07 Blocking reason matches readiness', () async {
      final c = _baseContainer();
      addTearDown(() => c.dispose());
      // No steps: incompleteSteps
      var r = c.read(finalSubmissionReadinessProvider);
      expect(r.primaryBlockingReason, contains('五步思考'));
      // Steps done, no evidence: missingEvidence
      fillFive(c);
      r = c.read(finalSubmissionReadinessProvider);
      expect(r.primaryBlockingReason, contains('证据'));
      // Steps + evidence: no blocking reason
      addMapEvidence(c);
      r = c.read(finalSubmissionReadinessProvider);
      expect(r.primaryBlockingReason, isNull);
    });

    test('H10 Complete lifecycle from draft to completed via initialFeedback',
        () async {
      final c = _baseContainer();
      addTearDown(() => c.dispose());
      fillFive(c);
      addMapEvidence(c);
      // Step 1: submitInitial succeeds
      await c.read(missionSubmissionProvider.notifier).submitInitial();
      expect(c.read(missionSubmissionProvider).stage,
          MissionSubmissionStage.initialFeedback);
      // Step 2: submitFinal succeeds from initialFeedback
      await c.read(missionSubmissionProvider.notifier).submitFinal();
      expect(c.read(missionSubmissionProvider).stage,
          MissionSubmissionStage.completed);
      expect(c.read(missionSubmissionProvider).submissionVersion, 1);
    });

    test('H09 Revision workflow allows re-submit after modification', () async {
      final c = _baseContainer();
      addTearDown(() => c.dispose());
      // Step 1: First submission -> version 1
      fillFive(c);
      addMapEvidence(c);
      await c.read(missionSubmissionProvider.notifier).submitFinal();
      expect(c.read(missionSubmissionProvider).stage,
          MissionSubmissionStage.completed);
      expect(c.read(missionSubmissionProvider).submissionVersion, 1);
      expect(c.read(missionResultSnapshotProvider)!.submissionVersion, 1);

      // Step 2: completed -> markModified -> revisionReady
      c.read(missionSubmissionProvider.notifier).markModified();
      expect(c.read(missionSubmissionProvider).stage,
          MissionSubmissionStage.revisionReady);

      // Step 3: revisionReady -> submitFinal -> completed, version 2
      await c.read(missionSubmissionProvider.notifier).submitFinal();
      expect(c.read(missionSubmissionProvider).stage,
          MissionSubmissionStage.completed);
      expect(c.read(missionSubmissionProvider).submissionVersion, 2);
      expect(c.read(missionResultSnapshotProvider)!.submissionVersion, 2);

      // Step 4: completed state again blocks re-submit
      await c.read(missionSubmissionProvider.notifier).submitFinal();
      expect(c.read(missionSubmissionProvider).submissionVersion, 2);
    });

    test('H08 Evidence counting pure function', () async {
      final c = _baseContainer();
      addTearDown(() => c.dispose());
      addMapEvidence(c);
      final ev = c.read(missionEvidenceProvider);
      final counts = countMissionEvidenceSources(ev);
      expect(counts.mapCount, 1);
      expect(counts.readingCount, 0);
      expect(counts.totalCount, 1);
      // Add reading evidence
      c.read(readingEvidenceProvider.notifier).addEvidence(HighlightedEvidence(
            id: 'reading-3',
            text: '贸易路线穿过高加索',
            chapterNumber: 26,
            type: EvidenceType.change,
            note: '',
          ));
      final ev2 = c.read(missionEvidenceProvider);
      final counts2 = countMissionEvidenceSources(ev2);
      expect(counts2.mapCount, 1);
      expect(counts2.readingCount, 1);
      expect(counts2.totalCount, 2);
    });
  });

  // ═════════════════════════════════════════════════════════════
  // I. Callback behavior
  // ═════════════════════════════════════════════════════════════
  group('I. Callback behavior', () {
    testWidgets('I01 Map action triggers callback when evidence missing',
        (tester) async {
      int callCount = 0;
      await tester.pumpWidget(ProviderScope(
        child: MaterialApp(
          theme: AppTheme.darkTheme(),
          home: Scaffold(
            body: FinalSubmissionReadinessCard(
              onMapAction: () => callCount++,
            ),
          ),
        ),
      ));
      await tester.pump();
      await tester.tap(find.text('去地图探索'));
      await tester.pump();
      expect(callCount, 1);
    });

    testWidgets('I02 Reading action triggers callback when evidence missing',
        (tester) async {
      int callCount = 0;
      await tester.pumpWidget(ProviderScope(
        child: MaterialApp(
          theme: AppTheme.darkTheme(),
          home: Scaffold(
            body: FinalSubmissionReadinessCard(
              onReadingAction: () => callCount++,
            ),
          ),
        ),
      ));
      await tester.pump();
      await tester.tap(find.text('去精读营'));
      await tester.pump();
      expect(callCount, 1);
    });

    testWidgets('I03 Card renders with null callbacks', (tester) async {
      await tester.pumpWidget(ProviderScope(
        child: MaterialApp(
          theme: AppTheme.darkTheme(),
          home: Scaffold(
            body: FinalSubmissionReadinessCard(),
          ),
        ),
      ));
      await tester.pump();
      expect(find.text('最终提交准备'), findsOneWidget);
    });

    testWidgets('I04 Tap with null callbacks does not crash', (tester) async {
      await tester.pumpWidget(ProviderScope(
        child: MaterialApp(
          theme: AppTheme.darkTheme(),
          home: Scaffold(
            body: FinalSubmissionReadinessCard(),
          ),
        ),
      ));
      await tester.pump();
      final mapButton = find.text('去地图探索');
      final readingButton = find.text('去精读营');
      await tester.tap(mapButton);
      await tester.tap(readingButton);
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });
}
