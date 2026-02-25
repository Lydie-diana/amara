import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../app/core/constants/app_colors.dart';
import '../../app/core/constants/app_text_styles.dart';
import '../../app/router/app_routes.dart';

class OrderConfirmationScreen extends StatefulWidget {
  final String orderId;

  const OrderConfirmationScreen({super.key, required this.orderId});

  @override
  State<OrderConfirmationScreen> createState() =>
      _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen>
    with TickerProviderStateMixin {
  late AnimationController _checkController;
  late AnimationController _pulseController;

  // Étapes de suivi simulées
  final List<_TrackingStep> _steps = [
    _TrackingStep(
      icon: Icons.receipt_long_rounded,
      label: 'Commande reçue',
      sublabel: 'Votre commande a été confirmée',
      isCompleted: true,
      time: 'Maintenant',
    ),
    _TrackingStep(
      icon: Icons.restaurant_rounded,
      label: 'En préparation',
      sublabel: 'Le restaurant prépare votre commande',
      isCompleted: false,
      isActive: true,
      time: '~10 min',
    ),
    _TrackingStep(
      icon: Icons.delivery_dining_rounded,
      label: 'En route',
      sublabel: 'Votre livreur est en chemin',
      isCompleted: false,
      time: '~25 min',
    ),
    _TrackingStep(
      icon: Icons.check_circle_rounded,
      label: 'Livré !',
      sublabel: 'Bon appétit 🎉',
      isCompleted: false,
      time: '~35 min',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    // Lancer l'animation après un court délai
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _checkController.forward();
        HapticFeedback.heavyImpact();
      }
    });
  }

  @override
  void dispose() {
    _checkController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AmaraColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    // ── Section succès ────────────────────────────────────
                    _buildSuccessSection(context),

                    // ── Numéro de commande ────────────────────────────────
                    _buildOrderId(context),

                    // ── Temps estimé ──────────────────────────────────────
                    _buildEstimatedTime(context),

                    // ── Tracking steps ────────────────────────────────────
                    _buildTrackingSteps(context),

                    // ── Info livreur ──────────────────────────────────────
                    _buildDriverCard(context),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // ── Boutons d'action ──────────────────────────────────────────
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  // ─── Section succès (cercle animé + checkmark) ─────────────────────────────

  Widget _buildSuccessSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 32),
      color: AmaraColors.bg,
      child: Column(
        children: [
          // Cercle animé avec checkmark
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  // Cercle pulse externe
                  Container(
                    width: 130 + (_pulseController.value * 20),
                    height: 130 + (_pulseController.value * 20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AmaraColors.success
                          .withValues(alpha: 0.08 - _pulseController.value * 0.07),
                    ),
                  ),
                  // Cercle moyen
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AmaraColors.success.withValues(alpha: 0.12),
                    ),
                  ),
                  child!,
                ],
              );
            },
            child: AnimatedBuilder(
              animation: _checkController,
              builder: (context, _) {
                return Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AmaraColors.success,
                  ),
                  child: Center(
                    child: _DrawCheckmark(
                      progress: _checkController.value,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          Text(
            'Commande confirmée !',
            style: AmaraTextStyles.h1.copyWith(
              color: AmaraColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3, end: 0),

          const SizedBox(height: 8),

          Text(
            'Votre commande est en cours de préparation.\nNous vous notifierons dès qu\'elle est en route !',
            style: AmaraTextStyles.bodySmall.copyWith(
              color: AmaraColors.textSecondary,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 500.ms),
        ],
      ),
    );
  }

  // ─── Numéro de commande ────────────────────────────────────────────────────

  Widget _buildOrderId(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: AmaraColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AmaraColors.divider),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AmaraColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.tag_rounded,
                  color: AmaraColors.primary, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Numéro de commande',
                    style: AmaraTextStyles.caption
                        .copyWith(color: AmaraColors.muted),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '#${widget.orderId.toUpperCase()}',
                    style: AmaraTextStyles.labelMedium.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                Clipboard.setData(
                    ClipboardData(text: '#${widget.orderId.toUpperCase()}'));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Numéro copié !'),
                    duration: const Duration(seconds: 1),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: AmaraColors.dark,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AmaraColors.bgAlt,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.copy_rounded,
                    size: 16, color: AmaraColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0);
  }

  // ─── Temps estimé ──────────────────────────────────────────────────────────

  Widget _buildEstimatedTime(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF3CD),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF39C12).withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AmaraColors.warning.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.access_time_rounded,
                  color: AmaraColors.warning, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Temps estimé de livraison',
                    style: AmaraTextStyles.caption.copyWith(
                        color: const Color(0xFF856404)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '30 – 45 minutes',
                    style: AmaraTextStyles.labelMedium.copyWith(
                      color: const Color(0xFF533F03),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.2, end: 0);
  }

  // ─── Tracking steps ────────────────────────────────────────────────────────

  Widget _buildTrackingSteps(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: AmaraColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text('Suivi de commande',
                  style: AmaraTextStyles.labelMedium
                      .copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AmaraColors.bgCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AmaraColors.divider),
            ),
            child: Column(
              children: List.generate(_steps.length, (index) {
                final step = _steps[index];
                final isLast = index == _steps.length - 1;
                return _TrackingStepTile(
                  step: step,
                  isLast: isLast,
                  animDelay: Duration(milliseconds: 800 + index * 120),
                );
              }),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.15, end: 0);
  }

  // ─── Carte livreur ─────────────────────────────────────────────────────────

  Widget _buildDriverCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AmaraColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AmaraColors.divider),
        ),
        child: Row(
          children: [
            // Avatar livreur
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AmaraColors.bgAlt,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🛵', style: TextStyle(fontSize: 26)),
              ),
            ),
            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Votre livreur',
                    style: AmaraTextStyles.caption
                        .copyWith(color: AmaraColors.muted),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Assignation en cours...',
                    style: AmaraTextStyles.labelMedium.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Vous serez notifié quand un livreur\naura pris en charge votre commande',
                    style: AmaraTextStyles.caption
                        .copyWith(color: AmaraColors.textSecondary),
                  ),
                ],
              ),
            ),

            // Bouton appel (désactivé pour l'instant)
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AmaraColors.bgAlt,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.phone_rounded,
                  color: AmaraColors.muted, size: 20),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 1100.ms).slideY(begin: 0.15, end: 0);
  }

  // ─── Boutons d'action ──────────────────────────────────────────────────────

  Widget _buildActions(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 12, 20, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: AmaraColors.bgCard,
        border: Border(top: BorderSide(color: AmaraColors.divider)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Bouton principal : Suivre la commande
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              // TODO: naviguer vers le tracking en temps réel
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Suivi en temps réel bientôt disponible !'),
                  backgroundColor: AmaraColors.dark,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: AmaraColors.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_on_rounded,
                      color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Suivre ma commande',
                    style: AmaraTextStyles.labelMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Bouton secondaire : Retour à l'accueil
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              context.go(AppRoutes.home);
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AmaraColors.bgAlt,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AmaraColors.divider),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.home_rounded,
                      color: AmaraColors.textPrimary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Retour à l\'accueil',
                    style: AmaraTextStyles.labelMedium.copyWith(
                      color: AmaraColors.textPrimary,
                      fontWeight: FontWeight.w600,
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

// ─── Tracking Step Tile ────────────────────────────────────────────────────────

class _TrackingStepTile extends StatelessWidget {
  final _TrackingStep step;
  final bool isLast;
  final Duration animDelay;

  const _TrackingStepTile({
    required this.step,
    required this.isLast,
    required this.animDelay,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icône + ligne verticale
        Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: step.isCompleted
                    ? AmaraColors.success
                    : step.isActive
                        ? AmaraColors.primary
                        : AmaraColors.bgAlt,
                shape: BoxShape.circle,
                border: Border.all(
                  color: step.isCompleted
                      ? AmaraColors.success
                      : step.isActive
                          ? AmaraColors.primary
                          : AmaraColors.divider,
                  width: 2,
                ),
              ),
              child: Icon(
                step.isCompleted ? Icons.check_rounded : step.icon,
                size: 18,
                color: step.isCompleted
                    ? Colors.white
                    : step.isActive
                        ? Colors.white
                        : AmaraColors.muted,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 32,
                margin: const EdgeInsets.symmetric(vertical: 4),
                color: step.isCompleted
                    ? AmaraColors.success
                    : AmaraColors.divider,
              ),
          ],
        ),

        const SizedBox(width: 14),

        // Texte
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 6, bottom: isLast ? 0 : 28),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step.label,
                        style: AmaraTextStyles.labelSmall.copyWith(
                          color: step.isCompleted || step.isActive
                              ? AmaraColors.textPrimary
                              : AmaraColors.muted,
                          fontWeight: step.isActive
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        step.sublabel,
                        style: AmaraTextStyles.caption.copyWith(
                          color: step.isCompleted || step.isActive
                              ? AmaraColors.textSecondary
                              : AmaraColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  step.time,
                  style: AmaraTextStyles.caption.copyWith(
                    color: step.isActive
                        ? AmaraColors.primary
                        : AmaraColors.muted,
                    fontWeight:
                        step.isActive ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: animDelay).slideX(begin: 0.1, end: 0);
  }
}

// ─── Modèle step tracking ──────────────────────────────────────────────────────

class _TrackingStep {
  final IconData icon;
  final String label;
  final String sublabel;
  final bool isCompleted;
  final bool isActive;
  final String time;

  const _TrackingStep({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.time,
    this.isCompleted = false,
    this.isActive = false,
  });
}

// ─── Checkmark dessiné à la main ──────────────────────────────────────────────

class _DrawCheckmark extends StatelessWidget {
  final double progress;
  final Color color;
  final double size;

  const _DrawCheckmark({
    required this.progress,
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _CheckmarkPainter(progress: progress, color: color),
    );
  }
}

class _CheckmarkPainter extends CustomPainter {
  final double progress;
  final Color color;

  _CheckmarkPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Points du checkmark
    final p1 = Offset(size.width * 0.2, size.height * 0.55);
    final p2 = Offset(size.width * 0.43, size.height * 0.75);
    final p3 = Offset(size.width * 0.8, size.height * 0.28);

    // Longueurs des segments
    final seg1 = (p2 - p1).distance;
    final seg2 = (p3 - p2).distance;
    final total = seg1 + seg2;

    final drawn = progress * total;

    if (drawn <= seg1) {
      // Premier segment partiellement dessiné
      final t = drawn / seg1;
      canvas.drawLine(p1, Offset.lerp(p1, p2, t)!, paint);
    } else {
      // Premier segment complet + deuxième partiellement
      canvas.drawLine(p1, p2, paint);
      final t = (drawn - seg1) / seg2;
      canvas.drawLine(p2, Offset.lerp(p2, p3, t)!, paint);
    }
  }

  @override
  bool shouldRepaint(_CheckmarkPainter old) => old.progress != progress;
}
