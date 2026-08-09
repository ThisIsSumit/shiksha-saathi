const service = require('./auth.service');
const { success, created, error, badRequest } = require('../../utils/response');
const logger = require('../../utils/logger');

const normalizeAuthPayload = (body) => ({
  ...body,
  name: body.name != null ? String(body.name).trim() : body.name,
  phone: body.phone != null ? String(body.phone).trim() : body.phone,
  email: body.email != null ? String(body.email).trim() : body.email,
  password: body.password != null ? String(body.password) : body.password,
  newPassword: body.newPassword != null ? String(body.newPassword) : body.newPassword,
  preferred_lang: body.preferred_lang != null ? String(body.preferred_lang).trim() : body.preferred_lang,
});

const wrap = (fn) => async (req, res, next) => {
  try { await fn(req, res, next); }
  catch (err) {
    if (err.statusCode) return res.status(err.statusCode).json({ success: false, message: err.message });
    next(err);
  }
};

const register = wrap(async (req, res) => {
  const payload = normalizeAuthPayload(req.body);
  const result = await service.register(payload);
  created(res, result, 'Registration successful. Please verify your phone number.');
});

const verifyOtp = wrap(async (req, res) => {
  const result = await service.verifyOtp(req.body.userId, req.body.otp);
  success(res, result, 'Phone verified. Welcome to Shiksha Saathi!');
});

const login = wrap(async (req, res) => {
  const payload = normalizeAuthPayload(req.body);
  const result = await service.login(payload);
  success(res, result, 'Login successful');
});

const refreshToken = wrap(async (req, res) => {
  const result = await service.refreshToken(req.body.refreshToken);
  success(res, result, 'Tokens refreshed');
});

const logout = wrap(async (req, res) => {
  const accessToken = req.headers.authorization?.split(' ')[1];
  await service.logout(req.user.id, accessToken, req.body.refreshToken);
  success(res, {}, 'Logged out successfully');
});

const forgotPassword = wrap(async (req, res) => {
  const result = await service.forgotPassword(String(req.body.phone).trim());
  success(res, result, 'OTP sent for password reset');
});

const resetPassword = wrap(async (req, res) => {
  const newPassword = req.body.newPassword || req.body.password;
  await service.resetPassword(req.body.userId, req.body.otp, newPassword);
  success(res, {}, 'Password reset successful');
});

const getProfile = wrap(async (req, res) => {
  const profile = await service.getProfile(req.user.id);
  success(res, profile);
});

module.exports = { register, verifyOtp, login, refreshToken, logout, forgotPassword, resetPassword, getProfile };
