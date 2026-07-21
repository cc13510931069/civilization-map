import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/civilization_reasoning_profile.dart';

/// 文明解释能力画像卡片
///
/// 以星级 + 进度条展示四项维度的能力数值。
/// 不显示普通分数——星级让人更关注能力成长而非数字竞争。
class ReasoningProfileCard extends StatelessWidget {
  final CivilizationReasoningProfile profile;

  const ReasoningProfileCard({super.key, required this.profile});

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
          // ── 标题 ──
          Row(children: [
            Icon(Icons.auto_awesome, color: AppTheme.gold, size: 16),
            const SizedBox(width: 8),
            Text('文明解释能力画像',
                style: TextStyle(
                  color: AppTheme.paper,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'PingFang SC',
                )),
          ]),
          const SizedBox(height: 16),

          _buildDimension(
            label: '地理定位',
            score: profile.geographicUnderstanding,
            maxScore: 25,
            barColor: AppTheme.gold,
          ),
          const SizedBox(height: 10),
          _buildDimension(
            label: '证据使用',
            score: profile.evidenceUsage,
            maxScore: 25,
            barColor: AppTheme.green,
          ),
          const SizedBox(height: 10),
          _buildDimension(
            label: '因果分析',
            score: profile.historicalCausality,
            maxScore: 30,
            barColor: const Color(0xFF5B9BD5),
          ),
          const SizedBox(height: 10),
          _buildDimension(
            label: '观点表达',
            score: profile.personalExplanation,
            maxScore: 20,
            barColor: const Color(0xFFD9A441),
          ),

          const Divider(color: AppTheme.divider, height: 24),

          // ── 总分 ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('总分',
                  style: TextStyle(
                    color: AppTheme.paper,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'PingFang SC',
                  )),
              Text('${profile.total}/100',
                  style: TextStyle(
                    color: profile.total >= 60 ? AppTheme.gold : AppTheme.green,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDimension({
    required String label,
    required int score,
    required int maxScore,
    required Color barColor,
  }) {
    final starCount =
        CivilizationReasoningProfile.toStarRating(score, maxScore);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: TextStyle(
                  color: AppTheme.paper,
                  fontSize: 13,
                  fontFamily: 'PingFang SC',
                )),
            Row(
              children: [
                _buildStars(starCount),
                const SizedBox(width: 8),
                Text('$score/$maxScore',
                    style: TextStyle(
                      color: AppTheme.paper.withAlpha(100),
                      fontSize: 11,
                    )),
              ],
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: Container(
            height: 5,
            decoration: BoxDecoration(
              color: AppTheme.background,
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: maxScore > 0 ? score / maxScore : 0,
              child: Container(
                decoration: BoxDecoration(
                  color: barColor,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStars(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = i < rating;
        final half = !filled && i < rating + 0.5;
        return Icon(
          filled
              ? Icons.star
              : half
                  ? Icons.star_half
                  : Icons.star_border,
          color: AppTheme.gold,
          size: 14,
        );
      }),
    );
  }
}
