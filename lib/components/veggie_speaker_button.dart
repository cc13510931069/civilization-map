/// Veggie 语音朗读按钮
///
/// 点击后调用 Edge TTS 合成语音。
/// Web 环境下会自动播放，原生环境下仅返回合成结果（播放待实现）。
library;

import 'package:flutter/material.dart';
import '../services/edge_tts_service.dart';
import '../theme/app_theme.dart';

enum _TtsState { idle, loading, success, error }

class VeggieSpeakerButton extends StatefulWidget {
  final String text;
  const VeggieSpeakerButton({super.key, required this.text});

  @override
  State<VeggieSpeakerButton> createState() => _VeggieSpeakerButtonState();
}

class _VeggieSpeakerButtonState extends State<VeggieSpeakerButton> {
  _TtsState _state = _TtsState.idle;
  final EdgeTtsService _service = EdgeTtsService();

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  Future<void> _synthesize() async {
    if (widget.text.isEmpty) return;
    setState(() => _state = _TtsState.loading);

    try {
      final audioBytes = await _service.synthesize(text: widget.text);
      await playMp3Bytes(Uint8List.fromList(audioBytes));
      setState(() => _state = _TtsState.success);
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) setState(() => _state = _TtsState.idle);
    } catch (_) {
      setState(() => _state = _TtsState.error);
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) setState(() => _state = _TtsState.idle);
    }
  }

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;
    VoidCallback? onTap;

    switch (_state) {
      case _TtsState.idle:
        icon = Icons.volume_up_outlined;
        color = AppTheme.gold.withAlpha(180);
        onTap = _synthesize;
      case _TtsState.loading:
        icon = Icons.hourglass_top;
        color = AppTheme.gold;
        onTap = null;
      case _TtsState.success:
        icon = Icons.volume_up;
        color = AppTheme.green;
        onTap = null;
      case _TtsState.error:
        icon = Icons.volume_off_outlined;
        color = Colors.redAccent.withAlpha(160);
        onTap = null;
    }

    return Semantics(
      button: true,
      label: '朗读这段文字',
      child: GestureDetector(
        onTap: onTap,
        child: _state == _TtsState.loading
            ? SizedBox(
                width: 28, height: 28,
                child: Center(
                  child: SizedBox(
                    width: 16, height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                ),
              )
            : Icon(icon, color: color, size: 20),
      ),
    );
  }
}
