import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shiksha_saathi/features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/stat_chip.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/ai_chat_sheet.dart';

// ════════════════════════════════════════════════════════════
// TEACHER HOME (Shell with BottomNav)
// ════════════════════════════════════════════════════════════
class TeacherShell extends StatelessWidget {
  final Widget child;
  const TeacherShell({super.key, required this.child});

  static const _tabRoutes = [
    '/teacher',
    '/teacher/lessons',
    '/teacher/attendance',
    '/teacher/worksheets',
    '/teacher/ai',
  ];

  static const _tabs = [
    {
      'icon': Icons.dashboard_outlined,
      'iconSel': Icons.dashboard_rounded,
      'label': 'Dashboard',
      'labelHi': 'होम'
    },
    {
      'icon': Icons.book_outlined,
      'iconSel': Icons.book_rounded,
      'label': 'Lessons',
      'labelHi': 'पाठ'
    },
    {
      'icon': Icons.checklist_outlined,
      'iconSel': Icons.checklist_rounded,
      'label': 'Attendance',
      'labelHi': 'हाज़री'
    },
    {
      'icon': Icons.description_outlined,
      'iconSel': Icons.description_rounded,
      'label': 'Worksheets',
      'labelHi': 'पत्रक'
    },
    {
      'icon': Icons.smart_toy_outlined,
      'iconSel': Icons.smart_toy_rounded,
      'label': 'AI',
      'labelHi': 'AI'
    },
  ];

  int _indexFromLocation(String location) {
    if (location.startsWith('/teacher/lessons')) return 1;
    if (location.startsWith('/teacher/attendance')) return 2;
    if (location.startsWith('/teacher/worksheets')) return 3;
    if (location.startsWith('/teacher/ai')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex =
        _indexFromLocation(GoRouterState.of(context).uri.path);
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          border: const Border(
              top: BorderSide(color: AppColors.border, width: 0.5)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, -4))
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
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primaryPale
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              isSelected
                                  ? t['iconSel'] as IconData
                                  : t['icon'] as IconData,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textMuted,
                              size: 22,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(t['labelHi'] as String,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.textMuted,
                              )),
                        ]),
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

// ════════════════════════════════════════════════════════════
// TEACHER DASHBOARD SCREEN
// ════════════════════════════════════════════════════════════
class TeacherDashboardScreen extends StatelessWidget {
  const TeacherDashboardScreen({super.key});

