import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/core/constants/app_colors.dart';
import '../../../app/core/constants/app_text_styles.dart';
import '../../../app/models/restaurant_model.dart';
import '../../../app/providers/cart_provider.dart';
import '../../menu_item/menu_item_detail_screen.dart';

class MenuCategorySection extends ConsumerWidget {
  final MenuCategory category;
  final String restaurantId;
  final String restaurantName;
  final String? restaurantImageUrl;
  final List<MenuItem> allItems;
  final int animationDelay;

  const MenuCategorySection({
    super.key,
    required this.category,
    required this.restaurantId,
    required this.restaurantName,
    this.restaurantImageUrl,
    this.allItems = const [],
    this.animationDelay = 0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 4),
          child: Text(category.name, style: AmaraTextStyles.h3),
        ),
        ...category.items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final companions =
              allItems.where((i) => i.id != item.id).take(4).toList();
          return _MenuItemTile(
            item: item,
            restaurantId: restaurantId,
            restaurantName: restaurantName,
            restaurantImageUrl: restaurantImageUrl,
            companions: companions,
          )
              .animate()
              .fadeIn(
                delay: Duration(milliseconds: animationDelay + index * 60),
                duration: 350.ms,
              )
              .slideX(begin: 0.05, end: 0);
        }),
      ],
    );
  }
}

// ─── Tuile article ────────────────────────────────────────────────────────────

class _MenuItemTile extends ConsumerWidget {
  final MenuItem item;
  final String restaurantId;
  final String restaurantName;
  final String? restaurantImageUrl;
  final List<MenuItem> companions;

  const _MenuItemTile({
    required this.item,
    required this.restaurantId,
    required this.restaurantName,
    this.restaurantImageUrl,
    this.companions = const [],
  });

  void _openDetail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MenuItemDetailScreen(
          item: item,
          restaurantId: restaurantId,
          restaurantName: restaurantName,
          restaurantImageUrl: restaurantImageUrl,
          companions: companions,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final quantity = cart.quantityFor(item.id);
    final inCart = quantity > 0;
    final hasOptions = item.optionGroups.isNotEmpty;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _openDetail(context);
      },
      child: Container(
        height: 140,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        decoration: BoxDecoration(
          color: AmaraColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: inCart
                ? AmaraColors.primary.withValues(alpha: 0.3)
                : AmaraColors.divider,
            width: inCart ? 1.5 : 1,
          ),
        ),
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            // ── Infos (gauche) ────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(13, 12, 8, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    // Nom + badges
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item.name,
                            style: AmaraTextStyles.labelMedium
                                .copyWith(fontWeight: FontWeight.w700),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (item.isPopular || item.isVegetarian || item.isSpicy)
                          Row(children: [
                            if (item.isPopular)
                              _Badge(label: '⭐', bgColor: const Color(0xFFFFF3E0)),
                            if (item.isVegetarian)
                              _Badge(label: '🌱', bgColor: const Color(0xFFE8F5E9)),
                            if (item.isSpicy)
                              _Badge(label: '🌶️', bgColor: const Color(0xFFFFEBEE)),
                          ]),
                      ],
                    ),
                    const SizedBox(height: 2),

                    // Description (2 lignes)
                    if (item.description.isNotEmpty)
                      Text(
                        item.description,
                        style: AmaraTextStyles.caption.copyWith(
                          color: AmaraColors.textSecondary,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                    // Stats : % like + nb commandes
                    if (item.hasStats) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (item.likePercent > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE74C3C).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.thumb_up_rounded,
                                      size: 9, color: Color(0xFFE74C3C)),
                                  const SizedBox(width: 2),
                                  Text(
                                    '${item.likePercent}%',
                                    style: AmaraTextStyles.caption.copyWith(
                                      color: const Color(0xFFE74C3C),
                                      fontWeight: FontWeight.w800,
                                      fontSize: 9,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (item.orderCount > 0) ...[
                            if (item.likePercent > 0) const SizedBox(width: 6),
                            Text(
                              '${item.formattedOrderCount} commandes',
                              style: AmaraTextStyles.caption.copyWith(
                                color: AmaraColors.textSecondary,
                                fontWeight: FontWeight.w600,
                                fontSize: 9,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],

                    const Spacer(),

                    // Prix + contrôle quantité
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (item.hasActiveDiscount) ...[
                          Text(
                            item.formattedPrice,
                            style: AmaraTextStyles.caption.copyWith(
                              color: AmaraColors.muted,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            item.formattedEffectivePrice,
                            style: AmaraTextStyles.labelMedium.copyWith(
                              color: AmaraColors.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: AmaraColors.primary,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '-${item.discountPercent!.toInt()}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ] else
                          Text(
                            item.formattedPrice,
                            style: AmaraTextStyles.labelMedium.copyWith(
                              color: AmaraColors.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        const Spacer(),
                        if (!item.isAvailable)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: AmaraColors.bgAlt,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AmaraColors.divider),
                            ),
                            child: Text('Indisponible',
                                style: AmaraTextStyles.caption
                                    .copyWith(color: AmaraColors.muted, fontSize: 10)),
                          )
                        else if (inCart)
                          _QuantityControl(
                            quantity: quantity,
                            onDecrement: () {
                              HapticFeedback.lightImpact();
                              ref.read(cartProvider.notifier).removeItem(item.id);
                            },
                            onIncrement: () {
                              HapticFeedback.lightImpact();
                              _openDetail(context);
                            },
                          )
                        else
                          _AddButton(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              _openDetail(context);
                            },
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── Image (droite, pleine hauteur) ──────────────────────
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(right: Radius.circular(15)),
              child: SizedBox(
                width: 112,
                child: item.imageUrl != null
                    ? Image.network(
                        item.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _EmojiImg(
                            emoji: item.imageEmoji, bgColor: _itemBg(item.id)),
                        loadingBuilder: (_, child, progress) => progress == null
                            ? child
                            : _EmojiImg(
                                emoji: item.imageEmoji, bgColor: _itemBg(item.id)),
                      )
                    : _EmojiImg(emoji: item.imageEmoji, bgColor: _itemBg(item.id)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Composants communs ───────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  final String label;
  final Color bgColor;
  const _Badge({required this.label, required this.bgColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 4),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label, style: const TextStyle(fontSize: 10)),
    );
  }
}

class _AddButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AmaraColors.primary,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: AmaraColors.primary.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
      ),
    );
  }
}

// ─── Image emoji pleine hauteur ───────────────────────────────────────────────

class _EmojiImg extends StatelessWidget {
  final String emoji;
  final Color bgColor;
  const _EmojiImg({required this.emoji, required this.bgColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: bgColor,
      child: Center(
        child: Text(emoji, style: const TextStyle(fontSize: 44)),
      ),
    );
  }
}

Color _itemBg(String id) {
  const colors = [
    Color(0xFFE8E0F5), Color(0xFFD4EDE3), Color(0xFFFCE4EC),
    Color(0xFFE3EDF9), Color(0xFFFFF3E0), Color(0xFFE0F4F4),
  ];
  return colors[id.hashCode % colors.length];
}

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
        border: Border.all(color: AmaraColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _CtrlBtn(icon: Icons.remove_rounded, onTap: onDecrement),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text('$quantity',
                style: AmaraTextStyles.labelMedium.copyWith(
                    color: AmaraColors.primary, fontWeight: FontWeight.w800)),
          ),
          _CtrlBtn(icon: Icons.add_rounded, onTap: onIncrement),
        ],
      ),
    );
  }
}

class _CtrlBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CtrlBtn({required this.icon, required this.onTap});

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
