// ═══════════════════════════════════════════════════
// FILE 1/6: lib/features/teacher/presentation/screens/teacher_shell.dart
// STATUS: NEW — create this file
// ═══════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

const teacherGreen = Color(0xFF166534);
const teacherLight = Color(0xFF22C55E);

class TeacherShell extends StatefulWidget {
  final Widget child;

  const TeacherShell({
    super.key,
    required this.child,
  });

  @override
  State<TeacherShell> createState() => _TeacherShellState();
}

class _TeacherShellState extends State<TeacherShell> {
  final List<Map<String, dynamic>> _tabs = const [
    {
      'icon': Icons.home_outlined,
      'iconSel': Icons.home_rounded,
      'label': 'होम',
      'labelEn': 'Home',
      'route': '/teacher',
    },
    {
      'icon': Icons.people_outline_rounded,
      'iconSel': Icons.people_rounded,
      'label': 'छात्र',
      'labelEn': 'Students',
      'route': '/teacher/students',
    },
    {
      'icon': Icons.fact_check_outlined,
      'iconSel': Icons.fact_check_rounded,
      'label': 'उपस्थिति',
      'labelEn': 'Attendance',
      'route': '/teacher/attendance',
    },
    {
      'icon': Icons.psychology_outlined,
      'iconSel': Icons.psychology_rounded,
      'label': 'AI',
      'labelEn': 'AI',
      'route': '/teacher/ai',
    },
    {
      'icon': Icons.person_outline_rounded,
      'iconSel': Icons.person_rounded,
      'label': 'प्रोफ़ाइल',
      'labelEn': 'Profile',
      'route': '/teacher/profile',
    },
  ];

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location == '/teacher/students' || location.startsWith('/teacher/students/')) {
      return 1;
    }
    if (location == '/teacher/attendance' || location.startsWith('/teacher/attendance/')) {
      return 2;
    }
    if (location == '/teacher/ai' || location.startsWith('/teacher/ai/')) {
      return 3;
    }
    if (location == '/teacher/profile' || location.startsWith('/teacher/profile/')) {
      return 4;
    }
    if (location == '/teacher' || location.startsWith('/teacher/')) {
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
                              ? teacherGreen.withOpacity(0.12)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          icon,
                          size: 22,
                          color: isSelected ? teacherGreen : AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        tab['label'] as String,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? teacherGreen : AppColors.textMuted,
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