  Future<void> _confirmLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Logout'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Logout'),
              ),
            ],
          ),
        ) ??
        false;

    if (!shouldLogout || !context.mounted) return;
    context.read<AuthBloc>().add(AuthLogout());
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final greeting = now.hour < 12
        ? 'Good Morning\nसुप्रभात'
        : now.hour < 17
            ? 'Good Afternoon\nनमस्कार'
            : 'Good Evening\nशुभ संध्या';

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          // ── Appbar ────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            expandedHeight: 160,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.primary, Color(0xFF2D8653)]),
                ),
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 16),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        CircleAvatar(
                            radius: 22,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            child: const Text('R',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18))),
                        const SizedBox(width: 12),
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Text(greeting,
                                  style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                      height: 1.4)),
                              const Text('Ramesh Kumar',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)),
                            ])),
                        IconButton(
                            icon: const Icon(Icons.notifications_outlined,
                                color: Colors.white),
                            onPressed: () {}),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert_rounded,
                              color: Colors.white),
                          onSelected: (value) {
                            if (value == 'logout') {
                              _confirmLogout(context);
                            }
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem<String>(
                              value: 'logout',
                              child: Row(
                                children: [
                                  Icon(Icons.logout_rounded, size: 18),
                                  SizedBox(width: 8),
                                  Text('Logout'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ]),
                    ]),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Today stats ───────────────────────────────────
                    Row(children: [
                      StatChip(
                          value: '28',
                          label: 'छात्र',
                          labelEn: 'Students',
                          icon: Icons.people_outlined,
                          color: AppColors.primary),
                      const SizedBox(width: 10),
                      StatChip(
                          value: '92%',
                          label: 'हाज़री',
                          labelEn: 'Attendance',
                          icon: Icons.check_circle_outline,
                          color: AppColors.success),
                      const SizedBox(width: 10),
                      StatChip(
                          value: '3',
                          label: 'पाठ',
                          labelEn: 'Lessons',
                          icon: Icons.book_outlined,
                          color: AppColors.saffron),
                    ]).animate().fadeIn(delay: 100.ms).slideY(begin: 0.3),

                    const SizedBox(height: 24),

                    // ── Quick actions ─────────────────────────────────
                    SectionHeader(
                        title: 'त्वरित क्रिया', subtitle: 'Quick Actions'),
                    const SizedBox(height: 12),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1.6,
                      children: [
                        _QuickAction(
                            emoji: '📖',
                            title: 'AI पाठ योजना',
                            subtitle: 'Generate plan',
                            color: AppColors.primary,
                            onTap: () => context.go('/teacher/lessons')),
                        _QuickAction(
                            emoji: '✅',
                            title: 'हाज़री लें',
                            subtitle: 'Mark attendance',
                            color: AppColors.success,
                            onTap: () => context.go('/teacher/attendance')),
                        _QuickAction(
                            emoji: '📝',
                            title: 'कार्यपत्रक',
                            subtitle: 'Create worksheet',
                            color: AppColors.saffron,
                            onTap: () => context.go('/teacher/worksheets')),
                        _QuickAction(
                            emoji: '💬',
                            title: 'SMS भेजें',
                            subtitle: 'Parent message',
                            color: AppColors.soil,
                            onTap: () => ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                                    content: Text(
                                        'SMS module will be available soon.')))),
                      ],
                    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3),

                    const SizedBox(height: 24),

                    // ── Today's schedule ──────────────────────────────
                    SectionHeader(
                        title: 'आज का कार्यक्रम', subtitle: "Today's Schedule"),
                    const SizedBox(height: 12),
                    ...[
                      _ScheduleItem(
                          time: '8:00 AM',
                          subject: 'गणित',
                          topic: 'भिन्न',
                          grade: 'Class 4',
                          done: true),
                      _ScheduleItem(
                          time: '10:00 AM',
                          subject: 'हिंदी',
                          topic: 'संज्ञा',
                          grade: 'Class 4',
                          done: false),
                      _ScheduleItem(
                          time: '12:00 PM',
                          subject: 'Science',
                          topic: 'Plants',
                          grade: 'Class 5',
                          done: false),
                    ].asMap().entries.map((e) => e.value
                        .animate(
                            delay: Duration(milliseconds: 280 + e.key * 80))
                        .fadeIn()
                        .slideX(begin: 0.2)),

                    const SizedBox(height: 24),

                    // ── Struggling students alert ─────────────────────
                    SectionHeader(
                        title: 'ध्यान चाहिए', subtitle: 'Needs Attention'),
                    const SizedBox(height: 12),
                    AppCard(
                      child: Column(children: [
                        _StudentAlert(
                            name: 'Rahul Kumar',
                            issue: 'गणित में कमज़ोर',
                            pct: 0.45),
                        const Divider(height: 1),
                        _StudentAlert(
                            name: 'Priya Sharma',
                            issue: '5 दिन अनुपस्थित',
                            pct: 0.0,
                            isAbsence: true),
                      ]),
                    ).animate().fadeIn(delay: 450.ms).slideY(begin: 0.3),

                    const SizedBox(height: 80),
                  ]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          builder: (_) => const AiChatSheet(role: 'teacher'),
        ),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.smart_toy_rounded, color: Colors.white),
        label: const Text('AI',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final String emoji, title, subtitle;
  final Color color;
  final VoidCallback onTap;
  const _QuickAction(
      {required this.emoji,
      required this.title,
      required this.subtitle,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(height: 6),
              Text(title,
                  style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600, color: color)),
              Text(subtitle,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textMuted)),
            ]),
      ),
    );
  }
}

