// ═══════════════════════════════════════════════════
// FILE 5/6: lib/features/parent/presentation/screens/parent_ai_screen.dart
// STATUS: NEW — create this file
// ═══════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/services/voice_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_widgets.dart';

const parentPurple = Color(0xFF3C3489);

class ParentAiScreen extends StatefulWidget {
  const ParentAiScreen({super.key});

  @override
  State<ParentAiScreen> createState() => _ParentAiScreenState();
}

class _ParentAiScreenState extends State<ParentAiScreen> {
  final TextEditingController _ctr = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final List<Map<String, String>> _messages = [];
  bool _loading = false;
  bool _isListening = false;

  final List<String> _suggestedPrompts = [
    'आज का गृहकार्य क्या है?',
    'Rahul गणित में कमज़ोर क्यों है?',
    'इस महीने उपस्थिति कैसी है?',
    'गणित में घर पर कैसे मदद करूँ?',
    'कल स्कूल है या नहीं?',
  ];

  @override
  void dispose() {
    _ctr.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _sendMessage([String? text]) async {
    final userText = (text ?? _ctr.text).trim();
    if (userText.isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'text': userText});
      _loading = true;
    });
    _ctr.clear();
    _scrollToBottom();

    try {
      final res = await ApiClient.instance.post(
        '/ai/parent-assistant',
        data: {
          'question': userText,
          'language': 'hi',
        },
      );

      final answer = res.data['data']['answer'] as String;
      if (mounted) {
        setState(() {
          _messages.add({'role': 'ai', 'text': answer});
          _loading = false;
        });
        _scrollToBottom();
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _messages.add({
            'role': 'ai',
            'text': 'माफ़ करें, अभी AI उपलब्ध नहीं है। बाद में कोशिश करें।',
          });
          _loading = false;
        });
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: 300.ms,
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _toggleVoice() async {
    if (_isListening) {
      await VoiceService.instance.stopListening();
      setState(() => _isListening = false);
    } else {
      setState(() => _isListening = true);
      await VoiceService.instance.startListening(
        localeId: 'hi_IN',
        onResult: (text) {
          _ctr.text = text;
          setState(() => _isListening = false);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: parentPurple,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AI सहायक',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
            ),
            Text(
              'AI Assistant',
              style: TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          if (_messages.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded, color: Colors.white),
              tooltip: 'Clear Chat',
              onPressed: () {
                setState(() => _messages.clear());
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Info banner always present at top
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            color: parentPurple.withOpacity(0.08),
            child: const Row(
              children: [
                Icon(Icons.shield_outlined, color: parentPurple, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '💡 शिक्षक को परेशान किए बिना पूछें · Ask without disturbing teacher',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: parentPurple,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Main body content
          if (_messages.isEmpty) ...[
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: parentPurple.withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(child: Text('🤖', style: TextStyle(fontSize: 34))),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'नमस्ते! अपने बच्चे की पढ़ाई से जुड़ा सवाल पूछें',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'गृहकार्य, उपस्थिति, या प्रगति के बारे में जानकारी प्राप्त करें।',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      '💡 सुझाव (Suggested Questions):',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _suggestedPrompts.map((p) {
                        return ActionChip(
                          label: Text(p, style: const TextStyle(fontSize: 12, color: parentPurple)),
                          backgroundColor: parentPurple.withOpacity(0.08),
                          side: BorderSide(color: parentPurple.withOpacity(0.2)),
                          onPressed: () => _sendMessage(p),
                        );
                      }).toList(),
                    ),
                  ],
                ).animate().fadeIn(duration: 300.ms),
              ),
            ),
          ] else ...[
            Expanded(
              child: ListView.builder(
                controller: _scroll,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length + (_loading ? 1 : 0),
                itemBuilder: (context, i) {
                  if (i == _messages.length) {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceCard,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2, color: parentPurple),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'उत्तर तैयार हो रहा है...',
                              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final m = _messages[i];
                  final isUser = m['role'] == 'user';

                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.82),
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                      decoration: BoxDecoration(
                        color: isUser ? parentPurple : AppColors.surfaceCard,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(14),
                          topRight: const Radius.circular(14),
                          bottomLeft: Radius.circular(isUser ? 14 : 3),
                          bottomRight: Radius.circular(isUser ? 3 : 14),
                        ),
                        border: isUser ? null : Border.all(color: AppColors.border, width: 0.8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ParsedMessageContent(
                        text: m['text']!,
                        isUser: isUser,
                      ),
                    ),
                  ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.15);
                },
              ),
            ),
          ],

          // Bottom Input Controls
          Container(
            padding: EdgeInsets.fromLTRB(12, 8, 12, MediaQuery.of(context).viewInsets.bottom + 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              border: const Border(top: BorderSide(color: AppColors.border, width: 0.6)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                    color: _isListening ? AppColors.error : parentPurple,
                  ),
                  tooltip: 'Voice Input / बोलकर पूछें',
                  onPressed: _toggleVoice,
                ),
                Expanded(
                  child: TextField(
                    controller: _ctr,
                    maxLines: 3,
                    minLines: 1,
                    decoration: InputDecoration(
                      hintText: _isListening ? 'सुन रहा हूँ... बोलिए' : 'सवाल पूछें (उदा. आज का गृहकार्य क्या है?)',
                      hintStyle: const TextStyle(fontSize: 13),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(22),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _sendMessage(),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: parentPurple,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
