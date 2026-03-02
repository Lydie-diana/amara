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

/// Bouton flottant rond panier — bas droite, visible uniquement dans le restaurant.
class FloatingCartBar extends ConsumerWidget {
  const FloatingCartBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    if (cart.isEmpty) return const SizedBox.shrink();

    return Positioned(
      right: 16,
      bottom: 16,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          final groups = cart.groups;
          if (groups.length == 1) {
            // Un seul restaurant → navigation directe
            context.push(
                '${AppRoutes.cartDetailPath}/${groups.first.restaurantId}');
          } else {
            // Plusieurs restaurants → bottom sheet
            _showCartPicker(context, groups);
          }
        },
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AmaraColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AmaraColors.primary.withValues(alpha: 0.4),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(
                Icons.shopping_bag_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            // Badge quantité
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: AmaraColors.warning,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Center(
                  child: Text(
                    cart.totalItems > 9 ? '9+' : '${cart.totalItems}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 200.ms)
        .scale(
            begin: const Offset(0.5, 0.5),
            end: const Offset(1, 1),
            duration: 250.ms,
            curve: Curves.easeOut);
  }

  void _showCartPicker(
      BuildContext context, List<CartRestaurantGroup> groups) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _CartPickerSheet(groups: groups),
    );
  }
}

// ─── Bottom sheet multi-restaurant ──────────────────────────────────────────

class _CartPickerSheet extends StatelessWidget {
  final List<CartRestaurantGroup> groups;
  const _CartPickerSheet({required this.groups});

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Poignée
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AmaraColors.muted.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Titre
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Icon(Icons.shopping_bag_rounded,
                    color: AmaraColors.primary, size: 22),
                const SizedBox(width: 10),
                Text(
                  'Mon panier',
                  style: AmaraTextStyles.h2
                      .copyWith(fontWeight: FontWeight.w800),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AmaraColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${groups.length} restaurant${groups.length > 1 ? 's' : ''}',
                    style: AmaraTextStyles.labelSmall.copyWith(
                      color: AmaraColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Liste des restaurants
          ...groups.map((group) => _RestaurantCartTile(group: group)),

          SizedBox(height: bottom + 16),
        ],
      ),
    );
  }
}

// ─── Tuile restaurant dans le picker ────────────────────────────────────────

class _RestaurantCartTile extends StatelessWidget {
  final CartRestaurantGroup group;
  const _RestaurantCartTile({required this.group});

  @override
  Widget build(BuildContext context) {
    final itemNames =
        group.items.map((e) => e.item.name).take(3).join(', ');
    final remaining = group.items.length - 3;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.of(context).pop(); // fermer le bottom sheet
        context.push('${AppRoutes.cartDetailPath}/${group.restaurantId}');
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AmaraColors.bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AmaraColors.divider,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Image restaurant ou emoji
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AmaraColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: group.restaurantImageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.network(
                        group.restaurantImageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Center(
                          child: Text('🍽️',
                              style: TextStyle(fontSize: 24)),
                        ),
                      ),
                    )
                  : const Center(
                      child:
                          Text('🍽️', style: TextStyle(fontSize: 24)),
                    ),
            ),
            const SizedBox(width: 14),

            // Infos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group.restaurantName,
                    style: AmaraTextStyles.labelMedium
                        .copyWith(fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${group.totalItems} article${group.totalItems > 1 ? 's' : ''} · ${group.subtotal.toStringAsFixed(0)} F',
                    style: AmaraTextStyles.labelSmall.copyWith(
                      color: AmaraColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    remaining > 0
                        ? '$itemNames +$remaining'
                        : itemNames,
                    style: AmaraTextStyles.caption
                        .copyWith(color: AmaraColors.muted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Chevron
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AmaraColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: AmaraColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
