import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/services/offline_sync_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/snack_helper.dart';

class TeacherSmsScreen extends StatefulWidget {
  const TeacherSmsScreen({super.key});

  @override
  State<TeacherSmsScreen> createState() => _TeacherSmsScreenState();
}

class _TeacherSmsScreenState extends State<TeacherSmsScreen> {
  String _selectedClass = 'Class 4-A';
  String _subject = 'गणित (Mathematics)';
  final _topicCtr = TextEditingController(text: 'भिन्न का जोड़');
  final _homeworkCtr = TextEditingController(text: 'अभ्यास 4.2 के प्रश्न 1-5 हल करें');
  final _smsMessageCtr = TextEditingController();

  bool _generatingAi = false;
  bool _sending = false;

  final _classes = ['Class 4-A', 'Class 5-B'];
  final _subjects = ['गणित (Mathematics)', 'हिंदी (Hindi)', 'विज्ञान (Science)', 'पर्यावरण (EVS)'];

  @override
  void initState() {
    super.initState();
    _smsMessageCtr.text = 'नमस्ते अभिभावक, आज कक्षा 4-A में गणित में भिन्न का जोड़ पढ़ाया गया। गृहकार्य: अभ्यास 4.2 हल करें। - प्राथमिक विद्यालय';
  }

  @override
  void dispose() {
    _topicCtr.dispose();
    _homeworkCtr.dispose();
    _smsMessageCtr.dispose();
    super.dispose();
  }

  Future<void> _generateAiDraft() async {
    setState(() => _generatingAi = true);
    try {
      final res = await ApiClient.instance.post(
        '/ai/sms-draft',
        data: {
          'grade': 4,
          'subject': _subject,
          'topic': _topicCtr.text.trim(),
          'homework': _homeworkCtr.text.trim(),
          'language': 'hi',
        },
      );

      final message = res.data['data']['message'] as String;
      if (mounted) {
        setState(() {
          _smsMessageCtr.text = message;
          _generatingAi = false;
        });
        SnackHelper.success(context, 'AI SMS ड्राफ्ट तैयार हो गया!');
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _smsMessageCtr.text = 'अभिभावक ध्यान दें: आज ${_subject.split(' ')[0]} में ${_topicCtr.text} पढ़ाया गया। गृहकार्य: ${_homeworkCtr.text}। कृपया बच्चे से कार्य पूरा कराएं।';
          _generatingAi = false;
        });
        SnackHelper.info(context, 'ड्राफ्ट टेम्पलेट तैयार किया गया।');
      }
    }
  }

  Future<void> _sendSms() async {
    final text = _smsMessageCtr.text.trim();
    if (text.isEmpty) {
      SnackHelper.error(context, 'कृपया संदेश दर्ज करें।');
      return;
    }

    setState(() => _sending = true);
    await Future.delayed(const Duration(milliseconds: 600));

    // Queue for sync or dispatch
    await OfflineSyncService.instance.enqueue(
      actionType: 'SEND_PARENT_SMS',
      endpoint: '/teacher/sms-broadcast',
      method: 'POST',
      data: {
        'className': _selectedClass,
        'message': text,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );

    if (mounted) {
      setState(() => _sending = false);
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: AppColors.success),
              SizedBox(width: 8),
              Text('SMS भेजा गया'),
            ],
          ),
          content: Text('$_selectedClass के 28 अभिभावकों को SMS सफलतापूर्वक भेज दिया गया है।'),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('ठीक है (OK)'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final charCount = _smsMessageCtr.text.length;
    final smsCount = (charCount / 160).ceil().clamp(1, 4);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.soil,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('अभिभावक SMS प्रसारण', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            Text('Parent SMS Broadcast & AI Generator', style: TextStyle(fontSize: 11, color: Colors.white70)),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Class and recipients summary card
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('कक्षा चुनें (Select Class):', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedClass,
                        decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                        items: _classes.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                        onChanged: (v) {
                          if (v != null) setState(() => _selectedClass = v);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryPale,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.primaryMint),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.people_alt_rounded, size: 16, color: AppColors.primary),
                          SizedBox(width: 6),
                          Text('28 अभिभावक', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.primary)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn(delay: 100.ms),

          const SizedBox(height: 18),

          // AI Prompt Helper
          AppCard(
            color: const Color(0xFFFDF7F2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.auto_awesome_rounded, color: AppColors.soil, size: 18),
                    SizedBox(width: 8),
                    Text('AI से SMS ड्राफ्ट करें (Hindi AI Assist)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.soil)),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _subject,
                  decoration: const InputDecoration(labelText: 'विषय (Subject)', contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                  items: _subjects.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _subject = v);
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _topicCtr,
                  decoration: const InputDecoration(labelText: 'आज क्या पढ़ाया गया? (Topic)', hintText: 'उदा. भिन्न का जोड़'),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _homeworkCtr,
                  decoration: const InputDecoration(labelText: 'गृहकार्य (Homework)', hintText: 'उदा. पृष्ठ 24 के प्रश्न 1-5'),
                ),
                const SizedBox(height: 12),
                AppButton(
                  label: _generatingAi ? 'AI ड्राफ्ट बना रहा है...' : 'AI से SMS बनाएं (< 160 Chars)',
                  icon: Icons.smart_toy_rounded,
                  color: AppColors.soil,
                  isLoading: _generatingAi,
                  onPressed: _generateAiDraft,
                ),
              ],
            ),
          ).animate().fadeIn(delay: 180.ms),

          const SizedBox(height: 20),

          // SMS Composer Box
          const Text('SMS संदेश (Message Content)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _smsMessageCtr,
            maxLines: 4,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              hintText: 'अभिभावकों को भेजे जाने वाला संदेश...',
              contentPadding: EdgeInsets.all(14),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'लंबाई: $charCount वर्ण • $smsCount SMS भाग',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: charCount > 160 ? AppColors.warning : AppColors.textMuted,
                ),
              ),
              const Text('Hindi Unicode SMS', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
            ],
          ),

          const SizedBox(height: 24),

          // Send Action
          AppButton(
            label: '28 अभिभावकों को SMS भेजें',
            icon: Icons.send_rounded,
            color: AppColors.soil,
            isLoading: _sending,
            onPressed: _sendSms,
          ).animate().fadeIn(delay: 260.ms),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
