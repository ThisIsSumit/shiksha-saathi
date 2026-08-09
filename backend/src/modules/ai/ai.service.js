const { withCache, TTL } = require('../../cache/redis');
const db = require('../../config/database');
const { v4: uuidv4 } = require('uuid');
const logger = require('../../utils/logger');

const getOpenRouterConfig = () => {
  const apiKey = (
    process.env.OPENROUTER_API_KEY ||
    process.env.OPEN_ROUTER_API_KEY ||
    ''
  ).trim();

  const baseUrl = (
    process.env.OPENROUTER_BASE_URL ||
    'https://openrouter.ai/api/v1'
  ).replace(/\/$/, '');

  const model = (
    process.env.AI_MODEL ||
    'openrouter/free'
  ).trim();

  if (!apiKey) {
    throw new Error('OPENROUTER_API_KEY is not configured');
  }

  return {
    apiKey,
    chatCompletionsUrl: `${baseUrl}/chat/completions`,
    model,
  };
};

const LANG_NAMES = {
  hi: 'Hindi (हिंदी)', en: 'English', pa: 'Punjabi (ਪੰਜਾਬੀ)',
  mr: 'Marathi (मराठी)', bn: 'Bengali (বাংলা)', ta: 'Tamil (தமிழ்)',
  te: 'Telugu (తెలుగు)', kn: 'Kannada (ಕನ್ನಡ)',
};

const stripCodeFences = (value = '') => String(value || '').replace(/```(?:json|javascript|js)?/gi, '').trim();

const parseAndNormalizeJsonResponse = (raw = '') => {
  if (typeof raw !== 'string') return raw;

  const cleaned = stripCodeFences(raw);
  if (!cleaned) return {};

  const candidates = [cleaned];

  const firstBrace = cleaned.indexOf('{');
  const lastBrace = cleaned.lastIndexOf('}');
  if (firstBrace >= 0 && lastBrace > firstBrace) {
    candidates.push(cleaned.slice(firstBrace, lastBrace + 1));
  }

  const firstBracket = cleaned.indexOf('[');
  const lastBracket = cleaned.lastIndexOf(']');
  if (firstBracket >= 0 && lastBracket > firstBracket) {
    candidates.push(cleaned.slice(firstBracket, lastBracket + 1));
  }

  for (const candidate of candidates) {
    try {
      return JSON.parse(candidate);
    } catch {
      // continue trying the next candidate shape
    }
  }

  throw new Error('AI returned invalid response. Please try again.');
};

const normalizeTextResponse = (raw = '') => {
  if (typeof raw !== 'string') return '';

  let text = stripCodeFences(raw);
  if (!text) return '';

  if ((text.startsWith('"') && text.endsWith('"')) || (text.startsWith("'") && text.endsWith("'"))) {
    text = text.slice(1, -1).trim();
  }

  text = text
    .replace(/\r\n?/g, '\n')
    .replace(/[\u00a0]/g, ' ')
    .replace(/\s+/g, ' ')
    .trim();

  return text;
};

// ── Core OpenRouter call ───────────────────────────────────────────────────
const callAI = async (systemPrompt, userMessage, userId, userRole, language = 'hi') => {
  const { apiKey, chatCompletionsUrl, model } = getOpenRouterConfig();
  const start = Date.now();
  const response = await fetch(chatCompletionsUrl, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${apiKey}`,
      'Content-Type': 'application/json',
      'HTTP-Referer': process.env.FRONTEND_URL || 'https://shiksha-saathi.in',
      'X-Title': 'Shiksha Saathi',
    },
    body: JSON.stringify({
      model,
      max_tokens: 1500,
      messages: [
        { role: 'system', content: systemPrompt },
        { role: 'user', content: userMessage },
      ],
    }),
  });

  if (!response.ok) {
    const err = await response.text();
    logger.error('OpenRouter error', { status: response.status, err });
    throw new Error('AI service temporarily unavailable');
  }

  const data = await response.json();
  const content = data.choices[0]?.message?.content || '';
  const latency = Date.now() - start;
  const tokens = data.usage?.total_tokens || 0;

  // Log AI query
  if (userId) {
    db.query(
      `INSERT INTO ai_queries (id,user_id,user_role,query_text,response_text,language,tokens_used,model,latency_ms)
       VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9)`,
      [uuidv4(), userId, userRole, userMessage.slice(0, 500), content.slice(0, 1000), language, tokens, model, latency]
    ).catch(logger.error);
  }

  return content;
};

// ── Generate Lesson Plan ───────────────────────────────────────────────────
const generateLessonPlan = async ({ grade, subject, topic, duration = 45, language = 'hi' }, userId) => {
  const langName = LANG_NAMES[language] || 'Hindi';
  const cacheKey = `ai:lesson:${grade}:${subject}:${topic}:${language}`;

  return withCache(cacheKey, async () => {
    const systemPrompt = `You are an expert Indian school curriculum planner following NCF 2023 guidelines.
Always respond in ${langName}. Be practical, simple, and suitable for rural Indian government schools.
Teachers may have limited resources. Keep activities doable without electricity or internet.
Return ONLY valid JSON, no markdown, no extra text.`;

    const userMessage = `Create a detailed ${duration}-minute lesson plan for:
- Grade: ${grade}
- Subject: ${subject}
- Topic: ${topic}
- Language: ${langName}

Return this exact JSON structure:
{
  "title": "lesson title",
  "objectives": ["objective 1", "objective 2", "objective 3"],
  "materials": ["item 1", "item 2"],
  "sections": [
    {"name": "Introduction", "duration_mins": 10, "activities": ["activity 1"], "teacher_notes": "note"},
    {"name": "Main Teaching", "duration_mins": 20, "activities": ["activity 1"], "teacher_notes": "note"},
    {"name": "Practice", "duration_mins": 10, "activities": ["activity 1"], "teacher_notes": "note"},
    {"name": "Summary", "duration_mins": 5, "activities": ["activity 1"], "teacher_notes": "note"}
  ],
  "homework": "homework description",
  "assessment_questions": ["question 1", "question 2", "question 3"],
  "board_notes": "what to write on the blackboard"
}`;

    const raw = await callAI(systemPrompt, userMessage, userId, 'teacher', language);
    return parseAndNormalizeJsonResponse(raw);
  }, TTL.DAY);
};

