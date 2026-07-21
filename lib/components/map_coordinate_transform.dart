import 'package:flutter/material.dart';

// ── Coordinate System Constants ──
// Map content space: 1200×750 (CustomPaint canvas)
// Child space: 1400×950 (SizedBox inside InteractiveViewer, includes 100px padding)
// Viewport space: screen coordinates after TransformationController transform

const double kMapContentWidth = 1200;
const double kMapContentHeight = 750;
const double kChildWidth = 1400;
const double kChildHeight = 950;
const double kMapPadding = 100.0;

// ── Conversions ──

/// Convert from map content coordinates (1200×750) to child space (1400×950)
Offset mapToChild(Offset mapPoint) {
  return Offset(mapPoint.dx + kMapPadding, mapPoint.dy + kMapPadding);
}

/// Convert from child space (1400×950) to map content coordinates (1200×750)
Offset childToMap(Offset childPoint) {
  return Offset(childPoint.dx - kMapPadding, childPoint.dy - kMapPadding);
}

/// Convert from child space to viewport/screen coordinates
/// using the TransformationController matrix.
Offset childToViewport(Offset childPoint, Matrix4 transform) {
  final s = transform.getMaxScaleOnAxis();
  final tx = transform.getTranslation().x;
  final ty = transform.getTranslation().y;
  return Offset(childPoint.dx * s + tx, childPoint.dy * s + ty);
}

/// Convert from viewport/screen coordinates to child space
Offset viewportToChild(Offset viewportPoint, Matrix4 transform) {
  final s = transform.getMaxScaleOnAxis();
  final tx = transform.getTranslation().x;
  final ty = transform.getTranslation().y;
  return Offset(
    (viewportPoint.dx - tx) / s,
    (viewportPoint.dy - ty) / s,
  );
}
