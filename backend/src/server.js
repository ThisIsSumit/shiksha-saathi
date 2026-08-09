const app = require('./app');
const logger = require('./utils/logger');
const { pool } = require('./config/database');
const { getRedisClient } = require('./cache/redis');
const { initializeSchema } = require('./database/init');
const fs = require('fs');
const path = require('path');

// Create logs dir
fs.mkdirSync(path.join(__dirname, '../logs'), { recursive: true });

const PORT = process.env.PORT || 5000;

const start = async () => {
  try {
    logger.info('Starting backend bootstrap', {
      nodeEnv: process.env.NODE_ENV,
      port: PORT,
      dbHost: process.env.DB_HOST || 'localhost',
      dbPort: process.env.DB_PORT || 5432,
      redisHost: process.env.REDIS_HOST || 'localhost',
      redisPort: process.env.REDIS_PORT || 6379,
    });

    // Test DB connection
    logger.info('Checking PostgreSQL connection');
    await pool.query('SELECT 1');
    logger.info('PostgreSQL connected');

    if (process.env.NODE_ENV !== 'production') {
      logger.info('Checking local database schema');
      await initializeSchema();
    }

    // Connect Redis when available, but do not block API startup if it is down.
    try {
      logger.info('Checking Redis connection');
      await getRedisClient().connect();
      logger.info('Redis connected');
    } catch (redisErr) {
      logger.warn('Redis unavailable, continuing without cache/session support', {
        message: redisErr.message,
        code: redisErr.code,
      });
    }

    app.listen(PORT, () => {
      logger.info(`Shiksha Saathi API running on port ${PORT} in ${process.env.NODE_ENV} mode`);
      logger.info(`Health: http://localhost:${PORT}/health`);
    });
  } catch (err) {
    logger.error('Failed to start server', {
      message: err.message,
      code: err.code,
      name: err.name,
      stack: err.stack,
    });
    process.exit(1);
  }
};

process.on('unhandledRejection', (err) => { logger.error('Unhandled rejection', err); process.exit(1); });
process.on('SIGTERM', async () => { await pool.end(); process.exit(0); });

start();
