import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/thinking_step.dart';
import '../services/step_coaching_service.dart';
import 'answer_input_card.dart';

/// 五步解释框架中的单步卡片
///
/// 支持：输入、提交本步辅导、渐进提示、暂时跳过。
class ThinkingFrameworkCard extends StatelessWidget {
  final ThinkingStep step;
  final String? answer;
  final bool showFeedback;
  final ValueChanged<String>? onAnswerChanged;
  final VoidCallback? onSubmitStep;
  final VoidCallback? onRequestHint;
  final VoidCallback? onSkip;
  final VoidCallback? onStartWriting;
  final StepCoachingFeedback? coachingFeedback;
  final FocusNode? focusNode;
  final TextEditingController? controller;
  final StepCoachingStage coachingStage;
  final String? currentHint;
  final int hintLevel;

  const ThinkingFrameworkCard({
    super.key,
    required this.step,
    this.answer,
    this.showFeedback = false,
    this.onAnswerChanged,
    this.onSubmitStep,
    this.onRequestHint,
    this.onSkip,
    this.onStartWriting,
    this.coachingFeedback,
    this.focusNode,
    this.controller,
    this.coachingStage = StepCoachingStage.empty,
    this.currentHint,
    this.hintLevel = 0,
  });

  @override
  Widget build(BuildContext context) {
    final hasAnswer = (answer ?? '').trim().isNotEmpty;
    final hasCoaching = coachingFeedback != null;
    final hasHint = currentHint != null && currentHint!.isNotEmpty;
    final isSkipped = coachingStage == StepCoachingStage.skipped;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSkipped
              ? Colors.grey.withAlpha(50)
              : hasCoaching
                  ? AppTheme.green.withAlpha(60)
                  : AppTheme.gold.withAlpha(50),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 步骤标题 ──
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: hasCoaching ? AppTheme.green : AppTheme.gold,
                  borderRadius: BorderRadius.circular(7),
                ),
                alignment: Alignment.center,
                child: hasCoaching
                    ? const Icon(Icons.check,
                        color: AppTheme.background, size: 16)
                    : Text('${step.stepNumber}',
                        style: const TextStyle(
                          color: AppTheme.background,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'PingFang SC',
                        )),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(step.title,
                            style: TextStyle(
                              color: isSkipped
                                  ? AppTheme.paper.withAlpha(80)
                                  : AppTheme.paper,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'PingFang SC',
                            )),
                        if (isSkipped) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey.withAlpha(30),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('待完善',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 10,
                                  fontFamily: 'PingFang SC',
                                )),
                          ),
                        ],
                      ],
                    ),
                    Text(step.subtitle,
                        style: TextStyle(
                          color: AppTheme.paper.withAlpha(100),
                          fontSize: 12,
                          fontFamily: 'PingFang SC',
                        )),
                  ],
                ),
              ),
              // ── 目标标签 ──
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.shimmerGold,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(step.goal,
                    style: TextStyle(
                      color: AppTheme.gold,
                      fontSize: 10,
                      fontFamily: 'PingFang SC',
                    )),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // ── 输入区 ──
          AnswerInputCard(
            prompt: step.prompt,
            initialValue: answer,
            onSubmitted: onAnswerChanged,
            controller: controller,
            focusNode: focusNode,
          ),
          // ── 提示显示 ──
          if (hasHint) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.gold.withAlpha(10),
                borderRadius: BorderRadius.circular(8),
                border:
                    Border.all(color: AppTheme.gold.withAlpha(30), width: 0.5),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lightbulb_outline, color: AppTheme.gold, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(currentHint!,
                        style: TextStyle(
                          color: AppTheme.paper.withAlpha(190),
                          fontSize: 13,
                          height: 1.5,
                          fontFamily: 'PingFang SC',
                        )),
                  ),
                ],
              ),
            ),
          ],
          // ── 单步辅导反馈 ──
          if (hasCoaching) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.green.withAlpha(8),
                borderRadius: BorderRadius.circular(8),
                border:
                    Border.all(color: AppTheme.green.withAlpha(30), width: 0.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Icon(Icons.pets, color: AppTheme.green, size: 14),
                    const SizedBox(width: 6),
                    const Text('Veggie · 本步辅导',
                        style: TextStyle(
                          color: AppTheme.green,
                          fontSize: 11,
                          fontFamily: 'PingFang SC',
                        )),
                  ]),
                  const SizedBox(height: 8),
                  _fbLine('✅ 你已经想到', coachingFeedback!.discovery),
                  const SizedBox(height: 4),
                  _fbLine('💡 还可以补充', coachingFeedback!.improvement),
                  const SizedBox(height: 4),
                  _fbLine('🤔 再想一想', coachingFeedback!.nextPrompt),
                ],
              ),
            ),
          ],
          const SizedBox(height: 10),
          // ── 操作按钮行 ──
          Row(
            children: [
              // 提交本步思考
              if (!isSkipped) _buildSubmitButton(hasAnswer),
              // 提示按钮
              if (!isSkipped) ...[
                const SizedBox(width: 8),
                _buildHintButton(),
              ],
              // 跳过按钮
              if (!isSkipped) ...[
                const SizedBox(width: 8),
                _buildSkipButton(),
              ],
              // 已跳过的步骤可以回来
              if (isSkipped) ...[
                _buildUnskipButton(),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _fbLine(String label, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(label,
              style: TextStyle(
                color: AppTheme.paper.withAlpha(130),
                fontSize: 11,
                fontFamily: 'PingFang SC',
              )),
        ),
        Expanded(
          child: Text(text,
              style: TextStyle(
                color: AppTheme.paper.withAlpha(200),
                fontSize: 12,
                height: 1.5,
                fontFamily: 'PingFang SC',
              )),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(bool hasAnswer) {
    String label;
    bool enabled;
    switch (coachingStage) {
      case StepCoachingStage.empty:
      case StepCoachingStage.drafting:
        label = '提交本步思考';
        enabled = hasAnswer;
        break;
      case StepCoachingStage.submitting:
        label = 'Veggie正在看……';
        enabled = false;
        break;
      case StepCoachingStage.hintShown:
        label = '提交本步思考';
        enabled = hasAnswer;
        break;
      case StepCoachingStage.feedbackReady:
      case StepCoachingStage.needsRevision:
        label = coachingStage == StepCoachingStage.needsRevision
            ? '提交修改后的思考'
            : '再次请Veggie检查';
        enabled = hasAnswer;
        break;
      case StepCoachingStage.skipped:
        label = '提交本步思考';
        enabled = true;
        break;
      case StepCoachingStage.failure:
        label = '重新请求本步辅导';
        enabled = true;
        break;
    }
    return SizedBox(
      height: 30,
      child: ElevatedButton(
        onPressed: enabled ? onSubmitStep : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: enabled ? AppTheme.gold : AppTheme.surfaceLight,
          disabledBackgroundColor: AppTheme.surfaceLight,
          foregroundColor: AppTheme.background,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        child: Text(label,
            style: TextStyle(
              color:
                  enabled ? AppTheme.background : AppTheme.paper.withAlpha(100),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              fontFamily: 'PingFang SC',
            )),
      ),
    );
  }

  Widget _buildHintButton() {
    return SizedBox(
      height: 30,
      child: OutlinedButton(
        onPressed: onRequestHint,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.gold,
          side: BorderSide(color: AppTheme.gold.withAlpha(80), width: 0.5),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        child: Text(
          hintLevel >= 3
              ? '没有更多提示'
              : hintLevel == 0
                  ? '给我一个提示'
                  : '再给我一个提示',
          style: TextStyle(
            fontSize: 11,
            fontFamily: 'PingFang SC',
          ),
        ),
      ),
    );
  }

  Widget _buildSkipButton() {
    return SizedBox(
      height: 30,
      child: TextButton(
        onPressed: onSkip,
        style: TextButton.styleFrom(
          foregroundColor: AppTheme.paper.withAlpha(100),
          padding: const EdgeInsets.symmetric(horizontal: 8),
        ),
        child: const Text('先跳过',
            style: TextStyle(
              fontSize: 11,
              fontFamily: 'PingFang SC',
            )),
      ),
    );
  }

  Widget _buildUnskipButton() {
    return SizedBox(
      height: 30,
      child: OutlinedButton(
        onPressed: onSkip,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.gold,
          side: BorderSide(color: AppTheme.gold.withAlpha(80), width: 0.5),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        child: const Text('回来继续写',
            style: TextStyle(
              fontSize: 11,
              fontFamily: 'PingFang SC',
            )),
      ),
    );
  }
}
