const bcrypt = require('bcryptjs');
const repo = require('./auth.repository');
const { generateTokenPair, generateAccessToken } = require('../../utils/jwt');
const { set, del, TTL } = require('../../cache/redis');
const logger = require('../../utils/logger');

const generateOtp = () => Math.floor(100000 + Math.random() * 900000).toString();

const logStep = (label, startedAt, extra = {}) => {
  logger.info(label, { ms: Date.now() - startedAt, ...extra });
};

// ── Register ───────────────────────────────────────────────────────────────
const register = async ({ name, phone, email, password, role, school_id, preferred_lang }) => {
  const startedAt = Date.now();
  logger.info('Auth register started', { phone, role, preferred_lang });

  const existing = await repo.findByPhone(phone);
  logStep('Auth register checked existing phone', startedAt, { found: Boolean(existing) });
  if (existing) throw Object.assign(new Error('Phone number already registered'), { statusCode: 409 });

  const user = await repo.createUser({ name, phone, email, password, role, school_id, preferred_lang });
  logStep('Auth register created user', startedAt, { userId: user.id });

  await repo.createRoleProfile(role, user.id, school_id);
  logStep('Auth register created role profile', startedAt, { role, userId: user.id });

  // Send OTP (mock — integrate Twilio in production)
  const otp = generateOtp();
  await repo.setOtp(user.id, otp);
  logStep('Auth register stored otp', startedAt, { userId: user.id });
  logger.info(`OTP for ${phone}: ${otp}`); // Remove in prod, use SMS

  return { userId: user.id, message: 'OTP sent to your phone number' };
};

// ── Verify OTP ─────────────────────────────────────────────────────────────
const verifyOtp = async (userId, otp) => {
  const verified = await repo.verifyOtpAndActivate(userId, otp);
  if (!verified) throw Object.assign(new Error('Invalid or expired OTP'), { statusCode: 400 });

  const user = await repo.findById(userId);
  const tokens = generateTokenPair({ id: user.id, role: user.role, school_id: user.school_id });
  await repo.storeRefreshToken(user.id, tokens.refreshToken);
  await repo.updateLastLogin(user.id);

  return { user: sanitizeUser(user), ...tokens };
};

// ── Login ──────────────────────────────────────────────────────────────────
const login = async ({ phone, password }) => {
  const startedAt = Date.now();
  logger.info('Auth login started', { phone });

  const user = await repo.findByPhone(phone);
  logStep('Auth login looked up user', startedAt, { found: Boolean(user) });
  if (!user) throw Object.assign(new Error('Invalid credentials'), { statusCode: 401 });
  if (!user.is_active) throw Object.assign(new Error('Account is deactivated'), { statusCode: 403 });

  const validPassword = await bcrypt.compare(password, user.password_hash);
  logStep('Auth login compared password', startedAt, { validPassword });
  if (!validPassword) throw Object.assign(new Error('Invalid credentials'), { statusCode: 401 });

  const tokens = generateTokenPair({ id: user.id, role: user.role, school_id: user.school_id });
  await repo.storeRefreshToken(user.id, tokens.refreshToken);
  await repo.updateLastLogin(user.id);

  // Cache user profile for fast lookups
  await set(`user:${user.id}`, sanitizeUser(user), TTL.LONG);

  return { user: sanitizeUser(user), ...tokens };
};

// ── Refresh Token ──────────────────────────────────────────────────────────
const refreshToken = async (token) => {
  const tokenRecord = await repo.findRefreshToken(token);
  if (!tokenRecord) throw Object.assign(new Error('Invalid or expired refresh token'), { statusCode: 401 });

  await repo.revokeRefreshToken(token); // Rotate: revoke old, issue new
  const user = await repo.findById(tokenRecord.user_id);
  const tokens = generateTokenPair({ id: user.id, role: user.role, school_id: user.school_id });
  await repo.storeRefreshToken(user.id, tokens.refreshToken);

  return tokens;
};

// ── Logout ─────────────────────────────────────────────────────────────────
const logout = async (userId, accessToken, refreshToken) => {
  // Blacklist access token
  await set(`blacklist:${accessToken}`, 1, 900); // 15 min = access token TTL
  if (refreshToken) await repo.revokeRefreshToken(refreshToken);
  await del(`user:${userId}`);
};

// ── Forgot Password ────────────────────────────────────────────────────────
const forgotPassword = async (phone) => {
  const user = await repo.findByPhone(phone);
  if (!user) throw Object.assign(new Error('No account found with this phone number'), { statusCode: 404 });

  const otp = generateOtp();
  await repo.setOtp(user.id, otp);
  logger.info(`Password reset OTP for ${phone}: ${otp}`); // Replace with SMS

  return { userId: user.id, message: 'OTP sent for password reset' };
};

// ── Reset Password ─────────────────────────────────────────────────────────
const resetPassword = async (userId, otp, newPassword) => {
  const verified = await repo.verifyOtpAndActivate(userId, otp);
  if (!verified) throw Object.assign(new Error('Invalid or expired OTP'), { statusCode: 400 });

  const passwordHash = await bcrypt.hash(newPassword, 12);
  await require('../../config/database').query(
    'UPDATE users SET password_hash=$1 WHERE id=$2', [passwordHash, userId]
  );
};

// ── Get Profile ────────────────────────────────────────────────────────────
const getProfile = async (userId) => {
  const user = await repo.findById(userId);
  if (!user) throw Object.assign(new Error('User not found'), { statusCode: 404 });
  return sanitizeUser(user);
};

const sanitizeUser = (user) => {
  const { password_hash, otp_code, otp_expires_at, reset_token, reset_token_expires, ...safe } = user;
  return safe;
};

module.exports = { register, verifyOtp, login, refreshToken, logout, forgotPassword, resetPassword, getProfile };
