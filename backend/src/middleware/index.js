const rateLimit = require('express-rate-limit');
const { validationResult } = require('express-validator');
const { error, badRequest } = require('../utils/response');
const logger = require('../utils/logger');

// ── Global error handler ───────────────────────────────────────────────────
const errorHandler = (err, req, res, next) => {
  logger.error('Unhandled error', { message: err.message, stack: err.stack, url: req.url });

  if (err.code === '23505') return badRequest(res, 'Duplicate entry — this record already exists');
  if (err.code === '23503') return badRequest(res, 'Referenced record does not exist');
  if (err.name === 'ValidationError') return badRequest(res, err.message);

  return error(res, process.env.NODE_ENV === 'production' ? 'Internal server error' : err.message);
};

// ── 404 handler ───────────────────────────────────────────────────────────
const notFound = (req, res) => {
  return res.status(404).json({ success: false, message: `Route ${req.originalUrl} not found` });
};

// ── Request validation helper ─────────────────────────────────────────────
const validate = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return badRequest(res, 'Validation failed', errors.array().map(e => ({ field: e.path, message: e.msg })));
  }
  next();
};

// ── Rate limiters ─────────────────────────────────────────────────────────
const defaultLimiter = rateLimit({
  windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS) || 900000,
  max: parseInt(process.env.RATE_LIMIT_MAX) || 100,
  standardHeaders: true,
  legacyHeaders: false,
  message: { success: false, message: 'Too many requests, please try again later.' },
});

const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,  // 15 min
  max: 10,
  message: { success: false, message: 'Too many auth attempts, please wait 15 minutes.' },
});

const aiLimiter = rateLimit({
  windowMs: 60 * 1000,  // 1 min
  max: 5,
  message: { success: false, message: 'AI rate limit reached. Please wait a moment.' },
});

// ── Request logger ────────────────────────────────────────────────────────
const requestLogger = (req, res, next) => {
  const start = Date.now();
  res.on('finish', () => {
    logger.info('HTTP', {
      method: req.method,
      url: req.originalUrl,
      status: res.statusCode,
      ms: Date.now() - start,
      user: req.user?.id || 'anon',
    });
  });
  next();
};

module.exports = { errorHandler, notFound, validate, defaultLimiter, authLimiter, aiLimiter, requestLogger };
