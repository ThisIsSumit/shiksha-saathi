// ═══════════════════════════════════════════════════
// FILE 2/6: lib/features/parent/presentation/screens/parent_dashboard_screen.dart
// STATUS: NEW — create this file
// ═══════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

const parentPurple = Color(0xFF3C3489);
const parentLight = Color(0xFF5B52C9);

class ParentDashboardScreen extends StatelessWidget {
  const ParentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.read<AuthBloc>().state;
    final user = state is AuthAuthenticated ? state.user : null;
    final userName = user?.name ?? 'अभिभावक';

    // Mock recent notifications (TODO: replace with API)
    final recentNotifications = [
      {
        'title': 'Rahul आज उपस्थित है',
        'time': '2 घंटे पहले',
        'emoji': '✅',
        'type': 'attendance',
      },
      {
        'title': 'गणित का गृहकार्य बाकी है',
        'time': '3 घंटे पहले',
        'emoji': '📚',
        'type': 'homework',
      },
      {
        'title': 'कल हिंदी Quiz होगा',
        'time': 'कल',
        'emoji': '📝',
        'type': 'exam',
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.surface,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/parent/ai'),
        backgroundColor: parentPurple,
        icon: const Icon(Icons.support_agent_rounded, color: Colors.white),
        label: const Text(
          'AI से पूछें',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3),
      body: CustomScrollView(
        slivers: [
          // Header SliverAppBar
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            backgroundColor: parentPurple,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [parentPurple, parentLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 48, 20, 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      child: Text(
                        userName.isNotEmpty ? userName[0].toUpperCase() : 'P',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'नमस्ते, $userName जी',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'अभिभावक · Parent',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                      onPressed: () => context.push('/parent/notifications'),
                      tooltip: 'Notifications / सूचनाएं',
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Main Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Child card (TODO: replace with API)
                  GestureDetector(
                    onTap: () => context.push('/parent/child'),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [parentPurple, parentLight],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: parentPurple.withOpacity(0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: Text('👦', style: TextStyle(fontSize: 22)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Rahul Kumar',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Class 4-A · Roll 03',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 16),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Divider(color: Colors.white24, height: 1),
                          const SizedBox(height: 12),
                          const Row(
                            children: [
                              _MiniStat(
                                label: 'Attendance',
                                labelHi: 'उपस्थिति',
                                value: '87%',
                              ),
                              _MiniStat(
                                label: 'Avg Score',
                                labelHi: 'औसत अंक',
                                value: '74%',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2),

                  const SizedBox(height: 24),

                  // Today summary
                  const SectionHeader(
                    title: 'आज की जानकारी',
                    subtitle: 'Today Summary',
                  ).animate().fadeIn(delay: 150.ms),

                  const SizedBox(height: 10),

                  AppCard(
                    child: Column(
                      children: const [
                        _InfoRow(
                          label: 'आज उपस्थित है',
                          value: '✓',
                          isSuccess: true,
                        ),
                        Divider(height: 16),
                        _InfoRow(
                          label: 'गृहकार्य बाकी',
                          value: '2 बाकी',
                        ),
                        Divider(height: 16),
                        _InfoRow(
                          label: 'हिंदी में सुधार',
                          value: '+8%',
                          valueColor: AppColors.success,
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),

                  const SizedBox(height: 24),

                  // Quick actions 2x2 grid
                  const SectionHeader(
                    title: 'त्वरित कार्य',
                    subtitle: 'Quick Actions',
                  ).animate().fadeIn(delay: 250.ms),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: _QuickAction(
                          emoji: '📊',
                          titleHi: 'प्रगति देखें',
                          titleEn: 'View Progress',
                          color: parentPurple,
                          onTap: () => context.push('/parent/child'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _QuickAction(
                          emoji: '🤖',
                          titleHi: 'AI से पूछें',
                          titleEn: 'Ask AI',
                          color: AppColors.primary,
                          onTap: () => context.push('/parent/ai'),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _QuickAction(
                          emoji: '🔔',
                          titleHi: 'सूचनाएं',
                          titleEn: 'Notifications',
                          color: AppColors.saffron,
                          onTap: () => context.push('/parent/notifications'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _QuickAction(
                          emoji: '📅',
                          titleHi: 'उपस्थिति',
                          titleEn: 'Attendance',
                          color: AppColors.success,
                          onTap: () => context.push('/parent/child'),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.2),

                  const SizedBox(height: 24),

                  // Recent notifications
                  SectionHeader(
                    title: 'हाल की सूचनाएं',
                    subtitle: 'Recent Notifications',
                    onSeeAll: () => context.push('/parent/notifications'),
                  ).animate().fadeIn(delay: 400.ms),

                  const SizedBox(height: 10),

                  // List of 3 mock items (TODO: replace with API)
                  ...recentNotifications.asMap().entries.map((entry) {
                    final index = entry.key;
                    final notif = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _NotifItem(
                        title: notif['title']!,
                        time: notif['time']!,
                        emoji: notif['emoji']!,
                        onTap: () => context.push('/parent/notifications'),
                      ),
                    ).animate(
                      delay: Duration(milliseconds: 450 + index * 60),
                    ).fadeIn().slideX(begin: 0.2);
                  }),

                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label, labelHi, value;
  const _MiniStat({
    required this.label,
    required this.labelHi,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$labelHi · $label',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isSuccess;
  final Color? valueColor;

  const _InfoRow({
    required this.label,
    required this.value,
    this.isSuccess = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isSuccess
        ? AppColors.success
        : (valueColor ?? AppColors.textPrimary);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  final String emoji;
  final String titleHi;
  final String titleEn;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.emoji,
    required this.titleHi,
    required this.titleEn,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2), width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titleHi,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                  Text(
                    titleEn,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotifItem extends StatelessWidget {
  final String title;
  final String time;
  final String emoji;
  final VoidCallback onTap;

  const _NotifItem({
    required this.title,
    required this.time,
    required this.emoji,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 16))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            size: 18,
            color: AppColors.textMuted,
          ),
        ],
      ),
    );
  }
}
