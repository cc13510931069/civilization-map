import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ───────────────────────────────────────────────────────────────
//  发现点
// ───────────────────────────────────────────────────────────────

/// 探索发现点 — 地图上的可交互证据节点
class DiscoveryPoint {
  final String id;
  final String name;
  final String type; // 地理位置 / 自然环境 / 交通交流
  final String explanation;
  final Offset position; // 地图上的相对坐标 (0.0 ~ 1.0)

  const DiscoveryPoint({
    required this.id,
    required this.name,
    required this.type,
    required this.explanation,
    required this.position,
  });

  /// 高加索区域 3 个发现点
  static const List<DiscoveryPoint> caucasus = [
    DiscoveryPoint(
      id: 'black-sea',
      name: '黑海',
      type: '地理位置证据',
      explanation: '连接欧洲与西亚的重要海域。\n高加索西临黑海，通过博斯普鲁斯海峡与地中海相连，自古就是东西方文明交汇的海上通道。',
      position: Offset(0.22, 0.30),
    ),
    DiscoveryPoint(
      id: 'caucasus-mountains',
      name: '高加索山脉',
      type: '自然环境证据',
      explanation:
          '山脉影响交流、迁移和文化形成。\n大高加索山脉横亘在黑海与里海之间，既是天然屏障也是连接的桥梁，塑造了这一地区独特的民族与文化格局。',
      position: Offset(0.48, 0.38),
    ),
    DiscoveryPoint(
      id: 'caspian-sea',
      name: '里海',
      type: '交通交流证据',
      explanation: '连接中亚和西亚的重要区域。\n高加索东临里海，这一世界最大内陆湖沿岸自古就是贸易与文化交流的重要通道。',
      position: Offset(0.76, 0.28),
    ),
  ];
}

// ───────────────────────────────────────────────────────────────
//  探索进度状态
// ───────────────────────────────────────────────────────────────

/// 每个区域的探索进度
class RegionProgress {
  final Set<String> collectedIds; // 已收集的发现点 id
  final Set<int> unlockedChapters; // 已解锁的章节编号

  const RegionProgress({
    this.collectedIds = const {},
    this.unlockedChapters = const {26}, // 默认第 26 章可用
  });

  bool isCollected(String id) => collectedIds.contains(id);
  bool get allCollected => collectedIds.length >= 3;
  int get progress => collectedIds.length;

  RegionProgress copyWith({
    Set<String>? collectedIds,
    Set<int>? unlockedChapters,
  }) {
    return RegionProgress(
      collectedIds: collectedIds ?? this.collectedIds,
      unlockedChapters: unlockedChapters ?? this.unlockedChapters,
    );
  }
}

// ── 全局探索进度（key = regionId） ──
class ExplorationProgressState {
  final Map<String, RegionProgress> regions;

  const ExplorationProgressState({
    this.regions = const {'caucasus': RegionProgress()},
  });

  RegionProgress forRegion(String regionId) =>
      regions[regionId] ?? const RegionProgress();

  ExplorationProgressState updateRegion(
      String regionId, RegionProgress updated) {
    final map = Map<String, RegionProgress>.from(regions);
    map[regionId] = updated;
    return ExplorationProgressState(regions: map);
  }
}

class ExplorationNotifier extends StateNotifier<ExplorationProgressState> {
  ExplorationNotifier() : super(const ExplorationProgressState());

  /// 收集一个发现点
  void collectDiscovery(String regionId, String pointId) {
    final current = state.forRegion(regionId);
    if (current.isCollected(pointId)) return;
    final updated = current.copyWith(
      collectedIds: {...current.collectedIds, pointId},
    );
    state = state.updateRegion(regionId, updated);
  }

  /// 重置区域进度
  void resetRegion(String regionId) {
    final updated = const RegionProgress();
    state = state.updateRegion(regionId, updated);
  }
}

final explorationProgressProvider =
    StateNotifierProvider<ExplorationNotifier, ExplorationProgressState>(
  (ref) => ExplorationNotifier(),
);

/// 当前选中的发现点（用于显示 DiscoveryCard）
final activeDiscoveryProvider = StateProvider<DiscoveryPoint?>((ref) => null);