class _ScheduleItem extends StatelessWidget {
  final String time, subject, topic, grade;
  final bool done;
  const _ScheduleItem(
      {required this.time,
      required this.subject,
      required this.topic,
      required this.grade,
      required this.done});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: done ? AppColors.surface : AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color:
                done ? AppColors.border : AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(children: [
        Container(
          width: 4,
          height: 40,
          decoration: BoxDecoration(
            color: done ? AppColors.textMuted : AppColors.primary,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('$subject — $topic',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: done ? AppColors.textMuted : AppColors.textPrimary)),
          Text('$grade · $time',
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
        ])),
        if (done)
          const Icon(Icons.check_circle_rounded,
              color: AppColors.success, size: 18)
        else
          const Icon(Icons.radio_button_unchecked,
              color: AppColors.textMuted, size: 18),
      ]),
    );
  }
}

class _StudentAlert extends StatelessWidget {
  final String name, issue;
  final double pct;
  final bool isAbsence;
  const _StudentAlert(
      {required this.name,
      required this.issue,
      required this.pct,
      this.isAbsence = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(children: [
        CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.surface,
            child: Text(name[0], style: const TextStyle(fontSize: 14))),
        const SizedBox(width: 10),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name,
              style:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          Text(issue,
              style: const TextStyle(fontSize: 11, color: AppColors.error)),
        ])),
        if (!isAbsence)
          SizedBox(
            width: 36,
            height: 36,
            child: CircularProgressIndicator(
              value: pct,
              strokeWidth: 3,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation(AppColors.error),
            ),
          ),
      ]),
    );
  }
}

// ════════════════════════════════════════════════════════════
// TEACHER AI TOOLS SCREEN
// ════════════════════════════════════════════════════════════
class TeacherAiScreen extends StatelessWidget {
  const TeacherAiScreen({super.key});

  Future<void> _confirmLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Logout'),
            content: const Text('Do you want to logout from this account?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Logout'),
              ),
            ],
          ),
        ) ??
        false;

    if (!shouldLogout || !context.mounted) return;
    context.read<AuthBloc>().add(AuthLogout());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('AI सहायक',
                style: TextStyle(fontSize: 16, color: Colors.white)),
            Text('AI Assistant',
                style: TextStyle(
                    fontSize: 11,
                    color: Colors.white70,
                    fontWeight: FontWeight.w400)),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => _confirmLogout(context),
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Use AI to speed up your classroom work.',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.primaryPale,
                      child: Icon(Icons.auto_awesome_rounded,
                          color: AppColors.primary),
                    ),
                    title: const Text('Open AI Chat'),
                    subtitle: const Text(
                        'Lesson plan, worksheet, translations and more'),
                    trailing:
                        const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                    onTap: () => showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      useSafeArea: true,
                      builder: (_) => const AiChatSheet(role: 'teacher'),
                    ),
                  ),
                  const Divider(height: 20),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.primaryPale,
                      child: Icon(Icons.book_rounded, color: AppColors.primary),
                    ),
                    title: const Text('Lesson Planner'),
                    subtitle: const Text('Generate complete class plans'),
                    trailing:
                        const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                    onTap: () => context.go('/teacher/lessons'),
                  ),
                  const Divider(height: 20),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.primaryPale,
                      child: Icon(Icons.description_rounded,
                          color: AppColors.primary),
                    ),
                    title: const Text('Worksheet Builder'),
                    subtitle: const Text('Create class worksheets instantly'),
                    trailing:
                        const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                    onTap: () => context.go('/teacher/worksheets'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            AppCard(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFFCEBEB),
                  child: Icon(Icons.logout_rounded, color: AppColors.error),
                ),
                title: const Text('Logout'),
                subtitle: const Text('Sign out from this device'),
                onTap: () => _confirmLogout(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
// ATTENDANCE SCREEN
// ════════════════════════════════════════════════════════════
class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});
  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final _today = DateTime.now();
  final Map<String, String> _status = {};

  final _students = [
    {'id': '1', 'name': 'Aarav Singh', 'roll': '01'},
    {'id': '2', 'name': 'Priya Sharma', 'roll': '02'},
    {'id': '3', 'name': 'Rahul Kumar', 'roll': '03'},
    {'id': '4', 'name': 'Sunita Devi', 'roll': '04'},
    {'id': '5', 'name': 'Mohan Lal', 'roll': '05'},
    {'id': '6', 'name': 'Anita Yadav', 'roll': '06'},
    {'id': '7', 'name': 'Ravi Gupta', 'roll': '07'},
    {'id': '8', 'name': 'Kavita Mishra', 'roll': '08'},
  ];

  int get _presentCount => _status.values.where((v) => v == 'present').length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('उपस्थिति / Attendance', style: TextStyle(fontSize: 16)),
          Text('${_today.day}/${_today.month}/${_today.year} · Class 4-A',
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.w400)),
        ]),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.check_circle_outline,
                color: Colors.white, size: 18),
            label: const Text('All Present',
                style: TextStyle(color: Colors.white, fontSize: 12)),
            onPressed: () => setState(() {
              for (var s in _students) _status[s['id']!] = 'present';
            }),
          ),
        ],
      ),
      body: Column(children: [
        // Summary bar
        AnimatedContainer(
          duration: 300.ms,
          color: AppColors.primaryPale,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _SummaryPill(
                label: 'Present',
                count: _presentCount,
                color: AppColors.success),
            _SummaryPill(
                label: 'Absent',
                count: _status.values.where((v) => v == 'absent').length,
                color: AppColors.error),
            _SummaryPill(
                label: 'Unmarked',
                count: _students.length - _status.length,
                color: AppColors.textMuted),
            _SummaryPill(
                label: 'Total',
                count: _students.length,
                color: AppColors.primary),
          ]),
        ),

        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _students.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final s = _students[i];
              final status = _status[s['id']] ?? '';
              return _AttendanceRow(
                student: s,
                status: status,
                onStatus: (v) => setState(() => _status[s['id']!] = v),
              )
                  .animate(delay: Duration(milliseconds: i * 40))
                  .fadeIn()
                  .slideX(begin: 0.2);
            },
          ),
        ),
      ]),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _status.length == _students.length ? _save : null,
            child: Text(
                'Save Attendance · ${_presentCount}/${_students.length} Present'),
          ),
        ),
      ),
    );
  }

  void _save() {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('✅ Attendance saved!')));
  }
}

