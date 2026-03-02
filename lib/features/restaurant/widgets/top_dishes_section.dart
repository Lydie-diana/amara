import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/core/constants/app_colors.dart';
import '../../../app/core/constants/app_text_styles.dart';
import '../../../app/core/l10n/app_localizations.dart';
import '../../../app/models/restaurant_model.dart';
import '../../../app/providers/cart_provider.dart';
import '../../menu_item/menu_item_detail_screen.dart';

/// Section "Les plats les plus aimés" — top 5 par rating.
class TopDishesSection extends StatelessWidget {
  final List<MenuItem> items;
  final String restaurantId;
  final String restaurantName;
  final String? restaurantImageUrl;

  const TopDishesSection({
    super.key,
    required this.items,
    required this.restaurantId,
    required this.restaurantName,
    this.restaurantImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Row(
              children: [
                const Text('🏆', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Text(AppLocalizations.of(context).restaurantMostLoved, style: AmaraTextStyles.h3),
                const Spacer(),
                Text(
                  AppLocalizations.of(context).restaurantByPopularity,
                  style: AmaraTextStyles.caption
                      .copyWith(color: AmaraColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(right: 20),
              physics: const BouncingScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (context, index) => _TopDishCard(
                item: items[index],
                rank: index + 1,
                restaurantId: restaurantId,
                restaurantName: restaurantName,
                restaurantImageUrl: restaurantImageUrl,
                companions: items.where((i) => i.id != items[index].id).take(4).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopDishCard extends ConsumerWidget {
  final MenuItem item;
  final int rank;
  final String restaurantId;
  final String restaurantName;
  final String? restaurantImageUrl;
  final List<MenuItem> companions;

  const _TopDishCard({
    required this.item,
    required this.rank,
    required this.restaurantId,
    required this.restaurantName,
    this.restaurantImageUrl,
    this.companions = const [],
  });

  void _openDetail(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => MenuItemDetailScreen(
        item: item,
        restaurantId: restaurantId,
        restaurantName: restaurantName,
        restaurantImageUrl: restaurantImageUrl,
        companions: companions,
      ),
    ));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final quantity = cart.quantityFor(item.id);
    final inCart = quantity > 0;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _openDetail(context);
      },
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: AmaraColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: inCart
                ? AmaraColors.primary.withValues(alpha: 0.35)
                : AmaraColors.divider,
            width: inCart ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image réelle + badge rang ─────────────────────────────
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                  child: SizedBox(
                    width: double.infinity,
                    height: 100,
                    child: item.imageUrl != null
                        ? Image.network(
                            item.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _EmojiPlaceholder(
                              emoji: item.imageEmoji,
                              color: _itemBg(item.id),
                            ),
                            loadingBuilder: (_, child, progress) =>
                                progress == null
                                    ? child
                                    : _EmojiPlaceholder(
                                        emoji: item.imageEmoji,
                                        color: _itemBg(item.id),
                                      ),
                          )
                        : _EmojiPlaceholder(
                            emoji: item.imageEmoji,
                            color: _itemBg(item.id),
                          ),
                  ),
                ),
                // Badge rang
                Positioned(
                  top: 6,
                  left: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: _rankColor(rank),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Text(
                      '#$rank',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                // Dégradé bas pour lisibilité
                Positioned(
                  bottom: 0, left: 0, right: 0,
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(0)),
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.4),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // ── Infos ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nom
                  Text(
                    item.name,
                    style: AmaraTextStyles.caption.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AmaraColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // % like + nb clients
                  if (item.hasStats) ...[
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
                          const SizedBox(width: 5),
                          Text(
                            AppLocalizations.of(context).restaurantOrders(item.formattedOrderCount),
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
                  const SizedBox(height: 6),

                  // Prix + bouton
                  Row(
                    children: [
                      Expanded(
                        child: item.hasActiveDiscount
                            ? Row(
                                children: [
                                  Text(
                                    item.formattedPrice,
                                    style: AmaraTextStyles.caption.copyWith(
                                      color: AmaraColors.muted,
                                      decoration: TextDecoration.lineThrough,
                                      fontSize: 9,
                                    ),
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    item.formattedEffectivePrice,
                                    style: AmaraTextStyles.caption.copyWith(
                                      color: AmaraColors.primary,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(width: 3),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: AmaraColors.primary,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '-${item.discountPercent!.toInt()}%',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 7,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Text(
                                item.formattedPrice,
                                style: AmaraTextStyles.caption.copyWith(
                                  color: AmaraColors.primary,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                      ),
                      if (inCart)
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            ref.read(cartProvider.notifier).removeItem(item.id);
                          },
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: AmaraColors.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: AmaraColors.primary.withValues(alpha: 0.3)),
                            ),
                            child: Center(
                              child: Text(
                                '$quantity',
                                style: AmaraTextStyles.caption.copyWith(
                                  color: AmaraColors.primary,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        )
                      else
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            _openDetail(context);
                          },
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: AmaraColors.primary,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: AmaraColors.primary.withValues(alpha: 0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.add_rounded,
                                color: Colors.white, size: 16),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _rankColor(int rank) {
    return switch (rank) {
      1 => const Color(0xFFF39C12),
      2 => const Color(0xFF95A5A6),
      3 => const Color(0xFFCD7F32),
      _ => AmaraColors.primary,
    };
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

class _EmojiPlaceholder extends StatelessWidget {
  final String emoji;
  final Color color;
  const _EmojiPlaceholder({required this.emoji, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      child: Center(child: Text(emoji, style: const TextStyle(fontSize: 38))),
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

