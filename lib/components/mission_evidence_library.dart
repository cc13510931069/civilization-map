import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../models/exploration_progress.dart';
import '../models/evidence_type.dart';
import '../models/highlighted_evidence.dart';
import '../data/reading_state.dart';
import '../data/typography_state.dart';

/// 证据库 — 右侧面板下半部分
///
/// 分组显示地图发现和阅读证据，支持展开/收起长文本。
class MissionEvidenceLibrary extends ConsumerStatefulWidget {
  const MissionEvidenceLibrary({super.key});

  @override
  ConsumerState<MissionEvidenceLibrary> createState() =>
      _MissionEvidenceLibraryState();
}

class _MissionEvidenceLibraryState
    extends ConsumerState<MissionEvidenceLibrary> {
  final Set<String> _expandedIds = {};

  @override
  Widget build(BuildContext context) {
    final progress =
        ref.watch(explorationProgressProvider).forRegion('caucasus');
    final readingEvidence = ref.watch(readingEvidenceProvider);

    final discoveries = DiscoveryPoint.caucasus
        .where((p) => progress.isCollected(p.id))
        .toList();

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark.withAlpha(200),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.divider, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 证据库标题 ──
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
            child: Row(children: [
              Icon(Icons.lightbulb_outline, color: AppTheme.gold, size: 14),
              const SizedBox(width: 6),
              Text('证据库',
                  style: TextStyle(
                      color: AppTheme.paper,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'PingFang SC')),
              const Spacer(),
              Text('${discoveries.length + readingEvidence.length} 条',
                  style: TextStyle(
                      color: AppTheme.paper.withAlpha(100),
                      fontSize: 11,
                      fontFamily: 'PingFang SC')),
            ]),
          ),
          const Divider(color: AppTheme.divider, height: 8),

          // ── 地图发现 ──
          if (discoveries.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 6, 14, 6),
              child: Text('地图发现',
                  style: TextStyle(
                      color: AppTheme.gold,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'PingFang SC')),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
              child: Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children:
                      discoveries.map((d) => _buildDiscoveryChip(d)).toList()),
            ),
          ],

          // ── 阅读证据 ──
          if (readingEvidence.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 4, 14, 6),
              child: Text('阅读证据',
                  style: TextStyle(
                      color: AppTheme.gold.withAlpha(180),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'PingFang SC')),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
                itemCount: readingEvidence.length,
                itemBuilder: (_, i) => _buildEvidenceCard(readingEvidence[i]),
              ),
            ),
          ],

          // ── 空状态 ──
          if (discoveries.isEmpty && readingEvidence.isEmpty)
            Expanded(
              child: Center(
                child: Text(
                  '完成高加索探索和精读营后会在这里显示收集的证据。',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: AppTheme.paper.withAlpha(80),
                      fontSize: 12,
                      fontFamily: 'PingFang SC'),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDiscoveryChip(DiscoveryPoint point) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.green.withAlpha(25),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppTheme.green.withAlpha(60), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, color: AppTheme.green, size: 12),
          const SizedBox(width: 4),
          Text(point.name,
              style: TextStyle(
                  color: AppTheme.paper,
                  fontSize: 12,
                  fontFamily: 'PingFang SC')),
        ],
      ),
    );
  }

  Widget _buildEvidenceCard(HighlightedEvidence ev) {
    final expanded = _expandedIds.contains(ev.id);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: GestureDetector(
        onTap: () {
          setState(() {
            if (expanded) {
              _expandedIds.remove(ev.id);
            } else {
              _expandedIds.add(ev.id);
            }
          });
        },
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.background,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.divider, width: 0.3),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 类型标签 + 展开状态 ──
              Row(children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _typeColor(ev.type).withAlpha(25),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(ev.type.label,
                      style: TextStyle(
                          color: _typeColor(ev.type),
                          fontSize: 10,
                          fontFamily: 'PingFang SC')),
                ),
                const Spacer(),
                Icon(expanded ? Icons.unfold_less : Icons.unfold_more,
                    color: AppTheme.paper.withAlpha(100), size: 14),
              ]),
              const SizedBox(height: 6),
              // ── 证据正文 ──
              Text(
                ev.text,
                maxLines: expanded ? null : 3,
                overflow: expanded ? null : TextOverflow.ellipsis,
                style: TextStyle(
                    color: AppTheme.paper.withAlpha(200),
                    fontSize: 13,
                    height: 1.5,
                    fontFamily: 'PingFang SC'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _typeColor(EvidenceType type) {
    switch (type) {
      case EvidenceType.geographic:
        return AppTheme.gold;
      case EvidenceType.historical:
        return const Color(0xFF5B9BD5);
      case EvidenceType.people:
        return AppTheme.green;
      case EvidenceType.change:
        return const Color(0xFFD9A441);
    }
  }
}
