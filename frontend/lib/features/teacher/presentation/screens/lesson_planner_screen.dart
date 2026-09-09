import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/services/pdf_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/network/api_client.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/snack_helper.dart';

// ════════════════════════════════════════════════════════════
// LESSON PLANNER SCREEN
// ════════════════════════════════════════════════════════════
class LessonPlannerScreen extends StatefulWidget {
  const LessonPlannerScreen({super.key});
  @override
  State<LessonPlannerScreen> createState() => _LessonPlannerScreenState();
}

class _LessonPlannerScreenState extends State<LessonPlannerScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final List<Map<String, dynamic>> _savedPlans = [];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _loadSavedPlans();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _loadSavedPlans() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList('saved_lesson_plans') ?? [];
    if (!mounted) return;
    setState(() {
      _savedPlans.clear();
      _savedPlans.addAll(raw.map((entry) {
        final decoded = jsonDecode(entry);
        return Map<String, dynamic>.from(decoded as Map);
      }).toList());
    });
  }

  Future<void> _persistPlans() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'saved_lesson_plans',
      _savedPlans.map((plan) => jsonEncode(plan)).toList(),
    );
  }

  Future<void> _savePlan(Map<String, dynamic> plan) async {
    final id = plan['id']?.toString() ??
        DateTime.now().millisecondsSinceEpoch.toString();
    final entry = Map<String, dynamic>.from(plan)
      ..['id'] = id
      ..['savedAt'] =
          plan['savedAt']?.toString() ?? DateTime.now().toIso8601String();

    final existingIndex = _savedPlans.indexWhere((item) => item['id'] == id);
    if (existingIndex >= 0) {
      _savedPlans[existingIndex] = entry;
    } else {
      _savedPlans.insert(0, entry);
    }

    await _persistPlans();
    if (mounted) setState(() {});
  }

  Future<void> _updatePlan(Map<String, dynamic> updatedPlan) async {
    final id = updatedPlan['id']?.toString();
    if (id == null) return;
    final index = _savedPlans.indexWhere((item) => item['id'] == id);
    if (index < 0) return;
    _savedPlans[index] = Map<String, dynamic>.from(updatedPlan);
    await _persistPlans();
    if (mounted) setState(() {});
  }

  Future<void> _deletePlan(String id) async {
    _savedPlans.removeWhere((item) => item['id'] == id);
    await _persistPlans();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('पाठ योजना',
                style: TextStyle(fontSize: 16, color: Colors.white)),
            Text('Lesson Planner',
                style: TextStyle(
                    fontSize: 11,
                    color: Colors.white70,
                    fontWeight: FontWeight.w400)),
          ],
        ),
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: AppColors.saffron,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(text: 'AI Generate'),
            Tab(text: 'My Plans'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _GenerateTab(onSavePlan: _savePlan),
          _MyPlansTab(
            plans: _savedPlans,
            onUpdate: _updatePlan,
            onDelete: _deletePlan,
          ),
        ],
      ),
    );
  }
}

// ── Generate Tab ──────────────────────────────────────────────────────────
class _GenerateTab extends StatefulWidget {
  final Future<void> Function(Map<String, dynamic> plan) onSavePlan;

  const _GenerateTab({required this.onSavePlan});
  @override
  State<_GenerateTab> createState() => _GenerateTabState();
}

class _GenerateTabState extends State<_GenerateTab> {
  String _grade = '4';
  String _subject = 'Mathematics';
  String _language = 'hi';
  final _topicCtr = TextEditingController();
  bool _loading = false;
  Map<String, dynamic>? _result;

  final _grades = ['1', '2', '3', '4', '5', '6', '7', '8'];
  final _subjects = [
    'Mathematics',
    'Hindi',
    'English',
    'Science',
    'Social Science',
    'EVS'
  ];
  final _languages = [
    {'id': 'hi', 'label': 'हिंदी'},
    {'id': 'en', 'label': 'English'},
    {'id': 'pa', 'label': 'ਪੰਜਾਬੀ'},
    {'id': 'mr', 'label': 'मराठी'},
  ];

