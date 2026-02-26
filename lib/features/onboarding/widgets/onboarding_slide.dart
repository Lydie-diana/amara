import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
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
    return Stack(
      fit: StackFit.expand,
      children: [
        // ── Image de fond plein écran ─────────────────────────────
        CachedNetworkImage(
          imageUrl: data.imageUrl,
          fit: BoxFit.cover,
          placeholder: (_, __) => Container(color: AmaraColors.dark),
          errorWidget: (_, __, ___) => Container(color: AmaraColors.dark),
        ),

        // ── Gradient overlay ─────────────────────────────────────
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0x33000000), // 20% en haut
                Color(0x1A000000), // 10% au milieu haut
                Color(0x80000000), // 50% milieu bas
                Color(0xE6000000), // 90% en bas
              ],
              stops: [0.0, 0.3, 0.6, 1.0],
            ),
          ),
        ),

        // ── Nom de l'app en haut ─────────────────────────────────
        Positioned(
          top: MediaQuery.of(context).padding.top + 16,
          left: 0,
          right: 0,
          child: Center(
            child: Text(
              'Amara',
              style: GoogleFonts.pacifico(
                fontSize: 24,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ),
        ),

        // ── Contenu texte en bas ─────────────────────────────────
        Positioned(
          left: 32,
          right: 100,
          bottom: 140,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Titre
              Text(
                data.title,
                style: AmaraTextStyles.displayOnDark.copyWith(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              )
                  .animate(target: isActive ? 1 : 0)
                  .fadeIn(duration: 400.ms, delay: 100.ms)
                  .slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic),

              const SizedBox(height: 16),

              // Description
              Text(
                data.description,
                style: AmaraTextStyles.bodyOnDark.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                  height: 1.5,
                  fontSize: 14,
                ),
              )
                  .animate(target: isActive ? 1 : 0)
                  .fadeIn(duration: 400.ms, delay: 200.ms)
                  .slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic),
            ],
          ),
        ),
      ],
    );
  }
}
