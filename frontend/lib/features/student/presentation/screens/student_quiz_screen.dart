// ═══════════════════════════════════════════════════
// FILE 3/4: lib/features/student/presentation/screens/student_quiz_screen.dart
// STATUS: NEW — create this file
// ═══════════════════════════════════════════════════

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';

const studentBlue = Color(0xFF0C447C);
const studentLight = Color(0xFF1A6DB0);

enum _QuizView {
  list,
  attempt,
  result,
}

class StudentQuizScreen extends StatefulWidget {
  const StudentQuizScreen({super.key});

  @override
  State<StudentQuizScreen> createState() => _StudentQuizScreenState();
}

class _StudentQuizScreenState extends State<StudentQuizScreen> {
  _QuizView _view = _QuizView.list;

  // TODO: replace with API
  final List<Map<String, dynamic>> _quizzes = [
    {
      'id': 'q1',
      'title': 'गणित — भिन्न',
      'subject': 'Mathematics',
      'marks': 10,
      'duration': 20,
      'attempted': false,
      'questions': [
        {
          'question': '1/2 + 1/4 = ?',
          'type': 'mcq',
          'options': ['3/4', '1/2', '1', '2/4'],
          'correctIndex': 0,
        },
        {
          'question': '0.5 को भिन्न में लिखें',
          'type': 'mcq',
          'options': ['1/2', '1/5', '5/10', '1/4'],
          'correctIndex': 0,
        },
        {
          'question': '2/4 = 1/2 सत्य है?',
          'type': 'true_false',
          'options': ['सत्य (True)', 'असत्य (False)'],
          'correctIndex': 0,
        },
        {
          'question': '3/6 को सरल करें',
          'type': 'mcq',
          'options': ['1/2', '1/3', '2/3', '3/3'],
          'correctIndex': 0,
        },
        {
          'question': 'कौन सी भिन्न सबसे बड़ी है?',
          'type': 'mcq',
          'options': ['1/4', '1/2', '1/3', '1/6'],
          'correctIndex': 1,
        },
      ],
    },
    {
      'id': 'q2',
      'title': 'हिंदी — संज्ञा',
      'subject': 'Hindi',
      'marks': 10,
      'duration': 15,
      'attempted': true,
      'score': 8,
      'questions': [],
    },
    {
      'id': 'q3',
      'title': 'Science — Plants',
      'subject': 'Science',
      'marks': 10,
      'duration': 20,
      'attempted': false,
      'questions': [
        {
          'question': 'पौधे भोजन बनाने के लिए किसका उपयोग करते हैं?',
          'type': 'mcq',
          'options': ['प्रकाश संश्लेषण', 'श्वसन', 'वाष्पोत्सर्जन', 'पाचन'],
          'correctIndex': 0,
        },
        {
          'question': 'पत्तियों का हरा रंग क्लोरोफिल के कारण होता है।',
          'type': 'true_false',
          'options': ['सत्य (True)', 'असत्य (False)'],
          'correctIndex': 0,
        },
      ],
    },
  ];

