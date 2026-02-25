import 'package:flutter/material.dart';
import '../../../app/core/constants/app_colors.dart';

class OnboardingIndicator extends StatelessWidget {
  final int count;
  final int current;
  final Color activeColor;

  const OnboardingIndicator({
    super.key,
    required this.count,
    required this.current,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 28 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive
                ? activeColor
                : AmaraColors.muted.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(100),
          ),
        );
      }),
    );
  }
}
