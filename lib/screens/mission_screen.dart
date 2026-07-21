import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../models/thinking_step.dart';
import '../models/ai_feedback.dart' as fb_model;
import '../models/civilization_reasoning_profile.dart';
import '../components/thinking_framework_card.dart';
import '../components/ai_feedback_card.dart';
import '../components/reasoning_profile_card.dart';
import '../components/mission_evidence_library.dart';
import '../data/mission_state.dart';
import '../components/final_submission_readiness_card.dart';
import '../services/step_coaching_service.dart';

/// 文明思考实验室 — 双栏布局
///
/// 左侧：五步文明解释工作区 + 提交操作区
/// 右侧：Veggie 反馈 + 评价 + 证据库
class MissionScreen extends ConsumerStatefulWidget {
  const MissionScreen({super.key});

  @override
  ConsumerState<MissionScreen> createState() => _MissionScreenState();
}

class _MissionScreenState extends ConsumerState<MissionScreen> {
  late final Map<int, TextEditingController> _stepControllers;
  late final Map<int, FocusNode> _stepFocusNodes;
  final _stepScrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    final answers = ref.read(stepAnswersProvider);

    _stepControllers = {
      for (int step = 1; step <= 5; step++)
        step: TextEditingController(
          text: answers[step] ?? '',
        ),
    };

