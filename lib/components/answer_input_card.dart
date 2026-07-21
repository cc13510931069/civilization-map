import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// 思考输入卡片
///
/// 为每一步提供干净的文本输入区，支持多行。
/// 不设计成聊天输入框样式。
class AnswerInputCard extends StatelessWidget {
  final String prompt;
  final String? initialValue;
  final ValueChanged<String>? onSubmitted;
  final TextEditingController? controller;
  final FocusNode? focusNode;

  const AnswerInputCard({
    super.key,
    required this.prompt,
    this.initialValue,
    this.onSubmitted,
    this.controller,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.divider, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 提示文字 ──
          Text(
            prompt,
            style: TextStyle(
              color: AppTheme.paper.withAlpha(160),
              fontSize: 13,
              height: 1.5,
              fontFamily: 'PingFang SC',
            ),
          ),
          const SizedBox(height: 10),
          // ── 输入框 ──
          TextField(
            controller: controller,
            focusNode: focusNode,
            maxLines: 5,
            minLines: 3,
            style: TextStyle(
              color: AppTheme.paper,
              fontSize: 14,
              height: 1.6,
              fontFamily: 'PingFang SC',
            ),
            decoration: InputDecoration(
              hintText: '在此输入你的思考...',
              hintStyle: TextStyle(
                color: AppTheme.paper.withAlpha(60),
                fontSize: 14,
                fontFamily: 'PingFang SC',
              ),
              filled: true,
              fillColor: AppTheme.surfaceDark.withAlpha(150),
              contentPadding: const EdgeInsets.all(14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: AppTheme.gold.withAlpha(80),
                  width: 1,
                ),
              ),
            ),
            textInputAction: TextInputAction.newline,
            onChanged: onSubmitted,
          ),
        ],
      ),
    );
  }
}
