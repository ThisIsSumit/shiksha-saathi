// ═══════════════════════════════════════════════════
// FILE 3/6: lib/features/teacher/presentation/screens/teacher_students_screen.dart
// STATUS: NEW — create this file
// ═══════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_card.dart';

const teacherGreen = Color(0xFF166534);
const teacherLight = Color(0xFF22C55E);

class TeacherStudentsScreen extends StatefulWidget {
  const TeacherStudentsScreen({super.key});

  @override
  State<TeacherStudentsScreen> createState() => _TeacherStudentsScreenState();
}

class _TeacherStudentsScreenState extends State<TeacherStudentsScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String _selectedClass = 'All';

  final List<String> _classes = const [
    'All',
    'Class 3-A',
    'Class 4-A',
    'Class 5-A',
  ];

  // TODO API: replace mock student roster with API endpoint response
  final List<Map<String, dynamic>> _students = const [
    {
      'id': 's1',
      'name': 'Rahul Kumar',
      'class': 'Class 4-A',
      'roll': '03',
      'attendance': 87,
      'averageScore': 74,
      'recentQuiz': '8/10 (Maths Fractions)',
      'recentHomework': 'Completed / पूर्ण',
      'strength': 'गणित में अच्छा (Good in Maths)',
      'improvement': 'हिंदी शब्दावली (Hindi Vocabulary)',
    },
    {
      'id': 's2',
      'name': 'Priya Singh',
      'class': 'Class 4-A',
      'roll': '12',
      'attendance': 95,
      'averageScore': 88,
      'recentQuiz': '9/10 (Hindi Vyakaran)',
      'recentHomework': 'Completed / पूर्ण',
      'strength': 'हिंदी और विज्ञान (Hindi & Science)',
      'improvement': 'अंग्रेजी उच्चारण (English Pronunciation)',
    },
    {
      'id': 's3',
      'name': 'Amit Patel',
      'class': 'Class 4-A',
      'roll': '01',
      'attendance': 68,
      'averageScore': 58,
      'recentQuiz': '5/10 (Science Plants)',
      'recentHomework': 'Pending / लंबित',
      'strength': 'खेलकूद और EVS (Sports & EVS)',
      'improvement': 'नियमित उपस्थिति (Regular Attendance)',
    },
    {
      'id': 's4',
      'name': 'Suman Verma',
      'class': 'Class 3-A',
      'roll': '08',
      'attendance': 92,
      'averageScore': 82,
      'recentQuiz': '8/10 (Basic Maths)',
      'recentHomework': 'Completed / पूर्ण',
      'strength': 'संख्यात्मक क्षमता (Numeracy)',
      'improvement': 'लेखन गति (Writing Speed)',
    },
    {
      'id': 's5',
      'name': 'Vikas Sharma',
      'class': 'Class 5-A',
      'roll': '15',
      'attendance': 78,
      'averageScore': 64,
      'recentQuiz': '6/10 (Social Studies)',
      'recentHomework': 'Completed / पूर्ण',
      'strength': 'सृजनात्मकता (Creativity)',
      'improvement': 'गणित प्रमेय (Maths Theorems)',
    },
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredStudents {
    return _students.where((s) {
      final name = (s['name'] as String).toLowerCase();
      final roll = s['roll'] as String;
      final cls = s['class'] as String;
      final q = _searchQuery.toLowerCase().trim();

      final matchesQuery = q.isEmpty ||
          name.contains(q) ||
          roll.contains(q) ||
          cls.toLowerCase().contains(q);

      final matchesClass =
          _selectedClass == 'All' || cls == _selectedClass;

      return matchesQuery && matchesClass;
    }).toList();
  }

  void _showStudentDetailsDialog(Map<String, dynamic> student) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: teacherGreen,
              child: Text(
                (student['name'] as String)[0],
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student['name'] as String,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${student['class']} • Roll ${student['roll']}',
                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Divider(color: AppColors.border),
              _detailRow('उपस्थिति / Attendance', '${student['attendance']}%'),
              _detailRow('औसत स्कोर / Avg Score', '${student['averageScore']}%'),
              _detailRow('हाल का क्विज़ / Recent Quiz', student['recentQuiz'] as String),
              _detailRow('गृहकार्य / Homework', student['recentHomework'] as String),
              const SizedBox(height: 10),
              const Text(
                'मजबूती / Strength:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: teacherGreen),
              ),
              Text(
                student['strength'] as String,
                style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              const Text(
                'सुधार की आवश्यकता / Needs Improvement:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.error),
              ),
              Text(
                student['improvement'] as String,
                style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'बंद करें / Close',
              style: TextStyle(color: teacherGreen, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = _filteredStudents;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: teacherGreen,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'छात्र',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Students',
              style: TextStyle(
                fontSize: 11,
                color: Colors.white70,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // 1. Search Bar & Class Selector Header
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.surfaceCard,
            child: Column(
              children: [
                TextField(
                  controller: _searchCtrl,
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                  style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'छात्र का नाम खोजें... / Search student...',
                    hintStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    fillColor: AppColors.surface,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: teacherGreen, width: 1.5),
                    ),
                  ),
                ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
                const SizedBox(height: 12),

                // Horizontal Class Selector Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(_classes.length, (i) {
                      final c = _classes[i];
                      final isSelected = _selectedClass == c;

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(
                            c == 'All' ? 'सभी / All' : c,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? Colors.white : AppColors.textPrimary,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: teacherGreen,
                          backgroundColor: AppColors.surface,
                          side: BorderSide(
                            color: isSelected ? teacherGreen : AppColors.border,
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedClass = c;
                              });
                            }
                          },
                        ),
                      );
                    }),
                  ),
                ).animate().fadeIn(delay: 150.ms),
              ],
            ),
          ),

          // 2. Student List
          Expanded(
            child: list.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('👨‍🎓', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 12),
                        const Text(
                          'कोई छात्र नहीं मिला',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'No students found',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ).animate().scale(duration: 300.ms),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: list.length,
                    itemBuilder: (context, i) {
                      final student = list[i];
                      final int att = student['attendance'] as int;
                      final int avg = student['averageScore'] as int;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: AppCard(
                          onTap: () => _showStudentDetailsDialog(student),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 22,
                                    backgroundColor: teacherGreen.withOpacity(0.12),
                                    child: Text(
                                      (student['name'] as String)[0],
                                      style: const TextStyle(
                                        color: teacherGreen,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          student['name'] as String,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${student['class']} • Roll ${student['roll']}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.chevron_right_rounded,
                                    color: AppColors.textMuted,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text(
                                              'Attendance: ',
                                              style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                                            ),
                                            Text(
                                              '$att%',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: att >= 75 ? AppColors.success : AppColors.error,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        LinearProgressIndicator(
                                          value: att / 100.0,
                                          backgroundColor: AppColors.border,
                                          color: att >= 75 ? AppColors.success : AppColors.error,
                                          minHeight: 4,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text(
                                              'Average: ',
                                              style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                                            ),
                                            Text(
                                              '$avg%',
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: teacherGreen,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        LinearProgressIndicator(
                                          value: avg / 100.0,
                                          backgroundColor: AppColors.border,
                                          color: teacherGreen,
                                          minHeight: 4,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ).animate(
                        delay: Duration(milliseconds: 100 + i * 60),
                      ).fadeIn().slideX(begin: 0.2);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
