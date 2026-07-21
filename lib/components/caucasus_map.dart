import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../models/exploration_progress.dart';

/// 高加索区域地图
///
///
/// 古地图风格区域地图：
/// • 黑海（左） - 里海（右）
/// • 高加索山脉（中）
/// • 城市节点（第比利斯 / 巴库 / 埃里温）
/// • 3 个可交互发现点
class CaucasusMap extends ConsumerStatefulWidget {
  const CaucasusMap({super.key});

  @override
  ConsumerState<CaucasusMap> createState() => _CaucasusMapState();
}

class _CaucasusMapState extends ConsumerState<CaucasusMap>
    with SingleTickerProviderStateMixin {
  AnimationController? _pulseCtrl;
  Animation<double>? _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _pulseAnim = Tween(begin: 0.0, end: 1.0).animate(_pulseCtrl!);
  }

  @override
  void dispose() {
    _pulseCtrl?.dispose();
    super.dispose();
  }

  void _handleTap(Offset localPos, Size size) {
    for (final point in DiscoveryPoint.caucasus) {
      final px = point.position.dx * size.width;
      final py = point.position.dy * size.height;
      final dx = localPos.dx - px;
      final dy = localPos.dy - py;
      if (math.sqrt(dx * dx + dy * dy) < 28) {
        ref.read(activeDiscoveryProvider.notifier).state = point;
        return;
      }
    }
    // 点击空白 → 关闭信息卡
    ref.read(activeDiscoveryProvider.notifier).state = null;
  }

  @override
  Widget build(BuildContext context) {
    final progress =
        ref.watch(explorationProgressProvider).forRegion('caucasus');
    final pulseValue = _pulseAnim?.value ?? 0.5;

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        return GestureDetector(
          onTapUp: (details) => _handleTap(details.localPosition, size),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CustomPaint(
              size: size,
              painter: _CaucasusPainter(progress: progress, pulse: pulseValue),
            ),
          ),
        );
      },
    );
  }
}

class _CaucasusPainter extends CustomPainter {
  final RegionProgress progress;
  final double pulse;

  _CaucasusPainter({required this.progress, required this.pulse});

  @override
  void paint(Canvas canvas, Size size) {
    _drawBg(canvas, size);
    _drawSeas(canvas, size);
    _drawLand(canvas, size);
    _drawMountains(canvas, size);
    _drawDiscoveryLines(canvas, size);
    _drawCityNodes(canvas, size);
    _drawDiscoveryNodes(canvas, size);
  }

  // ── 背景 ──
  void _drawBg(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF0D2A3A),
          const Color(0xFF0A1F30),
          const Color(0xFF081A28),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // 网格
    final grid = Paint()
      ..color = AppTheme.gold.withAlpha(12)
      ..strokeWidth = 0.3;
    for (double x = 0; x < size.width; x += 30) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (double y = 0; y < size.height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
  }

  // ── 黑海与里海 ──
  void _drawSeas(Canvas canvas, Size size) {
    final seaFill = Paint()
      ..color = const Color(0xFF0A3050)
      ..style = PaintingStyle.fill;
    final seaStroke = Paint()
      ..color = AppTheme.gold.withAlpha(60)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    // 黑海
    final blackSeaPath = Path()
      ..addOval(Rect.fromCenter(
        center: _rel(0.22, 0.30, size),
        width: size.width * 0.20,
        height: size.height * 0.16,
      ));
    canvas.drawPath(blackSeaPath, seaFill);
    canvas.drawPath(blackSeaPath, seaStroke);

    // 里海
    final caspianPath = Path()
      ..addOval(Rect.fromCenter(
        center: _rel(0.76, 0.32, size),
        width: size.width * 0.16,
        height: size.height * 0.28,
      ));
    canvas.drawPath(caspianPath, seaFill);
    canvas.drawPath(caspianPath, seaStroke);

    // 海名
    _drawLabel(canvas, '黑海', _rel(0.22, 0.30, size), 11, 50);
    _drawLabel(canvas, '里海', _rel(0.76, 0.32, size), 11, 50);
  }

  // ── 陆地 ──
  void _drawLand(Canvas canvas, Size size) {
    final land = Paint()
      ..color = AppTheme.gold.withAlpha(20)
      ..style = PaintingStyle.fill;
    final outline = Paint()
      ..color = AppTheme.gold.withAlpha(50)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;

    final landPath = Path();
    final cx = size.width * 0.48;
    final cy = size.height * 0.55;
    landPath.moveTo(cx - size.width * 0.30, cy - size.height * 0.10);
    landPath.cubicTo(
      cx - size.width * 0.15,
      cy - size.height * 0.25,
      cx + size.width * 0.15,
      cy - size.height * 0.25,
      cx + size.width * 0.30,
      cy - size.height * 0.10,
    );
    landPath.cubicTo(
      cx + size.width * 0.35,
      cy,
      cx + size.width * 0.30,
      cy + size.height * 0.15,
      cx + size.width * 0.20,
      cy + size.height * 0.20,
    );
    landPath.cubicTo(
      cx + size.width * 0.10,
      cy + size.height * 0.25,
      cx - size.width * 0.10,
      cy + size.height * 0.25,
      cx - size.width * 0.20,
      cy + size.height * 0.20,
    );
    landPath.cubicTo(
      cx - size.width * 0.30,
      cy + size.height * 0.15,
      cx - size.width * 0.35,
      cy,
      cx - size.width * 0.30,
      cy - size.height * 0.10,
    );
    landPath.close();

    canvas.drawPath(landPath, land);
    canvas.drawPath(landPath, outline);
  }

