import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ai_proxy_service.dart';
import '../models/mission_result_snapshot.dart';

// ── Single-step coaching data classes ──

class StepCoachingFeedback {
  final int step;
  final String discovery; // 你已经想到
  final String improvement; // 还可以补充
  final String nextPrompt; // Veggie追问

  const StepCoachingFeedback({
    required this.step,
    required this.discovery,
    required this.improvement,
    required this.nextPrompt,
  });
}

class StepCoachingEvidence {
  final String id;
  final String type;
  final String text;
  final String source;

  const StepCoachingEvidence({
    required this.id,
    this.type = '',
    required this.text,
    this.source = '',
  });
}

class StepHint {
  final int step;
  final int hintLevel;
  final String text;

  const StepHint(
      {required this.step, required this.hintLevel, required this.text});
}

// ── Coaching stage per step ──

enum StepCoachingStage {
  empty,
  drafting,
  hintShown,
  submitting,
  feedbackReady,
  needsRevision,
  skipped,
  failure,
}

class StepCoachingState {
  final int step;
  final StepCoachingStage stage;
  final StepCoachingFeedback? latestFeedback;
  final int currentHintLevel;
  final StepHint? latestHint;
  final String submittedAnswer;
  final int revisionNumber;
  final bool hasChangesAfterFeedback;
  final String? errorMessage;

  const StepCoachingState({
    required this.step,
    this.stage = StepCoachingStage.empty,
    this.latestFeedback,
    this.currentHintLevel = 0,
    this.latestHint,
    this.submittedAnswer = '',
    this.revisionNumber = 0,
    this.hasChangesAfterFeedback = false,
    this.errorMessage,
  });

