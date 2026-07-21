import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../data/map_state.dart';

/// 地图左侧图层控制栏
///
/// 提供地形/水系/文明路线等图层开关。
/// 每个图层以图标 + 中文标签 + 开关 (Switch) 展示。
class MapLayerPanel extends ConsumerWidget {
  const MapLayerPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final layers = ref.watch(mapLayersProvider);

    return Container(
      width: 180,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark.withAlpha(230),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 标题 ──
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 14),
            child: Row(
              children: [
                Icon(Icons.layers, color: AppTheme.gold, size: 16),
                const SizedBox(width: 8),
                Text(
                  '图层',
                  style: TextStyle(
                    color: AppTheme.paper,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'PingFang SC',
                  ),
                ),
              ],
            ),
          ),
          // ── 图层项 ──
          _LayerItem(
            icon: Icons.terrain_outlined,
            label: '地形',
            value: layers.terrain,
            onChanged: (_) =>
                ref.read(mapLayersProvider.notifier).toggle('terrain'),
          ),
          const SizedBox(height: 4),
          _LayerItem(
            icon: Icons.water_drop_outlined,
            label: '水系',
            value: layers.water,
            onChanged: (_) =>
                ref.read(mapLayersProvider.notifier).toggle('water'),
          ),
          const SizedBox(height: 4),
          _LayerItem(
            icon: Icons.route_outlined,
            label: '文明路线',
            value: layers.routes,
            onChanged: (_) =>
                ref.read(mapLayersProvider.notifier).toggle('routes'),
          ),
          const SizedBox(height: 4),
          _LayerItem(
            icon: Icons.directions_walk_outlined,
            label: '人群迁移',
            value: layers.migration,
            onChanged: (_) =>
                ref.read(mapLayersProvider.notifier).toggle('migration'),
          ),
          const SizedBox(height: 4),
          _LayerItem(
            icon: Icons.history_edu_outlined,
            label: '历史事件',
            value: layers.events,
            onChanged: (_) =>
                ref.read(mapLayersProvider.notifier).toggle('events'),
          ),
          const Spacer(),
          // ── 丝绸之路独立开关 ──
          _buildSilkRoadToggle(ref),
        ],
      ),
    );
  }

  Widget _buildSilkRoadToggle(WidgetRef ref) {
    final visible = ref.watch(silkRoadVisibleProvider);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: AppTheme.divider, width: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.alt_route, color: AppTheme.gold, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '丝绸之路',
                  style: TextStyle(
                    color: AppTheme.paper,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'PingFang SC',
                  ),
                ),
              ),
              SizedBox(
                height: 24,
                child: Switch.adaptive(
                  value: visible,
                  activeColor: AppTheme.gold,
                  activeTrackColor: AppTheme.shimmerGold,
                  onChanged: (v) {
                    ref.read(silkRoadVisibleProvider.notifier).state = v;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LayerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _LayerItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.paper.withAlpha(160), size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: AppTheme.paper.withAlpha(180),
              fontSize: 13,
              fontFamily: 'PingFang SC',
            ),
          ),
        ),
        SizedBox(
          height: 22,
          child: Switch.adaptive(
            value: value,
            activeColor: AppTheme.gold,
            activeTrackColor: AppTheme.shimmerGold,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