    _stepFocusNodes = {
      for (int step = 1; step <= 5; step++)
        step: FocusNode(
          debugLabel: 'mission-step-$step',
        ),
    };
  }

  @override
  void dispose() {
    for (final controller in _stepControllers.values) {
      controller.dispose();
    }
    for (final node in _stepFocusNodes.values) {
      node.dispose();
    }
    _stepScrollController.dispose();
    super.dispose();
  }

  void _onAnswerChanged(int step, String value) {
    ref.read(stepAnswersProvider.notifier).updateAnswer(step, value);
    ref.read(missionSubmissionProvider.notifier).markModified();
    ref.read(stepCoachingProvider.notifier).markModified(step);
  }

  // ── Single-step coaching submission ──
  Future<void> _submitStepCoaching(int step) async {
    final text = _stepControllers[step]?.text.trim() ?? '';
    if (text.isEmpty) return;
    ref.read(stepAnswersProvider.notifier).updateAnswer(step, text);
    ref.read(missionSubmissionProvider.notifier).markModified();
    final question = ThinkingStep.allSteps[step - 1].prompt;
    await ref
        .read(stepCoachingProvider.notifier)
        .submitStep(step, question, text);
  }

  // ── Request hint for a step ──
  void _onStartWriting(int step) {
    // Set active step and scroll to it
    ref.read(activeStepProvider.notifier).state = step;
    final offset = (step - 1) * 260.0;
    _stepScrollController.animateTo(offset,
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  void _requestHint(int step) {
    ref.read(stepCoachingProvider.notifier).requestHint(step);
  }

  // ── Skip step ──
  void _skipStep(int step) {
    final stage = ref.read(stepCoachingProvider)[step]?.stage;
    if (stage == StepCoachingStage.skipped) {
      ref.read(stepCoachingProvider.notifier).unskipStep(step);
    } else {
      ref.read(stepCoachingProvider.notifier).skipStep(step);
      // Move to the next step
      final next = step + 1;
      if (next <= 5) {
        ref.read(activeStepProvider.notifier).state = next;
      }
    }
  }

  // ── Initial submit (first stage) ──
  void _submitInitial() {
    ref.read(missionSubmissionProvider.notifier).submitInitial();
  }

  // ── Final submit (second stage) ──
  void _submitFinal() {
    ref.read(missionSubmissionProvider.notifier).submitFinal();
  }

  @override
  Widget build(BuildContext context) {
    final mission = ref.watch(currentMissionProvider);
    final stepAnswers = ref.watch(stepAnswersProvider);
    final activeStep = ref.watch(activeStepProvider);
    final feedbacks = ref.watch(stepFeedbacksProvider);
    final profile = ref.watch(reasoningProfileProvider);
    final submission = ref.watch(missionSubmissionProvider);
    final canSubmitInitial = ref.watch(canSubmitInitialProvider);
    final canSubmitFinal = ref.watch(canSubmitFinalProvider);

    // Listen for evidence changes → mark modified
    ref.listen<Map<String, String>>(missionEvidenceProvider, (prev, next) {
      if (prev != null && !_mapsEqual(prev, next)) {
        ref.read(missionSubmissionProvider.notifier).markModified();
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(mission, stepAnswers, submission),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                        flex: 2,
                        child: _buildStepsPanel(
                            activeStep,
                            stepAnswers,
                            feedbacks,
                            profile,
                            submission,
                            canSubmitInitial,
                            canSubmitFinal)),
                    const SizedBox(width: 12),
                    SizedBox(
                        width: 320,
                        child: _buildRightPanel(
                            feedbacks, activeStep, profile, submission)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Top header ──
  Widget _buildHeader(
      Mission mission, Map<int, String> answers, MissionSubmissionState sub) {
    final answered = answers.values.where((t) => t.trim().isNotEmpty).length;
    return Container(
      padding: const EdgeInsets.fromLTRB(32, 20, 32, 16),
      child: Row(children: [
        Container(
          width: 50,
          height: 36,
          decoration: BoxDecoration(
            color: AppTheme.shimmerGold,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.psychology, color: AppTheme.gold, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('文明思考实验室',
                  style: TextStyle(
                    color: AppTheme.paper,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'PingFang SC',
                  )),
              const SizedBox(height: 2),
              Text(mission.question,
                  style: TextStyle(
                    color: AppTheme.gold.withAlpha(200),
                    fontSize: 14,
                    fontFamily: 'PingFang SC',
                  )),
            ],
          ),
        ),
        // Stage badge
        _stageBadge(sub.stage),
        const SizedBox(width: 10),
        // Step count
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.surfaceLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text('$answered/5',
              style: TextStyle(
                color: answered == 5
                    ? AppTheme.gold
                    : AppTheme.paper.withAlpha(160),
                fontSize: 13,
                fontWeight: FontWeight.w600,
                fontFamily: 'PingFang SC',
              )),
        ),
      ]),
    );
  }

  Widget _stageBadge(MissionSubmissionStage stage) {
    String label;
    Color bg;
    switch (stage) {
      case MissionSubmissionStage.draft:
        return const SizedBox.shrink();
      case MissionSubmissionStage.initialFeedback:
        label = '初步反馈';
        bg = AppTheme.gold;
        break;
      case MissionSubmissionStage.revisionReady:
        label = '需要完善';
        bg = Colors.orange;
        break;
      case MissionSubmissionStage.completed:
        label = '已完成';
        bg = AppTheme.green;
        break;
      case MissionSubmissionStage.failure:
        label = '提交失败';
        bg = Colors.redAccent;
        break;
      default:
        return const SizedBox.shrink();
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg.withAlpha(40),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: bg.withAlpha(80), width: 0.5),
      ),
      child: Text(label,
          style: TextStyle(
            color: bg,
            fontSize: 11,
            fontWeight: FontWeight.w500,
            fontFamily: 'PingFang SC',
          )),
    );
  }

  // ── Left panel: thinking steps + submit area ──
  Widget _buildStepsPanel(
    int activeStep,
    Map<int, String> answers,
    Map<int, fb_model.AiFeedback> feedbacks,
    CivilizationReasoningProfile? profile,
    MissionSubmissionState submission,
    bool canInit,
    bool canFin,
  ) {
    final stepCards = <Widget>[];
    for (int i = 0; i < ThinkingStep.allSteps.length; i++) {
      final step = ThinkingStep.allSteps[i];
      final stepNum = step.stepNumber;
      final hasFeedback = feedbacks.containsKey(stepNum);
      final answer = answers[stepNum] ?? '';
      final coachingStates = ref.watch(stepCoachingProvider);
      final stepCoaching =
          coachingStates[stepNum] ?? StepCoachingState(step: stepNum);

      stepCards.add(ThinkingFrameworkCard(
        step: step,
        answer: answer,
        showFeedback: hasFeedback,
        controller: _stepControllers[stepNum],
        onAnswerChanged: (text) => _onAnswerChanged(stepNum, text),
        onSubmitStep: () => _submitStepCoaching(stepNum),
        onRequestHint: () => _requestHint(stepNum),
        onSkip: () => _skipStep(stepNum),
        onStartWriting: () => _onStartWriting(stepNum),
        focusNode: _stepFocusNodes[stepNum],
        coachingFeedback: stepCoaching.latestFeedback,
        coachingStage: stepCoaching.stage,
        currentHint: stepCoaching.latestHint?.text,
        hintLevel: stepCoaching.currentHintLevel,
      ));
      stepCards.add(const SizedBox(height: 12));
    }

    return SingleChildScrollView(
      controller: _stepScrollController,
      key: const Key('mission_steps_scroll'),
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: [
          ...stepCards,
          _buildSubmitArea(submission, canInit, canFin),
        ],
      ),
    );
  }

  Widget _buildSubmitArea(
      MissionSubmissionState sub, bool canInit, bool canFin) {
    // Determine button text and action
    String buttonText;
    bool enabled;
    VoidCallback? onPressed;
    bool showProcessing = false;

    switch (sub.stage) {
      case MissionSubmissionStage.draft:
        buttonText = '提交初步思考';
        enabled = canInit;
        onPressed = _submitInitial;
        break;
      case MissionSubmissionStage.failure:
        buttonText =
            sub.failedAttempt == MissionSubmissionAttempt.finalEvaluation
                ? '重新提交完善后的解释'
                : '重新提交初步思考';
        enabled = sub.failedAttempt == MissionSubmissionAttempt.finalEvaluation
            ? canFin
            : canInit;
        onPressed = () =>
            ref.read(missionSubmissionProvider.notifier).retrySubmission();
        break;
      case MissionSubmissionStage.submittingInitial:
      case MissionSubmissionStage.submittingFinal:
        buttonText = '正在整理思考……';
        enabled = false;
        showProcessing = true;
        break;
      case MissionSubmissionStage.initialFeedback:
        enabled = canFin;
        if (enabled) {
          buttonText = '提交完善后的解释';
        } else {
          final r = ref.read(finalSubmissionReadinessProvider);
          buttonText = r.primaryBlockingReason ?? '还差 ${r.remainingCount} 项可提交';
        }
        onPressed = _submitFinal;
        break;
      case MissionSubmissionStage.revisionReady:
        final hasPrevious = ref.read(missionResultSnapshotProvider) != null;
        enabled = canFin;
        if (enabled) {
          buttonText = hasPrevious ? '提交更新后的解释' : '提交完善后的解释';
        } else {
          final r = ref.read(finalSubmissionReadinessProvider);
          buttonText = r.primaryBlockingReason ?? '还差 ${r.remainingCount} 项可提交';
        }
        onPressed = _submitFinal;
        break;
      case MissionSubmissionStage.completed:
        buttonText = '修改后重新提交';
        enabled = canInit;
        onPressed = _submitInitial;
        break;
    }

    // Show processing indicator
    Widget? processingWidget;
    if (showProcessing) {
      processingWidget = const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppTheme.background,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppTheme.divider, width: 0.5),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Readiness card
          if (sub.stage == MissionSubmissionStage.initialFeedback ||
              sub.stage == MissionSubmissionStage.revisionReady)
            FinalSubmissionReadinessCard(
              onMapAction: () => context.go('/caucasus'),
              onReadingAction: () => context.go('/reading-camp'),
            ),
          // Error message
          if (sub.errorMessage != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.redAccent.withAlpha(20),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: Colors.redAccent.withAlpha(60), width: 0.5),
              ),
              child: Text(sub.errorMessage!,
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 12,
                    fontFamily: 'PingFang SC',
                  )),
            ),
          // Unsaved changes hint
          if (sub.hasUnsavedChanges &&
              sub.stage != MissionSubmissionStage.draft)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withAlpha(15),
                borderRadius: BorderRadius.circular(8),
                border:
                    Border.all(color: Colors.orange.withAlpha(50), width: 0.5),
              ),
              child: Text('答案已修改，请重新提交',
                  style: TextStyle(
                    color: Colors.orange.shade300,
                    fontSize: 12,
                    fontFamily: 'PingFang SC',
                  )),
            ),
          // Submit button
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: enabled ? onPressed : null,
              icon: processingWidget ??
                  Icon(
                    _buttonIcon(sub.stage),
                    size: 18,
                  ),
              label: Text(buttonText,
                  style: TextStyle(
                    color: enabled
                        ? AppTheme.background
                        : AppTheme.paper.withAlpha(100),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'PingFang SC',
                  )),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    enabled ? AppTheme.gold : AppTheme.surfaceLight,
                disabledBackgroundColor: AppTheme.surfaceLight,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _buttonIcon(MissionSubmissionStage stage) {
    switch (stage) {
      case MissionSubmissionStage.completed:
        return Icons.refresh;
      case MissionSubmissionStage.failure:
        return Icons.refresh;
      default:
        return Icons.send;
    }
  }

  // ── Right panel ──
  Widget _buildRightPanel(
    Map<int, fb_model.AiFeedback> feedbacks,
    int activeStep,
    CivilizationReasoningProfile? profile,
    MissionSubmissionState submission,
  ) {
    final hasFeedback = feedbacks.isNotEmpty;
    final hasInitial = submission.initialFeedbackText != null;
    final hasFinal = submission.finalEvaluation != null;
    final hasAnything =
        hasFeedback || hasInitial || hasFinal || profile != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Feedback + evaluation area (scrollable, max ~40% of right panel)
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 280),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Per-step feedback cards
                if (hasFeedback)
                  ...feedbacks.entries.map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: AiFeedbackCard(feedback: e.value),
                      )),
                // Initial feedback (after first submit)
                if (hasInitial) _buildInitialFeedbackCard(submission),
                // Final evaluation (after final submit)
                if (hasFinal) _buildFinalEvaluationCard(submission),
                // Empty state
                if (!hasAnything) _buildEmptyRightPanel(submission),
              ],
            ),
          ),
        ),
        // Profile card
        if (profile != null) ...[
          const SizedBox(height: 8),
          ReasoningProfileCard(profile: profile),
        ],
        const SizedBox(height: 8),
        // Evidence library
        const Expanded(child: MissionEvidenceLibrary()),
      ],
    );
  }

  Widget _buildInitialFeedbackCard(MissionSubmissionState sub) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.gold.withAlpha(50), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.pets, color: AppTheme.gold, size: 18),
            const SizedBox(width: 8),
            Text('Veggie · 本地练习反馈',
                style: TextStyle(
                  color: AppTheme.gold,
                  fontSize: 12,
                  fontFamily: 'PingFang SC',
                )),
          ]),
          const SizedBox(height: 10),
          Text(
            sub.initialFeedbackText ?? '',
            style: TextStyle(
              color: AppTheme.paper.withAlpha(210),
              fontSize: 13,
              height: 1.6,
              fontFamily: 'PingFang SC',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinalEvaluationCard(MissionSubmissionState sub) {
    final eval = sub.finalEvaluation;
    if (eval == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.green.withAlpha(60), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.auto_awesome, color: AppTheme.green, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text('四项能力评价 · 原型评价',
                  style: TextStyle(
                    color: AppTheme.green,
                    fontSize: 12,
                    fontFamily: 'PingFang SC',
                  ),
                  softWrap: false,
                  overflow: TextOverflow.ellipsis),
            ),
            const SizedBox(width: 8),
            Text('${eval.totalScore}/100',
                style: TextStyle(
                  color: AppTheme.gold,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'PingFang SC',
                )),
          ]),
          const SizedBox(height: 12),
          // Four dimensions
          _evalRow('📍 位置与知识', eval.locationScore, 25, eval.locationLevel),
          const SizedBox(height: 6),
          _evalRow('📋 证据使用', eval.evidenceScore, 25, eval.evidenceLevel),
          const SizedBox(height: 6),
          _evalRow('🔗 因果与逻辑', eval.causalityScore, 30, eval.causalityLevel),
          const SizedBox(height: 6),
          _evalRow('💡 个人解释', eval.explanationScore, 20, eval.explanationLevel),
        ],
      ),
    );
  }

  Widget _evalRow(String label, int score, int max, String level) {
    final ratio = score / max;
    final barColor = ratio >= 0.7
        ? AppTheme.green
        : ratio >= 0.4
            ? AppTheme.gold
            : Colors.orange;
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(label,
              style: TextStyle(
                color: AppTheme.paper.withAlpha(180),
                fontSize: 11,
                fontFamily: 'PingFang SC',
              )),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: ratio,
              backgroundColor: AppTheme.surfaceLight,
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
              minHeight: 8,
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 50,
          child: Text('$score',
              textAlign: TextAlign.right,
              style: TextStyle(
                color: AppTheme.paper,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                fontFamily: 'PingFang SC',
              )),
        ),
        const SizedBox(width: 6),
        SizedBox(
          width: 40,
          child: Text(level,
              style: TextStyle(
                color: barColor,
                fontSize: 11,
                fontFamily: 'PingFang SC',
              )),
        ),
      ],
    );
  }

  Widget _buildEmptyRightPanel(MissionSubmissionState sub) {
    // Show different empty state based on stage
    String message;
    if (sub.stage == MissionSubmissionStage.draft) {
      message = '完成第一步思考后，Veggie 将为你提供反馈。';
    } else if (sub.stage == MissionSubmissionStage.initialFeedback ||
        sub.stage == MissionSubmissionStage.revisionReady) {
      message = 'Veggie 正在等待你完善答案。\n补充证据或修改回答后即可提交。';
    } else {
      message = '完成第一步思考后，\nVeggie 将为你提供反馈。';
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark.withAlpha(180),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.divider, width: 0.5),
      ),
      child: Column(
        children: [
          const SizedBox(height: 24),
          Icon(Icons.pets, color: AppTheme.gold.withAlpha(80), size: 48),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.paper.withAlpha(100),
              fontSize: 13,
              height: 1.6,
              fontFamily: 'PingFang SC',
            ),
          ),
        ],
      ),
    );
  }
}

bool _mapsEqual(Map<String, String> a, Map<String, String> b) {
  if (a.length != b.length) return false;
  for (final k in a.keys) {
    if (a[k] != b[k]) return false;
  }
  return true;
}