  StepCoachingState copyWith({
    StepCoachingStage? stage,
    StepCoachingFeedback? latestFeedback,
    bool clearFeedback = false,
    int? currentHintLevel,
    StepHint? latestHint,
    bool clearHint = false,
    String? submittedAnswer,
    int? revisionNumber,
    bool? hasChangesAfterFeedback,
    String? errorMessage,
    bool clearError = false,
  }) {
    return StepCoachingState(
      step: step,
      stage: stage ?? this.stage,
      latestFeedback:
          clearFeedback ? null : (latestFeedback ?? this.latestFeedback),
      currentHintLevel: currentHintLevel ?? this.currentHintLevel,
      latestHint: clearHint ? null : (latestHint ?? this.latestHint),
      submittedAnswer: submittedAnswer ?? this.submittedAnswer,
      revisionNumber: revisionNumber ?? this.revisionNumber,
      hasChangesAfterFeedback:
          hasChangesAfterFeedback ?? this.hasChangesAfterFeedback,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

// ── Service interface ──

abstract class StepCoachingService {
  Future<StepCoachingFeedback> evaluateStep({
    required int step,
    required String question,
    required String answer,
    required List<StepCoachingEvidence> evidence,
    required int revisionNumber,
  });

  StepHint getHint({required int step, required int hintLevel});
}

// ── Local implementation ──

class LocalStepCoachingService implements StepCoachingService {
  @override
  Future<StepCoachingFeedback> evaluateStep({
    required int step,
    required String question,
    required String answer,
    required List<StepCoachingEvidence> evidence,
    required int revisionNumber,
  }) async {
    final text = answer.trim();
    final discovery = _buildDiscovery(step, text);
    final improvement = _buildImprovement(step, text);
    final nextPrompt = _prompts[step] ?? '想一想这是为什么？';
    return StepCoachingFeedback(
      step: step,
      discovery: discovery,
      improvement: improvement,
      nextPrompt: nextPrompt,
    );
  }

  String _buildDiscovery(int step, String text) {
    if (text.length >= 20) return '你已经写出了自己的想法，继续完善。';
    if (text.length >= 10) return '你已经开始了第 $step 步的思考。';
    return '你已经写了一些内容。';
  }

  String _buildImprovement(int step, String text) {
    switch (step) {
      case 1:
        if (!text.contains('高加索') &&
            !text.contains('欧亚') &&
            !text.contains('黑海') &&
            !text.contains('里海')) return '可以说明高加索在哪个大洲之间。';
        if (!text.contains('黑海') && !text.contains('里海'))
          return '可以加入黑海或里海作为位置参考。';
        return '可以补充高加索山脉的相对位置。';
      case 2:
        if (!text.contains('山') &&
            !text.contains('海') &&
            !text.contains('气候') &&
            !text.contains('自然')) return '可以分析地形、水系或气候条件。';
        return '可以思考这些条件如何影响人们的生活和往来。';
      case 3:
        if (!text.contains('民族') && !text.contains('帝国') && !text.contains('人'))
          return '可以列举在这里活动的民族或帝国。';
        return '可以思考他们为什么来这里、留下了什么。';
      case 4:
        if (!text.contains('变化') &&
            !text.contains('交流') &&
            !text.contains('贸易') &&
            !text.contains('战争')) return '可以描述高加索地区发生了哪些变化。';
        return '可以补充时间线索，让变化过程更清晰。';
      case 5:
        if (!text.contains('因为') &&
            !text.contains('所以') &&
            !text.contains('因此')) return '可以用"因为……所以……"来连接你的观点。';
        if (!text.contains('我')) return '尝试用"我认为"来表达你自己的判断。';
        return '可以整合前面几步的发现，形成更完整的解释。';
      default:
        return '可以结合你收集到的证据展开分析。';
    }
  }

  @override
  StepHint getHint({required int step, required int hintLevel}) {
    final hints = _hints[step];
    if (hints == null || hintLevel < 1 || hintLevel > 3) {
      return StepHint(
        step: step,
        hintLevel: hintLevel,
        text: '试着用自己的话写一写，写完后Veggie可以继续帮你检查。',
      );
    }
    return StepHint(step: step, hintLevel: hintLevel, text: hints[hintLevel]!);
  }

  static const Map<int, Map<int, String>> _hints = {
    1: {
      1: '先找一找高加索位于哪两个大洲之间。',
      2: '观察黑海、里海和高加索山脉分别在它的哪个方向。',
      3: '可以从这句话开始："高加索位于______，它的西边是______，东边是______。"',
    },
    2: {
      1: '想一想高加索地区的地形有什么特点？是平原、山地还是海洋？',
      2: '山脉对交通和气候有什么影响？黑海和里海的水系呢？',
      3: '可以从这句话开始："高加索有______，这些条件使得______。"',
    },
    3: {
      1: '想一想哪些民族或帝国曾在高加索地区活动。',
      2: '丝绸之路与高加索有什么关系？商人和移民在这里做了什么？',
      3: '可以从这句话开始："______、______等民族曾在这里活动，他们带来了______。"',
    },
    4: {
      1: '高加索历史上发生过哪些重要事件？战争、贸易还是文化交流？',
      2: '想想从古代到现代，高加索经历了哪些变化？',
      3: '可以从这句话开始："历史上，高加索经历了______，这导致了______。"',
    },
    5: {
      1: '综合前面的思考，高加索为什么成为文明交汇区？',
      2: '用证据来支持你的观点——位置、环境、人群、历史变化。',
      3: '可以从这句话开始："我认为高加索之所以成为文明交汇区域，是因为______。首先______，其次______。这让______。"',
    },
  };

  static const Map<int, String> _prompts = {
    1: '这种位置为什么容易让不同地区的人经过这里？',
    2: '这些条件如何影响了当地民族生活和文化形成？',
    3: '这些不同人群的互动导致了什么结果？',
    4: '这些变化对今天的高加索有什么影响？',
    5: '如果用一个核心词概括高加索文明，你会选什么？',
  };
}

// ── Fake for testing ──

class FakeStepCoachingService implements StepCoachingService {
  int evaluateStepCallCount = 0;
  int lastStep = 0;
  String? lastQuestion;
  String? lastAnswer;
  int lastRevisionNumber = 0;
  List<StepCoachingEvidence>? lastEvidence;

  FakeStepCoachingService();

  @override
  Future<StepCoachingFeedback> evaluateStep({
    required int step,
    required String question,
    required String answer,
    required List<StepCoachingEvidence> evidence,
    required int revisionNumber,
  }) async {
    evaluateStepCallCount++;
    lastStep = step;
    lastQuestion = question;
    lastAnswer = answer;
    lastEvidence = evidence;
    lastRevisionNumber = revisionNumber;
    return StepCoachingFeedback(
      step: step,
      discovery: '你已经开始思考第 $step 步了。',
      improvement: '可以结合证据来完善这个思考。',
      nextPrompt: '为什么会这样呢？试着解释一下。',
    );
  }

  @override
  StepHint getHint({required int step, required int hintLevel}) {
    return StepHint(step: step, hintLevel: hintLevel, text: '试着从地图或书中找线索。');
  }
}


/// 远程单步辅导服务（调用 DeepSeek API）
class RemoteStepCoachingService implements StepCoachingService {
  final AiProxyService _proxy;

  RemoteStepCoachingService({AiProxyService? proxy})
      : _proxy = proxy ?? AiProxyService();

  @override
  Future<StepCoachingFeedback> evaluateStep({
    required int step,
    required String question,
    required String answer,
    required List<StepCoachingEvidence> evidence,
    required int revisionNumber,
  }) async {
    try {
      final evMap = evidence.map((e) => {'type': e.type, 'text': e.text}).toList();
      final req = StepCoachingRequest(
        step: step,
        question: question,
        answer: answer,
        evidence: evMap,
      );
      final resp = await _proxy.stepCoaching(req);
      return StepCoachingFeedback(
        step: step,
        discovery: resp.feedbackText,
        improvement: '',
        nextPrompt: '',
      );
    } catch (_) {
      return LocalStepCoachingService().evaluateStep(
        step: step,
        question: question,
        answer: answer,
        evidence: evidence,
        revisionNumber: revisionNumber,
      );
    }
  }

  @override
  StepHint getHint({required int step, required int hintLevel}) {
    return LocalStepCoachingService().getHint(step: step, hintLevel: hintLevel);
  }
}

// ── Provider ──

final stepCoachingServiceProvider = Provider<StepCoachingService>((ref) {
  if (AiProxyConfig.isConfigured) {
    return RemoteStepCoachingService();
  }
  return LocalStepCoachingService();
});
