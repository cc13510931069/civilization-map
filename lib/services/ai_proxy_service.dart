/// Veggie AI 代理服务
///
/// 通过 Vercel Edge Function 调用 DeepSeek API，
/// 为 Veggie 提供真实的文明探索辅导和评价。
///
/// 使用方式（在 provider 中）：
/// ```dart
/// final aiProxy = ref.read(aiProxyServiceProvider);
/// final result = await aiProxy.stepCoaching(request);
/// ```
library;

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/ai_feedback.dart';
import '../models/mission_evaluation.dart';

// ── 配置 ──────────────────────────────────────────────────────

/// AI 代理服务配置
class AiProxyConfig {
  /// Vercel Edge Function 的部署 URL。
  /// 部署后可通过 --dart-define=VEGGIE_API_URL=https://your-app.vercel.app 覆盖。
  static const String _defaultBaseUrl = 'http://localhost:3000';

  static bool get isConfigured {
    const fromDefine = String.fromEnvironment(
      'VEGGIE_API_URL',
      defaultValue: '',
    );
    return fromDefine.isNotEmpty;
  }

  static String get baseUrl {
    const fromDefine = String.fromEnvironment(
      'VEGGIE_API_URL',
      defaultValue: _defaultBaseUrl,
    );
    return fromDefine;
  }
}

// ── 请求 / 响应模型 ──────────────────────────────────────────

class StepCoachingRequest {
  final int step;
  final String question;
  final String answer;
  final List<Map<String, String>> evidence;

  const StepCoachingRequest({
    required this.step,
    required this.question,
    required this.answer,
    this.evidence = const [],
  });

  Map<String, dynamic> toJson() => {
    'type': 'step-coaching',
    'step': step,
    'question': question,
    'answer': answer,
    'evidence': evidence,
  };
}

class StepCoachingResponse {
  final String feedbackText;
  final String? hint;
  final int? hintLevel;

  const StepCoachingResponse({
    required this.feedbackText,
    this.hint,
    this.hintLevel,
  });

  factory StepCoachingResponse.fromJson(Map<String, dynamic> json) {
    return StepCoachingResponse(
      feedbackText: json['feedbackText'] as String? ?? '',
      hint: json['hint'] as String?,
      hintLevel: json['hintLevel'] as int?,
    );
  }
}

class FinalEvaluationRequest {
  final Map<int, String> answers;
  final List<Map<String, String>> evidence;

  const FinalEvaluationRequest({
    required this.answers,
    this.evidence = const [],
  });

  Map<String, dynamic> toJson() {
    final answersMap = <String, String>{};
    for (final entry in answers.entries) {
      answersMap[entry.key.toString()] = entry.value;
    }
    return {
      'type': 'final-evaluation',
      'answers': answersMap,
      'evidence': evidence,
    };
  }
}

class FinalEvaluationResponse {
  final String initialFeedbackText;
  final FinalMissionEvaluation? evaluation;

  const FinalEvaluationResponse({
    required this.initialFeedbackText,
    this.evaluation,
  });

  factory FinalEvaluationResponse.fromJson(Map<String, dynamic> json) {
    final evalData = json['evaluation'] as Map<String, dynamic>?;
    return FinalEvaluationResponse(
      initialFeedbackText: json['initialFeedbackText'] as String? ?? '',
      evaluation: evalData != null
          ? FinalMissionEvaluation(
              locationScore: evalData['locationScore'] as int? ?? 0,
              evidenceScore: evalData['evidenceScore'] as int? ?? 0,
              causalityScore: evalData['causalityScore'] as int? ?? 0,
              explanationScore: evalData['explanationScore'] as int? ?? 0,
              totalScore: evalData['totalScore'] as int? ?? 0,
            )
          : null,
    );
  }
}

// ── 异常 ──────────────────────────────────────────────────────

class AiProxyException implements Exception {
  final String message;
  final int? statusCode;
  const AiProxyException(this.message, {this.statusCode});

  @override
  String toString() => 'AiProxyException($statusCode): $message';
}

// ── 核心服务 ──────────────────────────────────────────────────

/// Veggie AI 代理服务。
///
/// 通过 Vercel Edge Function 调用 DeepSeek API。
/// 当 API 不可用时，抛出 [AiProxyException] 供调用方降级。
class AiProxyService {
  final http.Client _client;
  final String _apiUrl;

  AiProxyService({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _apiUrl = '${baseUrl ?? AiProxyConfig.baseUrl}/api/evaluate';

  /// 调用单步辅导
  Future<StepCoachingResponse> stepCoaching(
      StepCoachingRequest request) async {
    final data = await _post(request.toJson());
    return StepCoachingResponse.fromJson(data);
  }

  /// 调用最终评价
  Future<FinalEvaluationResponse> finalEvaluation(
      FinalEvaluationRequest request) async {
    final data = await _post(request.toJson());
    return FinalEvaluationResponse.fromJson(data);
  }

  /// 发送 HTTP POST 请求
  Future<Map<String, dynamic>> _post(Map<String, dynamic> body) async {
    // 在非 Web 环境下且 URL 是默认值时，直接抛出异常（未部署）
    if (!kIsWeb && _apiUrl.contains('localhost:3000')) {
      throw AiProxyException(
        'AI 服务未部署。请先部署 Vercel 函数并设置 VEGGIE_API_URL。',
        statusCode: 0,
      );
    }

    final response = await _client.post(
      Uri.parse(_apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    throw AiProxyException(
      'API 返回错误: ${response.statusCode}',
      statusCode: response.statusCode,
    );
  }

  void dispose() => _client.close();
}
