// ═══════════════════════════════════════════════════
// FILE 2/6: lib/features/teacher/presentation/screens/teacher_dashboard_screen.dart
// STATUS: NEW — create this file
// ═══════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/snack_helper.dart';
import '../../../../shared/widgets/stat_chip.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';

const teacherGreen = Color(0xFF166534);
const teacherLight = Color(0xFF22C55E);

class TeacherDashboardScreen extends StatelessWidget {
  const TeacherDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.read<AuthBloc>().state;
    final user = state is AuthAuthenticated ? state.user : null;
    final name = user?.name ?? 'Teacher';
    final initials = name.isNotEmpty ? name[0].toUpperCase() : 'T';

    // TODO API: replace fallback dashboard stats with live API endpoint data
    const totalStudents = '28';
    const presentToday = '25';
    const pendingHomework = '3';
    const classAverage = '76%';

    final todayClasses = const [
      {
        'subject': 'गणित',
        'subjectEn': 'Mathematics',
        'icon': '📚',
        'class': 'कक्षा 4-A / Class 4-A',
        'time': '09:00 AM',
        'status': 'चल रही है / Ongoing',
        'isOngoing': true,
      },
      {
        'subject': 'हिंदी',
        'subjectEn': 'Hindi',
        'icon': '📖',
        'class': 'कक्षा 4-A / Class 4-A',
        'time': '10:00 AM',
        'status': 'आने वाली / Upcoming',
        'isOngoing': false,
      },
      {
        'subject': 'विज्ञान',
        'subjectEn': 'Science',
        'icon': '🔬',
        'class': 'कक्षा 4-A / Class 4-A',
        'time': '11:00 AM',
        'status': 'आने वाली / Upcoming',
        'isOngoing': false,
      },
      {
        'subject': 'EVS',
        'subjectEn': 'EVS',
        'icon': '🌍',
        'class': 'कक्षा 4-A / Class 4-A',
        'time': '12:00 PM',
        'status': 'आने वाली / Upcoming',
        'isOngoing': false,
      },
    ];

