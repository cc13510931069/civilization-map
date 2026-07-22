/// Veggie AI 服务 — 直接调用 DeepSeek API
///
/// 通过 --dart-define=DEEPSEEK_API_KEY=sk-... 传入 API Key。
/// 未配置时自动降级到本地模拟数据。
library;

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

// ── 配置 ──────────────────────────────────────────────────────

class DeepSeekConfig {
  /// 从 --dart-define 读取 API Key
  static String? get apiKey {
    const key = String.fromEnvironment('DEEPSEEK_API_KEY', defaultValue: '');
    return key.isNotEmpty ? key : null;
  }

  /// AI 服务是否已配置
  static bool get isConfigured => apiKey != null;
}

// ── DeepSeek API 调用 ─────────────────────────────────────────

class DeepSeekService {
  final http.Client _client;
  static const String _apiUrl = 'https://api.deepseek.com/v1/chat/completions';

  DeepSeekService({http.Client? client}) : _client = client ?? http.Client();

  /// 直接调用 DeepSeek API
  Future<Map<String, dynamic>> chat({
    required List<Map<String, String>> messages,
    int maxTokens = 500,
    double temperature = 0.8,
  }) async {
    final apiKey = DeepSeekConfig.apiKey;
    if (apiKey == null) {
      throw DeepSeekException('API Key 未配置，请设置 --dart-define=DEEPSEEK_API_KEY');
    }

    final response = await _client.post(
      Uri.parse(_apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': 'deepseek-chat',
        'messages': messages,
        'max_tokens': maxTokens,
        'temperature': temperature,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final choice = (data['choices'] as List?)?.firstOrNull;
      final content = choice?['message']?['content'] as String?;
      if (content != null) return {'text': content};
      throw DeepSeekException('DeepSeek 返回空结果');
    }

    throw DeepSeekException(
      'DeepSeek API 错误: ${response.statusCode} ${response.body}',
    );
  }

  void dispose() => _client.close();
}

class DeepSeekException implements Exception {
  final String message;
  const DeepSeekException(this.message);
  @override
  String toString() => 'DeepSeekException: $message';
}

// ── Veggie 提示词 ─────────────────────────────────────────────

class VeggiePrompts {
  static const String system = '''你是 Veggie（菜狗），一个初中生的文明探索导师。你不是答案机器人。

你的核心任务：引导学生通过五步文明思考框架自己得出结论，而不是直接告诉他们答案。

五步思考框架：
1. 在哪里？— 空间位置
2. 有什么条件？— 自然环境、资源、交通
3. 谁在那里活动？— 民族、国家、文明
4. 发生了什么变化？— 交流、冲突、迁徙、融合
5. 我的解释是什么？— 形成个人文明观点

行为准则：
- 先肯定学生的回答，指出亮点
- 然后提出 1-2 个引导性问题，帮学生深入观察
- 引用学生收集的证据来建立联系
- 鼓励学生把不同证据联系起来形成自己的解释
- 用口语化的中文，像朋友一样聊天
- 不要直接给答案
- 保持在 3-5 句话以内，简洁有力''';

  static String stepCoachingPrompt({
    required int step,
    required String question,
    required String answer,
    required List<Map<String, String>> evidence,
  }) {
    final evidenceText = evidence.isNotEmpty
        ? '\n学生已收集的证据：${evidence.map((e) => '[${e['type']}] ${e['text']}').join('\n')}'
        : '\n学生还没有收集证据。';
    return '学生正在完成五步思考的第 $step 步。\n问题：$question\n学生的回答：$answer$evidenceText\n\n请以 Veggie 的身份给出反馈。';
  }

  static String finalEvaluationPrompt({
    required Map<int, String> answers,
    required List<Map<String, String>> evidence,
  }) {
    final answersText = answers.entries
        .map((e) => '步骤 ${e.key}: ${e.value}')
        .join('\n');
    final evidenceText = evidence.isNotEmpty
        ? '\n学生收集的证据：${evidence.map((e) => '[${e['type']}] ${e['text']}').join('\n')}'
        : '\n学生没有收集证据。';
    return '''学生完成了五步文明思考，提交了最终解释。

五步内容：
$answersText$evidenceText

请以 Veggie 的身份给出最终评价。
先肯定整体思考，再指出可以深化的方向，最后鼓励继续探索。
保持在 4-6 句话以内。

最后请给出四项能力的分数（满分分别为：位置与知识 25分，证据使用 25分，因果与逻辑 30分，个人解释 20分）。
格式如下：
【分数】
位置与知识：XX/25
证据使用：XX/25
因果与逻辑：XX/30
个人解释：XX/20''';
  }
}

// ── 保留 Vercel 配置接口（未来可选） ───────────────────────────

class AiProxyConfig {
  static bool get isConfigured => DeepSeekConfig.isConfigured;
  static String? get directApiKey => DeepSeekConfig.apiKey;
}
