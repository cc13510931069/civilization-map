/// 文明解释模块定义
///
/// 对应 MissionScreen 的五步文明解释框架。
/// 每步包含表情符号、标题、英文标题和思考提示。
class ExplanationModule {
  final int stepNumber;
  final String emoji;
  final String title;
  final String titleEn;

  const ExplanationModule({
    required this.stepNumber,
    required this.emoji,
    required this.title,
    required this.titleEn,
  });

  /// 五个解释模块
  static const List<ExplanationModule> all = [
    ExplanationModule(
        stepNumber: 1, emoji: '📍', title: '在哪里？', titleEn: 'Where?'),
    ExplanationModule(
        stepNumber: 2,
        emoji: '🏔',
        title: '有什么条件？',
        titleEn: 'What conditions?'),
    ExplanationModule(
        stepNumber: 3,
        emoji: '👥',
        title: '谁在那里活动？',
        titleEn: 'Who interacted?'),
    ExplanationModule(
        stepNumber: 4, emoji: '🔄', title: '发生什么变化？', titleEn: 'What changed?'),
    ExplanationModule(
        stepNumber: 5,
        emoji: '💡',
        title: '我的解释是什么？',
        titleEn: 'My explanation?'),
  ];
}

/// 模块填充状态
enum ModuleStatus { empty, draft, complete }

/// 单个解释模块的内容状态
class ExplanationSection {
  final ExplanationModule module;
  final String content;
  final ModuleStatus status;

  const ExplanationSection({
    required this.module,
    this.content = '',
    this.status = ModuleStatus.empty,
  });
}
