import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../components/app_shell.dart';
import '../screens/home_screen.dart';
import '../screens/world_map_screen.dart';
import '../screens/caucasus_screen.dart';
import '../screens/mission_screen.dart';
import '../screens/ai_thinking_lab_screen.dart';
import '../screens/reading_camp_screen.dart';
import '../screens/my_civilization_map_screen.dart';
import '../screens/profile_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

final routerProvider = Provider<GoRouter>((ref) {
  return _createRouter();
});

GoRouter _createRouter() {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
      // ── ShellRoute: 三栏主布局 ──
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/world-map',
            name: 'world-map',
            builder: (context, state) => const WorldMapScreen(),
          ),
          GoRoute(
            path: '/caucasus',
            name: 'caucasus',
            builder: (context, state) => const CaucasusScreen(),
          ),
          GoRoute(
            path: '/mission',
            name: 'mission',
            builder: (context, state) => const MissionScreen(),
          ),
          GoRoute(
            path: '/ai-lab',
            name: 'ai-lab',
            builder: (context, state) => const AIThinkingLabScreen(),
          ),
          GoRoute(
            path: '/reading-camp',
            name: 'reading-camp',
            builder: (context, state) => const ReadingCampScreen(),
          ),
          GoRoute(
            path: '/my-map',
            name: 'my-map',
            builder: (context, state) => const MyCivilizationMapScreen(),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
    ],
  );
}
