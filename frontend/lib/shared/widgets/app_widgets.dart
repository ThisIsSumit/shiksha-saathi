// ════════════════════════════════════════════════════════════
// SHARED WIDGETS — all in one file for reference convenience
// Split into individual files during production
// ════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../core/network/api_client.dart';

// ── AppTextField ──────────────────────────────────────────────────────────
class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label, hint;
  final TextInputType? keyboardType;
  final bool obscureText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final int maxLines;
  final bool enabled;
  final void Function(String)? onChanged;

  const AppTextField({
    super.key, required this.controller, required this.label, required this.hint,
    this.keyboardType, this.obscureText = false, this.prefixIcon,
    this.suffixIcon, this.validator, this.maxLines = 1, this.enabled = true, this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: maxLines,
      enabled: enabled,
      onChanged: onChanged,
      validator: validator,
      style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label, hintText: hint,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: AppColors.textMuted, size: 20) : null,
        suffixIcon: suffixIcon,
      ),
    );
  }
}

// ── AppButton ─────────────────────────────────────────────────────────────
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool outlined;
  final Color? color;
  final IconData? icon;

  const AppButton({
    super.key, required this.label, this.onPressed,
    this.isLoading = false, this.outlined = false, this.color, this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final bg = color ?? AppColors.primary;
    if (outlined) {
      return OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(foregroundColor: bg, side: BorderSide(color: bg, width: 1.5)),
        child: _child(bg),
      );
    }
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(backgroundColor: bg, disabledBackgroundColor: bg.withOpacity(0.5)),
      child: _child(Colors.white),
    );
  }

  Widget _child(Color textColor) => isLoading
      ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: textColor))
      : Row(mainAxisSize: MainAxisSize.min, children: [
          if (icon != null) ...[Icon(icon, size: 18, color: textColor), const SizedBox(width: 8)],
          Text(label, style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 15)),
        ]);
}

// ── AppCard ────────────────────────────────────────────────────────────────
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color? color;
  final VoidCallback? onTap;

  const AppCard({super.key, required this.child, this.padding, this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color ?? AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border, width: 0.5),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: child,
      ),
    );
  }
}

// ── StatChip ──────────────────────────────────────────────────────────────
class StatChip extends StatelessWidget {
  final String value, label, labelEn;
  final IconData icon;
  final Color color;

  const StatChip({super.key, required this.value, required this.label, required this.labelEn, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: color)),
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
        ]),
      ),
    );
  }
}

// ── SectionHeader ─────────────────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title, subtitle;
  final VoidCallback? onSeeAll;

  const SectionHeader({super.key, required this.title, required this.subtitle, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
      ]),
      const Spacer(),
      if (onSeeAll != null)
        TextButton(onPressed: onSeeAll, child: const Text('See all', style: TextStyle(fontSize: 12, color: AppColors.primary))),
    ]);
  }
}

