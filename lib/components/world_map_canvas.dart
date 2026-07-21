import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../data/map_data.dart';
import '../components/map_coordinate_transform.dart';
import '../data/map_state.dart';
import '../models/civilization_region.dart';
import 'silk_road_layer.dart';

/// 世界地图画布 — InteractiveViewer + CustomPainter
///
/// 支持统一矩阵动画、双指手势、双击放大、按钮缩放、回到全图。
class WorldMapCanvas extends ConsumerStatefulWidget {
  final void Function(CivilizationRegion region)? onNodeTap;

  const WorldMapCanvas({super.key, this.onNodeTap});

  @override
  ConsumerState<WorldMapCanvas> createState() => _WorldMapCanvasState();
}

class _WorldMapCanvasState extends ConsumerState<WorldMapCanvas>
    with SingleTickerProviderStateMixin {
  final TransformationController _transformCtrl = TransformationController();
  AnimationController? _animCtrl;
  Animation<Matrix4>? _anim;
  Size? _lastViewportSize;
  bool _initialFitApplied = false;
  Offset? _doubleTapPos;
  DateTime? _lastDoubleTapTime;
  Offset? _lastNodeScreenPos;
  double _fitScale = 1.0;

  static const double _childW = 1400;
  static const double _childH = 950;

  double get _minScale => _fitScale * 0.85;
  double get _maxScale => (_fitScale * 4).clamp(3.5, 5.0);
  double get _currentAbsScale => _transformCtrl.value.getMaxScaleOnAxis();
  double get _currentZoomPercent =>
      (_currentAbsScale / _fitScale * 100).roundToDouble();

  /// 最近点击节点的屏幕位置（在父容器坐标系中），用于自适应信息卡定位
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 380));
  }

  @override
  void dispose() {
    _transformCtrl.dispose();
    _animCtrl?.dispose();
    super.dispose();
  }

  // ── 统一矩阵动画 ──
  void _animateToMatrix(Matrix4 target) {
    _anim?.removeListener(_onAnimTick);
    _animCtrl!.stop();
    _animCtrl!.reset();
    final start = _transformCtrl.value;
    _anim = _animCtrl!
        .drive(CurveTween(curve: Curves.easeOutCubic))
        .drive(Matrix4Tween(begin: start, end: target));
    _anim!.addListener(_onAnimTick);
    _animCtrl!.forward(from: 0);
  }

  void _onAnimTick() {
    if (_anim == null) return;
    _transformCtrl.value = _anim!.value;
    _publishZoom();
  }

  void _publishZoom() {
    ref.read(mapZoomLevelProvider.notifier).state = _currentAbsScale;
    ref.read(zoomDisplayProvider.notifier).state = _currentZoomPercent;
  }

  // ── Fit 矩阵 ──
  Matrix4 _calculateFitMatrix(Size viewport) {
    const double margin = 1.05;
    _fitScale = math.min(
      viewport.width / (_childW * margin),
      viewport.height / (_childH * margin),
    );
    final double dx = (viewport.width - _childW * _fitScale) / 2;
    final double dy = (viewport.height - _childH * _fitScale) / 2;
    return Matrix4.identity()
      ..translate(dx, dy)
      ..scale(_fitScale);
  }

  void _animateToFitView(Size viewport) {
    _animateToMatrix(_calculateFitMatrix(viewport));
  }

  // ── 缩放保持指定视口坐标点不变 ──
  Matrix4 _scaleAroundViewportCenter(
      Matrix4 current, Offset center, double targetAbsScale) {
    final s = current.getMaxScaleOnAxis();
    final ratio = targetAbsScale / s;
    final tx = current.getTranslation().x;
    final ty = current.getTranslation().y;
    final newTx = center.dx * (1 - ratio) + tx * ratio;
    final newTy = center.dy * (1 - ratio) + ty * ratio;
    return Matrix4.identity()
      ..translate(newTx, newTy)
      ..scale(targetAbsScale);
  }

  // ── 公共方法（WorldMapScreen 调用） ──
  void zoomIn(Size viewport) {
    final c = Offset(viewport.width / 2, viewport.height / 2);
    final ns = (_currentAbsScale * 1.25).clamp(_minScale, _maxScale);
    _animateToMatrix(_scaleAroundViewportCenter(_transformCtrl.value, c, ns));
  }

  void zoomOut(Size viewport) {
    final c = Offset(viewport.width / 2, viewport.height / 2);
    final ns = (_currentAbsScale / 1.25).clamp(_minScale, _maxScale);
    _animateToMatrix(_scaleAroundViewportCenter(_transformCtrl.value, c, ns));
  }

  void resetToFit(Size viewport) {
    _animateToFitView(viewport);
  }

  // ── 节点点击 ──
  void _handleTap(Offset localPos) {
    // Skip if a double-tap just occurred (within 400ms)
    if (_lastDoubleTapTime != null &&
        DateTime.now().difference(_lastDoubleTapTime!).inMilliseconds < 400) {
      return;
    }
    for (final region in CivilizationRegion.worldMap) {
      final mapPos = childToMap(localPos);
      final dx = mapPos.dx - region.position.dx;
      final dy = mapPos.dy - region.position.dy;
      if (math.sqrt(dx * dx + dy * dy) < 28) {
        // Compute node screen position for info card adaptive placement
        final current = _transformCtrl.value;
        final s = current.getMaxScaleOnAxis();
        final tx = current.getTranslation().x;
        final ty = current.getTranslation().y;
        final childPos = mapToChild(region.position);
        ref.read(nodeScreenPositionProvider.notifier).state = Offset(
          childPos.dx * s + tx,
          childPos.dy * s + ty,
        );
        widget.onNodeTap?.call(region);
        // Focus on node
        final vp = _lastViewportSize;
        if (vp == null) return;
        final targetScale = (_fitScale * 2.2).clamp(_minScale, _maxScale);
        final center = Offset(vp.width * 0.38, vp.height * 0.50);
        final s2 = current.getMaxScaleOnAxis();
        final ratio = targetScale / s2;
        final tx2 = current.getTranslation().x;
        final ty2 = current.getTranslation().y;
        final newTx = center.dx * (1 - ratio) + tx2 * ratio;
        final newTy = center.dy * (1 - ratio) + ty2 * ratio;
        // Adjust for node position in child coordinates
        final childPos2 = mapToChild(region.position);
        final nodeScreen = Offset(
          childPos2.dx * s2 + tx2,
          childPos2.dy * s2 + ty2,
        );
        final adjustX = center.dx - nodeScreen.dx;
        final adjustY = center.dy - nodeScreen.dy;
        final finalTx = newTx + adjustX;
        final finalTy = newTy + adjustY;
        _animateToMatrix(Matrix4.identity()
          ..translate(finalTx, finalTy)
          ..scale(targetScale));
        return;
      }
    }
    widget.onNodeTap?.call(CivilizationRegion(
        id: '', name: '', nameEn: '', position: Offset.zero));
  }

  @override
  Widget build(BuildContext context) {
    final silkVisible = ref.watch(silkRoadVisibleProvider);

    ref.listen<int>(mapResetViewProvider, (_, __) {
      if (_lastViewportSize != null) _animateToFitView(_lastViewportSize!);
    });
    ref.listen<MapZoomAction>(mapZoomActionProvider, (_, action) {
      if (action == MapZoomAction.none || _lastViewportSize == null) return;
      if (action == MapZoomAction.zoomIn)
        zoomIn(_lastViewportSize!);
      else if (action == MapZoomAction.zoomOut)
        zoomOut(_lastViewportSize!);
      else if (action == MapZoomAction.reset) resetToFit(_lastViewportSize!);
      ref.read(mapZoomActionProvider.notifier).state = MapZoomAction.none;
    });

    return LayoutBuilder(
      builder: (context, constraints) {
        final vp = constraints.biggest;
        if (_lastViewportSize != vp) {
          final changed = _lastViewportSize == null ||
              (_lastViewportSize!.width - vp.width).abs() > 10 ||
              (_lastViewportSize!.height - vp.height).abs() > 10;
          _lastViewportSize = vp;
          if (changed) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _transformCtrl.value = _calculateFitMatrix(vp);
              _initialFitApplied = true;
              _publishZoom();
            });
          }
        }
        return InteractiveViewer(
          transformationController: _transformCtrl,
          minScale: _minScale,
          maxScale: _maxScale,
          boundaryMargin: EdgeInsets.all(math.max(vp.width, vp.height) * 0.5),
          constrained: false,
          onInteractionEnd: (_) => _publishZoom(),
          child: GestureDetector(
            onTapDown: (d) => _doubleTapPos = d.localPosition,
            onTapUp: (d) => _handleTap(d.localPosition),
            onDoubleTap: () {
              _lastDoubleTapTime = DateTime.now();
              final vp = _lastViewportSize;
              final tapPos = _doubleTapPos;
              if (vp == null || tapPos == null) return;
              // If double-tapping on a node, skip zoom (let node focus)
              bool onNode = false;
              for (final region in CivilizationRegion.worldMap) {
                final tapMap = childToMap(tapPos);
                final dx = tapMap.dx - region.position.dx;
                final dy = tapMap.dy - region.position.dy;
                if (math.sqrt(dx * dx + dy * dy) < 28) {
                  onNode = true;
                  break;
                }
              }
              if (onNode) return;
              // Convert child-space tap to screen-space center for zoom-around-point
              final current = _transformCtrl.value;
              final s = current.getMaxScaleOnAxis();
              final tx = current.getTranslation().x;
              final ty = current.getTranslation().y;
              final screenPos = Offset(tapPos.dx * s + tx, tapPos.dy * s + ty);
              final ns = (_currentAbsScale * 1.5).clamp(_minScale, _maxScale);
              _animateToMatrix(
                  _scaleAroundViewportCenter(current, screenPos, ns));
            },
            child: SizedBox(
              width: _childW,
              height: _childH,
              child: Padding(
                padding: const EdgeInsets.all(100),
                child: CustomPaint(
                  size: MapConstants.canvasSize,
                  painter: _WorldMapPainter(
                    regions: CivilizationRegion.worldMap,
                    silkRoadVisible: silkVisible,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ───────────── _WorldMapPainter (unchanged) ─────────────

class _WorldMapPainter extends CustomPainter {
  final List<CivilizationRegion> regions;
  final bool silkRoadVisible;
  _WorldMapPainter({required this.regions, this.silkRoadVisible = false});

  @override
  void paint(Canvas canvas, Size size) {
    _drawOceanBg(canvas, size);
    _drawContinents(canvas, size);
    _drawConnectionLines(canvas, size);
    if (silkRoadVisible) _drawSilkRoad(canvas, size);
    _drawNodes(canvas, size);
  }

  void _drawOceanBg(Canvas c, Size s) {
    final p = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF0A2030),
          const Color(0xFF071C2C),
          const Color(0xFF051624)
        ],
      ).createShader(Rect.fromLTWH(0, 0, s.width, s.height));
    c.drawRect(Rect.fromLTWH(0, 0, s.width, s.height), p);
    final g = Paint()
      ..color = AppTheme.gold.withAlpha(10)
      ..strokeWidth = 0.3;
    for (double x = 0; x <= s.width; x += 60)
      c.drawLine(Offset(x, 0), Offset(x, s.height), g);
    for (double y = 0; y <= s.height; y += 60)
      c.drawLine(Offset(0, y), Offset(s.width, y), g);
  }

  void _drawContinents(Canvas c, Size s) {
    final f = Paint()
      ..color = AppTheme.gold.withAlpha(30)
      ..style = PaintingStyle.fill;
    final st = Paint()
      ..color = AppTheme.gold.withAlpha(80)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    for (final ct in ContinentData.all) {
      c.drawPath(ct.path, f);
      c.drawPath(ct.path, st);
      final b = ct.path.getBounds();
      final tp = TextPainter(
          text: TextSpan(
              text: ct.name,
              style: TextStyle(
                  color: AppTheme.gold.withAlpha(60),
                  fontSize: 13,
                  fontFamily: 'PingFang SC')),
          textDirection: TextDirection.ltr);
      tp.layout();
      tp.paint(
          c, Offset(b.center.dx - tp.width / 2, b.center.dy - tp.height / 2));
    }
  }

  void _drawNodes(Canvas c, Size s) {
    for (final r in regions) {
      final p = r.position;
      final hl = r.isHighlighted;
      final nr = hl ? 10.0 : 7.0;
      if (hl) {
        final g = Paint()
          ..color = AppTheme.gold.withAlpha(50)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
        c.drawCircle(p, 20, g);
      }
      final o = Paint()
        ..color = hl ? AppTheme.gold : AppTheme.paper.withAlpha(120)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      c.drawCircle(p, nr + 3, o);
      final f = Paint()
        ..color = hl ? AppTheme.gold : AppTheme.paper.withAlpha(200);
      c.drawCircle(p, nr, f);
      final tp = TextPainter(
          text: TextSpan(
              text: r.name,
              style: TextStyle(
                  color: AppTheme.paper,
                  fontSize: hl ? 14 : 12,
                  fontWeight: hl ? FontWeight.w600 : FontWeight.w400,
                  fontFamily: 'PingFang SC',
                  shadows: const [
                    Shadow(color: AppTheme.background, blurRadius: 4)
                  ])),
          textDirection: TextDirection.ltr);
      tp.layout();
      tp.paint(c, Offset(p.dx - tp.width / 2, p.dy + nr + 8));
      if (r.isActive) {
        final bg = Paint()..color = AppTheme.gold;
        c.drawRRect(
            RRect.fromRectAndRadius(
                Rect.fromCenter(
                    center: Offset(p.dx, p.dy + nr + 32),
                    width: 52,
                    height: 18),
                const Radius.circular(4)),
            bg);
        final bt = TextPainter(
            text: const TextSpan(
                text: '探索中',
                style: TextStyle(
                    color: AppTheme.background,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'PingFang SC')),
            textDirection: TextDirection.ltr);
        bt.layout();
        bt.paint(c, Offset(p.dx - 18, p.dy + nr + 25));
      }
    }
  }

  void _drawConnectionLines(Canvas c, Size s) {
    final p = Paint()
      ..color = AppTheme.gold.withAlpha(35)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;
    final n = <String, Offset>{};
    for (final r in regions) n[r.id] = r.position;
    _dl(c, n['caucasus']!, n['central-asia']!, p);
    _dl(c, n['central-asia']!, n['china']!, p);
    _dl(c, n['caucasus']!, n['persia']!, p);
    _dl(c, n['caucasus']!, n['mediterranean']!, p);
  }

  void _dl(Canvas c, Offset a, Offset b, Paint p) {
    final dx = b.dx - a.dx,
        dy = b.dy - a.dy,
        dist = math.sqrt(dx * dx + dy * dy);
    if (dist < 1) return;
    final angle = math.atan2(dy, dx);
    const dash = 5.0, gap = 4.0;
    double d = 0;
    bool isDash = true;
    while (d < dist) {
      final l = (isDash ? dash : gap).clamp(0, dist - d);
      if (isDash)
        c.drawLine(
            a + Offset(math.cos(angle) * d, math.sin(angle) * d),
            a + Offset(math.cos(angle) * (d + l), math.sin(angle) * (d + l)),
            p);
      d += l;
      isDash = !isDash;
    }
  }

  void _drawSilkRoad(Canvas canvas, Size size) {
    final n = <String, Offset>{};
    for (final r in regions) n[r.id] = r.position;
    SilkRoadLayer.draw(canvas, n);
  }

  @override
  bool shouldRepaint(covariant _WorldMapPainter old) =>
      old.silkRoadVisible != silkRoadVisible || old.regions != regions;
}

/// Matrix4Tween for smooth matrix animation
class Matrix4Tween extends Tween<Matrix4> {
  Matrix4Tween({Matrix4? begin, Matrix4? end}) : super(begin: begin, end: end);
  @override
  Matrix4 lerp(double t) {
    final result = Matrix4.identity();
    for (int i = 0; i < 16; i++) {
      result.storage[i] =
          begin!.storage[i] + (end!.storage[i] - begin!.storage[i]) * t;
    }
    return result;
  }
}
