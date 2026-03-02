import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/core/constants/app_colors.dart';
import '../../app/core/constants/app_images.dart';
import '../../app/core/constants/app_text_styles.dart';
import '../../app/core/l10n/app_localizations.dart';
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

  List<OnboardingData> _buildSlides(AppLocalizations l10n) => [
    OnboardingData(
      imageUrl: AmaraImages.onboarding1,
      title: l10n.onboardingSlide1Title,
      description: l10n.onboardingSlide1Desc,
      accentColor: AmaraColors.primary,
    ),
    OnboardingData(
      imageUrl: AmaraImages.onboarding2,
      title: l10n.onboardingSlide2Title,
      description: l10n.onboardingSlide2Desc,
      accentColor: const Color(0xFFFF8C42),
    ),
    OnboardingData(
      imageUrl: AmaraImages.onboarding3,
      title: l10n.onboardingSlide3Title,
      description: l10n.onboardingSlide3Desc,
      accentColor: const Color(0xFF27AE60),
    ),
  ];

  void _nextPage() {
    HapticFeedback.lightImpact();
    final slides = _buildSlides(AppLocalizations.of(context));
    if (_currentPage < slides.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _finish();
    }
  }

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
    final l10n = AppLocalizations.of(context);
    final slides = _buildSlides(l10n);
    final isLast = _currentPage == slides.length - 1;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── PageView plein écran ────────────────────────────────
          PageView.builder(
            controller: _controller,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemCount: slides.length,
            itemBuilder: (context, index) {
              return OnboardingSlide(
                data: slides[index],
                isActive: index == _currentPage,
              );
            },
          ),

          // ── Bottom overlay (dots + bouton) ──────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(32, 24, 32, 56),
              child: Row(
                children: [
                  // Dots de pagination
                  OnboardingIndicator(
                    count: slides.length,
                    current: _currentPage,
                    activeColor: Colors.white,
                  ),

                  const Spacer(),

                  // Bouton next / commencer
                  if (isLast)
                    GestureDetector(
                      onTap: _nextPage,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 28, vertical: 14),
                        decoration: BoxDecoration(
                          color: AmaraColors.primary,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              l10n.onboardingStartButton,
                              style: AmaraTextStyles.labelMedium
                                  .copyWith(color: Colors.white),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward_rounded,
                                color: Colors.white, size: 18),
                          ],
                        ),
                      ),
                    )
                  else
                    GestureDetector(
                      onTap: _nextPage,
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: const BoxDecoration(
                          color: AmaraColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_forward_rounded,
                            color: Colors.white, size: 24),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingData {
  final String imageUrl;
  final String title;
  final String description;
  final Color accentColor;

  const OnboardingData({
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.accentColor,
  });
}
