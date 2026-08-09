import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/auth_model.dart';
import '../../data/repositories/auth_repository.dart';

// ── Events ────────────────────────────────────────────────────────────────
abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthCheckSession extends AuthEvent {}

class AuthRegister extends AuthEvent {
  final String name, phone, password, role, preferredLang;
  final String? schoolId;
  AuthRegister(
      {required this.name,
      required this.phone,
      required this.password,
      required this.role,
      this.preferredLang = 'hi',
      this.schoolId});
  @override
  List<Object?> get props => [phone, role];
}

class AuthVerifyOtp extends AuthEvent {
  final String userId, otp;
  AuthVerifyOtp({required this.userId, required this.otp});
  @override
  List<Object?> get props => [userId, otp];
}

class AuthLogin extends AuthEvent {
  final String phone, password;
  AuthLogin({required this.phone, required this.password});
  @override
  List<Object?> get props => [phone];
}

class AuthForgotPassword extends AuthEvent {
  final String phone;
  AuthForgotPassword(this.phone);
}

class AuthResetPassword extends AuthEvent {
  final String userId, otp, newPassword;
  AuthResetPassword(
      {required this.userId, required this.otp, required this.newPassword});
}

class AuthLogout extends AuthEvent {}

// ── States ─────────────────────────────────────────────────────────────────
abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final UserModel user;
  AuthAuthenticated(this.user);
  @override
  List<Object?> get props => [user.id];
}

class AuthUnauthenticated extends AuthState {}

class AuthOtpSent extends AuthState {
  final String userId, phone, message;
  AuthOtpSent(
      {required this.userId, required this.phone, required this.message});
  @override
  List<Object?> get props => [userId, phone, message];
}

class AuthPasswordResetOtpSent extends AuthState {
  final String userId;
  AuthPasswordResetOtpSent(this.userId);
}

class AuthPasswordResetSuccess extends AuthState {}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
  @override
  List<Object?> get props => [message];
}

// ── BLoC ───────────────────────────────────────────────────────────────────
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _repo;

  AuthBloc(this._repo) : super(AuthInitial()) {
    on<AuthCheckSession>(_onCheckSession);
    on<AuthRegister>(_onRegister);
    on<AuthVerifyOtp>(_onVerifyOtp);
    on<AuthLogin>(_onLogin);
    on<AuthForgotPassword>(_onForgotPassword);
    on<AuthResetPassword>(_onResetPassword);
    on<AuthLogout>(_onLogout);
  }

  Future<void> _onCheckSession(
      AuthCheckSession e, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final hasSession = await _repo.hasValidSession();
      if (hasSession) {
        final user = await _repo.getStoredUser();
        if (user != null) {
          emit(AuthAuthenticated(user));
          return;
        }
      }
      emit(AuthUnauthenticated());
    } catch (_) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onRegister(AuthRegister e, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final result = await _repo.register(
        name: e.name,
        phone: e.phone,
        password: e.password,
        role: e.role,
        preferredLang: e.preferredLang,
        schoolId: e.schoolId,
      );
      emit(AuthOtpSent(
        userId: result['userId'],
        phone: e.phone,
        message: result['message'] ?? 'OTP sent to your phone number',
      ));
    } catch (err) {
      emit(AuthError(_parseError(err)));
    }
  }

  Future<void> _onVerifyOtp(AuthVerifyOtp e, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final auth = await _repo.verifyOtp(userId: e.userId, otp: e.otp);
      emit(AuthAuthenticated(auth.user));
    } catch (err) {
      emit(AuthError(_parseError(err)));
    }
  }

  Future<void> _onLogin(AuthLogin e, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final auth = await _repo.login(phone: e.phone, password: e.password);
      emit(AuthAuthenticated(auth.user));
    } catch (err) {
      emit(AuthError(_parseError(err)));
    }
  }

  Future<void> _onForgotPassword(
      AuthForgotPassword e, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final result = await _repo.forgotPassword(e.phone);
      emit(AuthPasswordResetOtpSent(result['userId']));
    } catch (err) {
      emit(AuthError(_parseError(err)));
    }
  }

  Future<void> _onResetPassword(
      AuthResetPassword e, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _repo.resetPassword(
          userId: e.userId, otp: e.otp, newPassword: e.newPassword);
      emit(AuthPasswordResetSuccess());
    } catch (err) {
      emit(AuthError(_parseError(err)));
    }
  }

  Future<void> _onLogout(AuthLogout e, Emitter<AuthState> emit) async {
    await _repo.logout();
    emit(AuthUnauthenticated());
  }

  String _parseError(dynamic err) {
    if (err.toString().contains('401')) {
      return 'Invalid credentials';
    }
    if (err.toString().contains('409')) {
      return 'Phone number already registered';
    }
    if (err.toString().contains('404')) {
      return 'Account not found';
    }
    if (err.toString().contains('400')) {
      return 'Invalid OTP or expired';
    }
    if (err.toString().contains('SocketException')) {
      return 'No internet connection';
    }
    if (err.toString().contains('TimeoutException')) {
      return 'Request timed out. Please retry.';
    }
    return 'Something went wrong. Please try again.';
  }
}
