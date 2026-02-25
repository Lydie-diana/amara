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
      appBar: AppBar(
        backgroundColor: AmaraColors.bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: AmaraColors.textPrimary, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text('Mon panier', style: AmaraTextStyles.h3),
        actions: [
          if (!cart.isEmpty)
            TextButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                ref.read(cartProvider.notifier).clear();
              },
              child: Text(
                'Vider',
                style: AmaraTextStyles.labelSmall.copyWith(
                  color: AmaraColors.error,
                ),
              ),
            ),
        ],
      ),
      body: cart.isEmpty ? const _EmptyCart() : _FilledCart(cart: cart),
      bottomNavigationBar: cart.isEmpty
          ? null
          : _CheckoutBar(cart: cart),
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
          const Text('🛒', style: TextStyle(fontSize: 64))
              .animate()
              .scale(duration: 400.ms, curve: Curves.easeOutBack),
          const SizedBox(height: 20),
          Text(
            'Votre panier est vide',
            style: AmaraTextStyles.h3,
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 8),
          Text(
            'Ajoutez des plats depuis un restaurant',
            style: AmaraTextStyles.bodySmall.copyWith(
              color: AmaraColors.textSecondary,
            ),
          ).animate().fadeIn(delay: 150.ms),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 28, vertical: 14),
              decoration: BoxDecoration(
                color: AmaraColors.primary,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                'Explorer les restaurants',
                style: AmaraTextStyles.labelMedium
                    .copyWith(color: Colors.white),
              ),
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
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      physics: const BouncingScrollPhysics(),
      children: [
        // Nom du restaurant
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: AmaraColors.bgCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AmaraColors.divider),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.storefront_rounded,
                color: AmaraColors.primary,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  cart.restaurantName ?? '',
                  style: AmaraTextStyles.labelMedium,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 300.ms),

        // Articles
        ...cart.items.asMap().entries.map((entry) {
          final index = entry.key;
          final cartItem = entry.value;
          return _CartItemTile(
            cartItem: cartItem,
          )
              .animate()
              .fadeIn(
                delay: Duration(milliseconds: index * 60),
                duration: 300.ms,
              )
              .slideX(begin: 0.05, end: 0);
        }),

        const SizedBox(height: 24),

        // Récapitulatif prix
        _PriceSummary(cart: cart),
      ],
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

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AmaraColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AmaraColors.divider),
      ),
      child: Row(
        children: [
          // Emoji
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AmaraColors.bgAlt,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                item.imageEmoji,
                style: const TextStyle(fontSize: 30),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Nom + prix
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: AmaraTextStyles.labelMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  cartItem.formattedSubtotal,
                  style: AmaraTextStyles.labelSmall.copyWith(
                    color: AmaraColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          // Contrôle quantité
          _QuantityControl(
            quantity: cartItem.quantity,
            onDecrement: () {
              HapticFeedback.lightImpact();
              ref.read(cartProvider.notifier).removeItem(item.id);
            },
            onIncrement: () {
              HapticFeedback.lightImpact();
              // On doit passer restaurantId et restaurantName pour addItem
              // Le cart les connaît déjà, donc on récupère depuis l'état
              final cartState = ref.read(cartProvider);
              ref.read(cartProvider.notifier).addItem(
                    item,
                    cartState.restaurantId ?? '',
                    cartState.restaurantName ?? '',
                  );
            },
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
        color: AmaraColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AmaraColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Récapitulatif', style: AmaraTextStyles.labelMedium),
          const SizedBox(height: 14),
          _Row(label: 'Sous-total', value: cart.formattedSubtotal),
          const SizedBox(height: 8),
          _Row(
            label: 'Livraison',
            value: cart.formattedDeliveryFee,
            valueColor: cart.deliveryFee == 0
                ? AmaraColors.success
                : AmaraColors.textPrimary,
          ),
          const SizedBox(height: 14),
          Container(height: 1, color: AmaraColors.divider),
          const SizedBox(height: 14),
          _Row(
            label: 'Total',
            value: cart.formattedTotal,
            bold: true,
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  final Color? valueColor;

  const _Row({
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
          child: Text(
            label,
            style: style.copyWith(
              color: bold ? AmaraColors.textPrimary : AmaraColors.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: style.copyWith(
            color: valueColor ??
                (bold ? AmaraColors.primary : AmaraColors.textPrimary),
            fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
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
          20, 12, 20, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: AmaraColors.bgCard,
        border: Border(top: BorderSide(color: AmaraColors.divider)),
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
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.credit_card_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                'Commander · ${cart.formattedTotal}',
                style: AmaraTextStyles.labelMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
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
    return Container(
      decoration: BoxDecoration(
        color: AmaraColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AmaraColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Btn(icon: Icons.remove_rounded, onTap: onDecrement),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '$quantity',
              style: AmaraTextStyles.labelMedium.copyWith(
                color: AmaraColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          _Btn(icon: Icons.add_rounded, onTap: onIncrement),
        ],
      ),
    );
  }
}

class _Btn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _Btn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AmaraColors.primary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }
}
