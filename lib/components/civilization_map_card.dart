import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/civilization_region.dart';
import 'civilization_node.dart';

/// 文明地图工作区组件
///
/// 古地图风格的交互式文明区域展示。
/// 背景：深棕渐变 + 仿古网格线 + 简化大陆轮廓。
/// 前景：文明节点 + 连接线。
class CivilizationMapCard extends StatelessWidget {
  const CivilizationMapCard({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.gold.withAlpha(60), width: 0.5),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              // ── 古地图背景 ──
              _buildMapBackground(size),
              // ── 自定义绘制：网格 + 大陆 + 连接线 ──
              Positioned.fill(
                child: CustomPaint(
                  painter: _AncientMapPainter(
                    regions: CivilizationRegion.featured,
                  ),
                ),
              ),
              // ── 文明节点 ──
              ...CivilizationRegion.featured.map((region) {
                return Positioned(
                  left: region.position.dx * size.width - 60,
                  top: region.position.dy * size.height - 30,
                  child: CivilizationNode(region: region),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMapBackground(Size size) {
    return Container(
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0D2A3A),
            const Color(0xFF0A1F30),
            const Color(0xFF081A28),
          ],
        ),
      ),
      child: Stack(
        children: [
          // ── 暖色中心光晕（仿古地图中心照明） ─-
          Center(
            child: Container(
              width: size.shortestSide * 0.8,
              height: size.shortestSide * 0.8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.7,
                  colors: [
                    AppTheme.gold.withAlpha(15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // ── 装饰性边框 ──
          Positioned(
            top: 12,
            left: 12,
            child: Icon(Icons.arrow_back,
                color: AppTheme.gold.withAlpha(50), size: 16),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: Transform.flip(
              flipX: true,
              child: Icon(Icons.arrow_back,
                  color: AppTheme.gold.withAlpha(50), size: 16),
            ),
          ),
          Positioned(
            bottom: 12,
            left: 12,
            child: Transform.flip(
              flipY: true,
              child: Icon(Icons.arrow_back,
                  color: AppTheme.gold.withAlpha(50), size: 16),
            ),
          ),
          Positioned(
            bottom: 12,
            right: 12,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationZ(math.pi),
              child: Icon(Icons.arrow_back,
                  color: AppTheme.gold.withAlpha(50), size: 16),
            ),
          ),
        ],
      ),
    );
  }
}

/// 古地图装饰绘制器
class _AncientMapPainter extends CustomPainter {
  final List<CivilizationRegion> regions;

  _AncientMapPainter({required this.regions});

  @override
  void paint(Canvas canvas, Size size) {
    _drawGrid(canvas, size);
    _drawContinents(canvas, size);
    _drawConnections(canvas, size);
    _drawCompass(canvas, size);
  }

  // ── 网格线 ──
  void _drawGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.gold.withAlpha(15)
      ..strokeWidth = 0.3;

    const xCount = 12;
    const yCount = 8;

    for (int i = 0; i <= xCount; i++) {
      final x = size.width * i / xCount;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (int i = 0; i <= yCount; i++) {
      final y = size.height * i / yCount;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  // ── 简化大陆轮廓（欧亚非） ──
  void _drawContinents(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.gold.withAlpha(25)
      ..style = PaintingStyle.fill;

    final path = Path();

    // 简化的欧亚大陆轮廓
    final cx = size.width * 0.48;
    final cy = size.height * 0.42;
    final rw = size.width * 0.35;
    final rh = size.height * 0.30;

    path.moveTo(cx - rw, cy - rh * 0.5);
    path.quadraticBezierTo(cx - rw * 0.5, cy - rh, cx, cy - rh * 0.6);
    path.quadraticBezierTo(
        cx + rw * 0.3, cy - rh * 0.8, cx + rw, cy - rh * 0.3);
    path.quadraticBezierTo(cx + rw * 1.1, cy, cx + rw * 0.8, cy + rh * 0.3);
    path.quadraticBezierTo(cx + rw * 0.5, cy + rh * 0.6, cx, cy + rh * 0.5);
    path.quadraticBezierTo(
        cx - rw * 0.3, cy + rh * 0.4, cx - rw, cy + rh * 0.2);
    path.quadraticBezierTo(cx - rw * 1.1, cy, cx - rw, cy - rh * 0.5);
    path.close();

    canvas.drawPath(path, paint);

    // 非洲突出部
    final africaPaint = Paint()
      ..color = AppTheme.gold.withAlpha(20)
      ..style = PaintingStyle.fill;

    final africa = Path();
    africa.moveTo(size.width * 0.40, size.height * 0.55);
    africa.quadraticBezierTo(
      size.width * 0.38,
      size.height * 0.62,
      size.width * 0.42,
      size.height * 0.70,
    );
    africa.quadraticBezierTo(
      size.width * 0.46,
      size.height * 0.68,
      size.width * 0.48,
      size.height * 0.60,
    );
    africa.quadraticBezierTo(
      size.width * 0.45,
      size.height * 0.55,
      size.width * 0.40,
      size.height * 0.55,
    );
    africa.close();
    canvas.drawPath(africa, africaPaint);
  }

  // ── 节点连接线（虚线风格） ──
  void _drawConnections(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.gold.withAlpha(50)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    // 高加索 → 中亚 → 中国
    _dashedLine(
      canvas,
      _pos(regions[2].position, size), // 高加索
      _pos(regions[1].position, size), // 中亚
      paint,
    );
    _dashedLine(
      canvas,
      _pos(regions[1].position, size), // 中亚
      _pos(regions[0].position, size), // 中国
      paint,
    );

    // 高加索 → 波斯
    _dashedLine(
      canvas,
      _pos(regions[2].position, size), // 高加索
      _pos(regions[3].position, size), // 波斯
      paint,
    );
  }

  Offset _pos(Offset relative, Size size) {
    return Offset(relative.dx * size.width, relative.dy * size.height);
  }

  void _dashedLine(Canvas canvas, Offset from, Offset to, Paint paint) {
    final dx = to.dx - from.dx;
    final dy = to.dy - from.dy;
    final distance = math.sqrt(dx * dx + dy * dy);
    final angle = math.atan2(dy, dx);
    const dashLength = 6.0;
    const gapLength = 4.0;

    double drawn = 0;
    bool isDash = true;

    while (drawn < distance) {
      final segmentLength = isDash ? dashLength : gapLength;
      final remaining = distance - drawn;
      final drawLen = segmentLength < remaining ? segmentLength : remaining;

      if (isDash) {
        canvas.drawLine(
          Offset(from.dx + math.cos(angle) * drawn,
              from.dy + math.sin(angle) * drawn),
          Offset(from.dx + math.cos(angle) * (drawn + drawLen),
              from.dy + math.sin(angle) * (drawn + drawLen)),
          paint,
        );
      }

      drawn += drawLen;
      isDash = !isDash;
    }
  }

  // ── 指南针 ──
  void _drawCompass(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.88, size.height * 0.15);
    final radius = 20.0;

    final ringPaint = Paint()
      ..color = AppTheme.gold.withAlpha(60)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    canvas.drawCircle(center, radius, ringPaint);
    canvas.drawCircle(center, radius * 0.7, ringPaint);

    final linePaint = Paint()
      ..color = AppTheme.gold.withAlpha(60)
      ..strokeWidth = 0.8;

    // 四向线
    for (int i = 0; i < 4; i++) {
      final angle = math.pi / 2 * i;
      canvas.drawLine(
        center +
            Offset(
                math.cos(angle) * radius * 0.7, math.sin(angle) * radius * 0.7),
        center + Offset(math.cos(angle) * radius, math.sin(angle) * radius),
        linePaint,
      );
    }

    // N
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'N',
        style: TextStyle(
          color: AppTheme.gold.withAlpha(80),
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      center + Offset(-3, -radius - 14),
    );
  }

  @override
  bool shouldRepaint(covariant _AncientMapPainter oldDelegate) => false;
}
