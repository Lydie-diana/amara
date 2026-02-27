import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/core/constants/app_colors.dart';
import '../../app/core/constants/app_text_styles.dart';
import '../../app/services/convex_client.dart';

/// Ecran de notation après livraison — restaurant (obligatoire) + livreur (optionnel)
class ReviewScreen extends ConsumerStatefulWidget {
  final String orderId;
  final String restaurantName;
  final bool hasDriver;
  final int initialRating;

  const ReviewScreen({
    super.key,
    required this.orderId,
    required this.restaurantName,
    this.hasDriver = false,
    this.initialRating = 0,
  });

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  late int _restaurantRating = widget.initialRating;
  int _driverRating = 0;
  final _commentController = TextEditingController();
  bool _isSubmitting = false;
  bool _submitted = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_restaurantRating == 0) return;
    setState(() => _isSubmitting = true);

    try {
      await ConvexClient.instance.submitReview(
        orderId: widget.orderId,
        rating: _restaurantRating,
        driverRating: widget.hasDriver && _driverRating > 0
            ? _driverRating
            : null,
        comment: _commentController.text,
      );
      if (mounted) {
        setState(() {
          _submitted = true;
          _isSubmitting = false;
        });
        // Attendre un instant puis fermer
        await Future.delayed(const Duration(milliseconds: 1500));
        if (mounted && context.canPop()) {
          context.pop(true);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().contains('déjà noté')
                  ? 'Vous avez deja note cette commande'
                  : 'Erreur lors de la soumission',
            ),
            backgroundColor: AmaraColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_submitted) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AmaraColors.success.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: AmaraColors.success,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Merci pour votre avis !',
                style: AmaraTextStyles.h2.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Votre retour aide la communaute',
                style: AmaraTextStyles.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded,
              color: AmaraColors.textPrimary, size: 22),
          onPressed: () => context.canPop() ? context.pop() : null,
        ),
        centerTitle: true,
        title: Text(
          'Votre avis',
          style: AmaraTextStyles.labelLarge.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 12),

            // ── Illustration
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AmaraColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.star_rounded,
                color: AmaraColors.primary,
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Comment etait votre experience ?',
              style: AmaraTextStyles.h2.copyWith(
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              widget.restaurantName,
              style: AmaraTextStyles.bodyMedium.copyWith(
                color: AmaraColors.primary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 36),

            // ── Note restaurant
            _RatingSection(
              label: 'Note du restaurant',
              icon: Icons.restaurant_rounded,
              rating: _restaurantRating,
              onChanged: (r) => setState(() => _restaurantRating = r),
            ),

            // ── Note livreur
            if (widget.hasDriver) ...[
              const SizedBox(height: 28),
              _RatingSection(
                label: 'Note du livreur',
                icon: Icons.delivery_dining_rounded,
                rating: _driverRating,
                onChanged: (r) => setState(() => _driverRating = r),
                optional: true,
              ),
            ],

            const SizedBox(height: 32),

            // ── Commentaire
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Un commentaire ? (optionnel)',
                style: AmaraTextStyles.labelMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _commentController,
              maxLines: 3,
              maxLength: 300,
              style: AmaraTextStyles.bodyLarge.copyWith(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Partagez votre experience...',
                hintStyle: AmaraTextStyles.bodyMedium.copyWith(
                  color: AmaraColors.muted,
                ),
                filled: true,
                fillColor: AmaraColors.bg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: AmaraColors.divider),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: AmaraColors.divider),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                      const BorderSide(color: AmaraColors.primary, width: 1.5),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                counterStyle: AmaraTextStyles.caption,
              ),
            ),

            const SizedBox(height: 32),

            // ── Bouton envoyer
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _restaurantRating > 0 && !_isSubmitting
                    ? _submit
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AmaraColors.primary,
                  disabledBackgroundColor: AmaraColors.divider,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(
                        'Envoyer mon avis',
                        style: AmaraTextStyles.button,
                      ),
              ),
            ),

            const SizedBox(height: 12),

            // ── Passer
            TextButton(
              onPressed: () =>
                  context.canPop() ? context.pop(false) : null,
              child: Text(
                'Passer',
                style: AmaraTextStyles.labelMedium.copyWith(
                  color: AmaraColors.muted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Section de notation (étoiles) ──────────────────────────────────────────

class _RatingSection extends StatelessWidget {
  final String label;
  final IconData icon;
  final int rating;
  final ValueChanged<int> onChanged;
  final bool optional;

  const _RatingSection({
    required this.label,
    required this.icon,
    required this.rating,
    required this.onChanged,
    this.optional = false,
  });

  static const _labels = ['', 'Mauvais', 'Moyen', 'Bien', 'Tres bien', 'Excellent'];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AmaraColors.bg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: rating > 0 ? AmaraColors.primary.withValues(alpha: 0.3) : AmaraColors.divider,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: AmaraColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: AmaraTextStyles.labelMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (optional) ...[
                const SizedBox(width: 6),
                Text(
                  '(optionnel)',
                  style: AmaraTextStyles.caption.copyWith(
                    color: AmaraColors.muted,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),

          // Étoiles
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final starIndex = index + 1;
              final isSelected = starIndex <= rating;
              return GestureDetector(
                onTap: () => onChanged(starIndex),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: AnimatedScale(
                    scale: isSelected ? 1.15 : 1.0,
                    duration: const Duration(milliseconds: 150),
                    child: Icon(
                      isSelected
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: isSelected
                          ? const Color(0xFFFFC107)
                          : AmaraColors.muted,
                      size: 40,
                    ),
                  ),
                ),
              );
            }),
          ),

          if (rating > 0) ...[
            const SizedBox(height: 10),
            Text(
              _labels[rating],
              style: AmaraTextStyles.labelSmall.copyWith(
                color: AmaraColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
