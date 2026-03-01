import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/core/constants/app_colors.dart';
import '../../app/core/constants/app_images.dart';
import '../../app/providers/auth_provider.dart';
import '../../app/providers/location_provider.dart';
import '../../app/router/app_routes.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _typingController;
  late AnimationController _cursorController;

  final String _brandName = 'Amara';

  @override
  void initState() {
    super.initState();

    // Animation d'écriture lettre par lettre
    _typingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    // Curseur clignotant
    _cursorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    // Démarrer l'animation d'écriture après un court délai
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _typingController.forward();
    });

    _navigate();

    // Démarrer la détection GPS en parallèle (non-bloquant)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(locationProvider.notifier).initLocation();
    });
  }

  @override
  void dispose() {
    _typingController.dispose();
    _cursorController.dispose();
    super.dispose();
  }

  Future<void> _navigate() async {
    // Attendre l'animation d'écriture + un petit buffer
    await Future.delayed(const Duration(milliseconds: 3200));
    if (!mounted) return;

    // Attendre que l'auth provider ait fini de vérifier le token
    final authState = await _waitForAuth();
    if (!mounted) return;

    if (authState.isAuthenticated) {
      // Utilisateur déjà connecté → direct home (comme Uber Eats)
      context.go(AppRoutes.home);
    } else {
      final prefs = await SharedPreferences.getInstance();
      final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;
      if (!mounted) return;

      if (hasSeenOnboarding) {
        context.go(AppRoutes.authPhone);
      } else {
        context.go(AppRoutes.onboarding);
      }
    }
  }

  /// Attend que le AuthNotifier ait fini son _init() (loading → authenticated/unauthenticated)
  Future<AuthState> _waitForAuth() async {
    var authState = ref.read(authProvider);

    // Si encore en loading, attendre la résolution
    if (authState.isLoading) {
      final completer = Completer<AuthState>();
      late ProviderSubscription<AuthState> sub;
      sub = ref.listenManual(authProvider, (_, next) {
        if (!next.isLoading && !completer.isCompleted) {
          completer.complete(next);
          sub.close();
        }
      });
      // Timeout de sécurité (5s max)
      authState = await completer.future.timeout(
        const Duration(seconds: 5),
        onTimeout: () => const AuthState(status: AuthStatus.unauthenticated),
      );
    }

    return authState;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Image de fond plein écran ────────────────────────────
          CachedNetworkImage(
            imageUrl: AmaraImages.splashHero,
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(color: AmaraColors.dark),
            errorWidget: (_, __, ___) => Container(color: AmaraColors.dark),
          ),

          // ── Overlay gradient sombre ─────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xCC000000),
                  Color(0x66000000),
                  Color(0xCC000000),
                ],
                stops: [0.0, 0.4, 1.0],
              ),
            ),
          ),

          // ── Contenu centré ──────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 3),

                // Petits points décoratifs
                _buildDecorationDots()
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 200.ms),

                const SizedBox(height: 24),

                // Logo texte "Amara" avec animation d'écriture
                _buildTypingText(),

                const Spacer(flex: 3),

                const SizedBox(height: 48),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingText() {
    return AnimatedBuilder(
      animation: Listenable.merge([_typingController, _cursorController]),
      builder: (context, child) {
        // Nombre de caractères visibles
        final charCount =
            (_typingController.value * _brandName.length).round();
        final visibleText = _brandName.substring(0, charCount);

        // Curseur visible seulement pendant l'écriture ou clignotant après
        final showCursor = _typingController.isAnimating ||
            (_typingController.isCompleted && _cursorController.value > 0.5);

        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              visibleText,
              style: GoogleFonts.pacifico(
                fontSize: 52,
                fontWeight: FontWeight.w400,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
            // Curseur
            AnimatedOpacity(
              opacity: showCursor ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 100),
              child: Container(
                width: 3,
                height: 42,
                margin: const EdgeInsets.only(left: 2, bottom: 4),
                decoration: BoxDecoration(
                  color: AmaraColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDecorationDots() {
    return SizedBox(
      width: 80,
      height: 20,
      child: CustomPaint(painter: _DotsPainter()),
    );
  }
}

/// Petits points décoratifs dispersés
class _DotsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AmaraColors.primary.withValues(alpha: 0.7);
    final positions = [
      Offset(size.width * 0.1, size.height * 0.3),
      Offset(size.width * 0.3, size.height * 0.1),
      Offset(size.width * 0.5, size.height * 0.6),
      Offset(size.width * 0.7, size.height * 0.2),
      Offset(size.width * 0.9, size.height * 0.5),
      Offset(size.width * 0.2, size.height * 0.8),
      Offset(size.width * 0.8, size.height * 0.9),
    ];
    for (final p in positions) {
      canvas.drawCircle(p, 2.5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
