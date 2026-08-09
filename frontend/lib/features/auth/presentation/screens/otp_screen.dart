import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../bloc/auth_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/snack_helper.dart';

class OtpScreen extends StatefulWidget {
  final String userId, phone;
  final bool isPasswordReset;
  const OtpScreen({super.key, required this.userId, required this.phone, this.isPasswordReset = false});
  @override State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _controllers = List.generate(6, (_) => TextEditingController());
  final _focusNodes = List.generate(6, (_) => FocusNode());
  int _resendCountdown = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusNodes[0].requestFocus());
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendCountdown == 0) { t.cancel(); return; }
      setState(() => _resendCountdown--);
    });
  }

  String get _otp => _controllers.map((c) => c.text).join();

  void _submit() {
    if (_otp.length != 6) { SnackHelper.error(context, 'Please enter complete 6-digit OTP'); return; }
    if (widget.isPasswordReset) {
      context.push('/reset-password', extra: {'userId': widget.userId, 'otp': _otp});
      return;
    }
    context.read<AuthBloc>().add(AuthVerifyOtp(userId: widget.userId, otp: _otp));
  }

  void _onInput(String val, int i) {
    if (val.isNotEmpty && i < 5) {
      _focusNodes[i + 1].requestFocus();
    } else if (val.isEmpty && i > 0) {
      _focusNodes[i - 1].requestFocus();
    }
    if (_otp.length == 6) _submit();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (ctx, state) {
        if (state is AuthAuthenticated) {
          final route = state.user.role == 'teacher' ? '/teacher'
              : state.user.role == 'student' ? '/student' : '/parent';
          ctx.go(route);
        } else if (state is AuthError) {
          SnackHelper.error(ctx, state.message);
          for (var c in _controllers) c.clear();
          _focusNodes[0].requestFocus();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0,
          leading: IconButton(icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary), onPressed: () => context.pop())),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 24),

            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(color: AppColors.primaryPale, borderRadius: BorderRadius.circular(16)),
              child: const Center(child: Text('📱', style: TextStyle(fontSize: 30))),
            ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),

            const SizedBox(height: 24),

            Text('Verify Phone\nफ़ोन सत्यापित करें',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(height: 1.3))
                .animate().fadeIn(delay: 150.ms).slideX(begin: -0.2),
            const SizedBox(height: 8),
            Text('OTP sent to ${widget.phone}\n${widget.phone} पर OTP भेजा गया',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5))
                .animate().fadeIn(delay: 220.ms),

            const SizedBox(height: 36),

            // OTP boxes
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (i) => _OtpBox(
                controller: _controllers[i],
                focusNode: _focusNodes[i],
                onChanged: (v) => _onInput(v, i),
                index: i,
              )),
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.3),

            const SizedBox(height: 32),

            BlocBuilder<AuthBloc, AuthState>(
              builder: (_, state) => AppButton(
                label: 'Verify / सत्यापित करें',
                onPressed: _submit,
                isLoading: state is AuthLoading,
              ),
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3),

            const SizedBox(height: 24),

            Center(
              child: _resendCountdown > 0
                  ? Text('Resend in ${_resendCountdown}s / ${_resendCountdown}s में दोबारा भेजें',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 13))
                  : TextButton(
                      onPressed: () { setState(() => _resendCountdown = 60); _startTimer(); },
                      child: const Text('Resend OTP / दोबारा भेजें',
                          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                    ),
            ).animate().fadeIn(delay: 500.ms),
          ]),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _controllers) c.dispose();
    for (var f in _focusNodes) f.dispose();
    super.dispose();
  }
}

class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final void Function(String) onChanged;
  final int index;

  const _OtpBox({required this.controller, required this.focusNode, required this.onChanged, required this.index});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 46, height: 56,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.primary),
        decoration: InputDecoration(
          counterText: '',
          contentPadding: EdgeInsets.zero,
          filled: true,
          fillColor: AppColors.surfaceCard,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
        onChanged: onChanged,
      ),
    ).animate(delay: Duration(milliseconds: 300 + index * 50)).fadeIn().scale(begin: const Offset(0.8, 0.8));
  }
}

// ═══════════════════════════════════════════════════════════
// FORGOT PASSWORD SCREEN
// ═══════════════════════════════════════════════════════════
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _phoneCtr = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (ctx, state) {
        if (state is AuthPasswordResetOtpSent) {
          ctx.push('/verify-otp', extra: {'userId': state.userId, 'phone': _phoneCtr.text.trim(), 'isPasswordReset': true});
        } else if (state is AuthError) {
          SnackHelper.error(ctx, state.message);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0,
          leading: IconButton(icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary), onPressed: () => context.pop())),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 24),
              const Text('🔑', style: TextStyle(fontSize: 48)).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
              const SizedBox(height: 24),
              Text('Reset Password\nपासवर्ड रीसेट करें', style: Theme.of(context).textTheme.displaySmall?.copyWith(height: 1.3))
                  .animate().fadeIn(delay: 150.ms),
              const SizedBox(height: 8),
              Text('Enter your phone number to receive OTP\nOTP पाने के लिए फ़ोन नंबर दर्ज करें',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.5))
                  .animate().fadeIn(delay: 220.ms),
              const SizedBox(height: 32),
              TextFormField(
                controller: _phoneCtr,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone / फ़ोन',
                  hintText: '9876543210',
                  prefixIcon: Icon(Icons.phone_outlined, color: AppColors.textMuted),
                ),
                validator: (v) => (v == null || v.length < 10) ? 'Valid phone number required' : null,
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
              const SizedBox(height: 28),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (_, state) => AppButton(
                  label: 'Send OTP / OTP भेजें',
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      context.read<AuthBloc>().add(AuthForgotPassword(_phoneCtr.text.trim()));
                    }
                  },
                  isLoading: state is AuthLoading,
                ),
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3),
            ]),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() { _phoneCtr.dispose(); super.dispose(); }
}
