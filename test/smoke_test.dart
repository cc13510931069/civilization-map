import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/theme/app_theme.dart';
import '../lib/screens/home_screen.dart';
import '../lib/screens/world_map_screen.dart';
import '../lib/screens/caucasus_screen.dart';
import '../lib/screens/mission_screen.dart';
import '../lib/screens/reading_camp_screen.dart';
import '../lib/screens/my_civilization_map_screen.dart';

void main() {
  testWidgets('HomeScreen renders correctly', (tester) async {
    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(
        theme: AppTheme.darkTheme(),
        home: const HomeScreen(),
      ),
    ));
    expect(find.text('文明的地图 HD'), findsOneWidget);
  });

  testWidgets('WorldMapScreen renders', (tester) async {
    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(
        theme: AppTheme.darkTheme(),
        home: const WorldMapScreen(),
      ),
    ));
    expect(find.text('世界文明地图'), findsOneWidget);
  });

  testWidgets('CaucasusScreen renders', (tester) async {
    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(
        theme: AppTheme.darkTheme(),
        home: const CaucasusScreen(),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('高加索'), findsOneWidget);
  });

  testWidgets('MissionScreen renders', (tester) async {
    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(
        theme: AppTheme.darkTheme(),
        home: const MissionScreen(),
      ),
    ));
    expect(find.text('文明思考实验室'), findsOneWidget);
  });

  testWidgets('ReadingCampScreen renders', (tester) async {
    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(
        theme: AppTheme.darkTheme(),
        home: const ReadingCampScreen(),
      ),
    ));
    expect(find.text('精读营'), findsOneWidget);
  });

  testWidgets('MyMapScreen renders', (tester) async {
    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(
        theme: AppTheme.darkTheme(),
        home: const MyCivilizationMapScreen(),
      ),
    ));
    expect(find.text('我的文明地图'), findsOneWidget);
  });
}