    // TODO API: replace mock recent activities with backend logs
    final recentActivities = const [
      {
        'icon': Icons.stars_rounded,
        'title': 'Rahul का गणित स्कोर अपडेट हुआ',
        'subtitle': "Rahul's Mathematics score updated",
        'time': '10m ago',
      },
      {
        'icon': Icons.assignment_turned_in_rounded,
        'title': 'कक्षा 4-A का गृहकार्य जमा हुआ',
        'subtitle': 'Class 4-A homework submitted',
        'time': '1h ago',
      },
      {
        'icon': Icons.fact_check_rounded,
        'title': '28 छात्रों की उपस्थिति दर्ज की गई',
        'subtitle': 'Attendance recorded for 28 students',
        'time': '2h ago',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: teacherGreen,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'नमस्ते, $name जी',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Text(
              'Teacher Dashboard',
              style: TextStyle(
                fontSize: 11,
                color: Colors.white70,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {
              SnackHelper.info(context, 'No new notifications / कोई सूचना नहीं');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Teacher Header Card
            AppCard(
              color: teacherGreen.withOpacity(0.06),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: teacherGreen,
                    child: Text(
                      initials,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: teacherGreen.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'शिक्षक · Teacher',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: teacherGreen,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        // TODO API: replace fallback school name with API response
                        const Text(
                          'Govt. Primary School, Hamirpur',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
            const SizedBox(height: 20),

            // Statistics Grid (Row of StatChips)
            Row(
              children: const [
                StatChip(
                  value: totalStudents,
                  label: 'कुल छात्र',
                  labelEn: 'Total Students',
                  icon: Icons.people_outline_rounded,
                  color: teacherGreen,
                ),
                SizedBox(width: 8),
                StatChip(
                  value: presentToday,
                  label: 'आज उपस्थित',
                  labelEn: 'Present Today',
                  icon: Icons.check_circle_outline,
                  color: AppColors.success,
                ),
              ],
            ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.2),
            const SizedBox(height: 8),
            Row(
              children: const [
                StatChip(
                  value: pendingHomework,
                  label: 'लंबित गृहकार्य',
                  labelEn: 'Pending Homework',
                  icon: Icons.assignment_outlined,
                  color: AppColors.saffron,
                ),
                SizedBox(width: 8),
                StatChip(
                  value: classAverage,
                  label: 'कक्षा औसत',
                  labelEn: 'Class Average',
                  icon: Icons.pie_chart_outline_rounded,
                  color: AppColors.info,
                ),
              ],
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
            const SizedBox(height: 24),

            // Today's Classes Section
            const SectionHeader(
              title: 'आज की कक्षाएं',
              subtitle: "Today's Classes",
            ),
            const SizedBox(height: 10),
            Column(
              children: List.generate(todayClasses.length, (i) {
                final cls = todayClasses[i];
                final isOngoing = cls['isOngoing'] == true;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: AppCard(
                    child: Row(
                      children: [
                        Text(
                          cls['icon'] as String,
                          style: const TextStyle(fontSize: 28),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${cls['subject']} / ${cls['subjectEn']}',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${cls['class']} • ${cls['time']}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isOngoing
                                ? teacherGreen.withOpacity(0.12)
                                : AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isOngoing ? teacherGreen : AppColors.border,
                            ),
                          ),
                          child: Text(
                            cls['status'] as String,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isOngoing ? teacherGreen : AppColors.textMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate(
                  delay: Duration(milliseconds: 100 + i * 60),
                ).fadeIn().slideX(begin: 0.2);
              }),
            ),
            const SizedBox(height: 24),

            // Quick Actions Section
            const SectionHeader(
              title: 'त्वरित कार्य',
              subtitle: 'Quick Actions',
            ),
            const SizedBox(height: 10),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 2.2,
              children: [
                _buildQuickActionCard(
                  context,
                  icon: Icons.people_outline_rounded,
                  title: 'छात्र देखें',
                  titleEn: 'View Students',
                  color: teacherGreen,
                  onTap: () => context.go('/teacher/students'),
                ),
                _buildQuickActionCard(
                  context,
                  icon: Icons.fact_check_outlined,
                  title: 'उपस्थिति लें',
                  titleEn: 'Mark Attendance',
                  color: AppColors.success,
                  onTap: () => context.go('/teacher/attendance'),
                ),
                _buildQuickActionCard(
                  context,
                  icon: Icons.psychology_outlined,
                  title: 'AI से पूछें',
                  titleEn: 'Ask AI',
                  color: teacherLight,
                  onTap: () => context.go('/teacher/ai'),
                ),
                _buildQuickActionCard(
                  context,
                  icon: Icons.assignment_outlined,
                  title: 'गृहकार्य',
                  titleEn: 'Homework',
                  color: AppColors.saffron,
                  onTap: () => SnackHelper.info(context, 'Coming soon / जल्द आएगा'),
                ),
              ],
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.3),
            const SizedBox(height: 24),

            // Recent Activity Section
            const SectionHeader(
              title: 'हाल की गतिविधि',
              subtitle: 'Recent Activity',
            ),
            const SizedBox(height: 10),
            AppCard(
              child: Column(
                children: List.generate(recentActivities.length, (i) {
                  final act = recentActivities[i];
                  final isLast = i == recentActivities.length - 1;

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: teacherGreen.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                act['icon'] as IconData,
                                size: 20,
                                color: teacherGreen,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    act['title'] as String,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    act['subtitle'] as String,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              act['time'] as String,
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!isLast) const Divider(height: 1, color: AppColors.border),
                    ],
                  );
                }),
              ),
            ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.3),
            const SizedBox(height: 80), // Padding for FAB
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: teacherGreen,
        foregroundColor: Colors.white,
        elevation: 3,
        icon: const Icon(Icons.psychology_outlined),
        label: const Text(
          'AI से पूछें / Ask AI',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        ),
        onPressed: () => context.go('/teacher/ai'),
      ).animate().fadeIn(delay: 400.ms).scale(duration: 300.ms),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String titleEn,
    required Color color,
    required VoidCallback onTap,
  }) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  titleEn,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
    );
  }
}
