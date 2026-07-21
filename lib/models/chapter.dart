import 'package:flutter/material.dart';

/// 章节状态
enum ChapterStatus { locked, available, completed }

/// 章节数据模型
///
/// 一个区域包含多个章节（5 章/区），
/// 解锁条件：收集对应区域的发现点。
class Chapter {
  final int number;
  final String title;
  final String subtitle;
  final ChapterStatus status;
  final String regionId; // 所属区域 id，e.g. 'caucasus'

  const Chapter({
    required this.number,
    required this.title,
    required this.subtitle,
    this.status = ChapterStatus.locked,
    this.regionId = 'caucasus',
  });

  /// 高加索区域章节（5 章）
  static const List<Chapter> caucasusChapters = [
    Chapter(
      number: 26,
      title: '高加索：欧亚交界线上的民族博物馆',
      subtitle: '探索高加索独特的地理位置与民族构成',
      status: ChapterStatus.available,
    ),
    Chapter(
      number: 27,
      title: '丝路明珠：高加索的商贸网络',
      subtitle: '了解高加索在丝绸之路上的枢纽地位',
    ),
    Chapter(
      number: 28,
      title: '山间王国：中世纪高加索政权',
      subtitle: '探索中世纪时期高加索的政治格局',
    ),
    Chapter(
      number: 29,
      title: '帝国边缘：俄土波在高加索的角逐',
      subtitle: '了解近代三大帝国在高加索的博弈',
    ),
    Chapter(
      number: 30,
      title: '现代高加索：冲突与共生的启示',
      subtitle: '思考高加索对当代文明互鉴的意义',
    ),
  ];

  /// 工厂方法 —— 按区域获取章节列表（预留扩展）
  static List<Chapter> forRegion(String regionId) {
    switch (regionId) {
      case 'caucasus':
        return caucasusChapters;
      // 未来扩展： china, central-asia, persia, mediterranean ...
      default:
        return caucasusChapters;
    }
  }
}
