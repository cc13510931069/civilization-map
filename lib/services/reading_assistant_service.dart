import '../models/evidence_type.dart';
import '../models/highlighted_evidence.dart';
import '../models/reading_chapter.dart';

/// 阅读助手服务（模拟）
///
/// 当前使用模拟逻辑，根据阅读进度和标记证据生成 Veggie 引导。
/// 未来对接 DeepSeek 时只需替换 generateHint 的实现。
class ReadingAssistantService {
  ReadingAssistantService._();

  /// 根据当前阅读状态生成 Veggie 引导提示
  static String generateHint({
    required ReadingChapter chapter,
    required List<HighlightedEvidence> evidence,
    required Set<ReadingTask> completedTasks,
  }) {
    final count = evidence.length;

    if (count == 0) {
      return '选择你觉得重要的句子或段落，点击「标记为证据」来收集文明解释的素材。';
    }

    if (count < 3) {
      final types = EvidenceType.values;
      final foundTypes = evidence.map((e) => e.type).toSet();
      final missing = types.where((t) => !foundTypes.contains(t)).toList();
      if (missing.isNotEmpty) {
        return '你已经找到了 $count 条证据。试试再找一条${missing.first.label}——${missing.first.description}。';
      }
      return '你已经找到了各类证据！试着再深入阅读，寻找更多细节来完善你的解释。';
    }

    // 已找到多个证据
    final geo = evidence.where((e) => e.type == EvidenceType.geographic).length;
    final hist =
        evidence.where((e) => e.type == EvidenceType.historical).length;
    final ppl = evidence.where((e) => e.type == EvidenceType.people).length;
    final chg = evidence.where((e) => e.type == EvidenceType.change).length;

    if (geo == 0) return '试着找一条地理证据——关注文中关于位置、山脉或水域的描述。';
    if (hist == 0) return '文中提到多个帝国在高加索活动，试试找到一条历史证据。';
    if (ppl == 0) return '高加索以民族多样性闻名，找一条关于民族或语言的人物证据。';
    if (chg == 0) return '丝绸之路给高加索带来了什么变化？找一条文明变化证据。';

    return '你已经收集了所有类型的证据！现在可以前往文明思考实验室，'
        '用这些证据完善你的文明解释。';
  }

  /// 对选中的文本生成 Veggie 反馈
  static String feedbackForSelection(String text, EvidenceType type) {
    switch (type) {
      case EvidenceType.geographic:
        return '这段描述展现了高加索的地理位置优势——连接黑海与里海、横贯的山脉通道。'
            '这是理解文明交汇的基础。';
      case EvidenceType.historical:
        return '这段话记录了重要的历史变迁。不同的帝国相继到来，'
            '每次更替都在高加索的文化肌理上留下了印记。';
      case EvidenceType.people:
        return '这段话揭示了高加索的民族多样性。多种语言并存、'
            '不同族群的交流与融合是理解这一地区的关键。';
      case EvidenceType.change:
        return '这段描述展现了文明交流带来的变化。贸易路线带来的不仅是商品，'
            '更是技术、宗教和思想的交汇。';
    }
  }

  /// 任务完成时的鼓励反馈
  static String taskCompleteFeedback(ReadingTask task) {
    switch (task) {
      case ReadingTask.geographic:
        return '很好！你找到了地理线索。这些证据将帮助你在思考实验室中回答「在哪里？」';
      case ReadingTask.historical:
        return '很好！历史证据揭示了高加索经历的变迁。这在「发生了什么变化？」步骤中非常有用。';
      case ReadingTask.people:
        return '很好！人群互动是高加索故事的核心。这些证据将支持你的「谁在那里活动？」分析。';
      case ReadingTask.change:
        return '很好！你发现的文化交流证据是理解文明交汇的关键。现在可以整合到你的最终解释中了。';
    }
  }
}
