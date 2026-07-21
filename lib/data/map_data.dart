import 'dart:ui';

/// 世界地图常量与大陆路径定义
///
/// 画布基准尺寸 1200×750 px。
/// 未来替换为 SVG 资源时只需修改此文件。

class MapConstants {
  MapConstants._();

  static const double canvasWidth = 1200;
  static const double canvasHeight = 750;

  static Size get canvasSize => const Size(canvasWidth, canvasHeight);
}

/// 大陆绘制数据
class ContinentData {
  final String id;
  final String name;
  final Path path;

  const ContinentData(
      {required this.id, required this.name, required this.path});

  /// 三大陆简化轮廓
  static List<ContinentData> get all => [europe, asia, africa];

  static final europe =
      ContinentData(id: 'europe', name: '欧洲', path: _buildEurope());
  static final asia = ContinentData(id: 'asia', name: '亚洲', path: _buildAsia());
  static final africa =
      ContinentData(id: 'africa', name: '非洲', path: _buildAfrica());

  static Path _buildEurope() {
    final p = Path();
    p.moveTo(520, 140);
    p.cubicTo(560, 120, 600, 125, 640, 150);
    p.cubicTo(680, 170, 700, 200, 700, 230);
    p.cubicTo(700, 260, 680, 290, 660, 310);
    p.cubicTo(640, 330, 610, 350, 580, 350);
    p.cubicTo(550, 350, 520, 340, 500, 320);
    p.cubicTo(470, 300, 450, 280, 440, 260);
    p.cubicTo(420, 240, 410, 210, 420, 180);
    p.cubicTo(440, 150, 480, 140, 520, 140);
    p.close();
    return p;
  }

  static Path _buildAsia() {
    final p = Path();
    p.moveTo(640, 150);
    p.cubicTo(700, 130, 800, 120, 920, 140);
    p.cubicTo(1020, 160, 1100, 200, 1140, 260);
    p.cubicTo(1160, 300, 1160, 350, 1120, 400);
    p.cubicTo(1080, 440, 1020, 480, 960, 500);
    p.cubicTo(900, 510, 840, 510, 780, 490);
    p.cubicTo(740, 470, 700, 440, 680, 410);
    p.cubicTo(660, 380, 650, 350, 640, 320);
    p.cubicTo(630, 280, 630, 240, 630, 200);
    p.cubicTo(630, 170, 635, 155, 640, 150);
    p.close();
    return p;
  }

  static Path _buildAfrica() {
    final p = Path();
    p.moveTo(420, 380);
    p.cubicTo(460, 360, 520, 360, 560, 380);
    p.cubicTo(600, 400, 640, 430, 650, 470);
    p.cubicTo(660, 510, 650, 560, 620, 600);
    p.cubicTo(600, 630, 570, 650, 540, 650);
    p.cubicTo(510, 650, 480, 630, 460, 600);
    p.cubicTo(430, 560, 410, 510, 400, 470);
    p.cubicTo(390, 430, 400, 400, 420, 380);
    p.close();
    return p;
  }
}

/// 丝绸之路节点顺序（路线依次连线）
const List<String> silkRoadOrder = [
  'china',
  'central-asia',
  'caucasus',
  'persia',
  'mediterranean',
];