  Future<void> _generate() async {
    if (_topicCtr.text.trim().isEmpty) {
      SnackHelper.error(context, 'Please enter a topic / विषय दर्ज करें');
      return;
    }
    setState(() {
      _loading = true;
      _result = null;
    });
    final messenger = ScaffoldMessenger.of(context);
    try {
      final res = await ApiClient.instance.post('/ai/lesson-plan', data: {
        'grade': int.parse(_grade),
        'subject': _subject,
        'topic': _topicCtr.text.trim(),
        'language': _language,
        'duration': 45,
      }).timeout(const Duration(seconds: 20));
      if (!mounted) return;
      setState(() {
        _result = res.data['data'];
        _loading = false;
      });
    } on TimeoutException {
      if (!mounted) return;
      setState(() => _loading = false);
      messenger.showSnackBar(
        const SnackBar(
            content: Text('AI response timed out. Please try again.')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      messenger.showSnackBar(
        const SnackBar(
            content: Text('Generation failed. Check internet / API key.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ── Form card ─────────────────────────────────────────
        AppCard(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('पाठ बनाएं',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
            const Text('Generate lesson plan',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
            const SizedBox(height: 16),

            // Grade + Subject row
            Row(children: [
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Grade / कक्षा',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.textSecondary)),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: _grade,
                        decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10)),
                        items: _grades
                            .map((g) => DropdownMenuItem(
                                value: g, child: Text('Class $g')))
                            .toList(),
                        onChanged: (v) => setState(() => _grade = v!),
                      ),
                    ]),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Subject / विषय',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.textSecondary)),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: _subject,
                        decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10)),
                        items: _subjects
                            .map((s) => DropdownMenuItem(
                                value: s,
                                child:
                                    Text(s, overflow: TextOverflow.ellipsis)))
                            .toList(),
                        onChanged: (v) => setState(() => _subject = v!),
                      ),
                    ]),
              ),
            ]),

            const SizedBox(height: 14),

            const Text('Topic / अध्याय',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 6),
            TextFormField(
              controller: _topicCtr,
              decoration: const InputDecoration(
                hintText: 'e.g. Fractions / भिन्न',
                prefixIcon: Icon(Icons.book_outlined,
                    color: AppColors.textMuted, size: 18),
              ),
            ),

            const SizedBox(height: 14),

            const Text('Language / भाषा',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _languages.map((l) {
                final sel = _language == l['id'];
                return GestureDetector(
                  onTap: () => setState(() => _language = l['id']!),
                  child: AnimatedContainer(
                    duration: 180.ms,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: sel ? AppColors.primary : AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: sel ? AppColors.primary : AppColors.border),
                    ),
                    child: Text(l['label']!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: sel ? Colors.white : AppColors.textPrimary,
                        )),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            AppButton(
              label: _loading ? 'AI सोच रहा है...' : '✨ AI से पाठ बनाएं',
              onPressed: _loading ? null : _generate,
              isLoading: _loading,
            ),
          ]),
        ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2),

        // ── AI Thinking animation ─────────────────────────────
        if (_loading) ...[
          const SizedBox(height: 24),
          _AiThinkingWidget(),
        ],

        // ── Result ────────────────────────────────────────────
        if (_result != null) ...[
          const SizedBox(height: 24),
          _LessonPlanResult(
            plan: _result!,
            grade: _grade,
            subject: _subject,
            onSavePlan: widget.onSavePlan,
          ),
        ],

        const SizedBox(height: 80),
      ]),
    );
  }

  @override
  void dispose() {
    _topicCtr.dispose();
    super.dispose();
  }
}

// ── AI Thinking Widget ────────────────────────────────────────────────────
class _AiThinkingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(children: [
        const SizedBox(height: 8),
        const Text('🤖', style: TextStyle(fontSize: 36))
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .scale(
                begin: const Offset(0.9, 0.9),
                end: const Offset(1.1, 1.1),
                duration: 800.ms),
        const SizedBox(height: 12),
        const Text('AI पाठ योजना बना रहा है...',
            style: TextStyle(
                fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        const Text('Generating lesson plan...',
            style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
        const SizedBox(height: 16),
        const LinearProgressIndicator(
          backgroundColor: AppColors.border,
          valueColor: AlwaysStoppedAnimation(AppColors.primary),
        ),
        const SizedBox(height: 8),
      ]),
    ).animate(onPlay: (c) => c.repeat()).shimmer(
        duration: 1500.ms, color: AppColors.primaryMint.withOpacity(0.3));
  }
}

// ── Lesson Plan Result ────────────────────────────────────────────────────
class _LessonPlanResult extends StatelessWidget {
  final Map<String, dynamic> plan;
  final String grade;
  final String subject;
  final Future<void> Function(Map<String, dynamic> plan) onSavePlan;
  const _LessonPlanResult({
    required this.plan,
    required this.grade,
    required this.subject,
    required this.onSavePlan,
  });

