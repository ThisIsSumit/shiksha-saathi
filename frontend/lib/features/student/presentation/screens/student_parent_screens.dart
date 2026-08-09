import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/ai_chat_sheet.dart';

// ════════════════════════════════════════════════════════════
// STUDENT DASHBOARD
// ════════════════════════════════════════════════════════════
class StudentDashboardScreen extends StatelessWidget {
  const StudentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(slivers: [
        SliverAppBar(
          pinned: true, expandedHeight: 140,
          backgroundColor: const Color(0xFF0C447C),
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFF0C447C), Color(0xFF1A6DB0)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight),
              ),
              padding: const EdgeInsets.fromLTRB(20, 55, 20, 16),
              child: Row(children: [
                const CircleAvatar(radius: 24, backgroundColor: Colors.white24,
                  child: Text('R', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 20))),
                const SizedBox(width: 14),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('नमस्ते, Rahul! 👋', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                  Text('Class 4-A · Roll 03', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
                ]),
                const Spacer(),
                // Streak badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: AppColors.saffron.withOpacity(0.2), borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.saffron)),
                  child: Row(children: [
                    const Text('🔥', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 4),
                    const Text('7 days', style: TextStyle(color: AppColors.saffron, fontSize: 12, fontWeight: FontWeight.w600)),
                  ]),
                ),
              ]),
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              // Subject progress cards
              SectionHeader(title: 'मेरा प्रदर्शन', subtitle: 'My Performance'),
              const SizedBox(height: 12),
              Row(children: [
                _SubjectCard(subject: 'गणित', score: 0.68, color: const Color(0xFF0C447C), emoji: '🔢'),
                const SizedBox(width: 10),
                _SubjectCard(subject: 'हिंदी', score: 0.82, color: AppColors.primary, emoji: '📖'),
              ]).animate().fadeIn(delay: 100.ms).slideY(begin: 0.3),
              const SizedBox(height: 10),
              Row(children: [
                _SubjectCard(subject: 'Science', score: 0.75, color: AppColors.success, emoji: '🔬'),
                const SizedBox(width: 10),
                _SubjectCard(subject: 'EVS', score: 0.90, color: AppColors.saffron, emoji: '🌱'),
              ]).animate().fadeIn(delay: 180.ms).slideY(begin: 0.3),

              const SizedBox(height: 24),

              // Attendance
              SectionHeader(title: 'इस महीने की उपस्थिति', subtitle: 'This Month Attendance'),
              const SizedBox(height: 12),
              AppCard(
                child: Column(children: [
                  LinearPercentIndicator(
                    percent: 0.87, lineHeight: 12,
                    backgroundColor: AppColors.border,
                    progressColor: AppColors.success,
                    barRadius: const Radius.circular(6),
                    padding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 10),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('87% उपस्थित', style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.success)),
                    Text('26/30 दिन', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  ]),
                ]),
              ).animate().fadeIn(delay: 260.ms).slideY(begin: 0.3),

              const SizedBox(height: 24),

              // Today's tasks
              SectionHeader(title: 'आज के काम', subtitle: "Today's Tasks"),
              const SizedBox(height: 12),
              ...[
                {'title': 'गणित — भिन्न', 'type': 'homework', 'done': false},
                {'title': 'हिंदी Quiz', 'type': 'quiz', 'done': true},
                {'title': 'Science Worksheet', 'type': 'worksheet', 'done': false},
              ].asMap().entries.map((e) {
                final t = e.value;
                return _TaskItem(title: t['title'] as String, type: t['type'] as String, done: t['done'] as bool)
                    .animate(delay: Duration(milliseconds: 300 + e.key * 60)).fadeIn().slideX(begin: 0.2);
              }),

              const SizedBox(height: 80),
            ]),
          ),
        ),
      ]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showModalBottomSheet(context: context, isScrollControlled: true, useSafeArea: true,
          builder: (_) => const AiChatSheet(role: 'student')),
        backgroundColor: const Color(0xFF0C447C),
        icon: const Icon(Icons.psychology_rounded, color: Colors.white),
        label: const Text('Study Buddy', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _SubjectCard extends StatelessWidget {
  final String subject, emoji; final double score; final Color color;
  const _SubjectCard({required this.subject, required this.score, required this.color, required this.emoji});
  @override
  Widget build(BuildContext context) {
    return Expanded(child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: color.withOpacity(0.07), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.2))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(emoji, style: const TextStyle(fontSize: 22)),
        const SizedBox(height: 8),
        Text(subject, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
        const SizedBox(height: 6),
        LinearPercentIndicator(percent: score, lineHeight: 6, backgroundColor: Colors.white,
          progressColor: color, barRadius: const Radius.circular(3), padding: EdgeInsets.zero),
        const SizedBox(height: 4),
        Text('${(score * 100).toInt()}%', style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
      ]),
    ));
  }
}

