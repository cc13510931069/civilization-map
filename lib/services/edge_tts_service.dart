/// 晓晓（Xiaoxiao）TTS 语音合成服务
import 'dart:convert';
import 'package:http/http.dart' as http;

class EdgeTtsService {
  static const String _tokenUrl = 'https://edge.microsoft.com/translate/auth';
  static const String _ttsUrl = 'https://speech.microsoft.com/cognitiveservices/v1';

  final http.Client _client;
  EdgeTtsService({http.Client? client}) : _client = client ?? http.Client();

  Future<String> _getToken() async {
    final resp = await _client.post(Uri.parse(_tokenUrl), headers: {'User-Agent': 'edge-tts'});
    if (resp.statusCode == 200) return resp.body.trim();
    throw Exception('Token failed: ${resp.statusCode}');
  }

  Future<List<int>> synthesize({required String text, String voice = 'zh-CN-XiaoxiaoMultilingualNeural', String style = 'chat'}) async {
    final ssml = _buildSsml(text, voice, style);
    final token = await _getToken();
    final resp = await _client.post(Uri.parse(_ttsUrl), headers: {
      'Content-Type': 'application/ssml+xml',
      'X-Microsoft-OutputFormat': 'audio-16khz-32kbitrate-mono-mp3',
      'Authorization': 'Bearer $token',
    }, body: ssml);
    if (resp.statusCode == 200) return resp.bodyBytes.toList();
    throw Exception('TTS failed: ${resp.statusCode}');
  }

  String _buildSsml(String text, String voice, String style) {
    final esc = text.replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;').replaceAll('"', '&quot;');
    return '<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xmlns:mstts="http://www.w3.org/2001/mstts" xml:lang="zh-CN"><voice name="$voice"><mstts:express-as style="$style">$esc</mstts:express-as></voice></speak>';
  }

  void dispose() => _client.close();
}