// ── Generate Worksheet ─────────────────────────────────────────────────────
const generateWorksheet = async ({ grade, subject, topic, questionCount = 10, language = 'hi' }, userId) => {
  const langName = LANG_NAMES[language] || 'Hindi';
  const cacheKey = `ai:worksheet:${grade}:${subject}:${topic}:${questionCount}:${language}`;

  return withCache(cacheKey, async () => {
    const systemPrompt = `You are an Indian school teacher creating worksheets aligned with NCERT syllabus.
Always respond in ${langName}. Questions should be age-appropriate for Grade ${grade}.
Return ONLY valid JSON, no markdown.`;

    const userMessage = `Create a worksheet with ${questionCount} questions for:
- Grade: ${grade}, Subject: ${subject}, Topic: ${topic}

Return this exact JSON:
{
  "title": "worksheet title",
  "instructions": "instructions for students",
  "questions": [
    {"id": 1, "type": "mcq", "question": "q text", "options": ["A","B","C","D"], "answer": "A", "marks": 1},
    {"id": 2, "type": "fill_blank", "question": "The ___ is...", "answer": "answer", "marks": 1},
    {"id": 3, "type": "short_answer", "question": "q text", "answer": "model answer", "marks": 2},
    {"id": 4, "type": "true_false", "question": "statement", "answer": "True", "marks": 1}
  ],
  "total_marks": ${questionCount}
}`;

    const raw = await callAI(systemPrompt, userMessage, userId, 'teacher', language);
    return parseAndNormalizeJsonResponse(raw);
  }, TTL.DAY);
};

// ── AI Doubt Solver (Teacher / Student) ───────────────────────────────────
const solveDoubt = async ({ question, subject, grade, role = 'student', language = 'hi' }, userId) => {
  const langName = LANG_NAMES[language] || 'Hindi';

  const systemPrompt = role === 'student'
    ? `You are a friendly, encouraging tutor for a Grade ${grade} Indian school student.
       Always respond in ${langName}. Use simple words, relatable examples (food, cricket, nature).
       Be warm and supportive. Keep answers short and clear.`
    : `You are an expert curriculum advisor for Indian school teachers.
       Always respond in ${langName}. Be practical and concise.`;

  const raw = await callAI(systemPrompt, question, userId, role, language);
  return normalizeTextResponse(raw);
};

// ── Parent AI Assistant ────────────────────────────────────────────────────
const parentAssistant = async ({ question, studentId, language = 'hi' }, userId) => {
  const langName = LANG_NAMES[language] || 'Hindi';

  // Fetch student context
  let studentContext = '';
  if (studentId) {
    const { rows } = await db.query(
      `SELECT u.name, s.roll_number,
              (SELECT ROUND(AVG(qa.percentage),1) FROM quiz_attempts qa WHERE qa.student_id=s.id) as avg_score,
              (SELECT COUNT(*) FILTER (WHERE a.status='present')::numeric /
               NULLIF(COUNT(*),0) * 100 FROM attendance a WHERE a.student_id=s.id AND a.date >= NOW()-'30 days'::interval) as attendance_pct
       FROM students s JOIN users u ON u.id=s.user_id WHERE s.id=$1`, [studentId]
    );
    if (rows[0]) {
      studentContext = `\nStudent: ${rows[0].name}, Roll: ${rows[0].roll_number}, Avg Score: ${rows[0].avg_score || 'N/A'}%, 30-day Attendance: ${Math.round(rows[0].attendance_pct || 0)}%`;
    }
  }

  const systemPrompt = `You are a helpful school assistant for parents of students at an Indian government school.
Always respond in ${langName}. Be warm, simple, and helpful. Use simple language.
If asked about the child's performance, use the data provided. Never disturb the teacher for small queries.
${studentContext}`;

  const raw = await callAI(systemPrompt, question, userId, 'parent', language);
  return normalizeTextResponse(raw);
};

// ── Generate Parent SMS ────────────────────────────────────────────────────
const generateParentSms = async ({ topic, homework, grade, subject, language = 'hi' }, userId) => {
  const langName = LANG_NAMES[language] || 'Hindi';
  const systemPrompt = `Generate a short, friendly WhatsApp/SMS message for parents from a school teacher.
Write in ${langName}. Keep it under 160 characters. Be warm and informative.`;

  const userMessage = `Today in Grade ${grade} ${subject} class, we covered: ${topic}. Homework: ${homework}. Write the parent message.`;
  const raw = await callAI(systemPrompt, userMessage, userId, 'teacher', language);
  return normalizeTextResponse(raw);
};

module.exports = {
  generateLessonPlan,
  generateWorksheet,
  solveDoubt,
  parentAssistant,
  generateParentSms,
  parseAndNormalizeJsonResponse,
  normalizeTextResponse,
};
