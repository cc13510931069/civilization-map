import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../data/map_state.dart';

/// 顶部横向地图图层工具栏
///
/// ┌────────────────────────────────────────────────────────────┐
/// │ [图层] [地形✓] [水系✓] [文明路线✓] [迁移] [事件] [丝路]  [回到全图] │
/// └────────────────────────────────────────────────────────────┘
class WorldMapToolbar extends ConsumerWidget {
  const WorldMapToolbar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final layers = ref.watch(mapLayersProvider);

    return Container(
      height: 52,
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark.withAlpha(220),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.divider, width: 0.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          // ── 图层图标 ──
          Icon(Icons.layers, color: AppTheme.gold, size: 16),
          const SizedBox(width: 4),
          Text('图层',
              style: TextStyle(
                  color: AppTheme.paper.withAlpha(180),
                  fontSize: 12,
                  fontFamily: 'PingFang SC')),
          const SizedBox(width: 8),
          Container(width: 1, height: 20, color: AppTheme.divider),
          const SizedBox(width: 8),

          // ── 可横向滚动的图层按钮 ──
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _chip(
                      ref,
                      '地形',
                      Icons.terrain_outlined,
                      layers.terrain,
                      () => ref
                          .read(mapLayersProvider.notifier)
                          .toggle('terrain')),
                  _chip(
                      ref,
                      '水系',
                      Icons.water_drop_outlined,
                      layers.water,
                      () =>
                          ref.read(mapLayersProvider.notifier).toggle('water')),
                  _chip(
                      ref,
                      '文明路线',
                      Icons.route_outlined,
                      layers.routes,
                      () => ref
                          .read(mapLayersProvider.notifier)
                          .toggle('routes')),
                  _chip(
                      ref,
                      '人群迁移',
                      Icons.directions_walk_outlined,
                      layers.migration,
                      () => ref
                          .read(mapLayersProvider.notifier)
                          .toggle('migration')),
                  _chip(
                      ref,
                      '历史事件',
                      Icons.history_edu_outlined,
                      layers.events,
                      () => ref
                          .read(mapLayersProvider.notifier)
                          .toggle('events')),
                  const SizedBox(width: 8),
                  Container(width: 1, height: 20, color: AppTheme.divider),
                  const SizedBox(width: 8),
                  // ── 丝绸之路 ──
                  _silkChip(ref),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(WidgetRef ref, String label, IconData icon, bool active,
      VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: active ? AppTheme.shimmerGold : AppTheme.background,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: active ? AppTheme.gold.withAlpha(80) : AppTheme.divider,
              width: 0.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  color: active ? AppTheme.gold : AppTheme.paper.withAlpha(120),
                  size: 14),
              const SizedBox(width: 4),
              Text(label,
                  style: TextStyle(
                      color: active
                          ? AppTheme.gold
                          : AppTheme.paper.withAlpha(160),
                      fontSize: 12,
                      fontFamily: 'PingFang SC')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _silkChip(WidgetRef ref) {
    final visible = ref.watch(silkRoadVisibleProvider);
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: GestureDetector(
        onTap: () =>
            ref.read(silkRoadVisibleProvider.notifier).state = !visible,
        child: Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: visible ? AppTheme.gold.withAlpha(40) : AppTheme.background,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: visible ? AppTheme.gold : AppTheme.divider,
              width: visible ? 1.0 : 0.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.alt_route,
                  color:
                      visible ? AppTheme.gold : AppTheme.paper.withAlpha(120),
                  size: 14),
              const SizedBox(width: 4),
              Text('丝绸之路',
                  style: TextStyle(
                      color: visible
                          ? AppTheme.gold
                          : AppTheme.paper.withAlpha(160),
                      fontSize: 12,
                      fontFamily: 'PingFang SC')),
            ],
          ),
        ),
      ),
    );
  }
}
