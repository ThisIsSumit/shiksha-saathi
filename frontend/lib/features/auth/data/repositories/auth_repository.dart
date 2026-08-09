import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import '../../data/models/auth_model.dart';
import '../../../../core/network/api_client.dart';

class AuthRepository {
  final _client = ApiClient.instance;
  final _storage = const FlutterSecureStorage();

  // ── Register ─────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> register({
    required String name,
    required String phone,
    required String password,
    required String role,
    String preferredLang = 'hi',
    String? schoolId,
  }) async {
    final res = await _client.post('/auth/register', data: {
      'name': name, 'phone': phone, 'password': password,
      'role': role, 'preferred_lang': preferredLang,
      if (schoolId != null) 'school_id': schoolId,
    });
    return res.data['data'];
  }

  // ── Verify OTP ────────────────────────────────────────────────────────────
  Future<AuthResponse> verifyOtp({required String userId, required String otp}) async {
    final res = await _client.post('/auth/verify-otp', data: {'userId': userId, 'otp': otp});
    final auth = AuthResponse.fromJson(res.data['data']);
    await _saveTokens(auth);
    return auth;
  }

  // ── Login ─────────────────────────────────────────────────────────────────
  Future<AuthResponse> login({required String phone, required String password}) async {
    final res = await _client.post('/auth/login', data: {'phone': phone, 'password': password});
    final auth = AuthResponse.fromJson(res.data['data']);
    await _saveTokens(auth);
    return auth;
  }

  // ── Forgot password ───────────────────────────────────────────────────────
  Future<Map<String, dynamic>> forgotPassword(String phone) async {
    final res = await _client.post('/auth/forgot-password', data: {'phone': phone});
    return res.data['data'];
  }

  // ── Reset password ────────────────────────────────────────────────────────
  Future<void> resetPassword({
    required String userId,
    required String otp,
    required String newPassword,
  }) async {
    await _client.post('/auth/reset-password', data: {
      'userId': userId, 'otp': otp, 'newPassword': newPassword,
    });
  }

  // ── Logout ────────────────────────────────────────────────────────────────
  Future<void> logout() async {
    try {
      final refreshToken = await _storage.read(key: 'refresh_token');
      await _client.post('/auth/logout', data: {'refreshToken': refreshToken});
    } catch (_) {}
    await _storage.deleteAll();
  }

  // ── Get profile ───────────────────────────────────────────────────────────
  Future<UserModel> getProfile() async {
    final res = await _client.get('/auth/profile');
    return UserModel.fromJson(res.data['data']);
  }

  // ── Session helpers ───────────────────────────────────────────────────────
  Future<UserModel?> getStoredUser() async {
    final raw = await _storage.read(key: 'user');
    if (raw == null) return null;
    return UserModel.fromJson(jsonDecode(raw));
  }

  Future<bool> hasValidSession() async {
    final token = await _storage.read(key: 'access_token');
    final user = await _storage.read(key: 'user');
    return token != null && user != null;
  }

  Future<void> _saveTokens(AuthResponse auth) async {
    await _storage.write(key: 'access_token', value: auth.accessToken);
    await _storage.write(key: 'refresh_token', value: auth.refreshToken);
    await _storage.write(key: 'user', value: jsonEncode(auth.user.toJson()));
  }
}
