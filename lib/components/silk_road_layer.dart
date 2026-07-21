import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../data/map_data.dart';

/// 丝绸之路图层绘制器（静态工具）
///
/// 在 CustomPainter 中调用，绘制金色路线。
/// 节点顺序：中国 → 中亚 → 高加索 → 波斯 → 地中海
class SilkRoadLayer {
  SilkRoadLayer._();

  static void draw(Canvas canvas, Map<String, Offset> nodes) {
    if (silkRoadOrder.length < 2) return;

    const double glowWidth = 6.0;
    const double lineWidth = 2.5;

    // 逐段绘制路径
    for (int i = 0; i < silkRoadOrder.length - 1; i++) {
      final fromId = silkRoadOrder[i];
      final toId = silkRoadOrder[i + 1];
      final from = nodes[fromId];
      final to = nodes[toId];
      if (from == null || to == null) continue;

      // 光晕底层
      final glowPaint = Paint()
        ..color = AppTheme.gold.withAlpha(40)
        ..strokeWidth = glowWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(from, to, glowPaint);

      // 主体金线
      final linePaint = Paint()
        ..color = AppTheme.gold.withAlpha(200)
        ..strokeWidth = lineWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(from, to, linePaint);

      // 流动光点动画（静态快照，运行时由 Widget 控制）
      final dotPaint = Paint()
        ..color = AppTheme.gold
        ..style = PaintingStyle.fill;
      for (int d = 0; d < 3; d++) {
        final progress = (i + d * 0.33) / silkRoadOrder.length;
        final pos = Offset.lerp(from, to, progress)!;
        canvas.drawCircle(pos, 2.5, dotPaint);
      }
    }

    // 端点发光
    for (final id in silkRoadOrder) {
      final pos = nodes[id];
      if (pos == null) continue;
      final dotGlow = Paint()
        ..color = AppTheme.gold.withAlpha(50)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(pos, 12, dotGlow);
    }
  }
}
