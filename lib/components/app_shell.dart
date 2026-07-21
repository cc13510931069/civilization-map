import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import 'app_sidebar.dart';
import 'ai_panel.dart';

/// 主布局 Shell — 三栏结构
///
/// ┌──────────┬────────────────────────────┬──────────────┐
/// │ Sidebar  │      Main Content          │  AI Panel    │
/// │  240px   │       (Expanded)           │   320px      │
/// └──────────┴────────────────────────────┴──────────────┘
///
/// 由 GoRouter ShellRoute 包装，child 随路由切换。
///
/// 部分页面拥有自己的导师面板（Mission / Reading / MyMap），
/// 此时全局 AI Panel 自动隐藏，避免双重右栏。
class AppShell extends ConsumerWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aiVisible = ref.watch(aiPanelVisibleProvider);
    final location = GoRouterState.of(context).uri.toString();

    // 带有自己专属工作台面板的页面不显示全局 AI Panel
    const pagesWithOwnPanel = ['/mission', '/reading-camp', '/my-map'];
    final showGlobalPanel = aiVisible && !pagesWithOwnPanel.contains(location);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Row(
          children: [
            const AppSidebar(),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  border: Border(
                    right: showGlobalPanel
                        ? BorderSide(color: AppTheme.divider, width: 0.5)
                        : BorderSide.none,
                  ),
                ),
                child: child,
              ),
            ),
            // 仅在页面没有专属面板时显示
            if (showGlobalPanel) const AIPanel(),
          ],
        ),
      ),
    );
  }
}