  Map<String, dynamic>? _activeQuiz;
  int _currentQ = 0;
  List<int?> _selectedAnswers = [];
  Timer? _timer;
  int _remainingSeconds = 0;
  int _latestScore = 0;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startQuiz(Map<String, dynamic> quiz) {
    final questions = quiz['questions'] as List<dynamic>? ?? [];
    if (questions.isEmpty) return;

    setState(() {
      _activeQuiz = quiz;
      _currentQ = 0;
      _selectedAnswers = List<int?>.filled(questions.length, null);
      _remainingSeconds = (quiz['duration'] as int) * 60;
      _view = _QuizView.attempt;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timer?.cancel();
        _submitQuiz();
      }
    });
  }

  void _cancelAttempt() {
    _timer?.cancel();
    setState(() {
      _view = _QuizView.list;
      _activeQuiz = null;
      _selectedAnswers = [];
      _currentQ = 0;
    });
  }

  void _submitQuiz() {
    _timer?.cancel();
    if (_activeQuiz == null) return;

    final questions = _activeQuiz!['questions'] as List<dynamic>;
    int correctCount = 0;
    for (int i = 0; i < questions.length; i++) {
      final q = questions[i] as Map<String, dynamic>;
      final correct = q['correctIndex'] as int;
      if (_selectedAnswers[i] == correct) {
        correctCount++;
      }
    }

    final totalMarks = _activeQuiz!['marks'] as int;
    final pointsPerQ = totalMarks / questions.length;
    final score = (correctCount * pointsPerQ).round();

    setState(() {
      _latestScore = score;
      _activeQuiz!['attempted'] = true;
      _activeQuiz!['score'] = score;
      _view = _QuizView.result;
    });
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String _getEmoji(String subject) {
    switch (subject.toLowerCase()) {
      case 'mathematics':
      case 'maths':
        return '🔢';
      case 'hindi':
        return '📖';
      case 'science':
        return '🔬';
      default:
        return '📝';
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (_view) {
      case _QuizView.list:
        return _buildQuizList();
      case _QuizView.attempt:
        return _buildQuizAttempt();
      case _QuizView.result:
        return _buildQuizResult();
    }
  }

  // ── 1. QUIZ LIST VIEW ──────────────────────────────────────────────────
  Widget _buildQuizList() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: studentBlue,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'क्विज़',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Quizzes',
              style: TextStyle(
                fontSize: 11,
                color: Colors.white70,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _quizzes.length,
        itemBuilder: (context, i) {
          final quiz = _quizzes[i];
          final bool attempted = quiz['attempted'] == true;
          final String emoji = _getEmoji(quiz['subject'] as String);

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AppCard(
              color: attempted ? AppColors.surface : AppColors.surfaceCard,
              onTap: () {
                if (attempted) {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text(
                        quiz['title'] as String,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      content: Text(
                        'आपका स्कोर: ${quiz['score']}/${quiz['marks']} अंक\nYour Score: ${quiz['score']}/${quiz['marks']} marks',
                        style: const TextStyle(fontSize: 14, height: 1.5),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text(
                            'ঠিক है / OK',
                            style: TextStyle(color: studentBlue, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  _startQuiz(quiz);
                }
              },
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: studentBlue.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      emoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          quiz['title'] as String,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: attempted ? AppColors.textSecondary : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              quiz['subject'] as String,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textMuted,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '• ${quiz['duration']} min',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: attempted
                          ? AppColors.success.withOpacity(0.1)
                          : studentBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      attempted ? '${quiz['score']}/${quiz['marks']} ✅' : 'नया',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: attempted ? AppColors.success : studentBlue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ).animate(
            delay: Duration(milliseconds: 100 + i * 60),
          ).fadeIn().slideX(begin: 0.2);
        },
      ),
    );
  }

  // ── 2. QUIZ ATTEMPT VIEW ───────────────────────────────────────────────
  Widget _buildQuizAttempt() {
    if (_activeQuiz == null) return const SizedBox();

    final questions = _activeQuiz!['questions'] as List<dynamic>;
    final q = questions[_currentQ] as Map<String, dynamic>;
    final totalQ = questions.length;
    final isLast = _currentQ == totalQ - 1;
    final isMcq = q['type'] == 'mcq';
    final options = q['options'] as List<dynamic>;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: studentBlue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: _cancelAttempt,
        ),
        title: Text(
          _activeQuiz!['title'] as String,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.timer_outlined, color: Colors.white, size: 16),
                const SizedBox(width: 4),
                Text(
                  _formatTime(_remainingSeconds),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: (_currentQ + 1) / totalQ,
            backgroundColor: AppColors.border,
            color: studentBlue,
            minHeight: 4,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question Counter
                  Text(
                    'प्रश्न ${_currentQ + 1} / $totalQ',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
                    ),
                  ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
                  const SizedBox(height: 10),

                  // Question Card
                  AppCard(
                    child: Text(
                      q['question'] as String,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3),
                  const SizedBox(height: 20),

                  // Options
                  if (isMcq)
                    ...List.generate(options.length, (optIdx) {
                      final optText = options[optIdx] as String;
                      final isSelected = _selectedAnswers[_currentQ] == optIdx;
                      final letter = String.fromCharCode(65 + optIdx); // A, B, C, D

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedAnswers[_currentQ] = optIdx;
                            });
                          },
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? studentBlue.withOpacity(0.1)
                                  : AppColors.surfaceCard,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected ? studentBlue : AppColors.border,
                                width: isSelected ? 1.5 : 1.0,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 28,
                                  height: 28,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? studentBlue
                                        : AppColors.surface,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected ? studentBlue : AppColors.border,
                                    ),
                                  ),
                                  child: Text(
                                    letter,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected ? Colors.white : AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    optText,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w400,
                                      color: isSelected ? studentBlue : AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ).animate(
                        delay: Duration(milliseconds: 100 + optIdx * 60),
                      ).fadeIn().slideX(begin: 0.2);
                    })
                  else
                    // True / False buttons
                    Row(
                      children: List.generate(options.length, (optIdx) {
                        final optText = options[optIdx] as String;
                        final isSelected = _selectedAnswers[_currentQ] == optIdx;

                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: optIdx == 0 ? 6 : 0,
                              left: optIdx == 1 ? 6 : 0,
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isSelected ? studentBlue : AppColors.surfaceCard,
                                foregroundColor: isSelected ? Colors.white : AppColors.textPrimary,
                                side: BorderSide(
                                  color: isSelected ? studentBlue : AppColors.border,
                                  width: 1.5,
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                setState(() {
                                  _selectedAnswers[_currentQ] = optIdx;
                                });
                              },
                              child: Text(
                                optText,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? Colors.white : AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.2),
                ],
              ),
            ),
          ),

          // Bottom navigation buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.surfaceCard,
              border: Border(
                top: BorderSide(color: AppColors.border, width: 0.5),
              ),
            ),
            child: Row(
              children: [
                if (_currentQ > 0)
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: studentBlue,
                        side: const BorderSide(color: studentBlue),
                        minimumSize: const Size(0, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _currentQ--;
                        });
                      },
                      child: const Text('पीछे'),
                    ),
                  )
                else
                  const Spacer(),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    label: isLast ? 'Submit / जमा करें' : 'अगला →',
                    color: studentBlue,
                    onPressed: () {
                      if (isLast) {
                        _submitQuiz();
                      } else {
                        setState(() {
                          _currentQ++;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3),
        ],
      ),
    );
  }

  // ── 3. QUIZ RESULT VIEW ───────────────────────────────────────────────
  Widget _buildQuizResult() {
    final totalMarks = _activeQuiz?['marks'] as int? ?? 10;
    final double percent = (_latestScore / totalMarks).clamp(0.0, 1.0);
    final int scorePercentInt = (percent * 100).round();

    Color color;
    String labelText;
    if (percent >= 0.7) {
      color = AppColors.success;
      labelText = 'शानदार! 🎉 / Excellent!';
    } else if (percent >= 0.5) {
      color = AppColors.warning;
      labelText = 'अच्छा! 👍 / Good job!';
    } else {
      color = AppColors.error;
      labelText = 'फिर कोशिश करें 💪 / Try again';
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _cancelAttempt();
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                CircularPercentIndicator(
                  radius: 80.0,
                  lineWidth: 12.0,
                  percent: percent,
                  animation: true,
                  animationDuration: 1000,
                  progressColor: color,
                  backgroundColor: AppColors.border,
                  circularStrokeCap: CircularStrokeCap.round,
                  center: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$_latestScore/$totalMarks',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Text(
                        'अंक / Marks',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
                const SizedBox(height: 24),

                Text(
                  labelText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
                const SizedBox(height: 8),

                Text(
                  '$_latestScore/$totalMarks marks',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ).animate().fadeIn(delay: 300.ms),

                Text(
                  '$scorePercentInt% score',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ).animate().fadeIn(delay: 350.ms),

                const Spacer(),

                AppButton(
                  label: 'वापस जाएं / Back to Quizzes',
                  color: studentBlue,
                  onPressed: () {
                    setState(() {
                      _view = _QuizView.list;
                      _activeQuiz = null;
                    });
                  },
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
