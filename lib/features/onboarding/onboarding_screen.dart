import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/core/constants/app_colors.dart';
import '../../app/core/constants/app_text_styles.dart';
import '../../app/router/app_routes.dart';
import 'widgets/onboarding_slide.dart';
import 'widgets/onboarding_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  static const _slides = [
    OnboardingData(
      emoji: '🍛',
      title: 'La cuisine africaine\nà portée de main',
      description:
          'Découvrez des centaines de plats authentiques préparés par les meilleurs restaurants africains de votre ville.',
      accentColor: Color(0xFFE62050),
    ),
    OnboardingData(
      emoji: '⚡',
      title: 'Livraison rapide\net fiable',
      description:
          'Suivez votre commande en temps réel et recevez vos plats chauds directement à votre porte en moins de 45 min.',
      accentColor: Color(0xFFFF8C42),
    ),
    OnboardingData(
      emoji: '💳',
      title: 'Paiement simple\net sécurisé',
      description:
          'Mobile Money, carte bancaire ou cash — choisissez le moyen de paiement qui vous convient le mieux.',
      accentColor: Color(0xFF27AE60),
    ),
  ];

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _finish();
    }
  }

  void _skip() => _finish();

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
    if (!mounted) return;
    context.go(AppRoutes.authPhone);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentPage == _slides.length - 1;

    return Scaffold(
      body: Container(
        color: AmaraColors.bg,
        child: SafeArea(
          child: Column(
            children: [
              // Skip button
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 16, right: 24),
                  child: AnimatedOpacity(
                    opacity: isLast ? 0 : 1,
                    duration: const Duration(milliseconds: 200),
                    child: TextButton(
                      onPressed: isLast ? null : _skip,
                      child: Text(
                        'Passer',
                        style: AmaraTextStyles.labelMedium.copyWith(
                          color: AmaraColors.muted,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Pages
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemCount: _slides.length,
                  itemBuilder: (context, index) {
                    return OnboardingSlide(
                      data: _slides[index],
                      isActive: index == _currentPage,
                    );
                  },
                ),
              ),

              // Bottom area
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 0, 32, 48),
                child: Column(
                  children: [
                    // Indicators
                    OnboardingIndicator(
                      count: _slides.length,
                      current: _currentPage,
                      activeColor: _slides[_currentPage].accentColor,
                    ),

                    const SizedBox(height: 40),

                    // CTA Button
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      child: ElevatedButton(
                        onPressed: _nextPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _slides[_currentPage].accentColor,
                          minimumSize: const Size(double.infinity, 58),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          isLast ? 'Commencer' : 'Suivant',
                          style: AmaraTextStyles.button,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OnboardingData {
  final String emoji;
  final String title;
  final String description;
  final Color accentColor;

  const OnboardingData({
    required this.emoji,
    required this.title,
    required this.description,
    required this.accentColor,
  });
}
