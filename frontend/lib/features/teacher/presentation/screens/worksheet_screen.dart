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

class WorksheetScreen extends StatefulWidget {
  const WorksheetScreen({super.key});
  @override
  State<WorksheetScreen> createState() => _WorksheetScreenState();
}

class _WorksheetScreenState extends State<WorksheetScreen> {
  String _grade = '4';
  String _subject = 'Mathematics';
  String _lang = 'hi';
  int _qCount = 10;
  final _topicCtr = TextEditingController();
  bool _loading = false;
  Map<String, dynamic>? _worksheet;
  String? _editingWorksheetId;
  final List<Map<String, dynamic>> _savedWorksheets = [];

  final _grades = ['1', '2', '3', '4', '5', '6', '7', '8'];
  final _subjects = [
    'Mathematics',
    'Hindi',
    'English',
    'Science',
    'Social Science',
    'EVS'
  ];
  final _langs = [
    {'id': 'hi', 'label': 'हिंदी'},
    {'id': 'en', 'label': 'English'},
    {'id': 'pa', 'label': 'ਪੰਜਾਬੀ'},
  ];

  @override
  void initState() {
    super.initState();
    _loadSavedWorksheets();
  }

  Future<void> _loadSavedWorksheets() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList('saved_worksheets') ?? [];
    if (!mounted) return;
    setState(() {
      _savedWorksheets.clear();
      _savedWorksheets.addAll(raw.map((entry) {
        final decoded = jsonDecode(entry);
        return Map<String, dynamic>.from(decoded as Map);
      }).toList());
    });
  }

  Future<void> _persistSavedWorksheets() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'saved_worksheets',
      _savedWorksheets.map((worksheet) => jsonEncode(worksheet)).toList(),
    );
  }

  Future<void> _saveWorksheet() async {
    if (_worksheet == null) {
      SnackHelper.error(context, 'Generate a worksheet first.');
      return;
    }

    final id =
        _editingWorksheetId ?? DateTime.now().millisecondsSinceEpoch.toString();
    final record = <String, dynamic>{
      'id': id,
      'title': _worksheet!['title']?.toString() ?? 'Worksheet',
      'grade': 'Class $_grade',
      'subject': _subject,
      'topic': _topicCtr.text.trim(),
      'questionCount': _qCount,
      'language': _lang,
      'savedAt': DateTime.now().toIso8601String(),
      'fullWorksheet': Map<String, dynamic>.from(_worksheet!),
    };

    final existingIndex =
        _savedWorksheets.indexWhere((item) => item['id'] == id);
    if (existingIndex >= 0) {
      _savedWorksheets[existingIndex] = record;
    } else {
      _savedWorksheets.insert(0, record);
    }

    await _persistSavedWorksheets();
    if (!mounted) return;
    setState(() {
      _editingWorksheetId = id;
    });
    SnackHelper.success(context, '✅ Worksheet saved!');
  }

  void _loadWorksheetRecord(Map<String, dynamic> record) {
    setState(() {
      _editingWorksheetId = record['id']?.toString();
      _worksheet = Map<String, dynamic>.from(record['fullWorksheet'] as Map);
      _topicCtr.text = record['topic']?.toString() ?? '';
      _qCount = int.tryParse(record['questionCount']?.toString() ?? '10') ?? 10;
      _subject = record['subject']?.toString() ?? _subject;
      _lang = record['language']?.toString() ?? _lang;
      final gradeText = record['grade']?.toString() ?? 'Class 4';
      _grade = gradeText.replaceFirst('Class ', '');
    });
    SnackHelper.info(context, 'Loaded worksheet for editing.');
  }

  Future<void> _deleteWorksheet(String id) async {
    _savedWorksheets.removeWhere((item) => item['id'] == id);
    await _persistSavedWorksheets();
    if (!mounted) return;
    setState(() {
      if (_editingWorksheetId == id) {
        _editingWorksheetId = null;
        _worksheet = null;
      }
    });
  }

  Future<void> _generate() async {
    if (_topicCtr.text.trim().isEmpty) {
      SnackHelper.error(context, 'Enter topic / विषय लिखें');
      return;
    }
    setState(() {
      _loading = true;
      _worksheet = null;
    });
    try {
      final res = await ApiClient.instance.post('/ai/worksheet', data: {
        'grade': int.parse(_grade),
        'subject': _subject,
        'topic': _topicCtr.text.trim(),
        'questionCount': _qCount,
        'language': _lang,
      });
      setState(() {
        _worksheet = res.data['data'];
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted)
        SnackHelper.error(context, 'Failed to generate. Check internet.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('कार्यपत्रक',
                style: TextStyle(fontSize: 16, color: Colors.white)),
            Text('Worksheet Builder',
                style: TextStyle(
                    fontSize: 11,
                    color: Colors.white70,
                    fontWeight: FontWeight.w400)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Config card
          AppCard(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('✏️  Generate Worksheet',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),

              Row(children: [
                Expanded(
                    child: _DropdownField(
                  label: 'Grade',
                  value: _grade,
                  items: _grades,
                  display: (v) => 'Class $v',
                  onChanged: (v) => setState(() => _grade = v!),
                )),
                const SizedBox(width: 12),
                Expanded(
                    child: _DropdownField(
                  label: 'Subject',
                  value: _subject,
                  items: _subjects,
                  onChanged: (v) => setState(() => _subject = v!),
                )),
              ]),

              const SizedBox(height: 14),

              TextFormField(
                controller: _topicCtr,
                decoration: const InputDecoration(
                  labelText: 'Topic / अध्याय',
                  hintText: 'e.g. Addition, भिन्न, Plants',
                  prefixIcon: Icon(Icons.topic_outlined,
                      size: 18, color: AppColors.textMuted),
                ),
              ),

              const SizedBox(height: 14),

              // Question count slider
              Row(children: [
                const Text('Questions: ',
                    style: TextStyle(
                        fontSize: 13, color: AppColors.textSecondary)),
                Text('$_qCount',
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary)),
              ]),
              Slider(
                value: _qCount.toDouble(),
                min: 5,
                max: 20,
                divisions: 15,
                activeColor: AppColors.primary,
                onChanged: (v) => setState(() => _qCount = v.toInt()),
              ),

              // Language
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: _langs.map((l) {
                  final sel = _lang == l['id'];
                  return GestureDetector(
                    onTap: () => setState(() => _lang = l['id']!),
                    child: AnimatedContainer(
                      duration: 180.ms,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: sel ? AppColors.primary : AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
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

              const SizedBox(height: 16),

              AppButton(
                label: _loading ? 'Generating...' : '✨ Generate Worksheet',
                onPressed: _loading ? null : _generate,
                isLoading: _loading,
              ),
            ]),
          ).animate().fadeIn().slideY(begin: 0.2),

          if (_loading) ...[
            const SizedBox(height: 20),
            const _LoadingCard(),
          ],

          if (_worksheet != null) ...[
            const SizedBox(height: 20),
            _WorksheetPreview(
              ws: _worksheet!,
              onSave: _saveWorksheet,
            ),
          ],

          if (_savedWorksheets.isNotEmpty) ...[
            const SizedBox(height: 20),
            _SavedWorksheetsList(
              worksheets: _savedWorksheets,
              onLoad: _loadWorksheetRecord,
              onDelete: _deleteWorksheet,
            ),
          ],

          const SizedBox(height: 80),
        ]),
      ),
    );
  }

  @override
  void dispose() {
    _topicCtr.dispose();
    super.dispose();
  }
}

