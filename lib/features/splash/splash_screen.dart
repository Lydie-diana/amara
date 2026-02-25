import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/core/constants/app_colors.dart';
import '../../app/core/constants/app_text_styles.dart';
import '../../app/router/app_routes.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _navigate();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 2800));
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;

    if (!mounted) return;

    if (isLoggedIn) {
      context.go(AppRoutes.home);
    } else if (hasSeenOnboarding) {
      context.go(AppRoutes.authPhone);
    } else {
      context.go(AppRoutes.onboarding);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Fond sombre hero uniquement pour le splash — accent de marque
        color: AmaraColors.dark,
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                // Logo area
                _buildLogo(),

                const SizedBox(height: 24),

                // App name
                Text(
                  'amara',
                  style: AmaraTextStyles.displayOnDark.copyWith(
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                )
                    .animate()
                    .fadeIn(delay: 400.ms, duration: 600.ms)
                    .slideY(begin: 0.3, end: 0, curve: Curves.easeOutCubic),

                const SizedBox(height: 8),

                // Tagline
                Text(
                  'La saveur africaine, livrée chez vous',
                  style: AmaraTextStyles.bodyOnDark.copyWith(letterSpacing: 0.3),
                )
                    .animate()
                    .fadeIn(delay: 700.ms, duration: 600.ms)
                    .slideY(begin: 0.3, end: 0, curve: Curves.easeOutCubic),

                const Spacer(flex: 2),

                // Loading dots
                _buildLoadingDots(),

                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: AmaraColors.primary,
        borderRadius: BorderRadius.circular(28),
      ),
      child: const Center(
        child: Text(
          'A',
          style: TextStyle(
            color: Colors.white,
            fontSize: 52,
            fontWeight: FontWeight.w900,
            height: 1,
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms)
        .scale(
          begin: const Offset(0.6, 0.6),
          end: const Offset(1, 1),
          curve: Curves.elasticOut,
          duration: 800.ms,
        );
  }

  Widget _buildLoadingDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            final delay = index * 0.2;
            final animValue = (_pulseController.value - delay).clamp(0.0, 1.0);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: AmaraColors.primary.withValues(
                  alpha: 0.3 + (animValue * 0.7),
                ),
                shape: BoxShape.circle,
              ),
            );
          },
        );
      }),
    ).animate().fadeIn(delay: 1200.ms, duration: 400.ms);
  }
}