  // ── 山脉（三角形符号） ──
  void _drawMountains(Canvas canvas, Size size) {
    final mtn = Paint()
      ..color = AppTheme.gold.withAlpha(80)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    final mtnFill = Paint()
      ..color = AppTheme.gold.withAlpha(20)
      ..style = PaintingStyle.fill;

    final startX = size.width * 0.28;
    final endX = size.width * 0.72;
    final peakY = size.height * 0.30;
    final baseY = size.height * 0.44;
    final count = 8;

    for (int i = 0; i < count; i++) {
      final t = i / (count - 1);
      final x = startX + (endX - startX) * t;
      final peakH = 8 + math.sin(t * math.pi) * 10;
      final baseW = 12 + math.sin(t * math.pi) * 6;

      final p = Path()
        ..moveTo(x - baseW, baseY)
        ..lineTo(x, peakY - peakH)
        ..lineTo(x + baseW, baseY)
        ..close();
      canvas.drawPath(p, mtnFill);
      canvas.drawPath(p, mtn);
    }

    _drawLabel(canvas, '大高加索山脉', _rel(0.48, 0.38, size), 10, 60);
  }

  // ── 城市节点 ──
  void _drawCityNodes(Canvas canvas, Size size) {
    final cities = [
      ('第比利斯', Offset(0.48, 0.55)),
      ('巴库', Offset(0.68, 0.56)),
      ('埃里温', Offset(0.42, 0.65)),
      ('库塔伊西', Offset(0.38, 0.50)),
    ];

    for (final (name, pos) in cities) {
      final p = _rel(pos.dx, pos.dy, size);
      final dot = Paint()..color = AppTheme.paper.withAlpha(140);
      canvas.drawCircle(p, 3, dot);
      _drawLabel(canvas, name, Offset(p.dx, p.dy + 8), 9, 100);
    }
  }

  // ── 发现点之间的路径 ──
  void _drawDiscoveryLines(Canvas canvas, Size size) {
    final points = DiscoveryPoint.caucasus;
    if (points.length < 3) return;

    final paint = Paint()
      ..color = AppTheme.gold.withAlpha(40)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    _dashedLine(canvas, _rp(points[0], size), _rp(points[1], size), paint);
    _dashedLine(canvas, _rp(points[1], size), _rp(points[2], size), paint);
  }

  // ── 发现点节点 ──
  void _drawDiscoveryNodes(Canvas canvas, Size size) {
    for (final point in DiscoveryPoint.caucasus) {
      final pos = _rp(point, size);
      final collected = progress.isCollected(point.id);
      final isHighlighted = point.id == 'caucasus-mountains';
      final radius = isHighlighted ? 10.0 : 8.0;

      // 脉冲光圈
      if (isHighlighted) {
        final glowR = 14 + pulse * 10;
        final glow = Paint()
          ..color = AppTheme.gold.withAlpha((30 + (pulse * 40)).toInt())
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
        canvas.drawCircle(pos, glowR, glow);
      }

      // 外圈
      final outer = Paint()
        ..color = collected ? AppTheme.green : AppTheme.gold
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(pos, radius + 3, outer);

      // 内点
      final inner = Paint()..color = collected ? AppTheme.green : AppTheme.gold;
      canvas.drawCircle(pos, radius, inner);

      if (collected) {
        // 对勾
        final check = Paint()
          ..color = AppTheme.background
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round;
        final ckPath = Path()
          ..moveTo(pos.dx - 4, pos.dy)
          ..lineTo(pos.dx - 1, pos.dy + 3)
          ..lineTo(pos.dx + 4, pos.dy - 3);
        canvas.drawPath(ckPath, check);
      }

      // 标签
      _drawLabel(canvas, point.name, Offset(pos.dx, pos.dy + radius + 10),
          collected ? 12 : 11, collected ? 220 : 180);
    }
  }

  // ── 工具 ──
  Offset _rel(double rx, double ry, Size s) =>
      Offset(rx * s.width, ry * s.height);
  Offset _rp(DiscoveryPoint p, Size s) =>
      Offset(p.position.dx * s.width, p.position.dy * s.height);

  void _drawLabel(
      Canvas canvas, String text, Offset pos, double size, int alpha) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: AppTheme.paper.withAlpha(alpha),
          fontSize: size,
          fontFamily: 'PingFang SC',
          shadows: const [Shadow(color: AppTheme.background, blurRadius: 3)],
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, Offset(pos.dx - tp.width / 2, pos.dy + 4));
  }

  void _dashedLine(Canvas canvas, Offset a, Offset b, Paint p) {
    final dx = b.dx - a.dx;
    final dy = b.dy - a.dy;
    final dist = math.sqrt(dx * dx + dy * dy);
    if (dist < 1) return;
    final angle = math.atan2(dy, dx);
    const dash = 4.0;
    const gap = 3.0;
    double drawn = 0;
    bool isDash = true;
    while (drawn < dist) {
      final len = (isDash ? dash : gap).clamp(0, dist - drawn);
      if (isDash) {
        canvas.drawLine(
          a + Offset(math.cos(angle) * drawn, math.sin(angle) * drawn),
          a +
              Offset(math.cos(angle) * (drawn + len),
                  math.sin(angle) * (drawn + len)),
          p,
        );
      }
      drawn += len;
      isDash = !isDash;
    }
  }

  @override
  bool shouldRepaint(covariant _CaucasusPainter old) =>
      old.progress != progress || old.pulse != pulse;
}
