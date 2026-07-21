import 'package:flutter/material.dart';

/// 文明区域数据模型 — 地图上的可交互节点
class CivilizationRegion {
  final String id;
  final String name;
  final String nameEn;
  final Offset position; // 在地图画布上的绝对坐标 (px)
  final String description; // 文明信息卡描述
  final String route; // 点击「进入探索」跳转的路由
  final bool isActive;
  final bool isHighlighted;

  const CivilizationRegion({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.position,
    this.description = '',
    this.route = '/',
    this.isActive = false,
    this.isHighlighted = false,
  });

  /// 首页展示的 4 个节点（相对坐标 0-1）
  static const List<CivilizationRegion> featured = [
    CivilizationRegion(
      id: 'china',
      name: '中国',
      nameEn: 'China',
      position: Offset(0.68, 0.52),
    ),
    CivilizationRegion(
      id: 'central-asia',
      name: '中亚',
      nameEn: 'Central Asia',
      position: Offset(0.55, 0.42),
    ),
    CivilizationRegion(
      id: 'caucasus',
      name: '高加索',
      nameEn: 'Caucasus',
      position: Offset(0.42, 0.35),
      isActive: true,
      isHighlighted: true,
    ),
    CivilizationRegion(
      id: 'persia',
      name: '波斯',
      nameEn: 'Persia',
      position: Offset(0.45, 0.48),
    ),
  ];

  /// 世界地图节点（绝对坐标，1200×750 画布）
  static const List<CivilizationRegion> worldMap = [
    CivilizationRegion(
      id: 'china',
      name: '中国',
      nameEn: 'China',
      position: Offset(890, 380),
      description: '东亚文明古国\n四大文明古国之一\n延续五千年的文化传承',
      route: '/',
    ),
    CivilizationRegion(
      id: 'central-asia',
      name: '中亚',
      nameEn: 'Central Asia',
      position: Offset(720, 310),
      description: '丝绸之路核心地带\n东西文明交汇的桥梁\n游牧与绿洲文明共存',
      route: '/',
    ),
    CivilizationRegion(
      id: 'caucasus',
      name: '高加索',
      nameEn: 'Caucasus',
      position: Offset(460, 260),
      description: '欧亚交界的重要区域\n连接黑海与里海\n多民族交流区域',
      route: '/caucasus',
      isActive: true,
      isHighlighted: true,
    ),
    CivilizationRegion(
      id: 'persia',
      name: '波斯',
      nameEn: 'Persia',
      position: Offset(520, 370),
      description: '伊朗高原文明\n世界首个帝国\n灿烂的艺术与建筑',
      route: '/',
    ),
    CivilizationRegion(
      id: 'mediterranean',
      name: '地中海',
      nameEn: 'Mediterranean',
      position: Offset(360, 290),
      description: '西方文明的摇篮\n古希腊罗马的发源地\n海上贸易的枢纽',
      route: '/',
    ),
  ];
}
