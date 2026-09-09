// ═══════════════════════════════════════════════════
// FILE 3/6: lib/features/parent/presentation/screens/parent_child_progress_screen.dart
// STATUS: NEW — create this file
// ═══════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_widgets.dart';

const parentPurple = Color(0xFF3C3489);
const parentLight = Color(0xFF5B52C9);

class ParentChildProgressScreen extends StatelessWidget {
  const ParentChildProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Present days in August (1-30 days)
    const presentDays = {
      1, 2, 3, 4, 7, 8, 9, 10, 11,
      14, 15, 16, 17, 18,
      21, 22, 23, 24, 25,
      28, 29, 30
    };

    // Subject performance mock data
    final subjects = [
      {'nameHi': 'गणित', 'nameEn': 'Math', 'score': 68, 'emoji': '🔢'},
      {'nameHi': 'हिंदी', 'nameEn': 'Hindi', 'score': 82, 'emoji': '📖'},
      {'nameHi': 'Science', 'nameEn': 'विज्ञान', 'score': 75, 'emoji': '🔬'},
      {'nameHi': 'EVS', 'nameEn': 'पर्यावरण', 'score': 90, 'emoji': '🌱'},
    ];

    // Recent quizzes mock data (TODO: replace with API)
    final recentQuizzes = [
      {'title': 'गणित Unit Test', 'score': 9, 'total': 10, 'date': '2 Aug'},
      {'title': 'हिंदी शब्दावली', 'score': 8, 'total': 10, 'date': '5 Aug'},
      {'title': 'Science Quiz', 'score': 5, 'total': 10, 'date': '7 Aug'},
    ];

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: parentPurple,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'बच्चे की प्रगति',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
            ),
            Text(
              'Child Progress',
              style: TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Child Hero Card
            Container(
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
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text('👦', style: TextStyle(fontSize: 24)),
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Rahul Kumar',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
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
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _HeroStatItem(label: 'Attendance', labelHi: 'उपस्थिति', value: '87%'),
                        _HeroStatItem(label: 'Avg Score', labelHi: 'औसत अंक', value: '74%'),
                        _HeroStatItem(label: 'Quizzes', labelHi: 'क्विज़', value: '12'),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 50.ms),

            const SizedBox(height: 24),

            // Attendance Section
            const SectionHeader(
              title: 'इस महीने उपस्थिति',
              subtitle: 'August Attendance',
            ).animate().fadeIn(delay: 100.ms),

            const SizedBox(height: 10),

            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        '87% उपस्थित',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.success,
                        ),
                      ),
                      Text(
                        '26/30 दिन',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Linear percent indicator
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      height: 10,
                      width: double.infinity,
                      color: AppColors.border,
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: 0.87,
                        child: Container(
                          color: AppColors.success,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'दैनिक उपस्थिति विवरण / Daily Record:',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 10),

                  // 30 Dots for days 1-30
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(30, (index) {
                      final day = index + 1;
                      final isFuture = day > 26;
                      final isPresent = presentDays.contains(day);

                      Color dotColor;
                      if (isFuture) {
                        dotColor = AppColors.border;
                      } else if (isPresent) {
                        dotColor = AppColors.success.withOpacity(0.8);
                      } else {
                        dotColor = AppColors.error.withOpacity(0.7);
                      }

                      return Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: dotColor,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '$day',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: isFuture ? AppColors.textMuted : Colors.white,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 14),
                  const Divider(height: 1),
                  const SizedBox(height: 10),

                  // Legend
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _LegendDot(color: AppColors.success.withOpacity(0.8), label: 'उपस्थित (Present)'),
                      const SizedBox(width: 16),
                      _LegendDot(color: AppColors.error.withOpacity(0.7), label: 'अनुपस्थित (Absent)'),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),

            const SizedBox(height: 24),

            // Subject Performance Section
            const SectionHeader(
              title: 'विषयवार प्रदर्शन',
              subtitle: 'Subject Performance',
            ).animate().fadeIn(delay: 250.ms),

            const SizedBox(height: 10),

            ...subjects.asMap().entries.map((entry) {
              final index = entry.key;
              final subj = entry.value;
              final score = subj['score'] as int;

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: AppCard(
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: parentPurple.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(subj['emoji'] as String, style: const TextStyle(fontSize: 20)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${subj['nameHi']} (${subj['nameEn']})',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  '$score%',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: parentPurple,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Container(
                                height: 6,
                                width: double.infinity,
                                color: AppColors.border,
                                child: FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: score / 100,
                                  child: Container(
                                    color: parentPurple,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate(
                delay: Duration(milliseconds: 300 + index * 60),
              ).fadeIn().slideX(begin: 0.2);
            }),

            const SizedBox(height: 24),

            // Recent Quizzes
            const SectionHeader(
              title: 'हाल की क्विज़',
              subtitle: 'Recent Quizzes',
            ).animate().fadeIn(delay: 450.ms),

            const SizedBox(height: 10),

            // List of 3 mock items (TODO: replace with API)
            ...recentQuizzes.asMap().entries.map((entry) {
              final index = entry.key;
              final q = entry.value;
              final score = q['score'] as int;
              final total = q['total'] as int;
              final isGood = score >= 7;

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: AppCard(
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isGood ? AppColors.success.withOpacity(0.1) : AppColors.warning.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            isGood ? Icons.star_rounded : Icons.star_half_rounded,
                            color: isGood ? AppColors.success : AppColors.warning,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              q['title'] as String,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              q['date'] as String,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isGood ? AppColors.success.withOpacity(0.12) : AppColors.warning.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isGood ? AppColors.success.withOpacity(0.3) : AppColors.warning.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          '$score / $total',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isGood ? AppColors.success : AppColors.warning,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate(
                delay: Duration(milliseconds: 500 + index * 60),
              ).fadeIn().slideX(begin: 0.2);
            }),

            const SizedBox(height: 24),

            // AI Suggestion Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: parentPurple.withOpacity(0.06),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
                border: const Border(
                  left: BorderSide(color: parentPurple, width: 4),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Text('🤖', style: TextStyle(fontSize: 18)),
                      SizedBox(width: 8),
                      Text(
                        'AI सुझाव',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: parentPurple,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Rahul को गणित में भिन्न पर अधिक अभ्यास चाहिए। रोज़ 10 मिनट practice करवाएं।',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => context.push('/parent/ai'),
                      icon: const Icon(Icons.arrow_forward_rounded, size: 16, color: parentPurple),
                      label: const Text(
                        'AI से पूछें →',
                        style: TextStyle(
                          color: parentPurple,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 650.ms).slideY(begin: 0.2),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _HeroStatItem extends StatelessWidget {
  final String label, labelHi, value;
  const _HeroStatItem({
    required this.label,
    required this.labelHi,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
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
          '$labelHi / $label',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