class _AttendanceRow extends StatelessWidget {
  final Map<String, String> student;
  final String status;
  final void Function(String) onStatus;
  const _AttendanceRow(
      {required this.student, required this.status, required this.onStatus});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: status == 'present'
            ? const Color(0xFFEAF7EF)
            : status == 'absent'
                ? const Color(0xFFFCEBEB)
                : AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: status == 'present'
              ? AppColors.success.withOpacity(0.4)
              : status == 'absent'
                  ? AppColors.error.withOpacity(0.4)
                  : AppColors.border,
        ),
      ),
      child: Row(children: [
        CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.surface,
            child: Text(student['roll']!,
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600))),
        const SizedBox(width: 12),
        Text(student['name']!,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const Spacer(),
        _StatusBtn(
            label: 'P',
            active: status == 'present',
            color: AppColors.success,
            onTap: () => onStatus('present')),
        const SizedBox(width: 6),
        _StatusBtn(
            label: 'A',
            active: status == 'absent',
            color: AppColors.error,
            onTap: () => onStatus('absent')),
        const SizedBox(width: 6),
        _StatusBtn(
            label: 'L',
            active: status == 'late',
            color: AppColors.warning,
            onTap: () => onStatus('late')),
      ]),
    );
  }
}

class _StatusBtn extends StatelessWidget {
  final String label;
  final bool active;
  final Color color;
  final VoidCallback onTap;
  const _StatusBtn(
      {required this.label,
      required this.active,
      required this.color,
      required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: 150.ms,
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: active ? color : AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: active ? color : AppColors.border),
          ),
          child: Center(
              child: Text(label,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: active ? Colors.white : AppColors.textMuted))),
        ),
      );
}

class _SummaryPill extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _SummaryPill(
      {required this.label, required this.count, required this.color});
  @override
  Widget build(BuildContext context) => Column(children: [
        Text('$count',
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.w700, color: color)),
        Text(label,
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
      ]);
}
