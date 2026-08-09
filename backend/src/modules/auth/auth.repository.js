const db = require('../../config/database');
const { v4: uuidv4 } = require('uuid');
const bcrypt = require('bcryptjs');
const crypto = require('crypto');

const findByPhone = async (phone) => {
  const { rows } = await db.query('SELECT * FROM users WHERE phone = $1', [phone]);
  return rows[0] || null;
};

const findById = async (id) => {
  const { rows } = await db.query('SELECT * FROM users WHERE id = $1', [id]);
  return rows[0] || null;
};

const findByEmail = async (email) => {
  const { rows } = await db.query('SELECT * FROM users WHERE email = $1', [email]);
  return rows[0] || null;
};

const createUser = async ({ name, phone, email, password, role, school_id, preferred_lang = 'hi' }) => {
  const password_hash = await bcrypt.hash(password, 12);
  const { rows } = await db.query(
    `INSERT INTO users (id, name, phone, email, password_hash, role, school_id, preferred_lang)
     VALUES ($1,$2,$3,$4,$5,$6,$7,$8) RETURNING id, name, phone, email, role, preferred_lang, created_at`,
    [uuidv4(), name, phone, email || null, password_hash, role, school_id || null, preferred_lang]
  );
  return rows[0];
};

const createRoleProfile = async (role, userId, schoolId) => {
  if (role === 'teacher') {
    await db.query(
      'INSERT INTO teachers (id, user_id, school_id) VALUES ($1,$2,$3)',
      [uuidv4(), userId, schoolId]
    );
  } else if (role === 'student') {
    await db.query(
      'INSERT INTO students (id, user_id, school_id) VALUES ($1,$2,$3)',
      [uuidv4(), userId, schoolId]
    );
  } else if (role === 'parent') {
    await db.query('INSERT INTO parents (id, user_id) VALUES ($1,$2)', [uuidv4(), userId]);
  }
};

const setOtp = async (userId, otp) => {
  const expires = new Date(Date.now() + 10 * 60 * 1000); // 10 min
  await db.query(
    'UPDATE users SET otp_code=$1, otp_expires_at=$2 WHERE id=$3',
    [otp, expires, userId]
  );
};

const verifyOtpAndActivate = async (userId, otp) => {
  const { rows } = await db.query(
    `SELECT id FROM users
     WHERE id=$1 AND otp_code=$2 AND otp_expires_at > NOW() AND is_active=true`,
    [userId, otp]
  );
  if (!rows[0]) return false;
  await db.query(
    'UPDATE users SET is_verified=true, otp_code=NULL, otp_expires_at=NULL WHERE id=$1',
    [userId]
  );
  return true;
};

const setResetToken = async (userId) => {
  const token = crypto.randomBytes(32).toString('hex');
  const expires = new Date(Date.now() + 60 * 60 * 1000); // 1 hr
  await db.query(
    'UPDATE users SET reset_token=$1, reset_token_expires=$2 WHERE id=$3',
    [token, expires, userId]
  );
  return token;
};

const resetPassword = async (token, newPassword) => {
  const password_hash = await bcrypt.hash(newPassword, 12);
  const { rows } = await db.query(
    `UPDATE users SET password_hash=$1, reset_token=NULL, reset_token_expires=NULL
     WHERE reset_token=$2 AND reset_token_expires > NOW() RETURNING id`,
    [password_hash, token]
  );
  return rows[0] || null;
};

const updateLastLogin = async (userId) => {
  await db.query('UPDATE users SET last_login_at=NOW() WHERE id=$1', [userId]);
};

const storeRefreshToken = async (userId, token) => {
  const hash = crypto.createHash('sha256').update(token).digest('hex');
  const expires = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000);
  await db.query(
    `INSERT INTO refresh_tokens (id, user_id, token_hash, expires_at)
     VALUES ($1,$2,$3,$4) ON CONFLICT DO NOTHING`,
    [uuidv4(), userId, hash, expires]
  );
};

const findRefreshToken = async (token) => {
  const hash = require('crypto').createHash('sha256').update(token).digest('hex');
  const { rows } = await db.query(
    `SELECT rt.*, u.role, u.is_active FROM refresh_tokens rt
     JOIN users u ON u.id = rt.user_id
     WHERE rt.token_hash=$1 AND rt.revoked=false AND rt.expires_at > NOW()`,
    [hash]
  );
  return rows[0] || null;
};

const revokeRefreshToken = async (token) => {
  const hash = require('crypto').createHash('sha256').update(token).digest('hex');
  await db.query('UPDATE refresh_tokens SET revoked=true WHERE token_hash=$1', [hash]);
};

module.exports = {
  findByPhone, findById, findByEmail, createUser, createRoleProfile,
  setOtp, verifyOtpAndActivate, setResetToken, resetPassword,
  updateLastLogin, storeRefreshToken, findRefreshToken, revokeRefreshToken,
};
