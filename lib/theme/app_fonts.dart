/// 字体配置 — 平台感知的字体系列
library;

import 'package:flutter/foundation.dart' show kIsWeb;

/// Web 上使用 CanvasKit 内置 Noto Sans（支持中文），
/// 原生平台上使用 PingFang SC（系统中文）。
String get appFontFamily => kIsWeb ? 'Noto Sans' : 'PingFang SC';
