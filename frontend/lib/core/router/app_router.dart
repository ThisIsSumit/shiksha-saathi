import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shiksha_saathi/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:shiksha_saathi/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:shiksha_saathi/features/auth/presentation/screens/login_screen.dart';
import 'package:shiksha_saathi/features/auth/presentation/screens/register_screen.dart';
import 'package:shiksha_saathi/features/auth/presentation/screens/otp_screen.dart';
import 'package:shiksha_saathi/features/teacher/presentation/screens/teacher_shell.dart';
import 'package:shiksha_saathi/features/teacher/presentation/screens/teacher_dashboard_screen.dart';
import 'package:shiksha_saathi/features/teacher/presentation/screens/teacher_students_screen.dart';
import 'package:shiksha_saathi/features/teacher/presentation/screens/teacher_attendance_screen.dart';
import 'package:shiksha_saathi/features/teacher/presentation/screens/teacher_ai_screen.dart';
import 'package:shiksha_saathi/features/teacher/presentation/screens/teacher_profile_screen.dart';
import 'package:shiksha_saathi/features/teacher/presentation/screens/lesson_planner_screen.dart';
import 'package:shiksha_saathi/features/teacher/presentation/screens/worksheet_screen.dart';
import 'package:shiksha_saathi/features/teacher/presentation/screens/teacher_sms_screen.dart';

import 'package:shiksha_saathi/features/student/presentation/screens/student_shell.dart';
import 'package:shiksha_saathi/features/student/presentation/screens/student_dashboard_screen.dart';
import 'package:shiksha_saathi/features/student/presentation/screens/student_progress_screen.dart';
import 'package:shiksha_saathi/features/student/presentation/screens/student_study_buddy_screen.dart';
import 'package:shiksha_saathi/features/student/presentation/screens/student_quiz_screen.dart';
import 'package:shiksha_saathi/features/student/presentation/screens/student_profile_screen.dart';

import 'package:shiksha_saathi/features/parent/presentation/screens/parent_shell.dart';
import 'package:shiksha_saathi/features/parent/presentation/screens/parent_dashboard_screen.dart';
import 'package:shiksha_saathi/features/parent/presentation/screens/parent_child_progress_screen.dart';
import 'package:shiksha_saathi/features/parent/presentation/screens/parent_ai_screen.dart';
import 'package:shiksha_saathi/features/parent/presentation/screens/parent_notifications_screen.dart';
import 'package:shiksha_saathi/features/parent/presentation/screens/parent_profile_screen.dart';

final _rootNavKey = GlobalKey<NavigatorState>();

