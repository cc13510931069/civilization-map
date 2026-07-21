import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../models/evidence_type.dart';
import '../models/highlighted_evidence.dart';
import '../models/reading_chapter.dart';
import '../data/reading_state.dart';
import '../components/reading_viewer.dart';
import '../components/reading_ai_panel.dart';
import '../components/evidence_marker.dart';
import '../components/highlight_toolbar.dart';
import '../services/reading_assistant_service.dart';

/// 文明精读营
///
/// ┌────────────────────────────────────────────────────────────┐
/// │  📖 第26章 · 高加索：欧亚交界线上的民族博物馆              │
/// ├──────────────────────────────────────┬─────────────────────┤
/// │  [ReadingViewer]                     │  [ReadingAIPanel]   │
/// │                                      │                     │
/// │  正文 (SelectableText per para)      │  ✓ 地理线索        │
/// │                                      │  ☐ 历史变化        │
/// │  ┌─────────────────────────────┐    │  ☐ 人群互动        │
/// │  │ ✨ 标记为证据          ✕    │    │  ☐ 文明演变        │
/// │  └─────────────────────────────┘    │                     │
/// │       ↑ HighlightToolbar            │  已标记证据 (3)    │
/// │       选中文本时浮动出现            │                     │
/// │                                      │  ● 高加索位于...  │
/// │                                      │  ● 30多种语言...  │
/// │                                      │                     │
/// │                                      │  💡 Veggie 提示   │
/// └──────────────────────────────────────┴─────────────────────┘
class ReadingCampScreen extends ConsumerStatefulWidget {
  const ReadingCampScreen({super.key});

  @override
  ConsumerState<ReadingCampScreen> createState() => _ReadingCampScreenState();
}

class _ReadingCampScreenState extends ConsumerState<ReadingCampScreen> {
  int _evidenceIdCounter = 0;

  void _markAsEvidence() {
    final text = ref.read(selectedTextProvider);
    if (text.isEmpty) return;

    showDialog(
      context: context,
      builder: (ctx) => EvidenceMarker(
        selectedText: text,
        onConfirm: (type) {
          Navigator.of(ctx).pop();
          _saveEvidence(text, type);
        },
      ),
    );
  }

  void _saveEvidence(String text, EvidenceType type) {
    _evidenceIdCounter++;
    final evidence = HighlightedEvidence(
      id: 'reading-evidence-$_evidenceIdCounter',
      text: text,
      chapterNumber: 26,
      type: type,
    );

    ref.read(readingEvidenceProvider.notifier).addEvidence(evidence);

    // 更新 Veggie 提示
    final allEvidence = ref.read(readingEvidenceProvider);
    final completed = ref.read(completedTasksProvider);
    final chapter = ref.read(currentChapterProvider);
    final hint = ReadingAssistantService.generateHint(
      chapter: chapter,
      evidence: allEvidence,
      completedTasks: completed,
    );
    updateVeggieHint(ref, hint);

    // 更新任务状态
    _updateTasks(type);

    // 清除选中文本
    setSelectedText(ref, '');
  }

  void _updateTasks(EvidenceType type) {
    switch (type) {
      case EvidenceType.geographic:
        completeTask(ref, ReadingTask.geographic);
      case EvidenceType.historical:
        completeTask(ref, ReadingTask.historical);
      case EvidenceType.people:
        completeTask(ref, ReadingTask.people);
      case EvidenceType.change:
        completeTask(ref, ReadingTask.change);
    }
  }

  @override
  Widget build(BuildContext context) {
    final chapter = ref.watch(currentChapterProvider);
    final selectedText = ref.watch(selectedTextProvider);
    final hasSelection = selectedText.trim().isNotEmpty;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ═══════════════════════════════════════════
            //  1. Header
            // ═══════════════════════════════════════════
            _buildHeader(chapter),

            // ═══════════════════════════════════════════
            //  2. 双栏主体
            // ═══════════════════════════════════════════
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── 左栏：阅读区 ──
                    Expanded(
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceDark.withAlpha(180),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ReadingViewer(chapter: chapter),
                            ),
                          ),
                          // ── 浮动工具栏 ──
                          if (hasSelection)
                            Positioned(
                              top: 12,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: HighlightToolbar(
                                  onMarkEvidence: _markAsEvidence,
                                  onDismiss: () {
                                    setSelectedText(ref, '');
                                  },
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // ── 右栏：Veggie 阅读导师 ──
                    const ReadingAIPanel(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ReadingChapter chapter) {
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
          child: const Icon(Icons.menu_book, color: AppTheme.gold, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('精读营',
                  style: TextStyle(
                    color: AppTheme.paper,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'PingFang SC',
                  )),
              const SizedBox(height: 2),
              Text('第${chapter.number}章 · ${chapter.title}',
                  style: TextStyle(
                    color: AppTheme.paper.withAlpha(160),
                    fontSize: 14,
                    fontFamily: 'PingFang SC',
                  )),
            ],
          ),
        ),
      ]),
    );
  }
}
