// ═══════════════════════════════════════════════════
// FILE 1/4: lib/features/student/presentation/screens/student_shell.dart
// STATUS: NEW — create this file
// ═══════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

const studentBlue = Color(0xFF0C447C);
const studentLight = Color(0xFF1A6DB0);

class StudentShell extends StatefulWidget {
  final Widget child;

  const StudentShell({
    super.key,
    required this.child,
  });

  @override
  State<StudentShell> createState() => _StudentShellState();
}

class _StudentShellState extends State<StudentShell> {
  final List<Map<String, dynamic>> _tabs = const [
    {
      'icon': Icons.dashboard_outlined,
      'iconSel': Icons.dashboard_rounded,
      'label': 'होम',
      'labelEn': 'Home',
      'route': '/student',
    },
    {
      'icon': Icons.trending_up_outlined,
      'iconSel': Icons.trending_up_rounded,
      'label': 'प्रगति',
      'labelEn': 'Progress',
      'route': '/student/progress',
    },
    {
      'icon': Icons.psychology_outlined,
      'iconSel': Icons.psychology_rounded,
      'label': 'Study',
      'labelEn': 'Buddy',
      'route': '/student/buddy',
    },
    {
      'icon': Icons.quiz_outlined,
      'iconSel': Icons.quiz_rounded,
      'label': 'Quiz',
      'labelEn': 'Quizzes',
      'route': '/student/quiz',
    },
    {
      'icon': Icons.person_outline_rounded,
      'iconSel': Icons.person_rounded,
      'label': 'प्रोफ़ाइल',
      'labelEn': 'Profile',
      'route': '/student/profile',
    },
  ];

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location == '/student/progress' || location.startsWith('/student/progress/')) {
      return 1;
    }
    if (location == '/student/buddy' || location.startsWith('/student/buddy/')) {
      return 2;
    }
    if (location == '/student/quiz' || location.startsWith('/student/quiz/')) {
      return 3;
    }
    if (location == '/student/profile' || location.startsWith('/student/profile/')) {
      return 4;
    }
    if (location == '/student' || location.startsWith('/student/')) {
      return 0;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _calculateSelectedIndex(context);

    return Scaffold(
      body: widget.child.animate().fadeIn(delay: 100.ms).slideY(begin: 0.05),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            border: const Border(
              top: BorderSide(
                color: AppColors.border,
                width: 0.5,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_tabs.length, (i) {
              final tab = _tabs[i];
              final isSelected = currentIndex == i;
              final icon = isSelected
                  ? (tab['iconSel'] as IconData)
                  : (tab['icon'] as IconData);

              return Expanded(
                child: InkWell(
                  onTap: () {
                    context.go(tab['route'] as String);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? studentBlue.withOpacity(0.12)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          icon,
                          size: 22,
                          color: isSelected ? studentBlue : AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        tab['label'] as String,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? studentBlue : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate(
                delay: Duration(milliseconds: 100 + i * 60),
              ).fadeIn().slideY(begin: 0.2);
            }),
          ),
        ),
      ),
    );
  }
}