GoRouter createRouter(AuthBloc authBloc) {
  return GoRouter(
    navigatorKey: _rootNavKey,
    initialLocation: '/splash',
    redirect: (context, state) {
      final authState = authBloc.state;
      final isLoggedIn = authState is AuthAuthenticated;
      final isLoading = authState is AuthInitial || authState is AuthLoading;
      final loc = state.matchedLocation;

      if (isLoading) {
        return loc == '/splash' ? '/splash' : null;
      }

      if (!isLoggedIn && (loc == '/splash' || loc == '/')) {
        return '/onboarding';
      }

      if (!isLoggedIn) {
        if (loc.startsWith('/teacher') ||
            loc.startsWith('/student') ||
            loc.startsWith('/parent')) {
          return '/login';
        }
        return null;
      }

      // Redirect to role-specific home
      if (loc == '/splash' || loc == '/login' || loc == '/') {
        final role = authState.user.role;
        return '/$role';
      }
      return null;
    },
    refreshListenable: _AuthStateNotifier(authBloc),
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const _SplashScreen()),
      GoRoute(
          path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(
        path: '/verify-otp',
        builder: (_, state) {
          final extra = state.extra as Map<String, dynamic>;
          return OtpScreen(
              userId: extra['userId'],
              phone: extra['phone'],
              isPasswordReset: extra['isPasswordReset'] ?? false);
        },
      ),
      GoRoute(
          path: '/forgot-password',
          builder: (_, __) => const ForgotPasswordScreen()),
      GoRoute(
        path: '/reset-password',
        builder: (_, state) {
          final extra = state.extra as Map<String, dynamic>;
          return _ResetPasswordScreen(
              userId: extra['userId'], otp: extra['otp']);
        },
      ),

      // ── Teacher ───────────────────────────────────────────
      ShellRoute(
        builder: (_, __, child) => TeacherShell(child: child),
        routes: [
          GoRoute(
              path: '/teacher',
              builder: (_, __) => const TeacherDashboardScreen()),
          GoRoute(
              path: '/teacher/students',
              builder: (_, __) => const TeacherStudentsScreen()),
          GoRoute(
              path: '/teacher/attendance',
              builder: (_, __) => const TeacherAttendanceScreen()),
          GoRoute(
              path: '/teacher/ai',
              builder: (_, __) => const TeacherAiScreen()),
          GoRoute(
              path: '/teacher/profile',
              builder: (_, __) => const TeacherProfileScreen()),
          GoRoute(
              path: '/teacher/lessons',
              builder: (_, __) => const LessonPlannerScreen()),
          GoRoute(
              path: '/teacher/worksheets',
              builder: (_, __) => const WorksheetScreen()),
          GoRoute(
              path: '/teacher/sms',
              builder: (_, __) => const TeacherSmsScreen()),
        ],
      ),

      // ── Student ───────────────────────────────────────────
      ShellRoute(
        builder: (_, __, child) => StudentShell(child: child),
        routes: [
          GoRoute(
              path: '/student',
              builder: (_, __) => const StudentDashboardScreen()),
          GoRoute(
              path: '/student/progress',
              builder: (_, __) => const StudentProgressScreen()),
          GoRoute(
              path: '/student/study-buddy',
              builder: (_, __) => const StudentStudyBuddyScreen()),
          GoRoute(
              path: '/student/quizzes',
              builder: (_, __) => const StudentQuizScreen()),
          GoRoute(
              path: '/student/profile',
              builder: (_, __) => const StudentProfileScreen()),
        ],
      ),

      // ── Parent ────────────────────────────────────────────
      ShellRoute(
        builder: (_, __, child) => ParentShell(child: child),
        routes: [
          GoRoute(
              path: '/parent',
              builder: (_, __) => const ParentDashboardScreen()),
          GoRoute(
              path: '/parent/child',
              builder: (_, __) => const ParentChildProgressScreen()),
          GoRoute(
              path: '/parent/child-progress',
              builder: (_, __) => const ParentChildProgressScreen()),
          GoRoute(
              path: '/parent/ai',
              builder: (_, __) => const ParentAiScreen()),
          GoRoute(
              path: '/parent/notifications',
              builder: (_, __) => const ParentNotificationsScreen()),
          GoRoute(
              path: '/parent/profile',
              builder: (_, __) => const ParentProfileScreen()),
        ],
      ),
    ],
  );
}

class _AuthStateNotifier extends ChangeNotifier {
  _AuthStateNotifier(AuthBloc bloc) {
    bloc.stream.listen((_) => notifyListeners());
  }
}

class _SplashScreen extends StatefulWidget {
  const _SplashScreen();
  @override
  State<_SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<_SplashScreen> {
  Timer? _fallbackTimer;

  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(AuthCheckSession());
    _fallbackTimer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      final state = context.read<AuthBloc>().state;
      if (state is AuthInitial || state is AuthLoading) {
        context.read<AuthBloc>().add(AuthSkipCheck());
      }
    });
  }

  @override
  void dispose() {
    _fallbackTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A5C38),
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20)),
            child: const Center(
                child: Text('S',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 42,
                        fontWeight: FontWeight.w800))),
          ),
          const SizedBox(height: 20),
          const Text('Shiksha Saathi',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700)),
          const Text('शिक्षा साथी',
              style: TextStyle(color: Colors.white60, fontSize: 15)),
          const SizedBox(height: 48),
          const CircularProgressIndicator(
              color: Colors.white54, strokeWidth: 2),
        ]),
      ),
    );
  }
}

class _ResetPasswordScreen extends StatefulWidget {
  final String userId, otp;
  const _ResetPasswordScreen({required this.userId, required this.otp});
  @override
  State<_ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<_ResetPasswordScreen> {
  final _ctr = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (ctx, state) {
        if (state is AuthPasswordResetSuccess) {
          ScaffoldMessenger.of(ctx).showSnackBar(
              const SnackBar(content: Text('Password reset successful!')));
          ctx.go('/login');
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('New Password')),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('🔐', style: TextStyle(fontSize: 40)),
              const SizedBox(height: 16),
              const Text('Set New Password',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 24),
              TextFormField(
                controller: _ctr,
                obscureText: _obscure,
                validator: (v) =>
                    (v == null || v.length < 6) ? 'Min 6 characters' : null,
                decoration: InputDecoration(
                  labelText: 'New Password / नया पासवर्ड',
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    icon: Icon(_obscure
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (_, state) => ElevatedButton(
                  onPressed: state is AuthLoading
                      ? null
                      : () {
                          if (_formKey.currentState!.validate()) {
                            context.read<AuthBloc>().add(AuthResetPassword(
                                userId: widget.userId,
                                otp: widget.otp,
                                newPassword: _ctr.text));
                          }
                        },
                  child: state is AuthLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Reset Password / पासवर्ड बदलें'),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _ctr.dispose();
    super.dispose();
  }
}
