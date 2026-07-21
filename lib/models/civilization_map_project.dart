import 'exploration_progress.dart';
import 'highlighted_evidence.dart';
import 'civilization_reasoning_profile.dart';

/// 文明地图作品 — 学生的完整研究聚合
///
/// 整合来自 WorldMap / Caucasus / Reading / Mission 的全部数据，
/// 形成一份可保存、可分享、可导出的文明研究作品。
class CivilizationMapProject {
  final String regionId;
  final String regionName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<DiscoveryPoint> discoveredPoints;
  final List<HighlightedEvidence> readingEvidences;
  final Map<int, String> thinkingSteps; // stepNumber -> answer
  final CivilizationReasoningProfile? profile;

  CivilizationMapProject({
    required this.regionId,
    this.regionName = '高加索',
    DateTime? createdAt,
    DateTime? updatedAt,
    this.discoveredPoints = const [],
    this.readingEvidences = const [],
    this.thinkingSteps = const {},
    this.profile,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  int get discoveryCount => discoveredPoints.length;
  int get readingEvidenceCount => readingEvidences.length;
  int get totalEvidence => discoveryCount + readingEvidenceCount;
  int get stepsCompleted =>
      thinkingSteps.values.where((t) => t.trim().isNotEmpty).length;
  bool get hasProfile => profile != null;

  /// 项目完整度百分比
  int get completeness {
    final discoveryScore = (discoveryCount / 3 * 20).round().clamp(0, 20);
    final readingScore = (readingEvidenceCount / 4 * 20).round().clamp(0, 20);
    final stepScore = (stepsCompleted / 5 * 30).round().clamp(0, 30);
    final profileScore = hasProfile ? 30 : 0;
    return (discoveryScore + readingScore + stepScore + profileScore)
        .clamp(0, 100);
  }
}

/// 预定义文明区域列表（预留扩展）
class CivilizationRegionMeta {
  final String id;
  final String name;

  const CivilizationRegionMeta({required this.id, required this.name});

  static const List<CivilizationRegionMeta> allRegions = [
    CivilizationRegionMeta(id: 'caucasus', name: '高加索'),
    // 未来扩展：china, central-asia, persia, mediterranean ...
  ];
}
