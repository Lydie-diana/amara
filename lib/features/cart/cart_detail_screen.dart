import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/core/constants/app_colors.dart';
import '../../app/core/constants/app_text_styles.dart';
import '../../app/core/l10n/app_localizations.dart';
import '../../app/models/cart_model.dart';
import '../../app/providers/cart_provider.dart';
import '../../app/router/app_routes.dart';

/// Page détail du panier d'un restaurant (style Uber Eats).
/// Affiche les articles, contrôle quantité, note, sous-total,
/// et bouton "Passer au paiement".
class CartDetailScreen extends ConsumerStatefulWidget {
  final String restaurantId;
  const CartDetailScreen({super.key, required this.restaurantId});

  @override
  ConsumerState<CartDetailScreen> createState() => _CartDetailScreenState();
}

class _CartDetailScreenState extends ConsumerState<CartDetailScreen> {

  CartRestaurantGroup? _findGroup(CartState cart) {
    try {
      return cart.groups.firstWhere(
          (g) => g.restaurantId == widget.restaurantId);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final group = _findGroup(cart);

    // Si le panier de ce restaurant est vide, retour auto
    if (group == null || group.items.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.pop();
      });
      return const Scaffold(backgroundColor: AmaraColors.bg);
    }

    final bottom = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AmaraColors.bg,
      body: Column(
        children: [
          // ── Header ─────────────────────────────────────────────────────
          _Header(
            restaurantName: group.restaurantName,
            restaurantId: group.restaurantId,
          ),

          // ── Contenu scrollable ─────────────────────────────────────────
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              physics: const BouncingScrollPhysics(),
              children: [
                // Articles
                ...group.items.map((item) => _CartItemTile(cartItem: item)),

                const SizedBox(height: 16),

                // Bouton "+ Ajouter des articles"
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    context.push(
                        '${AppRoutes.restaurantPath}/${group.restaurantId}');
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: AmaraColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add_rounded,
                            size: 18, color: AmaraColors.primary),
                        const SizedBox(width: 6),
                        Text(
                          AppLocalizations.of(context).cartAddItems,
                          style: AmaraTextStyles.labelSmall.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AmaraColors.primary),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                Container(height: 1, color: AmaraColors.divider),
                const SizedBox(height: 20),

                // Sous-total
                Row(
                  children: [
                    Text(
                      AppLocalizations.of(context).cartSubtotal,
                      style: AmaraTextStyles.labelLarge
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    Text(
                      '${group.subtotal.toStringAsFixed(0)} F',
                      style: AmaraTextStyles.labelLarge.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AmaraColors.primary),
                    ),
                  ],
                ),

                const SizedBox(height: 80),
              ],
            ),
          ),

          // ── Barre "Passer au paiement" ─────────────────────────────────
          Container(
            padding: EdgeInsets.fromLTRB(16, 12, 16, bottom + 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AmaraColors.divider)),
            ),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                context.push(
                    '${AppRoutes.checkout}?restaurantId=${group.restaurantId}');
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: AmaraColors.primary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    AppLocalizations.of(context).cartProceedToPayment,
                    style: AmaraTextStyles.button,
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

// ─── Header ──────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final String restaurantName;
  final String restaurantId;

  const _Header({
    required this.restaurantName,
    required this.restaurantId,
  });

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Container(
      color: AmaraColors.primary,
      padding: EdgeInsets.fromLTRB(16, top + 12, 16, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                  child: const Icon(Icons.close_rounded,
                      color: Colors.white, size: 20),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.push(
                      '${AppRoutes.restaurantPath}/$restaurantId');
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.storefront_rounded,
                      color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            restaurantName,
            style: AmaraTextStyles.h1.copyWith(
                fontWeight: FontWeight.w800, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

// ─── Tuile article panier ────────────────────────────────────────────────────

class _CartItemTile extends ConsumerWidget {
  final CartItem cartItem;
  const _CartItemTile({required this.cartItem});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final item = cartItem.item;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image du plat
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 72,
              height: 72,
              child: item.imageUrl != null
                  ? Image.network(
                      item.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _fallbackImage(item),
                    )
                  : _fallbackImage(item),
            ),
          ),
          const SizedBox(width: 12),

          // Nom + prix
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: AmaraTextStyles.labelMedium
                      .copyWith(fontWeight: FontWeight.w700),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${cartItem.unitPrice.toStringAsFixed(0)} F',
                  style: AmaraTextStyles.caption
                      .copyWith(color: AmaraColors.textSecondary),
                ),
                if (cartItem.selectedOptions.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    _optionsSummary(context),
                    style: AmaraTextStyles.caption
                        .copyWith(color: AmaraColors.muted, fontSize: 10),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Contrôle quantité
          _QuantityControl(cartItem: cartItem),
        ],
      ),
    );
  }

  String _optionsSummary(BuildContext context) {
    final count = cartItem.selectedOptions.values
        .fold(0, (sum, list) => sum + list.length);
    return AppLocalizations.of(context).cartOptionsSelected(count);
  }

  Widget _fallbackImage(dynamic item) {
    return Container(
      width: 72,
      height: 72,
      color: AmaraColors.bgAlt,
      child: Center(
        child: Text(item.imageEmoji, style: const TextStyle(fontSize: 30)),
      ),
    );
  }
}

// ─── Contrôle quantité ───────────────────────────────────────────────────────

class _QuantityControl extends ConsumerWidget {
  final CartItem cartItem;
  const _QuantityControl({required this.cartItem});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: AmaraColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Bouton supprimer / décrémenter
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              ref.read(cartProvider.notifier).removeItem(cartItem.item.id);
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                cartItem.quantity <= 1
                    ? Icons.delete_outline_rounded
                    : Icons.remove_rounded,
                size: 16,
                color: cartItem.quantity <= 1
                    ? AmaraColors.error
                    : AmaraColors.primary,
              ),
            ),
          ),

          // Quantité
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              '${cartItem.quantity}',
              style: AmaraTextStyles.labelSmall.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AmaraColors.textPrimary),
            ),
          ),

          // Incrémenter
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              ref.read(cartProvider.notifier).addItem(
                    cartItem.item,
                    cartItem.restaurantId,
                    cartItem.restaurantName,
                    restaurantImageUrl: cartItem.restaurantImageUrl,
                  );
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.add_rounded,
                  size: 16, color: AmaraColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