// ── SnackHelper ───────────────────────────────────────────────────────────
class SnackHelper {
  static void error(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [const Icon(Icons.error_outline, color: Colors.white, size: 18), const SizedBox(width: 8), Expanded(child: Text(msg))]),
      backgroundColor: AppColors.error,
    ));
  }

  static void success(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [const Icon(Icons.check_circle_outline, color: Colors.white, size: 18), const SizedBox(width: 8), Expanded(child: Text(msg))]),
      backgroundColor: AppColors.success,
    ));
  }

  static void info(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

// ── AiChatSheet ───────────────────────────────────────────────────────────
class AiChatSheet extends StatefulWidget {
  final String role;
  const AiChatSheet({super.key, required this.role});
  @override State<AiChatSheet> createState() => _AiChatSheetState();
}

class _AiChatSheetState extends State<AiChatSheet> {
  final _ctr = TextEditingController();
  final _scroll = ScrollController();
  final List<Map<String, String>> _msgs = [];
  bool _loading = false;

  Future<void> _send() async {
    final q = _ctr.text.trim();
    if (q.isEmpty) return;
    setState(() { _msgs.add({'role': 'user', 'text': q}); _loading = true; });
    _ctr.clear();
    _scrollBottom();

    try {
      final endpoint = widget.role == 'parent' ? '/ai/parent-assistant' : '/ai/doubt';
      final res = await ApiClient.instance.post(endpoint, data: {'question': q, 'language': 'hi'});
      final answer = res.data['data']['answer'] as String;
      setState(() { _msgs.add({'role': 'ai', 'text': answer}); _loading = false; });
      _scrollBottom();
    } catch (e) {
      setState(() { _msgs.add({'role': 'ai', 'text': 'माफ़ करें, कुछ गड़बड़ हो गई। / Sorry, something went wrong.'}); _loading = false; });
    }
  }

  void _scrollBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) _scroll.animateTo(_scroll.position.maxScrollExtent, duration: 300.ms, curve: Curves.easeOut);
    });
  }

  @override
  Widget build(BuildContext context) {
    final greeting = widget.role == 'teacher' ? 'AI सहायक' : widget.role == 'parent' ? 'अभिभावक सहायक' : 'AI Study Buddy';

    return DraggableScrollableSheet(
      initialChildSize: 0.85, maxChildSize: 0.95, minChildSize: 0.5, expand: false,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(children: [
          const SizedBox(height: 8),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Container(width: 36, height: 36, decoration: BoxDecoration(color: AppColors.primaryPale, borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.smart_toy_rounded, color: AppColors.primary, size: 20)),
              const SizedBox(width: 10),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(greeting, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                const Text('हिंदी में पूछें · Ask in Hindi', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
              ]),
            ]),
          ),
          const Divider(height: 1),

          Expanded(
            child: _msgs.isEmpty
                ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Text('🤖', style: TextStyle(fontSize: 40)),
                    const SizedBox(height: 12),
                    Text('कोई भी सवाल पूछें\nAsk me anything', textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textSecondary, height: 1.6)),
                  ]).animate().fadeIn())
                : ListView.builder(
                    controller: ctrl, padding: const EdgeInsets.all(16),
                    itemCount: _msgs.length + (_loading ? 1 : 0),
                    itemBuilder: (_, i) {
                      if (i == _msgs.length) return _TypingIndicator();
                      final m = _msgs[i];
                      final isUser = m['role'] == 'user';
                      return Align(
                        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isUser ? AppColors.primary : AppColors.surface,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(14), topRight: const Radius.circular(14),
                              bottomLeft: Radius.circular(isUser ? 14 : 4),
                              bottomRight: Radius.circular(isUser ? 4 : 14),
                            ),
                            border: isUser ? null : Border.all(color: AppColors.border),
                          ),
                          child: Text(m['text']!, style: TextStyle(
                            color: isUser ? Colors.white : AppColors.textPrimary, fontSize: 14, height: 1.5,
                          )),
                        ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.2),
                      );
                    },
                  ),
          ),

          Container(
            padding: EdgeInsets.fromLTRB(12, 8, 12, MediaQuery.of(context).viewInsets.bottom + 16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
            ),
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: _ctr,
                  maxLines: 3, minLines: 1,
                  decoration: const InputDecoration(
                    hintText: 'कोई भी सवाल पूछें / Ask anything...',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                  onSubmitted: (_) => _send(),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _send,
                child: Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  @override
  void dispose() { _ctr.dispose(); _scroll.dispose(); super.dispose(); }
}

class _TypingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
        child: Row(children: [
          _Dot(delay: 0), _Dot(delay: 200), _Dot(delay: 400),
        ]),
      ),
    ]);
  }
}

class _Dot extends StatelessWidget {
  final int delay;
  const _Dot({required this.delay});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      width: 7, height: 7,
      decoration: const BoxDecoration(color: AppColors.textMuted, shape: BoxShape.circle),
    ).animate(onPlay: (c) => c.repeat()).moveY(begin: 0, end: -4, delay: Duration(milliseconds: delay), duration: 400.ms, curve: Curves.easeInOut).then().moveY(begin: -4, end: 0, duration: 400.ms, curve: Curves.easeInOut);
  }
}
