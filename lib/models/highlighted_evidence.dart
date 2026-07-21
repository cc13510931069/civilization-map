import 'evidence_type.dart';

/// 阅读中标记的证据
///
/// 学生从正文中选择文本片段，赋予证据类型和备注。
/// 这些证据会自动流入 MissionSystem 的文明思考实验室。
class HighlightedEvidence {
  final String id;
  final String text; // 选中的原文
  final int chapterNumber;
  final EvidenceType type;
  final String note; // 学生备注（为什么这是证据）
  final DateTime createdAt;

  HighlightedEvidence({
    required this.id,
    required this.text,
    required this.chapterNumber,
    required this.type,
    this.note = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}

/// 阅读任务类型（右侧面板显示）
enum ReadingTask {
  geographic,
  historical,
  people,
  change,
}

extension ReadingTaskX on ReadingTask {
  String get label {
    switch (this) {
      case ReadingTask.geographic:
        return '地理线索';
      case ReadingTask.historical:
        return '历史变化';
      case ReadingTask.people:
        return '人群互动';
      case ReadingTask.change:
        return '文明演变';
    }
  }

  String get prompt {
    switch (this) {
      case ReadingTask.geographic:
        return '在文中找出高加索地理位置的关键描述——它连接了哪些区域？';
      case ReadingTask.historical:
        return '关注文中提到的帝国兴衰和时间变化——哪些势力在这里留下了印记？';
      case ReadingTask.people:
        return '留意不同民族和语言——高加索的居民构成有什么特点？';
      case ReadingTask.change:
        return '寻找文化交流和融合的证据——丝路贸易带来了什么变化？';
    }
  }
}

/// 默认阅读任务列表（第26章）
const List<ReadingTask> defaultReadingTasks = [
  ReadingTask.geographic,
  ReadingTask.historical,
  ReadingTask.people,
  ReadingTask.change,
];
