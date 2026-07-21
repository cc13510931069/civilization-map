import 'dart:ui' show Offset;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/civilization_region.dart';

// ───────────────────────────────────────────────────────────────
//  地图图层状态
// ───────────────────────────────────────────────────────────────

class MapLayers {
  final bool terrain;
  final bool water;
  final bool routes;
  final bool migration;
  final bool events;

  const MapLayers({
    this.terrain = true,
    this.water = true,
    this.routes = true,
    this.migration = false,
    this.events = false,
  });

  MapLayers copyWith({
    bool? terrain,
    bool? water,
    bool? routes,
    bool? migration,
    bool? events,
  }) {
    return MapLayers(
      terrain: terrain ?? this.terrain,
      water: water ?? this.water,
      routes: routes ?? this.routes,
      migration: migration ?? this.migration,
      events: events ?? this.events,
    );
  }
}

class MapLayersNotifier extends StateNotifier<MapLayers> {
  MapLayersNotifier() : super(const MapLayers());

  void toggle(String key) {
    switch (key) {
      case 'terrain':
        state = state.copyWith(terrain: !state.terrain);
        break;
      case 'water':
        state = state.copyWith(water: !state.water);
        break;
      case 'routes':
        state = state.copyWith(routes: !state.routes);
        break;
      case 'migration':
        state = state.copyWith(migration: !state.migration);
        break;
      case 'events':
        state = state.copyWith(events: !state.events);
        break;
    }
  }
}

final mapLayersProvider = StateNotifierProvider<MapLayersNotifier, MapLayers>(
    (ref) => MapLayersNotifier());

// ───────────────────────────────────────────────────────────────
//  选中文明节点（显示信息卡）
// ───────────────────────────────────────────────────────────────

final selectedRegionProvider =
    StateProvider<CivilizationRegion?>((ref) => null);

// ───────────────────────────────────────────────────────────────
//  丝绸之路图层开关
// ───────────────────────────────────────────────────────────────

final silkRoadVisibleProvider = StateProvider<bool>((ref) => false);

// ───────────────────────────────────────────────────────────────
//  地图缩放级别追踪
// ───────────────────────────────────────────────────────────────

final mapZoomLevelProvider = StateProvider<double>((ref) => 1.0);

/// 地图回到全图触发器
final mapResetViewProvider = StateProvider<int>((ref) => 0);

/// 缩放比例显示值（相对于 fit 基准的百分比）
final zoomDisplayProvider = StateProvider<double>((ref) => 100.0);

/// 地图缩放操作指令（canvas 监听并执行）
enum MapZoomAction { none, zoomIn, zoomOut, reset }

final mapZoomActionProvider =
    StateProvider<MapZoomAction>((ref) => MapZoomAction.none);

/// 最近点击节点的屏幕位置（用于自适应信息卡定位）
final nodeScreenPositionProvider = StateProvider<Offset?>((ref) => null);
