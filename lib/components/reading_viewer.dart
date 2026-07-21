import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../components/reading_text_control.dart';
import '../models/reading_chapter.dart';
import '../data/reading_state.dart';
import '../data/typography_state.dart';

/// 阅读内容展示组件
///
/// 显示章节标题、摘要和正文。
/// 支持文本选择，选中后可通过浮动按钮标记为证据。
class ReadingViewer extends ConsumerStatefulWidget {
  final ReadingChapter chapter;

  const ReadingViewer({super.key, required this.chapter});

  @override
  ConsumerState<ReadingViewer> createState() => _ReadingViewerState();
}

class _ReadingViewerState extends ConsumerState<ReadingViewer> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chapter = widget.chapter;
    final paragraphs = chapter.content.split('\n\n');
    final double readingFontSize = ref.watch(readingFontSizeProvider);
    final double readingLineHeight = ref.watch(readingLineHeightProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── 章节标题 ──
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.shimmerGold,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text('第${chapter.number}章',
                style: TextStyle(
                  color: AppTheme.gold,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'PingFang SC',
                )),
          ),
        ),
        Text(chapter.title,
            style: TextStyle(
              color: AppTheme.paper,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              fontFamily: 'PingFang SC',
              height: 1.3,
            )),
        const SizedBox(height: 12),
        // ── 摘要 ──
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.surfaceLight,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.gold.withAlpha(30), width: 0.5),
          ),
          child: Text(chapter.summary,
              style: TextStyle(
                color: AppTheme.paper.withAlpha(200),
                fontSize: 14,
                height: 1.6,
                fontFamily: 'PingFang SC',
              )),
        ),
        const SizedBox(height: 12),
        // ── 阅读控制 ──
        const ReadingTextControl(),
        const SizedBox(height: 12),
        // ── 正文 ──
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: paragraphs.map((para) {
                final trimmed = para.trim();
                if (trimmed.isEmpty) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: SelectableText(
                    trimmed,
                    style: TextStyle(
                      color: AppTheme.paper.withAlpha(220),
                      fontSize: readingFontSize,
                      height: readingLineHeight,
                      fontFamily: 'PingFang SC',
                    ),
                    onSelectionChanged: (selection, _) {
                      if (selection != null && selection.isValid) {
                        final selected = trimmed.substring(
                          selection.start,
                          selection.end,
                        );
                        if (selected.trim().isNotEmpty) {
                          setSelectedText(ref, selected);
                        }
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
