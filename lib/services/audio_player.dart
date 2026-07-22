/// 跨平台音频播放器（Web only）
///
/// 使用 dart:js_interop + dart:js_interop_unsafe 调用浏览器 Audio API。
/// 原生平台上编译通过但运行时抛出 UnsupportedError。
library;

import 'dart:convert';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:typed_bytes';

/// 播放 MP3 音频字节（仅 Web 环境）
Future<void> playMp3Bytes(Uint8List bytes) async {
  final base64 = base64Encode(bytes);
  final code = 'new Audio("data:audio/mpeg;base64,$base64").play()'.toJS;
  try {
    // Use dart:js_interop_unsafe to call JavaScript eval
    (globalThis as JSObject).callMethod('eval'.toJS, [code].toJS);
  } catch (_) {
    throw UnsupportedError('音频播放需要 Web 环境');
  }
}
