/// AI 导师反馈结构
///
/// 为五步框架中每一步提供三层反馈：
/// - 发现（正向确认）
/// - 可加强（改进建议）
/// - 下一步思考（延伸问题）
///
/// 未来对接 DeepSeek 时，此结构直接对应 API 输出格式。
class AiFeedback {
  final int stepNumber;
  final String discovery; // "你发现了……"
  final String improvement; // "可以加入……"
  final String nextPrompt; // "下一步思考：……"

  const AiFeedback({
    required this.stepNumber,
    required this.discovery,
    required this.improvement,
    required this.nextPrompt,
  });
}

/// 学生回答数据结构（未来发送给 DeepSeek）
class StudentAnswer {
  final String questionId;
  final String chapterId;
  final List<String> evidenceUsed;
  final Map<int, String> thinkingSteps; // stepNumber -> answer text
  final String finalExplanation;

  const StudentAnswer({
    required this.questionId,
    this.chapterId = '',
    this.evidenceUsed = const [],
    this.thinkingSteps = const {},
    this.finalExplanation = '',
  });
}
