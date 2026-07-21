import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../models/exploration_progress.dart';
import '../components/caucasus_map.dart';
import '../components/chapter_path.dart';
import '../components/discovery_card.dart';

/// 高加索文明探索页面
class CaucasusScreen extends ConsumerStatefulWidget {
  const CaucasusScreen({super.key});

  @override
  ConsumerState<CaucasusScreen> createState() => _CaucasusScreenState();
}

class _CaucasusScreenState extends ConsumerState<CaucasusScreen> {
  void _collectDiscovery(DiscoveryPoint point) {
    ref
        .read(explorationProgressProvider.notifier)
        .collectDiscovery('caucasus', point.id);
  }

  void _dismissDiscovery() {
    ref.read(activeDiscoveryProvider.notifier).state = null;
  }

  @override
  Widget build(BuildContext context) {
    final progress =
        ref.watch(explorationProgressProvider).forRegion('caucasus');
    final activePoint = ref.watch(activeDiscoveryProvider);
    final allCollected = progress.allCollected;
    final cardBottom = allCollected ? 88.0 : 16.0;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(progress),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                        flex: 3,
                        child: Stack(
                          children: [
                            const CaucasusMap(),
                            if (activePoint != null)
                              Positioned(
                                left: 16,
                                bottom: cardBottom,
                                child: SizedBox(
                                  width: 300,
                                  child: DiscoveryCard(
                                    point: activePoint,
                                    isCollected:
                                        progress.isCollected(activePoint.id),
                                    onCollect: () =>
                                        _collectDiscovery(activePoint),
                                    onDismiss: _dismissDiscovery,
                                  ),
                                ),
                              ),
                          ],
                        )),
                    const SizedBox(width: 12),
                    const SizedBox(width: 240, child: ChapterPath()),
                  ],
                ),
              ),
            ),
            _buildCompletionBar(allCollected),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(RegionProgress progress) {
    return Container(
      padding: const EdgeInsets.fromLTRB(32, 20, 32, 16),
      child: Row(children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppTheme.shimmerGold,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.landscape, color: AppTheme.gold, size: 20),
        ),
        const SizedBox(width: 14),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('高加索',
              style: TextStyle(
                color: AppTheme.paper,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                fontFamily: 'PingFang SC',
              )),
          const SizedBox(height: 2),
          Text('欧亚交界线上的民族博物馆',
              style: TextStyle(
                color: AppTheme.paper.withAlpha(140),
                fontSize: 13,
                fontFamily: 'PingFang SC',
              )),
        ]),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.surfaceLight,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.divider, width: 0.5),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.explore, color: AppTheme.gold, size: 16),
            const SizedBox(width: 6),
            Text('探索进度 ${progress.progress}/3',
                style: TextStyle(
                  color: progress.allCollected ? AppTheme.gold : AppTheme.paper,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'PingFang SC',
                )),
          ]),
        ),
      ]),
    );
  }

  Widget _buildCompletionBar(bool show) {
    // Animation for show/hide transition with dynamic height
    return AnimatedSize(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      child: show
          ? Padding(
              padding: const EdgeInsets.fromLTRB(32, 0, 32, 20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 64),
                child: Container(
                  key: const Key('caucasus_completion_bar'),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      AppTheme.gold.withAlpha(30),
                      AppTheme.surfaceDark,
                    ], begin: Alignment.centerLeft, end: Alignment.centerRight),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: AppTheme.gold.withAlpha(80), width: 0.5),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.auto_awesome, color: AppTheme.gold, size: 22),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          '你找到了高加索成为文明交汇点的三个关键证据。',
                          maxLines: 2,
                          softWrap: true,
                          overflow: TextOverflow.visible,
                          style: TextStyle(
                              color: AppTheme.paper,
                              fontSize: 15,
                              fontFamily: 'PingFang SC'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: () => context.go('/mission'),
                        icon: const Icon(Icons.psychology, size: 18),
                        label: Text('开始文明思考',
                            style: TextStyle(
                              color: AppTheme.background,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'PingFang SC',
                            )),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.gold,
                          foregroundColor: AppTheme.background,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}
