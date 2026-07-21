import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/chapter.dart';

/// 章节探索路径 — Duolingo 风格
///
/// 垂直时间线样式，显示区域内的 5 章内容。
/// 当前章节金色高亮，后续章节锁定。
class ChapterPath extends StatelessWidget {
  final String regionId;

  const ChapterPath({super.key, this.regionId = 'caucasus'});

  @override
  Widget build(BuildContext context) {
    final chapters = Chapter.forRegion(regionId);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark.withAlpha(200),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.divider, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 标题 ──
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 16),
            child: Row(
              children: [
                Icon(Icons.menu_book, color: AppTheme.gold, size: 16),
                const SizedBox(width: 8),
                Text(
                  '章节探索路径',
                  style: TextStyle(
                    color: AppTheme.paper,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'PingFang SC',
                  ),
                ),
              ],
            ),
          ),
          // ── 章节列表 ──
          Expanded(
            child: ListView.builder(
              itemCount: chapters.length,
              itemBuilder: (context, index) {
                final chapter = chapters[index];
                final isLast = index == chapters.length - 1;
                return _ChapterNode(chapter: chapter, isLast: isLast);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ChapterNode extends StatelessWidget {
  final Chapter chapter;
  final bool isLast;

  const _ChapterNode({required this.chapter, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final isAvailable = chapter.status == ChapterStatus.available;
    final isCompleted = chapter.status == ChapterStatus.completed;
    final isLocked = chapter.status == ChapterStatus.locked;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 左侧节点 + 连接线 ──
          SizedBox(
            width: 32,
            child: Column(
              children: [
                // 节点圆
                Container(
                  width: isAvailable ? 22 : 18,
                  height: isAvailable ? 22 : 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isAvailable
                        ? AppTheme.gold
                        : isCompleted
                            ? AppTheme.green
                            : AppTheme.paper.withAlpha(40),
                    border: Border.all(
                      color: isAvailable
                          ? AppTheme.gold
                          : AppTheme.paper.withAlpha(40),
                      width: 1.5,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: isLocked
                      ? Icon(Icons.lock_outline,
                          color: AppTheme.paper.withAlpha(80), size: 10)
                      : isCompleted
                          ? Icon(Icons.check,
                              color: AppTheme.background, size: 12)
                          : Text(
                              '${chapter.number}',
                              style: TextStyle(
                                color: AppTheme.background,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'PingFang SC',
                              ),
                            ),
                ),
                // 连接线
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1.5,
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: isAvailable
                              ? [AppTheme.gold, AppTheme.paper.withAlpha(30)]
                              : [
                                  AppTheme.paper.withAlpha(30),
                                  AppTheme.paper.withAlpha(30)
                                ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // ── 右侧内容 ──
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题
                  Text(
                    '第${chapter.number}章',
                    style: TextStyle(
                      color: isAvailable
                          ? AppTheme.gold
                          : AppTheme.paper.withAlpha(100),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'PingFang SC',
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    chapter.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isLocked
                          ? AppTheme.paper.withAlpha(80)
                          : AppTheme.paper,
                      fontSize: 13,
                      height: 1.4,
                      fontFamily: 'PingFang SC',
                    ),
                  ),
                  const SizedBox(height: 4),
                  // 状态标签
                  _buildStatusBadge(chapter),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(Chapter ch) {
    switch (ch.status) {
      case ChapterStatus.available:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppTheme.shimmerGold,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            '当前开放',
            style: TextStyle(
              color: AppTheme.gold,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              fontFamily: 'PingFang SC',
            ),
          ),
        );
      case ChapterStatus.completed:
        return Row(
          children: [
            Icon(Icons.check_circle, color: AppTheme.green, size: 12),
            const SizedBox(width: 4),
            Text(
              '已完成',
              style: TextStyle(
                color: AppTheme.green,
                fontSize: 10,
                fontFamily: 'PingFang SC',
              ),
            ),
          ],
        );
      case ChapterStatus.locked:
        return Text(
          '完成探索高加索后解锁',
          style: TextStyle(
            color: AppTheme.paper.withAlpha(60),
            fontSize: 10,
            fontFamily: 'PingFang SC',
          ),
        );
    }
  }
}
