import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/core/constants/app_colors.dart';
import '../../app/core/constants/app_text_styles.dart';
import '../../app/core/l10n/app_localizations.dart';
import '../../app/router/app_routes.dart';
import '../shell/main_shell.dart';

class OrderConfirmationScreen extends ConsumerWidget {
  final String orderId;
  final String restaurantName;
  final List<Map<String, dynamic>> orderItems;

  const OrderConfirmationScreen({
    super.key,
    required this.orderId,
    this.restaurantName = 'Restaurant',
    this.orderItems = const [],
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bottom = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    _HeroSection(restaurantName: restaurantName),
                    _OrderIdSection(orderId: orderId),
                    _DetailCard(orderItems: orderItems),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            _Buttons(
              bottom: bottom,
              orderId: orderId,
              onBackHome: () {
                ref.read(shellIndexProvider.notifier).state = 0;
                context.go(AppRoutes.home);
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Hero : confettis + badge rose + texte ──────────────────────────────────

class _HeroSection extends StatefulWidget {
  final String restaurantName;
  const _HeroSection({required this.restaurantName});

  @override
  State<_HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<_HeroSection>
    with TickerProviderStateMixin {
  late AnimationController _badgeController;
  late AnimationController _confettiController;

  @override
  void initState() {
    super.initState();
    _badgeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _badgeController.forward();
        _confettiController.forward();
        HapticFeedback.heavyImpact();
      }
    });
  }

  @override
  void dispose() {
    _badgeController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 320,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _confettiController,
            builder: (context, _) {
              return CustomPaint(
                size: const Size(double.infinity, 320),
                painter: _ConfettiPainter(
                  progress: _confettiController.value,
                ),
              );
            },
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              AnimatedBuilder(
                animation: _badgeController,
                builder: (context, child) {
                  final scale = _badgeController.value < 0.5
                      ? _badgeController.value * 2.4
                      : 1.0 +
                          (1.0 -
                                  ((_badgeController.value - 0.5) * 2)
                                      .clamp(0.0, 1.0)) *
                              0.2;
                  return Transform.scale(
                    scale: scale.clamp(0.0, 1.2),
                    child: child,
                  );
                },
                child: SizedBox(
                  width: 120,
                  height: 120,
                  child: CustomPaint(
                    painter: _BadgePainter(),
                    child: const Center(
                      child: Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                AppLocalizations.of(context).orderConfirmSent,
                style: AmaraTextStyles.h1.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AmaraColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  AppLocalizations.of(context).orderConfirmThankYou(widget.restaurantName),
                  style: AmaraTextStyles.bodySmall.copyWith(
                    color: AmaraColors.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Order ID ───────────────────────────────────────────────────────────────

class _OrderIdSection extends StatelessWidget {
  final String orderId;
  const _OrderIdSection({required this.orderId});

  @override
  Widget build(BuildContext context) {
    final displayId =
        orderId.length > 12 ? orderId.substring(0, 12).toUpperCase() : orderId.toUpperCase();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          '${AppLocalizations.of(context).orderConfirmOrderNumber}\n#$displayId',
          style: AmaraTextStyles.labelLarge.copyWith(
            fontWeight: FontWeight.w800,
            color: AmaraColors.textPrimary,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

// ─── Detail Card ────────────────────────────────────────────────────────────

class _DetailCard extends StatelessWidget {
  final List<Map<String, dynamic>> orderItems;
  const _DetailCard({required this.orderItems});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AmaraColors.divider),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context).orderConfirmRecipientName,
              style: AmaraTextStyles.caption.copyWith(
                color: AmaraColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              AppLocalizations.of(context).orderConfirmClientName,
              style: AmaraTextStyles.labelLarge.copyWith(
                fontWeight: FontWeight.w700,
                color: AmaraColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context).orderConfirmOrderDetail,
              style: AmaraTextStyles.labelMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: AmaraColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            if (orderItems.isNotEmpty)
              ...orderItems.map((item) => _OrderItemRow(item: item))
            else
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  AppLocalizations.of(context).orderConfirmNoItems,
                  style: AmaraTextStyles.bodySmall
                      .copyWith(color: AmaraColors.muted),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _OrderItemRow extends StatelessWidget {
  final Map<String, dynamic> item;
  const _OrderItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final name = item['name'] as String? ?? '';
    final imageUrl = item['imageUrl'] as String?;
    final emoji = item['imageEmoji'] as String? ?? '';
    final quantity = item['quantity'] as int? ?? 1;
    final unitPrice = (item['unitPrice'] as num?)?.toDouble() ?? 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 60,
              height: 60,
              child: imageUrl != null
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AmaraColors.bgAlt,
                        child: Center(
                          child: Text(emoji,
                              style: const TextStyle(fontSize: 28)),
                        ),
                      ),
                    )
                  : Container(
                      color: AmaraColors.bgAlt,
                      child: Center(
                        child:
                            Text(emoji, style: const TextStyle(fontSize: 28)),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              name,
              style: AmaraTextStyles.labelMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AmaraColors.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${unitPrice.toStringAsFixed(0)} F',
                style: AmaraTextStyles.labelMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AmaraColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${quantity}Pcs',
                style: AmaraTextStyles.caption.copyWith(
                  color: AmaraColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Buttons ────────────────────────────────────────────────────────────────

class _Buttons extends StatelessWidget {
  final double bottom;
  final String orderId;
  final VoidCallback onBackHome;

  const _Buttons({
    required this.bottom,
    required this.orderId,
    required this.onBackHome,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 12, 20, bottom + 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              context.push('/order/$orderId/tracking');
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: AmaraColors.primary, width: 1.5),
              ),
              child: Center(
                child: Text(
                  AppLocalizations.of(context).orderConfirmTrackOrder,
                  style: AmaraTextStyles.labelLarge.copyWith(
                    color: AmaraColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              onBackHome();
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: AmaraColors.primary,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Center(
                child: Text(
                  AppLocalizations.of(context).orderConfirmBackHome,
                  style: AmaraTextStyles.labelLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Badge painter (forme sceau/rosette rose) ─────────────────────────────────

class _BadgePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final shadowPaint = Paint()
      ..color = const Color(0xFFE62050).withValues(alpha: 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawCircle(
        center + const Offset(0, 4), radius * 0.85, shadowPaint);

    final path = Path();
    const waveCount = 14;
    final outerRadius = radius;
    final innerRadius = radius * 0.82;

    for (int i = 0; i < waveCount * 2; i++) {
      final angle = (i * pi) / waveCount - pi / 2;
      final r = i.isEven ? outerRadius : innerRadius;
      final x = center.dx + r * cos(angle);
      final y = center.dy + r * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFFF6B8A),
          Color(0xFFE62050),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── Confetti painter ─────────────────────────────────────────────────────────

class _ConfettiPainter extends CustomPainter {
  final double progress;

  _ConfettiPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0) return;

    final random = Random(42);
    const count = 40;

    final colors = [
      const Color(0xFFE62050),
      const Color(0xFF4FC3F7),
      const Color(0xFFFFD54F),
      const Color(0xFF81C784),
      const Color(0xFFBA68C8),
      const Color(0xFFFF8A65),
      const Color(0xFF4DB6AC),
    ];

    for (int i = 0; i < count; i++) {
      final color = colors[random.nextInt(colors.length)];
      final startX = random.nextDouble() * size.width;
      const startY = -20.0;
      final endX = startX + (random.nextDouble() - 0.5) * 120;
      final endY = size.height * (0.3 + random.nextDouble() * 0.7);

      final x = startX + (endX - startX) * progress;
      final y = startY + (endY - startY) * progress;

      final opacity = progress < 0.7 ? 1.0 : (1.0 - progress) / 0.3;

      final paint = Paint()
        ..color = color.withValues(alpha: opacity.clamp(0.0, 1.0));

      final shape = random.nextInt(3);
      if (shape == 0) {
        final w = 4.0 + random.nextDouble() * 6;
        final h = 8.0 + random.nextDouble() * 10;
        canvas.save();
        canvas.translate(x, y);
        canvas.rotate(progress * pi * 2 * (random.nextDouble() - 0.5));
        canvas.drawRect(
            Rect.fromCenter(center: Offset.zero, width: w, height: h), paint);
        canvas.restore();
      } else if (shape == 1) {
        canvas.drawCircle(
            Offset(x, y), 3 + random.nextDouble() * 3, paint);
      } else {
        final s = 6.0 + random.nextDouble() * 6;
        final p = Path()
          ..moveTo(x, y - s)
          ..lineTo(x - s * 0.7, y + s * 0.5)
          ..lineTo(x + s * 0.7, y + s * 0.5)
          ..close();
        canvas.save();
        canvas.translate(x, y);
        canvas.rotate(progress * pi * (random.nextDouble() - 0.5));
        canvas.translate(-x, -y);
        canvas.drawPath(p, paint);
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.progress != progress;
}