  @override
  Widget build(BuildContext context) {
    final sections = (plan['sections'] as List?) ?? [];
    final objectives = (plan['objectives'] as List?) ?? [];
    final materials = (plan['materials'] as List?) ?? [];
    final questions = (plan['assessment_questions'] as List?) ?? [];

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Header
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [AppColors.primary, Color(0xFF2D8653)]),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8)),
              child: const Text('AI Generated',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600)),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.save_outlined,
                  color: Colors.white, size: 20),
              onPressed: () =>
                  SnackHelper.success(context, 'Lesson plan saved!'),
            ),
            IconButton(
              icon: const Icon(Icons.share_outlined,
                  color: Colors.white, size: 20),
              onPressed: () {},
            ),
          ]),
          const SizedBox(height: 8),
          Text(plan['title'] ?? 'Lesson Plan',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700)),
        ]),
      ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.3),

      const SizedBox(height: 12),

      // Objectives
      if (objectives.isNotEmpty) ...[
        _ResultSection(
          icon: '🎯',
          title: 'उद्देश्य / Objectives',
          color: AppColors.primary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:
                objectives.map((o) => _BulletItem(text: o.toString())).toList(),
          ),
        ).animate().fadeIn(delay: 180.ms).slideY(begin: 0.2),
        const SizedBox(height: 10),
      ],

      // Materials
      if (materials.isNotEmpty) ...[
        _ResultSection(
          icon: '🧰',
          title: 'सामग्री / Materials',
          color: AppColors.saffron,
          child: Wrap(
            spacing: 8,
            runSpacing: 6,
            children: materials
                .map((m) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.saffronPale,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.saffron.withOpacity(0.3)),
                      ),
                      child: Text(m.toString(),
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.soil)),
                    ))
                .toList(),
          ),
        ).animate().fadeIn(delay: 240.ms).slideY(begin: 0.2),
        const SizedBox(height: 10),
      ],

      // Sections (timeline)
      _ResultSection(
        icon: '⏱',
        title: 'पाठ की रूपरेखा / Lesson Outline',
        color: AppColors.info,
        child: Column(
          children: sections.asMap().entries.map((e) {
            final s = e.value as Map<String, dynamic>;
            final activities = (s['activities'] as List?) ?? [];
            return _TimelineItem(
              index: e.key + 1,
              name: s['name']?.toString() ?? '',
              duration: s['duration_mins']?.toString() ?? '',
              activities: activities.map((a) => a.toString()).toList(),
              note: s['teacher_notes']?.toString() ?? '',
            );
          }).toList(),
        ),
      ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),

      const SizedBox(height: 10),

      // Homework
      if (plan['homework'] != null) ...[
        _ResultSection(
          icon: '📚',
          title: 'गृहकार्य / Homework',
          color: AppColors.soil,
          child: Text(plan['homework'].toString(),
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textPrimary, height: 1.5)),
        ).animate().fadeIn(delay: 360.ms).slideY(begin: 0.2),
        const SizedBox(height: 10),
      ],

      // Board notes
      if (plan['board_notes'] != null) ...[
        _ResultSection(
          icon: '📋',
          title: 'श्यामपट्ट नोट / Board Notes',
          color: AppColors.textSecondary,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0F0),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(plan['board_notes'].toString(),
                style: const TextStyle(
                    fontSize: 13, fontFamily: 'monospace', height: 1.6)),
          ),
        ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
        const SizedBox(height: 10),
      ],

      // Assessment questions
      if (questions.isNotEmpty) ...[
        _ResultSection(
          icon: '❓',
          title: 'मूल्यांकन प्रश्न / Assessment',
          color: AppColors.success,
          child: Column(
            children: questions
                .asMap()
                .entries
                .map((e) => _BulletItem(
                    text: '${e.key + 1}. ${e.value}', bullet: false))
                .toList(),
          ),
        ).animate().fadeIn(delay: 440.ms).slideY(begin: 0.2),
        const SizedBox(height: 10),
      ],

      // Actions
      Row(children: [
        Expanded(
          child: AppButton(
            label: 'Save Plan',
            icon: Icons.save_outlined,
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              final planToSave = <String, dynamic>{
                'title': plan['title']?.toString() ?? 'Untitled Plan',
                'subject': subject,
                'grade': 'Class $grade',
                'className': 'Class $grade',
                'notes': plan['board_notes']?.toString() ??
                    plan['notes']?.toString() ??
                    '',
                'createdBy': 'AI',
                'topic': plan['topic']?.toString() ?? '',
                'language': plan['language']?.toString() ?? '',
                'fullPlan': Map<String, dynamic>.from(plan),
                'savedAt': DateTime.now().toIso8601String(),
              };
              await onSavePlan(planToSave);
              if (!context.mounted) return;
              messenger.showSnackBar(
                const SnackBar(content: Text('✅ Plan saved to My Plans')),
              );
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: AppButton(
            label: 'Export PDF',
            icon: Icons.picture_as_pdf_outlined,
            outlined: true,
            onPressed: () {
              PdfService.exportLessonPlanPdf(
                title: plan['title']?.toString() ?? 'पाठ योजना (Lesson Plan)',
                grade: 'Class $grade',
                subject: subject,
                topic: plan['topic']?.toString() ?? plan['title']?.toString() ?? '',
                content: plan,
              );
            },
          ),
        ),
      ]).animate().fadeIn(delay: 500.ms).slideY(begin: 0.3),
    ]);
  }
}

