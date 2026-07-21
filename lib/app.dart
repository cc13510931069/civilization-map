import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router/app_router.dart';
import 'data/typography_state.dart';
import 'theme/app_theme.dart';

class CivilizationMapApp extends ConsumerWidget {
  const CivilizationMapApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final typography = ref.watch(appTypographyProvider);

    return MaterialApp.router(
      title: 'Civilization Map HD',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme(typography: typography),
      routerConfig: router,
    );
  }
}
