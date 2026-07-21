import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// 文本选择工具栏
///
/// 当用户在阅读区选中文本后浮动出现。
/// 提供「标记为证据」按钮，点击后打开证据标记对话框。
class HighlightToolbar extends StatelessWidget {
  final VoidCallback onMarkEvidence;
  final VoidCallback? onDismiss;

  const HighlightToolbar({
    super.key,
    required this.onMarkEvidence,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.gold.withAlpha(60), width: 0.5),
        boxShadow: [
          BoxShadow(
            color: AppTheme.background.withAlpha(150),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome, color: AppTheme.gold, size: 16),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onMarkEvidence,
            child: Text('标记为证据',
                style: TextStyle(
                  color: AppTheme.gold,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'PingFang SC',
                )),
          ),
          if (onDismiss != null) ...[
            const SizedBox(width: 12),
            Container(width: 1, height: 16, color: AppTheme.divider),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onDismiss,
              child: Icon(Icons.close,
                  color: AppTheme.paper.withAlpha(100), size: 16),
            ),
          ],
        ],
      ),
    );
  }
}
