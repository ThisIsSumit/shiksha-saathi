require('dotenv').config();

const fs = require('fs');
const path = require('path');
const logger = require('../utils/logger');
const { pool } = require('../config/database');

const schemaPath = path.join(__dirname, 'schema.sql');

const isSchemaPresent = async () => {
  const { rows } = await pool.query("SELECT to_regclass('public.users') AS users_table");
  return Boolean(rows[0]?.users_table);
};

const initializeSchema = async () => {
  const schemaExists = await isSchemaPresent();
  if (schemaExists) {
    logger.info('Database schema already present');
    return false;
  }

  logger.info('Database schema missing, creating tables from schema.sql');
  const schemaSql = fs.readFileSync(schemaPath, 'utf8');
  await pool.query(schemaSql);
  logger.info('Database schema initialized successfully');
  return true;
};

module.exports = { initializeSchema };