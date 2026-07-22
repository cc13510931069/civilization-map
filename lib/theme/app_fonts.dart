/// 字体配置 — 平台感知的字体系列
///
/// Web 上不设自定义字体，由 CanvasKit 使用内置 Noto Sans 渲染中文。
/// iOS/macOS 上使用 PingFang SC（系统中文）。
library;

import 'package:flutter/foundation.dart' show kIsWeb;

/// 应用主字体系列。Web 上返回 null（使用 Flutter 默认字体）。
String? get appFontFamily => kIsWeb ? null : 'PingFang SC';