class _ResultSection extends StatelessWidget {
  final String icon, title;
  final Color color;
  final Widget child;
  const _ResultSection(
      {required this.icon,
      required this.title,
      required this.color,
      required this.child});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Text(title,
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600, color: color)),
        ]),
        const SizedBox(height: 10),
        child,
      ]),
    );
  }
}

class _BulletItem extends StatelessWidget {
  final String text;
  final bool bullet;
  const _BulletItem({required this.text, this.bullet = true});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (bullet)
            Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.only(top: 6, right: 8),
                decoration: const BoxDecoration(
                    color: AppColors.primary, shape: BoxShape.circle)),
          Expanded(
              child: Text(text,
                  style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                      height: 1.5))),
        ]),
      );
}

class _TimelineItem extends StatelessWidget {
  final int index;
  final String name, duration, note;
  final List<String> activities;
  const _TimelineItem(
      {required this.index,
      required this.name,
      required this.duration,
      required this.activities,
      required this.note});

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Column(children: [
        Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
              color: AppColors.primary, shape: BoxShape.circle),
          child: Center(
              child: Text('$index',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700))),
        ),
        if (index < 4) Container(width: 2, height: 40, color: AppColors.border),
      ]),
      const SizedBox(width: 12),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(
                  child: Text(name,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                    color: AppColors.primaryPale,
                    borderRadius: BorderRadius.circular(10)),
                child: Text('$duration min',
                    style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500)),
              ),
            ]),
            if (activities.isNotEmpty) ...[
              const SizedBox(height: 4),
              ...activities.take(2).map((a) => Text('• $a',
                  style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.5))),
            ],
            if (note.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text('📌 $note',
                  style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                      fontStyle: FontStyle.italic)),
            ],
          ]),
        ),
      ),
    ]);
  }
}

// ── My Plans Tab ──────────────────────────────────────────────────────────
class _MyPlansTab extends StatefulWidget {
  final List<Map<String, dynamic>> plans;
  final Future<void> Function(Map<String, dynamic> plan) onUpdate;
  final Future<void> Function(String id) onDelete;

  const _MyPlansTab(
      {required this.plans, required this.onUpdate, required this.onDelete});

  @override
  State<_MyPlansTab> createState() => _MyPlansTabState();
}

class _MyPlansTabState extends State<_MyPlansTab> {
  @override
  Widget build(BuildContext context) {
    if (widget.plans.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('📝', style: TextStyle(fontSize: 36)),
            const SizedBox(height: 12),
            const Text('No saved plans yet',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text('Generate a lesson plan and save it here.',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
          ]),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: widget.plans.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final p = widget.plans[i];
        final title = p['title']?.toString() ?? 'Untitled Plan';
        final subject = p['subject']?.toString() ?? 'Subject';
        final grade = p['grade']?.toString() ?? 'Class';
        final savedAt = p['savedAt']?.toString();
        final ai = p['createdBy'] == 'AI' || p['ai'] == true;

        return AppCard(
          onTap: () => _openPlanDetails(context, p),
          child: Row(children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                  color: AppColors.primaryPale,
                  borderRadius: BorderRadius.circular(10)),
              child: const Center(
                  child: Text('📖', style: TextStyle(fontSize: 22))),
            ),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text('$subject · $grade',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                  Text(savedAt != null ? savedAt : 'Saved',
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textMuted)),
                ])),
            if (ai)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                    color: AppColors.primaryPale,
                    borderRadius: BorderRadius.circular(6)),
                child: const Text('AI',
                    style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary)),
              ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textMuted, size: 20),
          ]),
        )
            .animate(delay: Duration(milliseconds: i * 60))
            .fadeIn()
            .slideX(begin: 0.2);
      },
    );
  }

  Future<void> _openPlanDetails(
      BuildContext context, Map<String, dynamic> plan) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _PlanDetailSheet(
        plan: plan,
        onUpdate: widget.onUpdate,
        onDelete: widget.onDelete,
      ),
    );
  }
}

