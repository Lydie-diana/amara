import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/core/constants/app_colors.dart';
import '../../app/core/constants/app_text_styles.dart';
import '../../app/models/cart_model.dart';
import '../../app/providers/cart_provider.dart';
import '../../app/router/app_routes.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);

    return Scaffold(
      backgroundColor: AmaraColors.bg,
      body: Column(
        children: [
          _CartHeader(cartCount: cart.groups.length),
          Expanded(
            child: cart.isEmpty
                ? const _EmptyCart()
                : _CartList(groups: cart.groups),
          ),
        ],
      ),
    );
  }
}

// ─── Header épuré ────────────────────────────────────────────────────────────

class _CartHeader extends StatelessWidget {
  final int cartCount;
  const _CartHeader({required this.cartCount});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Container(
      color: AmaraColors.primary,
      padding: EdgeInsets.fromLTRB(20, top + 16, 20, 20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.arrow_back_ios_rounded,
                  color: Colors.white, size: 16),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'Paniers',
              style: AmaraTextStyles.h1.copyWith(
                  fontWeight: FontWeight.w800, color: Colors.white),
            ),
          ),
          // Badge nombre de paniers
          if (cartCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$cartCount',
                style: AmaraTextStyles.labelSmall.copyWith(
                    color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Panier vide ─────────────────────────────────────────────────────────────

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🛒', style: TextStyle(fontSize: 72))
              .animate()
              .scale(duration: 400.ms, curve: Curves.easeOutBack),
          const SizedBox(height: 24),
          Text('Votre panier est vide',
                  style: AmaraTextStyles.h3.copyWith(fontWeight: FontWeight.w800))
              .animate()
              .fadeIn(delay: 100.ms),
          const SizedBox(height: 8),
          Text(
            'Ajoutez des plats depuis un restaurant\npour commencer votre commande',
            style: AmaraTextStyles.bodySmall
                .copyWith(color: AmaraColors.textSecondary, height: 1.5),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 150.ms),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              decoration: BoxDecoration(
                color: AmaraColors.primary,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text('Explorer les restaurants',
                  style: AmaraTextStyles.labelMedium
                      .copyWith(color: Colors.white)),
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }
}

// ─── Liste des paniers par restaurant ────────────────────────────────────────

class _CartList extends StatelessWidget {
  final List<CartRestaurantGroup> groups;
  const _CartList({required this.groups});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      physics: const BouncingScrollPhysics(),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        return _RestaurantCartCard(group: groups[index])
            .animate()
            .fadeIn(
              delay: Duration(milliseconds: index * 80),
              duration: 300.ms,
            )
            .slideY(begin: 0.04, end: 0);
      },
    );
  }
}

// ─── Carte panier restaurant (style Uber Eats) ──────────────────────────────

class _RestaurantCartCard extends ConsumerWidget {
  final CartRestaurantGroup group;
  const _RestaurantCartCard({required this.group});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AmaraColors.divider.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── En-tête : image + infos + bouton ··· ─────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image ronde du restaurant
              ClipOval(
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: group.restaurantImageUrl != null
                      ? Image.network(
                          group.restaurantImageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _fallbackAvatar(),
                        )
                      : _fallbackAvatar(),
                ),
              ),
              const SizedBox(width: 12),

              // Nom, articles, adresse
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.restaurantName,
                      style: AmaraTextStyles.labelMedium
                          .copyWith(fontWeight: FontWeight.w800),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${group.totalItems} article${group.totalItems > 1 ? 's' : ''} · ${group.subtotal.toStringAsFixed(0)} F',
                      style: AmaraTextStyles.bodySmall
                          .copyWith(color: AmaraColors.textSecondary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Livrer à l\'adresse Cocody, Abidjan',
                      style: AmaraTextStyles.caption
                          .copyWith(color: AmaraColors.muted, fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Bouton ···
              GestureDetector(
                onTap: () => _showOptions(context, ref),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AmaraColors.bgAlt,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(Icons.more_horiz_rounded,
                      color: AmaraColors.textSecondary, size: 20),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── Bouton "Voir le panier" ──────────────────────────────────
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              context.push('${AppRoutes.cartDetailPath}/${group.restaurantId}');
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AmaraColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  'Voir le panier',
                  style: AmaraTextStyles.labelMedium.copyWith(
                      color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // ── Bouton "Afficher l'offre du magasin" ─────────────────────
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              context.push('${AppRoutes.restaurantPath}/${group.restaurantId}');
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AmaraColors.bgAlt,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  'Afficher l\'offre du magasin',
                  style: AmaraTextStyles.labelMedium.copyWith(
                      color: AmaraColors.textPrimary,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fallbackAvatar() {
    return Container(
      width: 56,
      height: 56,
      color: AmaraColors.bgAlt,
      child: const Center(
        child: Icon(Icons.storefront_rounded,
            color: AmaraColors.muted, size: 24),
      ),
    );
  }

  void _showOptions(BuildContext context, WidgetRef ref) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: EdgeInsets.fromLTRB(
            20, 20, 20, MediaQuery.of(context).padding.bottom + 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AmaraColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              group.restaurantName,
              style: AmaraTextStyles.labelMedium
                  .copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                ref
                    .read(cartProvider.notifier)
                    .removeRestaurant(group.restaurantId);
                Navigator.of(context).pop();
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AmaraColors.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'Vider ce panier',
                    style: AmaraTextStyles.labelMedium.copyWith(
                        color: AmaraColors.error, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AmaraColors.bgAlt,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'Annuler',
                    style: AmaraTextStyles.labelMedium.copyWith(
                        color: AmaraColors.textPrimary,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
