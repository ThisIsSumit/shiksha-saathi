import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_strings.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  final _pages = const [
    _OnboardPage(
      emoji: '📖',
      gradient: [Color(0xFF1A5C38), Color(0xFF2D8653)],
      title: AppStrings.onb1Title,
      titleHi: AppStrings.onb1TitleHi,
      desc: AppStrings.onb1Desc,
      descHi: AppStrings.onb1DescHi,
      tag: 'AI Lesson Planner',
    ),
    _OnboardPage(
      emoji: '📶',
      gradient: [Color(0xFF0C447C), Color(0xFF1A6DB0)],
      title: AppStrings.onb2Title,
      titleHi: AppStrings.onb2TitleHi,
      desc: AppStrings.onb2Desc,
      descHi: AppStrings.onb2DescHi,
      tag: 'Offline First',
    ),
    _OnboardPage(
      emoji: '🤝',
      gradient: [Color(0xFF3C3489), Color(0xFF5B52C9)],
      title: AppStrings.onb3Title,
      titleHi: AppStrings.onb3TitleHi,
      desc: AppStrings.onb3Desc,
      descHi: AppStrings.onb3DescHi,
      tag: '3 Portals',
    ),
  ];

  void _next() {
    if (_page < _pages.length - 1) {
      _controller.nextPage(duration: 400.ms, curve: Curves.easeInOut);
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: _pages.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (_, i) => _pages[i],
          ),
          // Bottom controls
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 48),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.4)],
                ),
              ),
              child: Column(children: [
                SmoothPageIndicator(
                  controller: _controller,
                  count: _pages.length,
                  effect: const ExpandingDotsEffect(
                    activeDotColor: Colors.white,
                    dotColor: Colors.white38,
                    dotHeight: 6, dotWidth: 6, expansionFactor: 4,
                  ),
                ),
                const SizedBox(height: 24),
                Row(children: [
                  if (_page < _pages.length - 1)
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: const Text('Skip', style: TextStyle(color: Colors.white70, fontSize: 14)),
                    ),
                  const Spacer(),
                  FilledButton(
                    onPressed: _next,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      minimumSize: Size(_page == _pages.length - 1 ? 180 : 120, 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text(
                        _page == _pages.length - 1 ? 'Get Started' : 'Next',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward_rounded, size: 18),
                    ]),
                  ),
                ]),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardPage extends StatelessWidget {
  final String emoji, title, titleHi, desc, descHi, tag;
  final List<Color> gradient;
  const _OnboardPage({
    required this.emoji, required this.gradient, required this.title,
    required this.titleHi, required this.desc, required this.descHi, required this.tag,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: gradient),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 60, 28, 140),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tag pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Text(tag, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
              ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.2),

              const SizedBox(height: 32),

              // Big emoji
              Text(emoji, style: const TextStyle(fontSize: 72))
                  .animate().scale(delay: 200.ms, duration: 500.ms, curve: Curves.elasticOut)
                  .fadeIn(),

              const SizedBox(height: 32),

              // Title in Hindi
              Text(titleHi, style: const TextStyle(
                fontSize: 26, fontWeight: FontWeight.w700, color: Colors.white, height: 1.2,
              )).animate().fadeIn(delay: 300.ms).slideY(begin: 0.3),

              const SizedBox(height: 6),

              // Title in English
              Text(title, style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w400, color: Colors.white.withOpacity(0.7),
              )).animate().fadeIn(delay: 400.ms),

              const SizedBox(height: 20),

              // Description
              Text(descHi, style: TextStyle(
                fontSize: 15, color: Colors.white.withOpacity(0.85), height: 1.6,
              )).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2),

              const SizedBox(height: 8),

              Text(desc, style: TextStyle(
                fontSize: 12, color: Colors.white.withOpacity(0.55), height: 1.5,
              )).animate().fadeIn(delay: 600.ms),
            ],
          ),
        ),
      ),
    );
  }
}
