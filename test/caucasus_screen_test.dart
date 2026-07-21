import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/theme/app_theme.dart';
import '../lib/data/typography_state.dart';
import '../lib/theme/app_typography.dart';
import 'package:flutter/rendering.dart';
import '../lib/models/exploration_progress.dart';
import '../lib/screens/caucasus_screen.dart';

/// 收集全部 3 个高加索发现点
void collectAll(ProviderContainer container) {
  final notifier = container.read(explorationProgressProvider.notifier);
  notifier.collectDiscovery('caucasus', 'black-sea');
  notifier.collectDiscovery('caucasus', 'caucasus-mountains');
  notifier.collectDiscovery('caucasus', 'caspian-sea');
}

/// 验证完成栏文字完整显示

void main() {
  group('Completion bar text visibility', () {
    for (final size in AppTextSize.values) {
      testWidgets('${size.name} font shows completion text without overflow',
          (tester) async {
        final container = ProviderContainer(overrides: [
          if (size != AppTextSize.standard)
            appTextSizeProvider.overrideWithProvider(
              StateProvider<AppTextSize>((ref) => size),
            ),
        ]);
        addTearDown(() => container.dispose());
        collectAll(container);

        await tester.pumpWidget(UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.darkTheme(),
            home: const CaucasusScreen(),
          ),
        ));
        await tester.pump();

        // Verify completion bar text exists
        expect(
          find.textContaining('你找到了高加索成为文明交汇点的三个关键证据'),
          findsOneWidget,
        );
      });
    }
  });

  group('Completion bar rect containment', () {
    testWidgets('Text rect is within completion bar rect', (tester) async {
      final container = ProviderContainer();
      addTearDown(() => container.dispose());
      collectAll(container);

      await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.darkTheme(),
          home: const CaucasusScreen(),
        ),
      ));
      await tester.pump();

      final barFinder = find.byKey(const Key('caucasus_completion_bar'));
      final barRect = tester.getRect(barFinder);

      final textFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Text &&
            widget.data?.contains('你找到了高加索成为文明交汇点的三个关键证据') == true,
      );
      final textRect = tester.getRect(textFinder);

      expect(textRect.left, greaterThanOrEqualTo(barRect.left));
      expect(textRect.top, greaterThanOrEqualTo(barRect.top));
      expect(textRect.right, lessThanOrEqualTo(barRect.right));
      expect(textRect.bottom, lessThanOrEqualTo(barRect.bottom));
    });

    testWidgets('ExtraLarge text rect within bar rect', (tester) async {
      final container = ProviderContainer(overrides: [
        appTextSizeProvider.overrideWithProvider(
          StateProvider<AppTextSize>((ref) => AppTextSize.extraLarge),
        ),
      ]);
      addTearDown(() => container.dispose());
      collectAll(container);

      await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.darkTheme(),
          home: const CaucasusScreen(),
        ),
      ));
      await tester.pump();

      final barFinder = find.byKey(const Key('caucasus_completion_bar'));
      final barRect = tester.getRect(barFinder);

      final textFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Text &&
            widget.data?.contains('你找到了高加索成为文明交汇点的三个关键证据') == true,
      );
      final textRect = tester.getRect(textFinder);

      expect(textRect.left, greaterThanOrEqualTo(barRect.left));
      expect(textRect.top, greaterThanOrEqualTo(barRect.top));
      expect(textRect.right, lessThanOrEqualTo(barRect.right));
      expect(textRect.bottom, lessThanOrEqualTo(barRect.bottom));
    });
  });

  group('Completion bar RenderParagraph', () {
    testWidgets('Standard font does not exceed maxLines', (tester) async {
      final container = ProviderContainer();
      addTearDown(() => container.dispose());
      collectAll(container);

      await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.darkTheme(),
          home: const CaucasusScreen(),
        ),
      ));
      await tester.pump();

      final textFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Text &&
            widget.data?.contains('你找到了高加索成为文明交汇点的三个关键证据') == true,
      );
      final paragraph = tester.renderObject<RenderParagraph>(textFinder);
      expect(paragraph.didExceedMaxLines, isFalse);
    });

    testWidgets('Comfortable font does not exceed maxLines', (tester) async {
      final container = ProviderContainer(overrides: [
        appTextSizeProvider.overrideWithProvider(
          StateProvider<AppTextSize>((ref) => AppTextSize.comfortable),
        ),
      ]);
      addTearDown(() => container.dispose());
      collectAll(container);

      await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.darkTheme(),
          home: const CaucasusScreen(),
        ),
      ));
      await tester.pump();

      final textFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Text &&
            widget.data?.contains('你找到了高加索成为文明交汇点的三个关键证据') == true,
      );
      final paragraph = tester.renderObject<RenderParagraph>(textFinder);
      expect(paragraph.didExceedMaxLines, isFalse);
    });

    testWidgets('Large font does not exceed maxLines', (tester) async {
      final container = ProviderContainer(overrides: [
        appTextSizeProvider.overrideWithProvider(
          StateProvider<AppTextSize>((ref) => AppTextSize.large),
        ),
      ]);
      addTearDown(() => container.dispose());
      collectAll(container);

      await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.darkTheme(),
          home: const CaucasusScreen(),
        ),
      ));
      await tester.pump();

      final textFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Text &&
            widget.data?.contains('你找到了高加索成为文明交汇点的三个关键证据') == true,
      );
      final paragraph = tester.renderObject<RenderParagraph>(textFinder);
      expect(paragraph.didExceedMaxLines, isFalse);
    });

    testWidgets('ExtraLarge font does not exceed maxLines', (tester) async {
      final container = ProviderContainer(overrides: [
        appTextSizeProvider.overrideWithProvider(
          StateProvider<AppTextSize>((ref) => AppTextSize.extraLarge),
        ),
      ]);
      addTearDown(() => container.dispose());
      collectAll(container);

      await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.darkTheme(),
          home: const CaucasusScreen(),
        ),
      ));
      await tester.pump();

      final textFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Text &&
            widget.data?.contains('你找到了高加索成为文明交汇点的三个关键证据') == true,
      );
      final paragraph = tester.renderObject<RenderParagraph>(textFinder);
      expect(paragraph.didExceedMaxLines, isFalse);
    });
  });

  group('Completion bar viewport compatibility', () {
    testWidgets('1366x1024 no overflow', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1366, 1024));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final container = ProviderContainer();
      addTearDown(() => container.dispose());
      collectAll(container);

      await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.darkTheme(),
          home: const CaucasusScreen(),
        ),
      ));
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(
        find.textContaining('你找到了高加索成为文明交汇点的三个关键证据'),
        findsOneWidget,
      );
    });

    testWidgets('1194x834 no overflow', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1194, 834));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final container = ProviderContainer();
      addTearDown(() => container.dispose());
      collectAll(container);

      await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.darkTheme(),
          home: const CaucasusScreen(),
        ),
      ));
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(
        find.textContaining('你找到了高加索成为文明交汇点的三个关键证据'),
        findsOneWidget,
      );
    });

    testWidgets('ExtraLarge 1194x834 text complete', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1194, 834));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final container = ProviderContainer(overrides: [
        appTextSizeProvider.overrideWithProvider(
          StateProvider<AppTextSize>((ref) => AppTextSize.extraLarge),
        ),
      ]);
      addTearDown(() => container.dispose());
      collectAll(container);

      await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.darkTheme(),
          home: const CaucasusScreen(),
        ),
      ));
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(
        find.textContaining('你找到了高加索成为文明交汇点的三个关键证据'),
        findsOneWidget,
      );
    });
  });

  group('Completion bar when hidden', () {
    testWidgets('Bar hidden when progress < 3', (tester) async {
      final container = ProviderContainer();
      addTearDown(() => container.dispose());
      // No discoveries collected
      await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.darkTheme(),
          home: const CaucasusScreen(),
        ),
      ));
      await tester.pump();
      expect(
        find.textContaining('你找到了高加索成为文明交汇点的三个关键证据'),
        findsNothing,
      );
    });
  });
}
