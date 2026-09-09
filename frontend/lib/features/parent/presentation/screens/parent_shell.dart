// ═══════════════════════════════════════════════════
// FILE 1/6: lib/features/parent/presentation/screens/parent_shell.dart
// STATUS: NEW — create this file
// ═══════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

const parentPurple = Color(0xFF3C3489);

class ParentShell extends StatefulWidget {
  final Widget child;
  const ParentShell({super.key, required this.child});

  @override
  State<ParentShell> createState() => _ParentShellState();
}

class _ParentShellState extends State<ParentShell> {
  static const _tabRoutes = [
    '/parent',
    '/parent/child',
    '/parent/ai',
    '/parent/notifications',
    '/parent/profile',
  ];

  static const _tabs = [
    {
      'icon': Icons.home_outlined,
      'iconSel': Icons.home_rounded,
      'label': 'होम',
    },
    {
      'icon': Icons.child_care_outlined,
      'iconSel': Icons.child_care_rounded,
      'label': 'बच्चा',
    },
    {
      'icon': Icons.support_agent_rounded,
      'iconSel': Icons.support_agent_rounded,
      'label': 'AI',
    },
    {
      'icon': Icons.notifications_outlined,
      'iconSel': Icons.notifications_rounded,
      'label': 'सूचनाएं',
    },
    {
      'icon': Icons.person_outline_rounded,
      'iconSel': Icons.person_rounded,
      'label': 'प्रोफ़ाइल',
    },
  ];

  int _indexFromLocation(String location) {
    if (location.startsWith('/parent/child')) return 1;
    if (location.startsWith('/parent/ai')) return 2;
    if (location.startsWith('/parent/notifications')) return 3;
    if (location.startsWith('/parent/profile')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _indexFromLocation(GoRouterState.of(context).uri.path);

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          border: const Border(top: BorderSide(color: AppColors.border, width: 0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 60,
            child: Row(
              children: _tabs.asMap().entries.map((e) {
                final isSelected = selectedIndex == e.key;
                final t = e.value;

                return Expanded(
                  child: GestureDetector(
                    onTap: () => context.go(_tabRoutes[e.key]),
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: 200.ms,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: isSelected ? parentPurple.withOpacity(0.12) : Colors.transparent,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            isSelected ? t['iconSel'] as IconData : t['icon'] as IconData,
                            color: isSelected ? parentPurple : AppColors.textMuted,
                            size: 22,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          t['label'] as String,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: isSelected ? parentPurple : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
