require('dotenv').config();
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const logger = require('./utils/logger');
const { errorHandler, notFound, defaultLimiter, requestLogger } = require('./middleware');

// ── Routes ────────────────────────────────────────────────────────────────
const authRoutes     = require('./modules/auth/auth.routes');
const teacherRoutes  = require('./modules/teacher/teacher.routes');
const studentRoutes  = require('./modules/student/student.routes');
const parentRoutes   = require('./modules/parent/parent.routes');
const aiRoutes       = require('./modules/ai/ai.routes');

const app = express();

const allowedOrigins = (process.env.FRONTEND_URLS || process.env.FRONTEND_URL || '')
  .split(',')
  .map((origin) => origin.trim())
  .filter(Boolean);

const isLocalDevOrigin = (origin) => {
  if (!origin) return true;
  return /^https?:\/\/(localhost|127\.0\.0\.1)(:\d+)?$/.test(origin);
};

const corsOrigin = (origin, callback) => {
  if (process.env.NODE_ENV !== 'production') {
    return callback(null, true);
  }

  if (!origin) return callback(null, true);

  if (allowedOrigins.includes(origin) || isLocalDevOrigin(origin)) {
    return callback(null, true);
  }

  return callback(new Error(`CORS blocked for origin: ${origin}`));
};

const corsOptions = {
  origin: corsOrigin,
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  credentials: true,
};

// ── Security & parsing ─────────────────────────────────────────────────────
app.use(helmet());
app.use(cors(corsOptions));
app.options(/.*/, cors(corsOptions));
app.use(express.json({ limit: '5mb' }));
app.use(express.urlencoded({ extended: true }));
app.use(defaultLimiter);
app.use(requestLogger);

// ── Health check ───────────────────────────────────────────────────────────
app.get('/health', (req, res) => res.json({
  status: 'ok', service: 'Shiksha Saathi API',
  version: '1.0.0', timestamp: new Date().toISOString(),
}));

// ── API Routes ─────────────────────────────────────────────────────────────
const v1 = express.Router();
v1.use('/auth',    authRoutes);
v1.use('/teacher', teacherRoutes);
v1.use('/student', studentRoutes);
v1.use('/parent',  parentRoutes);
v1.use('/ai',      aiRoutes);
app.use('/api/v1', v1);

// ── Error handling ─────────────────────────────────────────────────────────
app.use(notFound);
app.use(errorHandler);

module.exports = app;
