import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../app/core/constants/app_colors.dart';
import '../../../app/core/constants/app_text_styles.dart';
import '../onboarding_screen.dart';

class OnboardingSlide extends StatelessWidget {
  final OnboardingData data;
  final bool isActive;

  const OnboardingSlide({
    super.key,
    required this.data,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Emoji illustration card
          _buildIllustration(),

          const SizedBox(height: 52),

          // Title
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: AmaraTextStyles.display2.copyWith(
              height: 1.25,
            ),
          )
              .animate(target: isActive ? 1 : 0)
              .fadeIn(duration: 400.ms, delay: 100.ms)
              .slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic),

          const SizedBox(height: 20),

          // Description
          Text(
            data.description,
            textAlign: TextAlign.center,
            style: AmaraTextStyles.bodyLarge.copyWith(
              color: AmaraColors.muted,
              height: 1.6,
            ),
          )
              .animate(target: isActive ? 1 : 0)
              .fadeIn(duration: 400.ms, delay: 200.ms)
              .slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic),
        ],
      ),
    );
  }

  Widget _buildIllustration() {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: AmaraColors.bgAlt,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(
          color: data.accentColor.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Center(
        child: Text(
          data.emoji,
          style: const TextStyle(fontSize: 80),
        ),
      ),
    )
        .animate(target: isActive ? 1 : 0)
        .fadeIn(duration: 500.ms)
        .scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1, 1),
          curve: Curves.easeOutBack,
          duration: 500.ms,
        );
  }
}