class _SavedPlanPreview extends StatelessWidget {
  final Map<String, dynamic> plan;

  const _SavedPlanPreview({required this.plan});

  @override
  Widget build(BuildContext context) {
    final sections = (plan['sections'] as List?) ?? [];
    final objectives = (plan['objectives'] as List?) ?? [];
    final questions = (plan['assessment_questions'] as List?) ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (plan['title'] != null) ...[
          Text(plan['title'].toString(),
              style:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
        ],
        if (objectives.isNotEmpty) ...[
          const Text('Objectives',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          ...objectives.take(3).map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('• $item',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
              )),
        ],
        if (sections.isNotEmpty) ...[
          const SizedBox(height: 6),
          const Text('Outline',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          ...sections.take(3).map((section) {
            final map = section as Map<String, dynamic>;
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '• ${map['name'] ?? 'Section'} (${map['duration_mins'] ?? ''} min)',
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary),
              ),
            );
          }),
        ],
        if (questions.isNotEmpty) ...[
          const SizedBox(height: 6),
          const Text('Assessment',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          ...questions.take(2).map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('• $item',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
              )),
        ],
      ],
    );
  }
}

class _PlanDetailSheet extends StatefulWidget {
  final Map<String, dynamic> plan;
  final Future<void> Function(Map<String, dynamic> plan) onUpdate;
  final Future<void> Function(String id) onDelete;

  const _PlanDetailSheet(
      {required this.plan, required this.onUpdate, required this.onDelete});

  @override
  State<_PlanDetailSheet> createState() => _PlanDetailSheetState();
}

class _PlanDetailSheetState extends State<_PlanDetailSheet> {
  late final TextEditingController _titleCtr;
  late final TextEditingController _subjectCtr;
  late final TextEditingController _gradeCtr;
  late final TextEditingController _notesCtr;

  @override
  void initState() {
    super.initState();
    _titleCtr =
        TextEditingController(text: widget.plan['title']?.toString() ?? '');
    _subjectCtr =
        TextEditingController(text: widget.plan['subject']?.toString() ?? '');
    _gradeCtr =
        TextEditingController(text: widget.plan['grade']?.toString() ?? '');
    _notesCtr =
        TextEditingController(text: widget.plan['notes']?.toString() ?? '');
  }

  @override
  void dispose() {
    _titleCtr.dispose();
    _subjectCtr.dispose();
    _gradeCtr.dispose();
    _notesCtr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      maxChildSize: 0.9,
      expand: false,
      builder: (_, controller) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: ListView(
          controller: controller,
          children: [
            Row(children: [
              Expanded(
                  child: Text(widget.plan['title']?.toString() ?? 'Saved Plan',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w700))),
              IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded)),
            ]),
            const SizedBox(height: 12),
            TextField(
              controller: _titleCtr,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _subjectCtr,
              decoration: const InputDecoration(labelText: 'Subject'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _gradeCtr,
              decoration: const InputDecoration(labelText: 'Grade'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _notesCtr,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Notes'),
            ),
            const SizedBox(height: 16),
            if (widget.plan['fullPlan'] != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryPale,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Saved lesson plan',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    _SavedPlanPreview(
                        plan: Map<String, dynamic>.from(
                            widget.plan['fullPlan'] as Map)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            AppButton(
              label: 'Save Changes',
              icon: Icons.edit_note_outlined,
              onPressed: () async {
                final navigator = Navigator.of(context);
                final updated = Map<String, dynamic>.from(widget.plan)
                  ..['title'] = _titleCtr.text.trim().isEmpty
                      ? 'Untitled Plan'
                      : _titleCtr.text.trim()
                  ..['subject'] = _subjectCtr.text.trim().isEmpty
                      ? 'Subject'
                      : _subjectCtr.text.trim()
                  ..['grade'] = _gradeCtr.text.trim().isEmpty
                      ? 'Class'
                      : _gradeCtr.text.trim()
                  ..['className'] = _gradeCtr.text.trim().isEmpty
                      ? 'Class'
                      : _gradeCtr.text.trim()
                  ..['notes'] = _notesCtr.text.trim();
                await widget.onUpdate(updated);
                if (!mounted) return;
                navigator.pop();
              },
            ),
            const SizedBox(height: 10),
            AppButton(
              label: 'Delete Plan',
              icon: Icons.delete_outline_rounded,
              outlined: true,
              color: AppColors.error,
              onPressed: () async {
                final navigator = Navigator.of(context);
                await widget.onDelete(widget.plan['id']?.toString() ?? '');
                if (!mounted) return;
                navigator.pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
