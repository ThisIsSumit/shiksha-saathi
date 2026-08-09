const { verifyAccessToken } = require('../utils/jwt');
const { unauthorized, forbidden } = require('../utils/response');
const { get } = require('../cache/redis');
const logger = require('../utils/logger');

// ── Verify JWT access token ────────────────────────────────────────────────
const authenticate = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader?.startsWith('Bearer ')) return unauthorized(res, 'No token provided');

    const token = authHeader.split(' ')[1];

    // Check if token is blacklisted (logout)
    const isBlacklisted = await get(`blacklist:${token}`);
    if (isBlacklisted) return unauthorized(res, 'Token has been revoked');

    const payload = verifyAccessToken(token);
    req.user = payload;
    next();
  } catch (error) {
    if (error.name === 'TokenExpiredError') return unauthorized(res, 'Token expired');
    if (error.name === 'JsonWebTokenError') return unauthorized(res, 'Invalid token');
    logger.error('Auth middleware error', error);
    return unauthorized(res);
  }
};

// ── Role-based access control ──────────────────────────────────────────────
const authorize = (...roles) => (req, res, next) => {
  if (!req.user) return unauthorized(res);
  if (!roles.includes(req.user.role)) return forbidden(res, `Access denied for role: ${req.user.role}`);
  next();
};

// ── Optional auth (doesn't fail if no token) ──────────────────────────────
const optionalAuth = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    if (authHeader?.startsWith('Bearer ')) {
      const token = authHeader.split(' ')[1];
      req.user = verifyAccessToken(token);
    }
  } catch (_) { /* ignore */ }
  next();
};

// ── Verify user owns the resource ─────────────────────────────────────────
const isSelf = (paramKey = 'userId') => (req, res, next) => {
  if (req.user.id !== req.params[paramKey] && req.user.role !== 'admin')
    return forbidden(res, 'You can only access your own data');
  next();
};

module.exports = { authenticate, authorize, optionalAuth, isSelf };
