import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/core/constants/app_colors.dart';
import '../../../app/core/constants/app_text_styles.dart';
import '../../../app/models/restaurant_model.dart';
import '../../../app/providers/cart_provider.dart';

/// Section "Les plats les plus aimés" — top 5 par likeCount.
class TopDishesSection extends StatelessWidget {
  final List<MenuItem> items;
  final String restaurantId;
  final String restaurantName;

  const TopDishesSection({
    super.key,
    required this.items,
    required this.restaurantId,
    required this.restaurantName,
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
                Text('Les plus aimés',
                    style: AmaraTextStyles.h3),
                const Spacer(),
                Text(
                  'Par popularité',
                  style: AmaraTextStyles.caption
                      .copyWith(color: AmaraColors.muted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 160,
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

  const _TopDishCard({
    required this.item,
    required this.rank,
    required this.restaurantId,
    required this.restaurantName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final quantity = cart.quantityFor(item.id);
    final inCart = quantity > 0;

    return Container(
      width: 130,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AmaraColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: inCart
              ? AmaraColors.primary.withValues(alpha: 0.35)
              : AmaraColors.divider,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Médaille + emoji
          Stack(
            children: [
              Container(
                width: double.infinity,
                height: 64,
                decoration: BoxDecoration(
                  color: AmaraColors.bgAlt,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(item.imageEmoji,
                      style: const TextStyle(fontSize: 34)),
                ),
              ),
              Positioned(
                top: 4,
                left: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: _rankColor(rank),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '#$rank',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Nom
          Text(
            item.name,
            style: AmaraTextStyles.caption
                .copyWith(fontWeight: FontWeight.w700),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),

          // Likes
          Row(
            children: [
              const Icon(Icons.favorite_rounded,
                  size: 11, color: AmaraColors.error),
              const SizedBox(width: 3),
              Text(
                '${item.likeCount}',
                style: AmaraTextStyles.caption
                    .copyWith(color: AmaraColors.muted),
              ),
            ],
          ),
          const Spacer(),

          // Prix + bouton
          Row(
            children: [
              Expanded(
                child: Text(
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
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color:
                          AmaraColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$quantity',
                          style: AmaraTextStyles.caption.copyWith(
                            color: AmaraColors.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    ref.read(cartProvider.notifier).addItem(
                          item,
                          restaurantId,
                          restaurantName,
                        );
                  },
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: AmaraColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.add_rounded,
                        color: Colors.white, size: 14),
                  ),
                ),
            ],
          ),
        ],
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