class _DropdownField<T> extends StatelessWidget {
  final String label, value;
  final List<T> items;
  final void Function(T?) onChanged;
  final String Function(T)? display;

  const _DropdownField(
      {required this.label,
      required this.value,
      required this.items,
      required this.onChanged,
      this.display});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      const SizedBox(height: 6),
      DropdownButtonFormField<T>(
        value: value as T,
        decoration: const InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
        items: items
            .map((i) => DropdownMenuItem(
                value: i,
                child: Text(display != null ? display!(i) : i.toString(),
                    overflow: TextOverflow.ellipsis)))
            .toList(),
        onChanged: onChanged,
      ),
    ]);
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();
  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(children: [
        const Text('📝', style: TextStyle(fontSize: 32))
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .moveY(
                begin: 0, end: -6, duration: 600.ms, curve: Curves.easeInOut),
        const SizedBox(height: 12),
        const Text('प्रश्न बनाए जा रहे हैं...',
            style: TextStyle(fontWeight: FontWeight.w600)),
        const Text('Creating questions...',
            style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
        const SizedBox(height: 14),
        const LinearProgressIndicator(
          backgroundColor: AppColors.border,
          valueColor: AlwaysStoppedAnimation(AppColors.saffron),
        ),
        const SizedBox(height: 4),
      ]),
    );
  }
}

class _WorksheetPreview extends StatelessWidget {
  final Map<String, dynamic> ws;
  final VoidCallback onSave;
  const _WorksheetPreview({required this.ws, required this.onSave});

