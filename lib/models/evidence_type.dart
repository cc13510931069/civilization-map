/// 阅读证据类型
///
/// 对应文明解释能力的四个分析维度。
/// 每种证据类型关联不同的思考训练。
enum EvidenceType {
  geographic,
  historical,
  people,
  change;

  String get label {
    switch (this) {
      case EvidenceType.geographic:
        return '地理证据';
      case EvidenceType.historical:
        return '历史证据';
      case EvidenceType.people:
        return '人物证据';
      case EvidenceType.change:
        return '文明变化证据';
    }
  }

  String get description {
    switch (this) {
      case EvidenceType.geographic:
        return '位置、山脉、海洋、交通路线';
      case EvidenceType.historical:
        return '战争、帝国、时间变化';
      case EvidenceType.people:
        return '民族、商人、统治者';
      case EvidenceType.change:
        return '交流、融合、冲突、迁移';
    }
  }

  String get icon {
    switch (this) {
      case EvidenceType.geographic:
        return '🔍';
      case EvidenceType.historical:
        return '📜';
      case EvidenceType.people:
        return '👥';
      case EvidenceType.change:
        return '🔄';
    }
  }
}