class _TaskItem extends StatelessWidget {
  final String title, type; final bool done;
  const _TaskItem({required this.title, required this.type, required this.done});
  static const _icons = {'homework': Icons.edit_note_rounded, 'quiz': Icons.quiz_rounded, 'worksheet': Icons.description_outlined};
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: done ? AppColors.surface : AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: done ? AppColors.border : const Color(0xFF0C447C).withOpacity(0.3)),
      ),
      child: Row(children: [
        Icon(_icons[type] ?? Icons.task_rounded, color: done ? AppColors.textMuted : const Color(0xFF0C447C), size: 20),
        const SizedBox(width: 10),
        Expanded(child: Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: done ? AppColors.textMuted : AppColors.textPrimary, decoration: done ? TextDecoration.lineThrough : null))),
        if (done) const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 18),
      ]),
    );
  }
}

// ════════════════════════════════════════════════════════════
// PARENT DASHBOARD
// ════════════════════════════════════════════════════════════
class ParentDashboardScreen extends StatelessWidget {
  const ParentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(slivers: [
        SliverAppBar(
          pinned: true, expandedHeight: 130,
          backgroundColor: const Color(0xFF3C3489),
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFF3C3489), Color(0xFF5B52C9)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              ),
              padding: const EdgeInsets.fromLTRB(20, 55, 20, 16),
              child: Row(children: [
                const CircleAvatar(radius: 22, backgroundColor: Colors.white24,
                  child: Text('S', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18))),
                const SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('नमस्ते, Suresh जी', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                  Text('अभिभावक · Parent', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
                ]),
                const Spacer(),
                IconButton(icon: const Icon(Icons.notifications_outlined, color: Colors.white), onPressed: () {}),
              ]),
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              // Child card
              SectionHeader(title: 'मेरे बच्चे', subtitle: 'My Children'),
              const SizedBox(height: 12),
              _ChildCard().animate().fadeIn(delay: 100.ms).slideY(begin: 0.3),
              const SizedBox(height: 24),

              // Today summary
              SectionHeader(title: 'आज की जानकारी', subtitle: "Today's Summary"),
              const SizedBox(height: 12),
              AppCard(
                child: Column(children: [
                  _InfoRow(icon: Icons.check_circle_outline, color: AppColors.success, label: 'आज उपस्थित है', value: '✓ School'),
                  const Divider(height: 20),
                  _InfoRow(icon: Icons.assignment_outlined, color: const Color(0xFF0C447C), label: 'गृहकार्य', value: '2 बाकी'),
                  const Divider(height: 20),
                  _InfoRow(icon: Icons.trending_up_rounded, color: AppColors.saffron, label: 'हिंदी में सुधार', value: '+8%'),
                ]),
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3),
              const SizedBox(height: 24),

              // Recent notifications
              SectionHeader(title: 'हाल की सूचनाएं', subtitle: 'Recent Notifications'),
              const SizedBox(height: 12),
              ...[
                {'icon': '📚', 'msg': 'आज गणित में भिन्न पढ़ाई गई। गृहकार्य: पृष्ठ 24', 'time': '2:00 PM'},
                {'icon': '✅', 'msg': 'Rahul आज स्कूल में उपस्थित है।', 'time': '8:15 AM'},
                {'icon': '📝', 'msg': 'कल हिंदी का Quiz है। तैयारी करवाएं।', 'time': 'Yesterday'},
              ].asMap().entries.map((e) {
                final n = e.value;
                return _NotifItem(icon: n['icon']!, msg: n['msg']!, time: n['time']!)
                    .animate(delay: Duration(milliseconds: 280 + e.key * 70)).fadeIn().slideX(begin: 0.2);
              }),

              const SizedBox(height: 80),
            ]),
          ),
        ),
      ]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showModalBottomSheet(context: context, isScrollControlled: true, useSafeArea: true,
          builder: (_) => const AiChatSheet(role: 'parent')),
        backgroundColor: const Color(0xFF3C3489),
        icon: const Icon(Icons.support_agent_rounded, color: Colors.white),
        label: const Text('AI से पूछें', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _ChildCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF3C3489), Color(0xFF5B52C9)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(children: [
        const CircleAvatar(radius: 28, backgroundColor: Colors.white24,
          child: Text('R', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700))),
        const SizedBox(width: 14),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Rahul Kumar', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
          Text('Class 4-A · Roll 03', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
          const SizedBox(height: 6),
          Row(children: [
            _MiniStat(label: 'Attendance', value: '87%', color: Colors.greenAccent),
            const SizedBox(width: 14),
            _MiniStat(label: 'Avg Score', value: '74%', color: Colors.amberAccent),
          ]),
        ]),
      ]),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label, value; final Color color;
  const _MiniStat({required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) => Column(children: [
    Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 14)),
    Text(label, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10)),
  ]);
}

class _InfoRow extends StatelessWidget {
  final IconData icon; final Color color; final String label, value;
  const _InfoRow({required this.icon, required this.color, required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Row(children: [
    Container(width: 36, height: 36, decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Icon(icon, color: color, size: 18)),
    const SizedBox(width: 12),
    Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
    const Spacer(),
    Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
  ]);
}

class _NotifItem extends StatelessWidget {
  final String icon, msg, time;
  const _NotifItem({required this.icon, required this.msg, required this.time});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: AppColors.surfaceCard, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border, width: 0.5)),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(icon, style: const TextStyle(fontSize: 20)),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(msg, style: const TextStyle(fontSize: 12, height: 1.4)),
        const SizedBox(height: 3),
        Text(time, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
      ])),
    ]),
  );
}
