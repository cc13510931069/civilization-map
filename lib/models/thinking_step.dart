/// 五步文明解释框架中的一步
class ThinkingStep {
  final int stepNumber;
  final String title; // "在哪里？"
  final String subtitle; // "Where?"
  final String goal; // "训练地理定位"
  final String prompt; // 输入提示文字

  const ThinkingStep({
    required this.stepNumber,
    required this.title,
    required this.subtitle,
    required this.goal,
    required this.prompt,
  });

  /// 文明解释框架 5 个步骤
  static const List<ThinkingStep> allSteps = [
    ThinkingStep(
      stepNumber: 1,
      title: '在哪里？',
      subtitle: 'Where?',
      goal: '训练地理定位',
      prompt: '请描述高加索的地理位置：它位于哪些海域之间？与哪些文明区域相邻？',
    ),
    ThinkingStep(
      stepNumber: 2,
      title: '有什么条件？',
      subtitle: 'What conditions?',
      goal: '分析环境特征',
      prompt: '高加索的地形、气候和交通条件如何？这些条件对文明发展有何影响？',
    ),
    ThinkingStep(
      stepNumber: 3,
      title: '谁在那里活动？',
      subtitle: 'Who interacted?',
      goal: '理解人群互动',
      prompt: '哪些民族、帝国、商人在高加索活动？他们带来了什么样的文化交流？',
    ),
    ThinkingStep(
      stepNumber: 4,
      title: '发生了什么变化？',
      subtitle: 'What changed?',
      goal: '分析历史变迁',
      prompt: '高加索经历了哪些战争、迁移和贸易变迁？这些变化如何塑造了今天的格局？',
    ),
    ThinkingStep(
      stepNumber: 5,
      title: '我的解释是什么？',
      subtitle: 'My explanation?',
      goal: '形成文明观点',
      prompt: '综合以上分析，用一段话解释：为什么高加索成为文明交汇区域？',
    ),
  ];
}
