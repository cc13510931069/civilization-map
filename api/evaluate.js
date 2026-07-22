/**
 * Veggie AI 文明探索导师 — DeepSeek 代理 API
 *
 * POST /api/evaluate
 * Body: { type, step?, question?, answer?, answers?, evidence? }
 *
 * 环境变量：DEEPSEEK_API_KEY
 */

const DEEPSEEK_API = 'https://api.deepseek.com/v1/chat/completions';

// ── Veggie 系统人格提示 ──
const SYSTEM_PROMPT = `你是 Veggie（菜狗），一个初中生的文明探索导师。你不是答案机器人。

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
- 不要直接给答案，不要替学生做五步思考
- 保持在 3-5 句话以内，简洁有力
- 每个反馈都要让学生有"我还能再想想"的感觉`;

// ── JSON 响应辅助 ──
function jsonResponse(data, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: { 'Content-Type': 'application/json' },
  });
}

// ── 单步辅导（Step Coaching）──
async function handleStepCoaching({ step, question, answer, evidence }) {
  const evidenceText = evidence?.length
    ? `\n学生已收集的证据：${evidence.map(e => `[${e.type}] ${e.text}`).join('\n')}`
    : '\n学生还没有收集证据。';

  const userPrompt = `学生正在完成五步思考的第 ${step} 步。
问题：${question}
学生的回答：${answer}${evidenceText}

请以 Veggie 的身份给出反馈。`;

  const response = await fetch(DEEPSEEK_API, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${process.env.DEEPSEEK_API_KEY}`,
    },
    body: JSON.stringify({
      model: 'deepseek-chat',
      messages: [
        { role: 'system', content: SYSTEM_PROMPT },
        { role: 'user', content: userPrompt },
      ],
      max_tokens: 500,
      temperature: 0.8,
    }),
  });

  if (!response.ok) {
    const err = await response.text();
    throw new Error(`DeepSeek API error: ${response.status} ${err}`);
  }

  const data = await response.json();
  const feedbackText = data.choices?.[0]?.message?.content || 'Veggie 正在思考…';

  return { feedbackText };
}

// ── 最终评价（Final Evaluation）──
async function handleFinalEvaluation({ answers, evidence }) {
  const answersText = Object.entries(answers)
    .sort(([a], [b]) => a - b)
    .map(([step, text]) => `步骤 ${step}: ${text}`)
    .join('\n');

  const evidenceText = evidence?.length
    ? `\n学生收集的证据：${evidence.map(e => `[${e.type}] ${e.text}`).join('\n')}`
    : '学生没有收集证据。';

  const userPrompt = `学生完成了五步文明思考，提交了最终解释。
五步内容：
${answersText}${evidenceText}

请以 Veggie 的身份给出最终评价，格式如下：
{
  "feedback": "最终反馈（3-5句，先肯定整体思考，再指出可以深化的方向，最后鼓励继续探索）",
  "scores": {
    "location": 0-25,
    "evidence": 0-25,
    "causality": 0-30,
    "explanation": 0-20
  }
}

评分依据：
- locationScore (0-25): 空间认知的准确性
- evidenceScore (0-25): 证据运用的恰当性
- causalityScore (0-30): 因果逻辑的合理性
- explanationScore (0-20): 个人解释的独特性

请确保返回纯 JSON，不要包含其他文字。`;

  const response = await fetch(DEEPSEEK_API, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${process.env.DEEPSEEK_API_KEY}`,
    },
    body: JSON.stringify({
      model: 'deepseek-chat',
      messages: [
        { role: 'system', content: SYSTEM_PROMPT },
        { role: 'user', content: userPrompt },
      ],
      max_tokens: 800,
      temperature: 0.7,
      response_format: { type: 'json_object' },
    }),
  });

  if (!response.ok) {
    const err = await response.text();
    throw new Error(`DeepSeek API error: ${response.status} ${err}`);
  }

  const data = await response.json();
  const content = data.choices?.[0]?.message?.content || '{}';

  let result;
  try {
    result = JSON.parse(content);
  } catch {
    // 如果解析失败，返回默认值
    result = {
      feedback: 'Veggie 正在思考…',
      scores: { location: 10, evidence: 10, causality: 10, explanation: 10 },
    };
  }

  return {
    initialFeedbackText: result.feedback,
    evaluation: {
      locationScore: result.scores?.location ?? 10,
      evidenceScore: result.scores?.evidence ?? 10,
      causalityScore: result.scores?.causality ?? 10,
      explanationScore: result.scores?.explanation ?? 10,
      totalScore: (result.scores?.location ?? 10) +
                  (result.scores?.evidence ?? 10) +
                  (result.scores?.causality ?? 10) +
                  (result.scores?.explanation ?? 10),
      locationLevel: scoreToLevel(result.scores?.location ?? 10, 25),
      evidenceLevel: scoreToLevel(result.scores?.evidence ?? 10, 25),
      causalityLevel: scoreToLevel(result.scores?.causality ?? 10, 30),
      explanationLevel: scoreToLevel(result.scores?.explanation ?? 10, 20),
    },
  };
}

function scoreToLevel(score, max) {
  const pct = score / max;
  if (pct >= 0.8) return '优秀';
  if (pct >= 0.6) return '良好';
  if (pct >= 0.4) return '继续加油';
  return '初探';
}

// ── 路由入口 ──
export default async function handler(request) {
  // CORS 头（允许跨域调用）
  const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'POST, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type',
  };

  if (request.method === 'OPTIONS') {
    return new Response(null, { status: 204, headers: corsHeaders });
  }

  if (request.method !== 'POST') {
    return jsonResponse({ error: 'Method not allowed' }, 405);
  }

  if (!process.env.DEEPSEEK_API_KEY) {
    return jsonResponse({
      error: 'DEEPSEEK_API_KEY 未设置',
      hint: '请在 Vercel 项目设置中配置 DEEPSEEK_API_KEY 环境变量',
    }, 500);
  }

  try {
    const body = await request.json();
    const { type } = body;

    let result;
    switch (type) {
      case 'step-coaching':
        result = await handleStepCoaching(body);
        break;
      case 'final-evaluation':
        result = await handleFinalEvaluation(body);
        break;
      default:
        return jsonResponse({ error: `Unknown type: ${type}` }, 400);
    }

    return jsonResponse({ ...result, _headers: corsHeaders });
  } catch (error) {
    return jsonResponse({ error: error.message }, 500);
  }
}
