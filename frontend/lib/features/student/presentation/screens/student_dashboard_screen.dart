import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/sync_status_badge.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  bool _loading = true;
  Map<String, dynamic>? _dashboardData;
  final List<Map<String, dynamic>> _tasks = [
    {'title': 'गणित — भिन्न (Maths Fractions)', 'type': 'homework', 'done': false},
    {'title': 'हिंदी Quiz (Hindi Vocabulary)', 'type': 'quiz', 'done': true},
    {'title': 'Science Worksheet (पौधों के भाग)', 'type': 'worksheet', 'done': false},
  ];

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() => _loading = true);
    try {
      final res = await ApiClient.instance.get('/student/dashboard');
      if (mounted && res.data is Map && res.data['data'] is Map) {
        setState(() {
          _dashboardData = Map<String, dynamic>.from(res.data['data']);
          _loading = false;
        });
        return;
      }
    } catch (_) {}

    if (mounted) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final userName = authState is AuthAuthenticated ? authState.user.name : 'Rahul';
    final studentData = _dashboardData?['student'] is Map ? Map<String, dynamic>.from(_dashboardData!['student']) : null;
    final grade = studentData?['grade']?.toString() ?? '4';
    final section = studentData?['section']?.toString() ?? 'A';
    final rollNo = studentData?['roll_number']?.toString() ?? '03';

    final attendanceData = _dashboardData?['attendance'] is Map ? Map<String, dynamic>.from(_dashboardData!['attendance']) : null;
    final attendancePct = (attendanceData?['pct'] is num) ? (attendanceData!['pct'] as num).toDouble() : 87.0;
    final presentDays = attendanceData?['present'] ?? 26;
    final totalDays = attendanceData?['total'] ?? 30;

    final streakData = _dashboardData?['streak'] is Map ? Map<String, dynamic>.from(_dashboardData!['streak']) : null;
    final streakDays = streakData?['current_streak'] ?? 7;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboard,
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    expandedHeight: 140,
                    backgroundColor: AppColors.studentColor,
                    actions: const [
                      SyncStatusBadge(),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF0C447C), Color(0xFF1A6DB0)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        padding: const EdgeInsets.fromLTRB(20, 50, 20, 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: Colors.white24,
                              child: Text(
                                userName.isNotEmpty ? userName[0].toUpperCase() : 'S',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 20),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'नमस्ते, $userName! 👋',
                                    style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700),
                                  ),
                                  Text(
                                    'Class $grade-$section · Roll $rollNo',
                                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.saffron.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppColors.saffron),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('🔥', style: TextStyle(fontSize: 14)),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$streakDays days',
                                    style: const TextStyle(color: AppColors.saffron, fontSize: 12, fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Subject progress
                          SectionHeader(
                            title: 'मेरा प्रदर्शन',
                            subtitle: 'My Subject Performance',
                            onSeeAll: () => context.go('/student/progress'),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _SubjectCard(
                                subject: 'गणित (Maths)',
                                score: 0.72,
                                color: AppColors.studentColor,
                                emoji: '🔢',
                              ),
                              const SizedBox(width: 10),
                              _SubjectCard(
                                subject: 'हिंदी (Hindi)',
                                score: 0.85,
                                color: AppColors.primary,
                                emoji: '📖',
                              ),
                            ],
                          ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              _SubjectCard(
                                subject: 'Science (विज्ञान)',
                                score: 0.78,
                                color: AppColors.success,
                                emoji: '🔬',
                              ),
                              const SizedBox(width: 10),
                              _SubjectCard(
                                subject: 'EVS (पर्यावरण)',
                                score: 0.92,
                                color: AppColors.saffron,
                                emoji: '🌱',
                              ),
                            ],
                          ).animate().fadeIn(delay: 180.ms).slideY(begin: 0.2),

                          const SizedBox(height: 24),

                          // Attendance
                          SectionHeader(title: 'इस महीने की उपस्थिति', subtitle: 'This Month Attendance'),
                          const SizedBox(height: 12),
                          AppCard(
                            child: Column(
                              children: [
                                LinearPercentIndicator(
                                  percent: (attendancePct / 100).clamp(0.0, 1.0),
                                  lineHeight: 12,
                                  backgroundColor: AppColors.border,
                                  progressColor: attendancePct >= 75 ? AppColors.success : AppColors.warning,
                                  barRadius: const Radius.circular(6),
                                  padding: EdgeInsets.zero,
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${attendancePct.toInt()}% उपस्थित',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: attendancePct >= 75 ? AppColors.success : AppColors.warning,
                                      ),
                                    ),
                                    Text('$presentDays/$totalDays दिन उपस्थित', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                                  ],
                                ),
                              ],
                            ),
                          ).animate().fadeIn(delay: 260.ms).slideY(begin: 0.2),

                          const SizedBox(height: 24),

                          // Today's tasks
                          SectionHeader(title: 'आज के काम', subtitle: "Today's Tasks"),
                          const SizedBox(height: 12),
                          ..._tasks.asMap().entries.map((e) {
                            final idx = e.key;
                            final t = e.value;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _tasks[idx]['done'] = !(_tasks[idx]['done'] as bool);
                                });
                              },
                              child: _TaskItem(
                                title: t['title'] as String,
                                type: t['type'] as String,
                                done: t['done'] as bool,
                              ),
                            ).animate(delay: Duration(milliseconds: 300 + idx * 60)).fadeIn().slideX(begin: 0.2);
                          }),

                          const SizedBox(height: 24),

                          // Quick Quiz Action Banner
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFF4A828), Color(0xFFE67E22)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                const Text('🎯', style: TextStyle(fontSize: 32)),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: const [
                                      Text(
                                        'आज का क्विज़ खेलें!',
                                        style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
                                      ),
                                      Text(
                                        '5 प्रश्न • 50 अंक प्राप्त करें',
                                        style: TextStyle(color: Colors.white, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () => context.go('/student/quizzes'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: const Color(0xFFE67E22),
                                    minimumSize: const Size(80, 36),
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: const Text('Start', style: TextStyle(fontWeight: FontWeight.w700)),
                                ),
                              ],
                            ),
                          ).animate().fadeIn(delay: 450.ms).slideY(begin: 0.2),

                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/student/study-buddy'),
        backgroundColor: AppColors.studentColor,
        icon: const Icon(Icons.psychology_rounded, color: Colors.white),
        label: const Text('AI Study Buddy', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class _SubjectCard extends StatelessWidget {
  final String subject, emoji;
  final double score;
  final Color color;
  const _SubjectCard({required this.subject, required this.score, required this.color, required this.emoji});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 8),
            Text(subject, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
            const SizedBox(height: 6),
            LinearPercentIndicator(
              percent: score,
              lineHeight: 6,
              backgroundColor: Colors.white,
              progressColor: color,
              barRadius: const Radius.circular(3),
              padding: EdgeInsets.zero,
            ),
            const SizedBox(height: 4),
            Text('${(score * 100).toInt()}%', style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _TaskItem extends StatelessWidget {
  final String title, type;
  final bool done;
  const _TaskItem({required this.title, required this.type, required this.done});

  static const _icons = {
    'homework': Icons.edit_note_rounded,
    'quiz': Icons.quiz_rounded,
    'worksheet': Icons.description_outlined,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: done ? AppColors.surface : AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: done ? AppColors.border : AppColors.studentColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(_icons[type] ?? Icons.task_rounded, color: done ? AppColors.textMuted : AppColors.studentColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: done ? AppColors.textMuted : AppColors.textPrimary,
                decoration: done ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
          Icon(
            done ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            color: done ? AppColors.success : AppColors.textMuted,
            size: 20,
          ),
        ],
      ),
    );
  }
}