  @override
  Widget build(BuildContext context) {
    final questions = (ws['questions'] as List?) ?? [];
    final typeColors = {
      'mcq': AppColors.primary,
      'fill_blank': AppColors.saffron,
      'short_answer': AppColors.success,
      'true_false': AppColors.info,
    };
    final typeLabels = {
      'mcq': 'MCQ',
      'fill_blank': 'Fill Blank',
      'short_answer': 'Short',
      'true_false': 'T/F',
    };

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Header
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xFF7B4F2E), Color(0xFF9B6748)]),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
                child: Text(ws['title'] ?? 'Worksheet',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8)),
              child: Text('${questions.length} Qs',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600)),
            ),
          ]),
          const SizedBox(height: 6),
          Text(ws['instructions'] ?? '',
              style: TextStyle(
                  color: Colors.white.withOpacity(0.8), fontSize: 12)),
        ]),
      ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.3),

      const SizedBox(height: 12),

      // Question type summary chips
      Wrap(
        spacing: 8,
        runSpacing: 6,
        children: typeColors.entries.map((e) {
          final count = questions.where((q) => q['type'] == e.key).length;
          if (count == 0) return const SizedBox.shrink();
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
                color: e.value.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: e.value.withOpacity(0.3))),
            child: Text('${typeLabels[e.key]} × $count',
                style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w600, color: e.value)),
          );
        }).toList(),
      ).animate().fadeIn(delay: 150.ms),

      const SizedBox(height: 12),

      // Questions
      ...questions.asMap().entries.map((e) {
        final q = e.value as Map<String, dynamic>;
        final type = q['type']?.toString() ?? 'short_answer';
        final color = typeColors[type] ?? AppColors.textSecondary;
        final options = (q['options'] as List?) ?? [];

        return AppCard(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: color.withOpacity(0.3))),
                child: Text(typeLabels[type] ?? type,
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: color)),
              ),
              const Spacer(),
              Text('${q['marks'] ?? 1} mark',
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textMuted)),
            ]),
            const SizedBox(height: 8),
            Text('Q${e.key + 1}. ${q['question'] ?? ''}',
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                    height: 1.5)),
            if (options.isNotEmpty) ...[
              const SizedBox(height: 8),
              ...options.asMap().entries.map((opt) {
                final letter = String.fromCharCode(65 + opt.key);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(4)),
                      child: Center(
                          child: Text(letter,
                              style: const TextStyle(
                                  fontSize: 11, fontWeight: FontWeight.w600))),
                    ),
                    const SizedBox(width: 8),
                    Text(opt.value.toString(),
                        style: const TextStyle(fontSize: 12)),
                  ]),
                );
              }),
            ],
          ]),
        )
            .animate(delay: Duration(milliseconds: 200 + e.key * 50))
            .fadeIn()
            .slideX(begin: 0.2);
      }),

      const SizedBox(height: 14),

      Row(children: [
        Expanded(
            child: AppButton(
          label: 'Save',
          icon: Icons.save_outlined,
          onPressed: onSave,
        )),
        const SizedBox(width: 10),
        Expanded(
            child: AppButton(
          label: 'Export PDF',
          icon: Icons.picture_as_pdf_outlined,
          outlined: true,
          onPressed: () {
            final qList = (ws['questions'] as List?) ?? [];
            if (qList.isEmpty) {
              SnackHelper.error(context, 'No questions to export.');
              return;
            }
            PdfService.exportWorksheetPdf(
              title: ws['title']?.toString() ?? 'कार्यपत्रक (Worksheet)',
              grade: 'Class 4',
              subject: 'Mathematics',
              topic: ws['instructions']?.toString() ?? '',
              questions: qList,
            );
          },
        )),
      ]).animate().fadeIn(delay: 400.ms),
    ]);
  }
}

class _SavedWorksheetsList extends StatelessWidget {
  final List<Map<String, dynamic>> worksheets;
  final void Function(Map<String, dynamic>) onLoad;
  final Future<void> Function(String) onDelete;

  const _SavedWorksheetsList({
    required this.worksheets,
    required this.onLoad,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Saved Worksheets',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        ...worksheets
            .map((worksheet) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => onLoad(worksheet),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    worksheet['title']?.toString() ??
                                        'Worksheet',
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600)),
                                const SizedBox(height: 4),
                                Text(
                                    '${worksheet['subject']} · ${worksheet['grade']}',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary)),
                                const SizedBox(height: 4),
                                Text(worksheet['savedAt']?.toString() ?? '',
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textMuted)),
                              ]),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded,
                            color: AppColors.error),
                        onPressed: () async {
                          await onDelete(worksheet['id']?.toString() ?? '');
                        },
                      ),
                    ]),
                  ),
                ))
            .toList(),
      ]),
    );
  }
}
