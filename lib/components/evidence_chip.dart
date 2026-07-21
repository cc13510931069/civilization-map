import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// 证据标签组件
///
/// 显示已收集的探索证据：图标 + 名称 + 对勾状态。
class EvidenceChip extends StatelessWidget {
  final String name;
  final bool collected;

  const EvidenceChip({super.key, required this.name, this.collected = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: collected ? AppTheme.green.withAlpha(25) : AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: collected ? AppTheme.green.withAlpha(60) : AppTheme.divider,
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            collected ? Icons.check_circle : Icons.circle_outlined,
            color: collected ? AppTheme.green : AppTheme.paper.withAlpha(80),
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            name,
            style: TextStyle(
              color: collected ? AppTheme.paper : AppTheme.paper.withAlpha(100),
              fontSize: 13,
              fontFamily: 'PingFang SC',
            ),
          ),
        ],
      ),
    );
  }
}
