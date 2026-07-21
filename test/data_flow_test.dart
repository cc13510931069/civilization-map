import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../lib/data/typography_state.dart';
import '../lib/theme/app_typography.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/theme/app_theme.dart';
import '../lib/data/mission_state.dart';
import '../lib/data/reading_state.dart';
import '../lib/models/mission_result_snapshot.dart';
import '../lib/services/evaluation_service.dart';
import '../lib/models/mission_evaluation.dart';
import '../lib/models/highlighted_evidence.dart';
import '../lib/models/evidence_type.dart';
import '../lib/models/civilization_reasoning_profile.dart';
import '../lib/models/exploration_progress.dart';
import '../lib/screens/mission_screen.dart';
import '../lib/screens/my_civilization_map_screen.dart';
import '../lib/screens/caucasus_screen.dart';
import '../lib/components/app_shell.dart';

Widget shellForRoute(String route) {
  final router = GoRouter(
    initialLocation: route,
    routes: [
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
              path: '/',
              builder: (_, __) => const SizedBox(width: 1, height: 1)),
          GoRoute(
              path: '/mission',
              builder: (_, __) => const SizedBox(width: 1, height: 1)),
          GoRoute(
              path: '/reading-camp',
              builder: (_, __) => const SizedBox(width: 1, height: 1)),
          GoRoute(
              path: '/my-map',
              builder: (_, __) => const SizedBox(width: 1, height: 1)),
        ],
      ),
    ],
  );
  return ProviderScope(
    child:
        MaterialApp.router(routerConfig: router, theme: AppTheme.darkTheme()),
  );
}

