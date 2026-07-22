import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'mission_state.dart';
import 'reading_state.dart';
import '../models/exploration_progress.dart';

/// 首页文明任务状态枚举
enum HomeCivilizationTaskStatus {
  notStarted,
  inProgress,
  completed,
}

/// 地图任务状态：高加索发现点完成度
final homeMapTaskStatusProvider = Provider<HomeCivilizationTaskStatus>((ref) {
  final progress = ref.watch(explorationProgressProvider).forRegion('caucasus');
  if (progress.allCollected) {
    return HomeCivilizationTaskStatus.completed;
  }
  if (progress.collectedIds.isNotEmpty) {
    return HomeCivilizationTaskStatus.inProgress;
  }
  return HomeCivilizationTaskStatus.notStarted;
});

/// 阅读任务状态：第26章证据或阅读完成
final homeReadingTaskStatusProvider =
    Provider<HomeCivilizationTaskStatus>((ref) {
  final evidence = ref.watch(readingEvidenceProvider);
  final hasCh26Evidence = evidence.any((e) => e.chapterNumber == 26);
  if (hasCh26Evidence) {
    return HomeCivilizationTaskStatus.completed;
  }
  if (evidence.isNotEmpty) {
    return HomeCivilizationTaskStatus.inProgress;
  }
  return HomeCivilizationTaskStatus.notStarted;
});

/// Mission 任务状态：正式提交结果
final homeMissionTaskStatusProvider =
    Provider<HomeCivilizationTaskStatus>((ref) {
  final snapshot = ref.watch(missionResultSnapshotProvider);
  if (snapshot != null && snapshot.submissionVersion >= 1) {
    return HomeCivilizationTaskStatus.completed;
  }
  final answers = ref.watch(stepAnswersProvider);
  final evidence = ref.watch(missionEvidenceProvider);
  if (answers.isNotEmpty || evidence.isNotEmpty) {
    return HomeCivilizationTaskStatus.inProgress;
  }
  return HomeCivilizationTaskStatus.notStarted;
});

/// 当前推荐任务编号（1=地图，2=阅读，3=Mission）
/// 返回第一个未完成的任务编号，全部完成时返回 null
final currentRecommendedHomeTaskProvider = Provider<int?>((ref) {
  final mapTask = ref.watch(homeMapTaskStatusProvider);
  final readingTask = ref.watch(homeReadingTaskStatusProvider);
  final missionTask = ref.watch(homeMissionTaskStatusProvider);
  if (mapTask != HomeCivilizationTaskStatus.completed) return 1;
  if (readingTask != HomeCivilizationTaskStatus.completed) return 2;
  if (missionTask != HomeCivilizationTaskStatus.completed) return 3;
  return null;
});
