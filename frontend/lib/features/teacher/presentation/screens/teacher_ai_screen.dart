// ═══════════════════════════════════════════════════
// FILE 5/6: lib/features/teacher/presentation/screens/teacher_ai_screen.dart
// STATUS: NEW — create this file
// ═══════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_theme.dart';

const teacherGreen = Color(0xFF166534);
const teacherLight = Color(0xFF22C55E);

class TeacherAiScreen extends StatefulWidget {
  const TeacherAiScreen({super.key});

  @override
  State<TeacherAiScreen> createState() => _TeacherAiScreenState();
}

class _TeacherAiScreenState extends State<TeacherAiScreen> {
  final List<Map<String, String>> _messages = [];
  bool _loading = false;
  final TextEditingController _ctrl = TextEditingController();
  final ScrollController _scroll = ScrollController();

  final List<String> _suggestedQuestions = const [
    'आज की कक्षा कैसे बेहतर बनाऊं?',
    'Rahul गणित में कमज़ोर क्यों है?',
    'भिन्न कैसे समझाऊं?',
    'कक्षा 4 के लिए Quiz बनाओ',
    'कम उपस्थिति वाले छात्रों की सूची बताओ',
  ];

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage([String? customQuery]) async {
    final query = (customQuery ?? _ctrl.text).trim();
    if (query.isEmpty) return;

    setState(() {
      _messages.add({
        'role': 'user',
        'text': query,
      });
      _loading = true;
    });

    _ctrl.clear();
    _scrollToBottom();

    try {
      final res = await ApiClient.instance.post(
        '/ai/teacher-assistant',
        data: {
          'question': query,
          'language': 'hi',
        },
      );

      final String answer = (res.data is Map && res.data['data'] != null && res.data['data']['answer'] != null)
          ? res.data['data']['answer'].toString()
          : 'उत्तर प्राप्त हुआ।';

      if (mounted) {
        setState(() {
          _messages.add({
            'role': 'ai',
            'text': answer,
          });
          _loading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add({
            'role': 'ai',
            'text': 'माफ़ करें, अभी AI उपलब्ध नहीं है।\nSorry, AI is currently unavailable.',
          });
          _loading = false;
        });
        _scrollToBottom();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: teacherGreen,
        automaticallyImplyLeading: false,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AI सहायक',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'AI Assistant',
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
          // 1. Info Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: AppColors.primaryPale,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '💡 शिक्षण से जुड़े सवाल पूछें',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: teacherGreen,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Ask anything about teaching',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),

          // 2. Chat ListView
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            '👨‍🏫',
                            style: TextStyle(fontSize: 56),
                          ).animate().scale(duration: 400.ms),
                          const SizedBox(height: 12),
                          const Text(
                            'शिक्षण सहायक AI',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Ask me anything about lesson planning, students, or pedagogy',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            alignment: WrapAlignment.center,
                            children: List.generate(_suggestedQuestions.length, (index) {
                              final q = _suggestedQuestions[index];
                              return ActionChip(
                                label: Text(
                                  q,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: teacherGreen,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                backgroundColor: teacherGreen.withOpacity(0.08),
                                side: BorderSide(
                                  color: teacherGreen.withOpacity(0.2),
                                ),
                                onPressed: () {
                                  _ctrl.text = q;
                                  _sendMessage(q);
                                },
                              ).animate(
                                delay: Duration(milliseconds: 150 + index * 60),
                              ).fadeIn().slideY(begin: 0.2);
                            }),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length + (_loading ? 1 : 0),
                    itemBuilder: (context, i) {
                      if (i == _messages.length && _loading) {
                        return _buildTypingIndicator();
                      }

                      final msg = _messages[i];
                      final isUser = msg['role'] == 'user';

                      return Align(
                        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.78,
                          ),
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isUser ? teacherGreen : AppColors.surface,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(14),
                              topRight: const Radius.circular(14),
                              bottomLeft: Radius.circular(isUser ? 14 : 4),
                              bottomRight: Radius.circular(isUser ? 4 : 14),
                            ),
                            border: isUser
                                ? null
                                : Border.all(color: AppColors.border, width: 0.5),
                          ),
                          child: Text(
                            msg['text'] ?? '',
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.4,
                              color: isUser ? Colors.white : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ).animate(
                        delay: Duration(milliseconds: 100 + i * 60),
                      ).fadeIn().slideX(begin: isUser ? 0.2 : -0.2);
                    },
                  ),
          ),

          // 3. Input bar
          Container(
            padding: EdgeInsets.fromLTRB(12, 8, 12, 16 + bottomInset),
            decoration: const BoxDecoration(
              color: AppColors.surfaceCard,
              border: Border(
                top: BorderSide(
                  color: AppColors.border,
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    minLines: 1,
                    maxLines: 4,
                    style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'अपना सवाल पूछें... / Ask your question...',
                      hintStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      fillColor: AppColors.surface,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(color: teacherGreen, width: 1.5),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Material(
                  color: teacherGreen,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: _loading ? null : () => _sendMessage(),
                    child: Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(14),
            topRight: Radius.circular(14),
            bottomRight: Radius.circular(14),
            bottomLeft: Radius.circular(4),
          ),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDot(0),
            const SizedBox(width: 4),
            _buildDot(200),
            const SizedBox(width: 4),
            _buildDot(400),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(int delayMs) {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: AppColors.textMuted,
        shape: BoxShape.circle,
      ),
    ).animate(
      onPlay: (c) => c.repeat(reverse: true),
    ).moveY(
      begin: 0,
      end: -5,
      delay: Duration(milliseconds: delayMs),
      duration: 400.ms,
    );
  }
}