void main() {
  final testEvidence = HighlightedEvidence(
    id: 'test-ev',
    text: '高加索位于黑海与里海之间，是欧亚交界的重要区域',
    chapterNumber: 26,
    type: EvidenceType.geographic,
  );

  final testAnswers = <int, String>{
    1: '高加索位于黑海与里海之间。',
    2: '山脉影响交流。',
    3: '多民族共存。',
    4: '帝国更替。',
    5: '文明交汇。',
  };

  final testProfile = const CivilizationReasoningProfile(
    geographicUnderstanding: 20,
    evidenceUsage: 18,
    historicalCausality: 22,
    personalExplanation: 15,
  );

  testWidgets('Reading evidence flows to Mission provider', (tester) async {
    final container = ProviderContainer(
      overrides: [
        readingEvidenceProvider.overrideWithProvider(
          StateNotifierProvider<EvidenceListNotifier,
              List<HighlightedEvidence>>(
            (ref) {
              final n = EvidenceListNotifier();
              n.addEvidence(testEvidence);
              return n;
            },
          ),
        ),
      ],
    );
    final missionEv = container.read(missionEvidenceProvider);
    expect(missionEv.values.any((v) => v.contains('高加索')), isTrue);
  });

  testWidgets('Step answers appear in MyMap', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        missionResultSnapshotProvider.overrideWithProvider(
          StateProvider<MissionResultSnapshot?>((ref) => MissionResultSnapshot(
                missionId: 'test',
                answers: testAnswers,
                evidenceIds: ['black-sea'],
                personalExplanation: testAnswers[5] ?? '',
                evaluation: const FinalMissionEvaluation(
                  locationScore: 10,
                  evidenceScore: 10,
                  causalityScore: 10,
                  explanationScore: 10,
                  totalScore: 40,
                ),
                submittedAt: DateTime(2025, 1, 1),
                submissionVersion: 1,
              )),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.darkTheme(),
        home: const MyCivilizationMapScreen(),
      ),
    ));
    await tester.pump();
    expect(find.textContaining('高加索位于'), findsOneWidget);
  });

  testWidgets('Reasoning profile appears in MyMap', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        missionResultSnapshotProvider.overrideWithProvider(
          StateProvider<MissionResultSnapshot?>((ref) => MissionResultSnapshot(
                missionId: 'test',
                answers: {},
                personalExplanation: '',
                evaluation: FinalMissionEvaluation(
                  locationScore: 15,
                  evidenceScore: 15,
                  causalityScore: 15,
                  explanationScore: 15,
                  totalScore: 60,
                  profile: testProfile,
                ),
                submittedAt: DateTime(2025, 1, 1),
                submissionVersion: 1,
              )),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.darkTheme(),
        home: const MyCivilizationMapScreen(),
      ),
    ));
    await tester.pump();
    expect(find.text('文明解释能力画像'), findsOneWidget);
  });

  testWidgets('Mission hides global AI Panel', (tester) async {
    await tester.pumpWidget(shellForRoute('/mission'));
    await tester.pump();
    expect(find.textContaining('陪您一同'), findsNothing);
  });

  testWidgets('Reading Camp hides global AI Panel', (tester) async {
    await tester.pumpWidget(shellForRoute('/reading-camp'));
    await tester.pump();
    expect(find.textContaining('陪您一同'), findsNothing);
  });

  testWidgets('My Map hides global AI Panel', (tester) async {
    await tester.pumpWidget(shellForRoute('/my-map'));
    await tester.pump();
    expect(find.textContaining('陪您一同'), findsNothing);
  });

  testWidgets('Three discoveries show action button', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        explorationProgressProvider.overrideWithProvider(
          StateNotifierProvider<ExplorationNotifier, ExplorationProgressState>(
            (ref) {
              final n = ExplorationNotifier();
              n.collectDiscovery('caucasus', 'black-sea');
              n.collectDiscovery('caucasus', 'caucasus-mountains');
              n.collectDiscovery('caucasus', 'caspian-sea');
              return n;
            },
          ),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.darkTheme(),
        home: const CaucasusScreen(),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('开始文明思考'), findsOneWidget);
  });

  testWidgets('Left evidence panel no longer shown', (tester) async {
    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(
        theme: AppTheme.darkTheme(),
        home: const MissionScreen(),
      ),
    ));
    await tester.pump();
    expect(find.text('收集的证据'), findsNothing);
  });

  testWidgets('Map discoveries appear in evidence library', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        explorationProgressProvider.overrideWithProvider(
          StateNotifierProvider<ExplorationNotifier, ExplorationProgressState>(
            (ref) {
              final n = ExplorationNotifier();
              n.collectDiscovery('caucasus', 'black-sea');
              return n;
            },
          ),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.darkTheme(),
        home: const MissionScreen(),
      ),
    ));
    await tester.pump();
    expect(find.text('黑海'), findsOneWidget);
  });

  testWidgets('Reading evidence appears in evidence library', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        readingEvidenceProvider.overrideWithProvider(
          StateNotifierProvider<EvidenceListNotifier,
              List<HighlightedEvidence>>(
            (ref) {
              final n = EvidenceListNotifier();
              n.addEvidence(testEvidence);
              return n;
            },
          ),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.darkTheme(),
        home: const MissionScreen(),
      ),
    ));
    await tester.pump();
    expect(find.textContaining('高加索位于黑海'), findsOneWidget);
  });

  testWidgets('Long evidence can expand and collapse', (tester) async {
    final longText = '高加索位于黑海与里海之间。' + '这是一个很长的证据描述用于测试展开和收起功能。' * 8;
    final longEv = HighlightedEvidence(
      id: 'long-ev',
      text: longText,
      chapterNumber: 26,
      type: EvidenceType.historical,
    );
    await tester.pumpWidget(ProviderScope(
      overrides: [
        readingEvidenceProvider.overrideWithProvider(
          StateNotifierProvider<EvidenceListNotifier,
              List<HighlightedEvidence>>(
            (ref) {
              final n = EvidenceListNotifier();
              n.addEvidence(longEv);
              return n;
            },
          ),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.darkTheme(),
        home: const MissionScreen(),
      ),
    ));
    await tester.pump();
    final target = find.byIcon(Icons.unfold_more);
    await tester.ensureVisible(target);
    await tester.pump();
    await tester.tap(target);
    await tester.pump();
    expect(find.byIcon(Icons.unfold_less), findsOneWidget);
  });

  testWidgets('Evidence library scrolls with many items', (tester) async {
    final items = List.generate(
        10,
        (i) => HighlightedEvidence(
              id: 'ev-$i',
              text: '测试证据第${i + 1}条',
              chapterNumber: 26,
              type: EvidenceType.geographic,
            ));
    await tester.pumpWidget(ProviderScope(
      overrides: [
        readingEvidenceProvider.overrideWithProvider(
          StateNotifierProvider<EvidenceListNotifier,
              List<HighlightedEvidence>>(
            (ref) {
              final n = EvidenceListNotifier();
              for (final e in items) n.addEvidence(e);
              return n;
            },
          ),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.darkTheme(),
        home: const MissionScreen(),
      ),
    ));
    await tester.pump();
    await tester.dragUntilVisible(
      find.textContaining('测试证据第10条'),
      find.byType(ListView).last,
      const Offset(0, -100),
    );
    await tester.pump();
    expect(find.textContaining('测试证据第10条'), findsOneWidget);
  });

  testWidgets('ExtraLarge font no overflow', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        appTextSizeProvider.overrideWithProvider(
            StateProvider<AppTextSize>((ref) => AppTextSize.extraLarge)),
      ],
      child: MaterialApp(
        theme: AppTheme.darkTheme(),
        home: const MissionScreen(),
      ),
    ));
    await tester.pump();
    expect(find.text('文明思考实验室'), findsOneWidget);
  });
}
