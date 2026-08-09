import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../bloc/auth_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/snack_helper.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtr = TextEditingController();
  final _phoneCtr = TextEditingController();
  final _passCtr = TextEditingController();
  String _selectedRole = 'teacher';
  String _selectedLang = 'hi';
  bool _obscure = true;
  int _step = 0; // 0 = role, 1 = details

  static const _roles = [
    {
      'id': 'teacher',
      'label': 'Teacher',
      'labelHi': 'शिक्षक',
      'emoji': '👩‍🏫',
      'color': 0xFF1A5C38
    },
    {
      'id': 'student',
      'label': 'Student',
      'labelHi': 'छात्र',
      'emoji': '👦',
      'color': 0xFF0C447C
    },
    {
      'id': 'parent',
      'label': 'Parent',
      'labelHi': 'अभिभावक',
      'emoji': '👨‍👩‍👧',
      'color': 0xFF3C3489
    },
  ];

  static const _langs = [
    {'id': 'hi', 'label': 'हिंदी'},
    {'id': 'en', 'label': 'English'},
    {'id': 'pa', 'label': 'ਪੰਜਾਬੀ'},
    {'id': 'mr', 'label': 'मराठी'},
  ];

  void _nextStep() {
    if (_step == 0) {
      setState(() => _step = 1);
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(AuthRegister(
          name: _nameCtr.text.trim(),
          phone: _phoneCtr.text.trim(),
          password: _passCtr.text,
          role: _selectedRole,
          preferredLang: _selectedLang,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (ctx, state) {
        if (state is AuthOtpSent) {
          SnackHelper.success(ctx, state.message);
          ctx.go('/verify-otp', extra: {
            'userId': state.userId,
            'phone': state.phone,
          });
        } else if (state is AuthError) {
          SnackHelper.error(ctx, state.message);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded,
                color: AppColors.textPrimary),
            onPressed: _step == 0
                ? () => context.pop()
                : () => setState(() => _step = 0),
          ),
          title: Text(_step == 0 ? 'I am a...' : 'Create Account',
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w600)),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _step == 0 ? _buildRoleStep() : _buildDetailsStep(),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text('मैं हूँ...', style: Theme.of(context).textTheme.displaySmall)
            .animate()
            .fadeIn()
            .slideX(begin: -0.2),
        const SizedBox(height: 6),
        Text('Select your role / अपनी भूमिका चुनें',
                style: TextStyle(color: AppColors.textSecondary))
            .animate()
            .fadeIn(delay: 100.ms),
        const SizedBox(height: 32),
        ..._roles.asMap().entries.map((e) {
          final r = e.value;
          final isSelected = _selectedRole == r['id'];
          final color = Color(r['color'] as int);
          return GestureDetector(
            onTap: () => setState(() => _selectedRole = r['id'] as String),
            child: AnimatedContainer(
              duration: 250.ms,
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withValues(alpha: 0.08)
                    : AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: isSelected ? color : AppColors.border,
                    width: isSelected ? 2 : 0.5),
              ),
              child: Row(children: [
                Text(r['emoji'] as String,
                    style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 16),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(r['labelHi'] as String,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? color : AppColors.textPrimary)),
                  Text(r['label'] as String,
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                ]),
                const Spacer(),
                AnimatedContainer(
                  duration: 200.ms,
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? color : Colors.transparent,
                    border: Border.all(
                        color: isSelected ? color : AppColors.border,
                        width: 1.5),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 14)
                      : null,
                ),
              ]),
            )
                .animate(delay: Duration(milliseconds: 150 + e.key * 80))
                .fadeIn()
                .slideX(begin: 0.2),
          );
        }),
        const Spacer(),
        AppButton(label: 'Continue / आगे बढ़ें', onPressed: _nextStep)
            .animate()
            .fadeIn(delay: 400.ms)
            .slideY(begin: 0.3),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildDetailsStep() {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 8),
          Text('Your Details / आपकी जानकारी',
                  style: Theme.of(context).textTheme.headlineMedium)
              .animate()
              .fadeIn(),
          const SizedBox(height: 24),
          AppTextField(
            controller: _nameCtr,
            label: 'Full Name / पूरा नाम',
            hint: 'Ramesh Kumar',
            prefixIcon: Icons.person_outline_rounded,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Name is required' : null,
          ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2),
          const SizedBox(height: 14),
          AppTextField(
            controller: _phoneCtr,
            label: 'Phone / फ़ोन',
            hint: '9876543210',
            keyboardType: TextInputType.phone,
            prefixIcon: Icons.phone_outlined,
            validator: (v) => (v == null || v.length < 10)
                ? 'Valid phone number required'
                : null,
          ).animate().fadeIn(delay: 170.ms).slideY(begin: 0.2),
          const SizedBox(height: 14),
          AppTextField(
            controller: _passCtr,
            label: 'Password / पासवर्ड',
            hint: '••••••••',
            obscureText: _obscure,
            prefixIcon: Icons.lock_outline_rounded,
            suffixIcon: IconButton(
              icon: Icon(_obscure
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
            validator: (v) =>
                (v == null || v.length < 6) ? 'Min 6 characters' : null,
          ).animate().fadeIn(delay: 240.ms).slideY(begin: 0.2),
          const SizedBox(height: 20),
          Text('Language / भाषा',
                  style:
                      TextStyle(fontSize: 13, color: AppColors.textSecondary))
              .animate()
              .fadeIn(delay: 300.ms),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _langs.map((l) {
              final isSelected = _selectedLang == l['id'];
              return GestureDetector(
                onTap: () => setState(() => _selectedLang = l['id']!),
                child: AnimatedContainer(
                  duration: 200.ms,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color:
                        isSelected ? AppColors.primary : AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color:
                            isSelected ? AppColors.primary : AppColors.border),
                  ),
                  child: Text(l['label']!,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color:
                            isSelected ? Colors.white : AppColors.textPrimary,
                      )),
                ),
              );
            }).toList(),
          ).animate().fadeIn(delay: 340.ms),
          const SizedBox(height: 28),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (_, state) => AppButton(
              label: 'Create Account / खाता बनाएं',
              onPressed: _nextStep,
              isLoading: state is AuthLoading,
            ),
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }

  @override
  void dispose() {
    _nameCtr.dispose();
    _phoneCtr.dispose();
    _passCtr.dispose();
    super.dispose();
  }
}
