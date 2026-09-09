import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/stat_chip.dart';

class StudentProgressScreen extends StatefulWidget {
  const StudentProgressScreen({super.key});

  @override
  State<StudentProgressScreen> createState() => _StudentProgressScreenState();
}

class _StudentProgressScreenState extends State<StudentProgressScreen> {
  bool _loading = true;
  List<dynamic> _progressList = [];

  final List<Map<String, dynamic>> _badges = [
    {'icon': '🔥', 'title': '7-Day Streak', 'desc': '7 दिन लगातार पढ़ाई', 'unlocked': true},
    {'icon': '🎯', 'title': 'Quiz Master', 'desc': '10 क्विज़ पूरे किए', 'unlocked': true},
    {'icon': '⭐', 'title': 'Math Star', 'desc': 'गणित में 90%+ अंक', 'unlocked': true},
    {'icon': '🏆', 'title': 'Top 5 Rank', 'desc': 'कक्षा में शीर्ष 5', 'unlocked': false},
    {'icon': '📚', 'title': 'Book Worm', 'desc': '20 पाठ पूर्ण', 'unlocked': false},
  ];

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    setState(() => _loading = true);
    try {
      final res = await ApiClient.instance.get('/student/progress');
      if (mounted && res.data is Map && res.data['data'] is List) {
        setState(() {
          _progressList = res.data['data'] as List;
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
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.studentColor,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('मेरी प्रगति', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            Text('My Learning Progress', style: TextStyle(fontSize: 11, color: Colors.white70)),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadProgress,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Overall mastery card
                  AppCard(
                    child: Row(
                      children: [
                        CircularPercentIndicator(
                          radius: 46,
                          lineWidth: 9,
                          percent: 0.78,
                          center: const Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('78%', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.studentColor)),
                              Text('Overall', style: TextStyle(fontSize: 9, color: AppColors.textMuted)),
                            ],
                          ),
                          progressColor: AppColors.studentColor,
                          backgroundColor: AppColors.border,
                          circularStrokeCap: CircularStrokeCap.round,
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'शानदार प्रदर्शन! 🌟',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'आप अपनी कक्षा में शीर्ष 10% विद्यार्थियों में हैं।',
                                style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.3),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryPale,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  '+12% improvement this month',
                                  style: TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2),

                  const SizedBox(height: 16),

                  // Stat chips
                  Row(
                    children: [
                      StatChip(
                        value: '24',
                        label: 'पाठ पूरे किए',
                        labelEn: 'Lessons',
                        icon: Icons.menu_book_rounded,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 10),
                      StatChip(
                        value: '18',
                        label: 'क्विज़ हल किए',
                        labelEn: 'Quizzes',
                        icon: Icons.quiz_rounded,
                        color: AppColors.studentColor,
                      ),
                      const SizedBox(width: 10),
                      StatChip(
                        value: '420',
                        label: 'अंक (Points)',
                        labelEn: 'Points',
                        icon: Icons.stars_rounded,
                        color: AppColors.saffron,
                      ),
                    ],
                  ).animate().fadeIn(delay: 180.ms).slideY(begin: 0.2),

                  const SizedBox(height: 24),

                  // Subject-wise Breakdown
                  SectionHeader(title: 'विषयवार स्थिति', subtitle: 'Subject Breakdown'),
                  const SizedBox(height: 12),
                  ...[
                    {'name': 'गणित (Mathematics)', 'score': 0.72, 'color': AppColors.studentColor, 'strong': 'जोड़ व घटाव', 'weak': 'भिन्न (Fractions)'},
                    {'name': 'हिंदी (Hindi)', 'score': 0.86, 'color': AppColors.primary, 'strong': 'व्याकरण व गद्य', 'weak': 'पर्यायवाची शब्द'},
                    {'name': 'विज्ञान (Science)', 'score': 0.78, 'color': AppColors.success, 'strong': 'सजीव व निर्जीव', 'weak': 'पौधों के भाग'},
                    {'name': 'पर्यावरण (EVS)', 'score': 0.90, 'color': AppColors.saffron, 'strong': 'हमारा परिवार', 'weak': 'जल चक्र'},
                  ].asMap().entries.map((e) {
                    final item = e.value;
                    final score = (item['score'] as double);
                    final color = item['color'] as Color;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceCard,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border, width: 0.6),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(item['name'] as String, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                              Text('${(score * 100).toInt()}%', style: TextStyle(fontWeight: FontWeight.w700, color: color, fontSize: 13)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          LinearPercentIndicator(
                            percent: score,
                            lineHeight: 7,
                            backgroundColor: AppColors.border,
                            progressColor: color,
                            barRadius: const Radius.circular(4),
                            padding: EdgeInsets.zero,
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    const Icon(Icons.check_circle_outline, color: AppColors.success, size: 14),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        'मजबूत: ${item['strong']}',
                                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  children: [
                                    const Icon(Icons.priority_high_rounded, color: AppColors.warning, size: 14),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        'सुधार: ${item['weak']}',
                                        style: const TextStyle(fontSize: 11, color: AppColors.warning),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ).animate(delay: Duration(milliseconds: 250 + e.key * 70)).fadeIn().slideX(begin: 0.15);
                  }),

                  const SizedBox(height: 24),

                  // Badges & Achievements
                  SectionHeader(title: 'उपलब्धियां व मेडल', subtitle: 'Badges & Achievements'),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 125,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _badges.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (_, i) {
                        final b = _badges[i];
                        final unlocked = b['unlocked'] as bool;
                        return Container(
                          width: 110,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: unlocked ? AppColors.surfaceCard : AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: unlocked ? AppColors.saffron.withOpacity(0.5) : AppColors.border,
                              width: unlocked ? 1.2 : 0.6,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(b['icon'] as String, style: TextStyle(fontSize: 26, color: unlocked ? null : Colors.grey)),
                              const SizedBox(height: 6),
                              Text(
                                b['title'] as String,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: unlocked ? AppColors.textPrimary : AppColors.textMuted,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                b['desc'] as String,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 9, color: AppColors.textMuted),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ).animate().fadeIn(delay: 450.ms),

                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }
}
