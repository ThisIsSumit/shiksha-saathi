const Redis = require('ioredis');
const logger = require('../utils/logger');

let client;

const getRedisClient = () => {
  if (!client) {
    client = new Redis({
      host: process.env.REDIS_HOST || 'localhost',
      port: parseInt(process.env.REDIS_PORT) || 6379,
      password: process.env.REDIS_PASSWORD || undefined,
      retryStrategy: (times) => Math.min(times * 50, 2000),
      lazyConnect: true,
    });

    client.on('connect', () => logger.info('Redis connected'));
    client.on('error', (err) => logger.error('Redis error', err));
  }
  return client;
};

// ── Cache helpers ──────────────────────────────────────────────────────────

const set = async (key, value, ttlSeconds = 300) => {
  try {
    const redis = getRedisClient();
    await redis.set(key, JSON.stringify(value), 'EX', ttlSeconds);
  } catch (err) {
    logger.error('Cache set error', { key, err: err.message });
  }
};

const get = async (key) => {
  try {
    const redis = getRedisClient();
    const data = await redis.get(key);
    return data ? JSON.parse(data) : null;
  } catch (err) {
    logger.error('Cache get error', { key, err: err.message });
    return null;
  }
};

const del = async (...keys) => {
  try {
    const redis = getRedisClient();
    await redis.del(...keys);
  } catch (err) {
    logger.error('Cache del error', { keys, err: err.message });
  }
};

const delPattern = async (pattern) => {
  try {
    const redis = getRedisClient();
    const keys = await redis.keys(pattern);
    if (keys.length) await redis.del(...keys);
  } catch (err) {
    logger.error('Cache delPattern error', { pattern, err: err.message });
  }
};

// Cache-aside wrapper: try cache first, fallback to fn, then store
const withCache = async (key, fn, ttlSeconds = 300) => {
  const cached = await get(key);
  if (cached !== null) return cached;
  const result = await fn();
  await set(key, result, ttlSeconds);
  return result;
};

// TTL constants (seconds)
const TTL = {
  SHORT: 60,        // 1 min  — live data (attendance today)
  MEDIUM: 300,      // 5 min  — lesson plans, quizzes
  LONG: 3600,       // 1 hr   — student profiles, teacher info
  DAY: 86400,       // 24 hrs — static content, language strings
};

module.exports = { getRedisClient, set, get, del, delPattern, withCache, TTL };
