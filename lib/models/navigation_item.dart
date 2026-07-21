import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 侧边栏导航条目定义
class NavigationItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String route;

  const NavigationItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.route,
  });

  static const List<NavigationItem> items = [
    NavigationItem(
      label: '首页',
      icon: Icons.explore_outlined,
      activeIcon: Icons.explore,
      route: '/',
    ),
    NavigationItem(
      label: '世界地图',
      icon: Icons.public_outlined,
      activeIcon: Icons.public,
      route: '/world-map',
    ),
    NavigationItem(
      label: '高加索',
      icon: Icons.landscape_outlined,
      activeIcon: Icons.landscape,
      route: '/caucasus',
    ),
    NavigationItem(
      label: '任务',
      icon: Icons.flag_outlined,
      activeIcon: Icons.flag,
      route: '/mission',
    ),
    NavigationItem(
      label: 'AI 思维',
      icon: Icons.psychology_outlined,
      activeIcon: Icons.psychology,
      route: '/ai-lab',
    ),
    NavigationItem(
      label: '阅读营',
      icon: Icons.menu_book_outlined,
      activeIcon: Icons.menu_book,
      route: '/reading-camp',
    ),
    NavigationItem(
      label: '我的文明',
      icon: Icons.my_location_outlined,
      activeIcon: Icons.my_location,
      route: '/my-map',
    ),
    NavigationItem(
      label: '个人',
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      route: '/profile',
    ),
  ];
}

/// 当前选中路由 provider
final activeRouteProvider = Provider<String>((ref) {
  // 默认由 ShellRoute 通过 context.location 提供,
  // 此处仅作备选初始值
  return '/';
});
