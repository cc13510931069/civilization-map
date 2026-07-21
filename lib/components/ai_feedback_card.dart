import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/ai_feedback.dart';

/// AI 导师反馈卡片
///
/// 为五步框架中当前步骤提供三层结构化反馈：
/// ✓ 发现 — △ 可加强 — ? 下一步思考
class AiFeedbackCard extends StatelessWidget {
  final AiFeedback feedback;

  const AiFeedbackCard({super.key, required this.feedback});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.divider, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 导师头部 ──
          Row(children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppTheme.shimmerGold,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.pets, color: AppTheme.gold, size: 16),
            ),
            const SizedBox(width: 8),
            Text('Veggie · 文明导师',
                style: TextStyle(
                  color: AppTheme.paper,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'PingFang SC',
                )),
          ]),
          const SizedBox(height: 16),

          // ── 发现 ✓ ──
          _buildSection(
            icon: Icons.check_circle_outline,
            iconColor: AppTheme.green,
            label: '发现',
            text: feedback.discovery,
          ),
          const SizedBox(height: 14),

          // ── 可加强 △ ──
          _buildSection(
            icon: Icons.trending_up,
            iconColor: AppTheme.gold,
            label: '可以加强',
            text: feedback.improvement,
          ),
          const SizedBox(height: 14),

          // ── 下一步 ? ──
          _buildSection(
            icon: Icons.lightbulb_outline,
            iconColor: const Color(0xFF5B9BD5),
            label: '下一步思考',
            text: feedback.nextPrompt,
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String text,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                    color: iconColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'PingFang SC',
                  )),
              const SizedBox(height: 4),
              Text(text,
                  style: TextStyle(
                    color: AppTheme.paper.withAlpha(200),
                    fontSize: 13,
                    height: 1.6,
                    fontFamily: 'PingFang SC',
                  )),
            ],
          ),
        ),
      ],
    );
  }
}
