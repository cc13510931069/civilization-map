import 'package:flutter/material.dart';
import 'app_theme.dart';

class AppTypography {
  final double scale;
  const AppTypography({this.scale = 1.15});

  double get display => (30 * scale).roundToDouble();
  double get title1 => (22 * scale).roundToDouble();
  double get title2 => (18 * scale).roundToDouble();
  double get cardTitle => (17 * scale).roundToDouble();
  double get body => (16 * scale).roundToDouble();
  double get button => (15 * scale).roundToDouble();
  double get label => (14 * scale).roundToDouble();
  double get caption => (13 * scale).roundToDouble();

  TextStyle displayStyle({Color? color}) =>
      _s(fontSize: display, w: FontWeight.w700, color: color);
  TextStyle title1Style({Color? color}) =>
      _s(fontSize: title1, w: FontWeight.w700, color: color);
  TextStyle title2Style({Color? color}) =>
      _s(fontSize: title2, w: FontWeight.w600, color: color);
  TextStyle cardTitleStyle({Color? color}) =>
      _s(fontSize: cardTitle, w: FontWeight.w600, color: color);
  TextStyle bodyStyle({Color? color}) =>
      _s(fontSize: body, w: FontWeight.w400, color: color);
  TextStyle buttonStyle({Color? color}) =>
      _s(fontSize: button, w: FontWeight.w600, color: color);
  TextStyle labelStyle({Color? color}) =>
      _s(fontSize: label, w: FontWeight.w500, color: color);
  TextStyle captionStyle({Color? color}) =>
      _s(fontSize: caption, w: FontWeight.w400, color: color);

  TextStyle _s(
          {required double fontSize, required FontWeight w, Color? color}) =>
      TextStyle(
        fontFamily: 'PingFang SC',
        fontSize: fontSize,
        fontWeight: w,
        color: color ?? AppTheme.paper,
      );
}

enum AppTextSize {
  standard(1.00),
  comfortable(1.15),
  large(1.30),
  extraLarge(1.45);

  final double scale;
  const AppTextSize(this.scale);
  String get label => ['标准', '舒适', '较大', '特大'][index];
}
