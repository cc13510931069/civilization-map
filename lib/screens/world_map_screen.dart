import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../data/map_state.dart';
import '../models/civilization_region.dart';
import '../components/world_map_canvas.dart';
import '../components/world_map_toolbar.dart';
import '../components/civilization_info_card.dart';
import '../components/map_zoom_controls.dart';

/// 世界文明地图页面
///
/// ┌──────────────────────────────────────────────────┐
/// │  🌍 世界文明地图                                  │
/// ├──────────────────┬───────────────────────────────┤
/// │ [图层工具栏]                        [回到全图]    │
/// ├──────────────────────────────────────────────────┤
/// │                                                  │
/// │          [InteractiveViewer + CustomPainter]     │
/// │          大陆 + 节点 + 连接 + 丝路    [信息卡]    │
/// │                                                  │
/// └──────────────────────────────────────────────────┘
class WorldMapScreen extends ConsumerStatefulWidget {
  const WorldMapScreen({super.key});

  @override
  ConsumerState<WorldMapScreen> createState() => _WorldMapScreenState();
}

class _WorldMapScreenState extends ConsumerState<WorldMapScreen> {
  void _onNodeTap(CivilizationRegion region) {
    if (region.id.isEmpty) {
      ref.read(selectedRegionProvider.notifier).state = null;
    } else {
      ref.read(selectedRegionProvider.notifier).state = region;
    }
  }

  void _dismissInfoCard() {
    ref.read(selectedRegionProvider.notifier).state = null;
  }

  void _handleNavigationIntent(BuildContext context, WidgetRef ref) {
    try {
      final routerState = GoRouterState.of(context);
      final extra = routerState.extra;
      if (extra is Map<String, dynamic>) {
        final focusId = extra['focusRegionId'] as String?;
        if (focusId != null) {
          final region = CivilizationRegion.worldMap
              .cast<CivilizationRegion?>()
              .firstWhere((r) => r?.id == focusId, orElse: () => null);
          if (region != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (ref.read(selectedRegionProvider)?.id != focusId) {
                ref.read(selectedRegionProvider.notifier).state = region;
              }
            });
          }
        }
      }
    } catch (_) {
      // GoRouter context may not be available in test environments
    }
  }

  /// 自适应计算信息卡安全位置
  /// 根据节点屏幕位置 + 卡片尺寸，尝试右侧/左侧/上方/下方，
  /// 最终坐标 clamp 在 viewport 安全区域内。
  Offset calculateSafeOverlayPosition({
    required Size viewport,
    required Offset anchor,
    required Size cardSize,
    required EdgeInsets safePadding,
  }) {
    // 尝试右侧
    double x = anchor.dx + 20;
    double y = anchor.dy - cardSize.height / 2;
    // 如果右侧超出，尝试左侧
    if (x + cardSize.width > viewport.width - safePadding.right) {
      x = anchor.dx - cardSize.width - 20;
    }
    // 如果左侧也超出，水平居中
    if (x < safePadding.left) {
      x = (viewport.width - cardSize.width) / 2;
    }
    // 垂直 clamp
    if (y < safePadding.top) {
      y = safePadding.top;
    }
    if (y + cardSize.height > viewport.height - safePadding.bottom) {
      y = viewport.height - safePadding.bottom - cardSize.height;
    }
    return Offset(
      x.clamp(safePadding.left,
          viewport.width - cardSize.width - safePadding.right),
      y.clamp(safePadding.top,
          viewport.height - cardSize.height - safePadding.bottom),
    );
  }

  @override
  Widget build(BuildContext context) {
    _handleNavigationIntent(context, ref);
    if (!mounted) return const SizedBox();
    final selectedRegion = ref.watch(selectedRegionProvider);
    final nodeScreenPos = ref.watch(nodeScreenPositionProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const WorldMapToolbar(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final viewport = constraints.biggest;
                    final cardWidth = (viewport.width - 32).clamp(280.0, 340.0);
                    const cardBaseHeight = 340.0;

                    return ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        children: [
                          WorldMapCanvas(onNodeTap: _onNodeTap),
                          // ── 信息卡（自适应位置） ──
                          if (selectedRegion != null)
                            Builder(builder: (context) {
                              final anchor = nodeScreenPos ??
                                  Offset(
                                      viewport.width / 2, viewport.height / 2);
                              final cardSize = Size(cardWidth, cardBaseHeight);
                              final pos = calculateSafeOverlayPosition(
                                viewport: viewport,
                                anchor: anchor,
                                cardSize: cardSize,
                                safePadding: const EdgeInsets.all(16),
                              );
                              return Positioned(
                                left: pos.dx,
                                top: pos.dy,
                                child: SizedBox(
                                  width: cardWidth,
                                  height: (viewport.height * 0.55).clamp(
                                      cardBaseHeight, viewport.height * 0.7),
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxHeight: viewport.height * 0.7,
                                    ),
                                    child: CivilizationInfoCard(
                                      region: selectedRegion,
                                      onDismiss: _dismissInfoCard,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          // ── 缩放控制 ──
                          Positioned(
                            right: 12,
                            bottom: 12,
                            child: Consumer(builder: (context, ref, _) {
                              final zoomPct = ref.watch(zoomDisplayProvider);
                              return MapZoomControls(
                                zoomPercent: zoomPct,
                                onZoomIn: () => ref
                                    .read(mapZoomActionProvider.notifier)
                                    .state = MapZoomAction.zoomIn,
                                onZoomOut: () => ref
                                    .read(mapZoomActionProvider.notifier)
                                    .state = MapZoomAction.zoomOut,
                                onResetView: () => ref
                                    .read(mapResetViewProvider.notifier)
                                    .state++,
                              );
                            }),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(32, 20, 32, 8),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.shimmerGold,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.public, color: AppTheme.gold, size: 20),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('世界文明地图',
                  style: TextStyle(
                    color: AppTheme.paper,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'PingFang SC',
                  )),
              const SizedBox(height: 2),
              Text('探索文明如何连接世界',
                  style: TextStyle(
                    color: AppTheme.paper.withAlpha(140),
                    fontSize: 14,
                    fontFamily: 'PingFang SC',
                  )),
            ],
          ),
        ],
      ),
    );
  }
}
