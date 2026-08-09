import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../bloc/auth_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/snack_helper.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtr = TextEditingController();
  final _passCtr = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _phoneCtr.dispose(); _passCtr.dispose(); super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(
      AuthLogin(phone: _phoneCtr.text.trim(), password: _passCtr.text),
    );
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
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 48),

                  // Logo + name
                  Row(children: [
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(child: Text('S', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800))),
                    ),
                    const SizedBox(width: 12),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Shiksha Saathi', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      Text('शिक्षा साथी', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    ]),
                  ]).animate().fadeIn(delay: 100.ms).slideY(begin: -0.3),

                  const SizedBox(height: 48),

                  Text('Welcome back', style: Theme.of(context).textTheme.displaySmall)
                      .animate().fadeIn(delay: 200.ms).slideX(begin: -0.2),
                  const SizedBox(height: 4),
                  Text('वापस स्वागत है', style: TextStyle(fontSize: 14, color: AppColors.textSecondary))
                      .animate().fadeIn(delay: 280.ms),

                  const SizedBox(height: 32),

                  AppTextField(
                    controller: _phoneCtr,
                    label: 'Phone Number / फ़ोन नंबर',
                    hint: '9876543210',
                    keyboardType: TextInputType.phone,
                    prefixIcon: Icons.phone_outlined,
                    validator: (v) => (v == null || v.length < 10) ? 'Enter valid phone number' : null,
                  ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.2),

                  const SizedBox(height: 16),

                  AppTextField(
                    controller: _passCtr,
                    label: 'Password / पासवर्ड',
                    hint: '••••••••',
                    obscureText: _obscure,
                    prefixIcon: Icons.lock_outline_rounded,
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                    validator: (v) => (v == null || v.length < 6) ? 'Password too short' : null,
                  ).animate().fadeIn(delay: 420.ms).slideY(begin: 0.2),

                  const SizedBox(height: 12),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => context.push('/forgot-password'),
                      child: const Text('Forgot Password? / पासवर्ड भूले?', style: TextStyle(color: AppColors.primary, fontSize: 13)),
                    ),
                  ).animate().fadeIn(delay: 480.ms),

                  const SizedBox(height: 24),

                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (_, state) => AppButton(
                      label: 'Log In / लॉग इन',
                      onPressed: _submit,
                      isLoading: state is AuthLoading,
                    ),
                  ).animate().fadeIn(delay: 540.ms).slideY(begin: 0.3),

                  const SizedBox(height: 20),

                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text("Don't have account? / ", style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    GestureDetector(
                      onTap: () => context.push('/register'),
                      child: const Text('Register', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13)),
                    ),
                  ]).animate().fadeIn(delay: 600.ms),

                  const SizedBox(height: 40),

                  // Role selector hint
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.primaryPale,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primaryMint),
                    ),
                    child: Row(children: [
                      const Icon(Icons.info_outline, color: AppColors.primary, size: 18),
                      const SizedBox(width: 10),
                      Expanded(child: Text(
                        'One app for Teachers, Students & Parents\nशिक्षक, छात्र और अभिभावक सभी के लिए',
                        style: TextStyle(fontSize: 12, color: AppColors.primary, height: 1.5),
                      )),
                    ]),
                  ).animate().fadeIn(delay: 700.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
