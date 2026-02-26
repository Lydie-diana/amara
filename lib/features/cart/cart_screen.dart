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
      backgroundColor: AmaraColors.bgAlt,
      body: Column(
        children: [
          // ── Header ────────────────────────────────────────────────────
          _CartHeader(cart: cart),

          // ── Contenu ───────────────────────────────────────────────────
          Expanded(
            child: cart.isEmpty
                ? const _EmptyCart()
                : _FilledCart(cart: cart),
          ),

          // ── Barre commander ───────────────────────────────────────────
          if (!cart.isEmpty) _CheckoutBar(cart: cart),
        ],
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _CartHeader extends ConsumerWidget {
  final CartState cart;
  const _CartHeader({required this.cart});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final top = MediaQuery.of(context).padding.top;
    return Container(
      color: AmaraColors.primary,
      padding: EdgeInsets.fromLTRB(20, top + 16, 20, 20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Icon(Icons.arrow_back_ios_rounded,
                  color: Colors.white, size: 16),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Mon panier',
                    style: AmaraTextStyles.h3
                        .copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
                if (!cart.isEmpty)
                  Text(
                    '${cart.totalItems} article${cart.totalItems > 1 ? 's' : ''} · ${cart.groups.length} restaurant${cart.groups.length > 1 ? 's' : ''}',
                    style: AmaraTextStyles.caption
                        .copyWith(color: Colors.white.withValues(alpha: 0.7)),
                  ),
              ],
            ),
          ),
          if (!cart.isEmpty)
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                ref.read(cartProvider.notifier).clear();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('Vider',
                    style: AmaraTextStyles.caption.copyWith(
                        color: Colors.white, fontWeight: FontWeight.w700)),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Panier vide ──────────────────────────────────────────────────────────────

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
                boxShadow: [
                  BoxShadow(
                    color: AmaraColors.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
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

// ─── Panier rempli ────────────────────────────────────────────────────────────

class _FilledCart extends ConsumerWidget {
  final CartState cart;
  const _FilledCart({required this.cart});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = cart.groups;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      physics: const BouncingScrollPhysics(),
      children: [
        // Groupes par restaurant
        ...groups.asMap().entries.map((entry) {
          final idx = entry.key;
          final group = entry.value;
          return _RestaurantGroup(group: group)
              .animate()
              .fadeIn(delay: Duration(milliseconds: idx * 80), duration: 300.ms)
              .slideY(begin: 0.06, end: 0);
        }),

        const SizedBox(height: 16),

        // Récapitulatif prix
        _PriceSummary(cart: cart)
            .animate()
            .fadeIn(delay: 200.ms, duration: 300.ms),

        const SizedBox(height: 8),

        // Info livraison
        Container(
          margin: const EdgeInsets.only(top: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AmaraColors.success.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: AmaraColors.success.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              const Icon(Icons.delivery_dining_rounded,
                  color: AmaraColors.success, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Livraison estimée : 25–40 min',
                  style: AmaraTextStyles.caption.copyWith(
                      color: AmaraColors.success,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 280.ms),
      ],
    );
  }
}

// ─── Groupe restaurant ────────────────────────────────────────────────────────

class _RestaurantGroup extends ConsumerWidget {
  final CartRestaurantGroup group;
  const _RestaurantGroup({required this.group});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête restaurant
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AmaraColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.storefront_rounded,
                      color: AmaraColors.primary, size: 16),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(group.restaurantName,
                      style: AmaraTextStyles.labelSmall
                          .copyWith(fontWeight: FontWeight.w800)),
                ),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    ref.read(cartProvider.notifier).removeRestaurant(group.restaurantId);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AmaraColors.error.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('Retirer',
                        style: AmaraTextStyles.caption.copyWith(
                            color: AmaraColors.error,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),

          Container(height: 1, color: AmaraColors.divider, margin: const EdgeInsets.symmetric(horizontal: 16)),

          // Articles
          ...group.items.map((cartItem) => _CartItemTile(cartItem: cartItem)),

          // Sous-total restaurant
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
            child: Row(
              children: [
                const Icon(Icons.delivery_dining_rounded,
                    size: 13, color: AmaraColors.muted),
                const SizedBox(width: 4),
                Text('Livraison',
                    style: AmaraTextStyles.caption
                        .copyWith(color: AmaraColors.muted)),
                const Spacer(),
                Text('500 F',
                    style: AmaraTextStyles.caption.copyWith(
                        color: AmaraColors.muted,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Tuile article ────────────────────────────────────────────────────────────

class _CartItemTile extends ConsumerWidget {
  final CartItem cartItem;
  const _CartItemTile({required this.cartItem});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final item = cartItem.item;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 2),
      child: Row(
        children: [
          // Emoji / image
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AmaraColors.bgAlt,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: item.imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(item.imageUrl!,
                          width: 52,
                          height: 52,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Text(item.imageEmoji,
                              style: const TextStyle(fontSize: 26))),
                    )
                  : Text(item.imageEmoji,
                      style: const TextStyle(fontSize: 26)),
            ),
          ),
          const SizedBox(width: 12),

          // Nom + prix unitaire
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name,
                    style: AmaraTextStyles.bodySmall
                        .copyWith(fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Text(item.formattedPrice,
                    style: AmaraTextStyles.caption
                        .copyWith(color: AmaraColors.muted)),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // Contrôle quantité + prix total
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _QuantityControl(
                quantity: cartItem.quantity,
                onDecrement: () {
                  HapticFeedback.lightImpact();
                  ref.read(cartProvider.notifier).removeItem(item.id);
                },
                onIncrement: () {
                  HapticFeedback.lightImpact();
                  ref.read(cartProvider.notifier).addItem(
                        item,
                        cartItem.restaurantId,
                        cartItem.restaurantName,
                      );
                },
              ),
              const SizedBox(height: 4),
              Text(
                cartItem.formattedSubtotal,
                style: AmaraTextStyles.caption.copyWith(
                    color: AmaraColors.primary,
                    fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Récapitulatif prix ───────────────────────────────────────────────────────

class _PriceSummary extends StatelessWidget {
  final CartState cart;
  const _PriceSummary({required this.cart});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Récapitulatif',
              style: AmaraTextStyles.labelSmall
                  .copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 14),
          _SummaryRow(label: 'Sous-total', value: cart.formattedSubtotal),
          const SizedBox(height: 8),
          _SummaryRow(
            label: 'Livraison (${cart.groups.length} restaurant${cart.groups.length > 1 ? 's' : ''})',
            value: cart.formattedDeliveryFee,
            valueColor: AmaraColors.textPrimary,
          ),
          const SizedBox(height: 14),
          Container(height: 1, color: AmaraColors.divider),
          const SizedBox(height: 14),
          _SummaryRow(
            label: 'Total',
            value: cart.formattedTotal,
            bold: true,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  final Color? valueColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.bold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final style = bold
        ? AmaraTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w800)
        : AmaraTextStyles.bodySmall;

    return Row(
      children: [
        Expanded(
          child: Text(label,
              style: style.copyWith(
                  color: bold
                      ? AmaraColors.textPrimary
                      : AmaraColors.textSecondary)),
        ),
        Text(value,
            style: style.copyWith(
              color: valueColor ??
                  (bold ? AmaraColors.primary : AmaraColors.textPrimary),
              fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
            )),
      ],
    );
  }
}

// ─── Barre commander ──────────────────────────────────────────────────────────

class _CheckoutBar extends StatelessWidget {
  final CartState cart;
  const _CheckoutBar({required this.cart});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 14, 20, MediaQuery.of(context).padding.bottom + 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AmaraColors.divider)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          context.push(AppRoutes.checkout);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AmaraColors.primary,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AmaraColors.primary.withValues(alpha: 0.35),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.shopping_bag_rounded,
                  color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Text(
                'Commander · ${cart.formattedTotal}',
                style: AmaraTextStyles.labelMedium.copyWith(
                    color: Colors.white, fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${cart.totalItems}',
                  style: AmaraTextStyles.caption.copyWith(
                      color: Colors.white, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Contrôle quantité ────────────────────────────────────────────────────────

class _QuantityControl extends StatelessWidget {
  final int quantity;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const _QuantityControl({
    required this.quantity,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _QBtn(
          icon: Icons.remove_rounded,
          onTap: onDecrement,
          outlined: true,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text('$quantity',
              style: AmaraTextStyles.labelSmall.copyWith(
                  color: AmaraColors.textPrimary,
                  fontWeight: FontWeight.w800)),
        ),
        _QBtn(icon: Icons.add_rounded, onTap: onIncrement),
      ],
    );
  }
}

class _QBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool outlined;
  const _QBtn({required this.icon, required this.onTap, this.outlined = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: outlined ? Colors.transparent : AmaraColors.primary,
          borderRadius: BorderRadius.circular(8),
          border: outlined
              ? Border.all(color: AmaraColors.divider, width: 1.5)
              : null,
        ),
        child: Icon(icon,
            color: outlined ? AmaraColors.textSecondary : Colors.white,
            size: 14),
      ),
    );
  }
}
