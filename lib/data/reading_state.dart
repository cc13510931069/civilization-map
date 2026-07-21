import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/highlighted_evidence.dart';
import '../models/reading_chapter.dart';

// ───────────────────────────────────────────────────────────────
//  当前阅读章节
import '../models/evidence_type.dart';
// ───────────────────────────────────────────────────────────────

final currentChapterProvider = Provider<ReadingChapter>((ref) {
  return ReadingChapter.chapter26;
});

// ───────────────────────────────────────────────────────────────
//  标记的证据列表
// ───────────────────────────────────────────────────────────────

class EvidenceListNotifier extends StateNotifier<List<HighlightedEvidence>> {
  EvidenceListNotifier() : super([]);

  void addEvidence(HighlightedEvidence evidence) {
    state = [...state, evidence];
  }

  void removeEvidence(String id) {
    state = state.where((e) => e.id != id).toList();
  }

  int countByType(EvidenceType type) {
    return state.where((e) => e.type == type).length;
  }

  /// 将阅读证据导出为 Mission 系统可用的格式
  /// 返回 evidence names 列表，用于扩充思考实验室的证据池
  List<String> exportEvidenceForMission() {
    return state.map((e) => e.text).toList();
  }
}

final readingEvidenceProvider =
    StateNotifierProvider<EvidenceListNotifier, List<HighlightedEvidence>>(
  (ref) => EvidenceListNotifier(),
);

// ───────────────────────────────────────────────────────────────
//  已完成阅读任务
// ───────────────────────────────────────────────────────────────

final completedTasksProvider = StateProvider<Set<ReadingTask>>((ref) => {});

void completeTask(WidgetRef ref, ReadingTask task) {
  final current = ref.read(completedTasksProvider);
  ref.read(completedTasksProvider.notifier).state = {...current, task};
}

// ───────────────────────────────────────────────────────────────
//  Veggie 阅读引导提示
// ───────────────────────────────────────────────────────────────

final veggieHintProvider = StateProvider<String>((ref) {
  return '开始阅读后，选择文本片段并标记为证据，Veggie 将为你提供引导。';
});

void updateVeggieHint(WidgetRef ref, String hint) {
  ref.read(veggieHintProvider.notifier).state = hint;
}

// ───────────────────────────────────────────────────────────────
//  当前选中的文本（用于证据标记）
// ───────────────────────────────────────────────────────────────

final selectedTextProvider = StateProvider<String>((ref) => '');

void setSelectedText(WidgetRef ref, String text) {
  ref.read(selectedTextProvider.notifier).state = text;
}
