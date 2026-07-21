import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../models/civilization_explanation.dart';

/// 解释模块卡片 — 中央作品区的单个模块
///
/// 显示：表情 + 标题 + 学生回答（或空状态）+ 编辑按钮。
class ExplanationSectionCard extends StatelessWidget {
  final ExplanationModule module;
  final String content;
  final bool isComplete;

  const ExplanationSectionCard({
    super.key,
    required this.module,
    this.content = '',
    this.isComplete = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasContent = content.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark.withAlpha(200),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isComplete
              ? AppTheme.green.withAlpha(60)
              : hasContent
                  ? AppTheme.gold.withAlpha(40)
                  : AppTheme.divider,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 模块头部 ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isComplete
                      ? AppTheme.green.withAlpha(25)
                      : AppTheme.shimmerGold,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(module.emoji, style: const TextStyle(fontSize: 18)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(module.title,
                        style: TextStyle(
                          color: AppTheme.paper,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'PingFang SC',
                        )),
                    Text(module.titleEn,
                        style: TextStyle(
                          color: AppTheme.paper.withAlpha(80),
                          fontSize: 11,
                          fontFamily: 'PingFang SC',
                        )),
                  ],
                ),
              ),
              // ── 状态标签 ──
              if (isComplete)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.green.withAlpha(25),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text('已完成',
                      style: TextStyle(
                        color: AppTheme.green,
                        fontSize: 10,
                        fontFamily: 'PingFang SC',
                      )),
                )
              else if (hasContent)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.shimmerGold,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text('草稿',
                      style: TextStyle(
                        color: AppTheme.gold,
                        fontSize: 10,
                        fontFamily: 'PingFang SC',
                      )),
                ),
            ],
          ),
          const SizedBox(height: 12),
          // ── 内容 ──
          if (hasContent)
            Text(content,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppTheme.paper.withAlpha(200),
                  fontSize: 13,
                  height: 1.6,
                  fontFamily: 'PingFang SC',
                ))
          else
            Text('尚未填写思考内容',
                style: TextStyle(
                  color: AppTheme.paper.withAlpha(60),
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  fontFamily: 'PingFang SC',
                )),
          const SizedBox(height: 12),
          // ── 编辑按钮 ──
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => context.go('/mission'),
              icon: Icon(Icons.edit_outlined, color: AppTheme.gold, size: 14),
              label: Text(isComplete ? '完善' : '去填写',
                  style: TextStyle(
                    color: AppTheme.gold,
                    fontSize: 12,
                    fontFamily: 'PingFang SC',
                  )),
            ),
          ),
        ],
      ),
    );
  }
}
