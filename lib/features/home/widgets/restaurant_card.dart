import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/core/constants/app_colors.dart';
import '../../../app/core/constants/app_text_styles.dart';
import '../../../app/models/restaurant_model.dart';
import '../../../app/router/app_routes.dart';

class RestaurantCard extends StatelessWidget {
  final Restaurant restaurant;
  final bool compact;

  const RestaurantCard({
    super.key,
    required this.restaurant,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return compact ? _buildCompact(context) : _buildFull(context);
  }

  Widget _buildFull(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push('${AppRoutes.restaurantPath}/${restaurant.id}');
      },
      child: Container(
        decoration: BoxDecoration(
          color: AmaraColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AmaraColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image area
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              child: Container(
                height: 140,
                color: _imageBgColor,
                child: Stack(
                  children: [
                    Center(
                      child: Text(
                        restaurant.imageEmoji,
                        style: const TextStyle(fontSize: 60),
                      ),
                    ),
                    Positioned(
                      top: 12, left: 12,
                      child: _StatusBadge(isOpen: restaurant.isOpen),
                    ),
                    if (restaurant.isFeatured)
                      Positioned(
                        top: 12, right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AmaraColors.primary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text('⭐ Populaire',
                            style: AmaraTextStyles.caption.copyWith(
                              color: Colors.white, fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(restaurant.name, style: AmaraTextStyles.h3,
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded,
                              color: Color(0xFFF39C12), size: 15),
                          const SizedBox(width: 3),
                          Text(restaurant.rating.toStringAsFixed(1),
                              style: AmaraTextStyles.labelMedium),
                          Text(' (${restaurant.reviewCount})',
                              style: AmaraTextStyles.caption),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(restaurant.cuisine, style: AmaraTextStyles.bodySmall),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _InfoChip(icon: Icons.access_time_rounded,
                          label: restaurant.deliveryTime),
                      const SizedBox(width: 8),
                      _InfoChip(
                        icon: Icons.delivery_dining_rounded,
                        label: restaurant.deliveryFee,
                        isHighlighted: restaurant.deliveryFee == 'Gratuit',
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

  Widget _buildCompact(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('${AppRoutes.restaurantPath}/${restaurant.id}'),
      child: SizedBox(
        width: 176,
        child: Container(
          decoration: BoxDecoration(
            color: AmaraColors.bgCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AmaraColors.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                child: Container(
                  height: 108,
                  color: _imageBgColor,
                  child: Center(
                    child: Text(restaurant.imageEmoji,
                        style: const TextStyle(fontSize: 44)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(restaurant.name, style: AmaraTextStyles.labelMedium,
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(restaurant.cuisine, style: AmaraTextStyles.caption,
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            color: Color(0xFFF39C12), size: 13),
                        const SizedBox(width: 3),
                        Text(restaurant.rating.toStringAsFixed(1),
                          style: AmaraTextStyles.caption.copyWith(
                            color: AmaraColors.textPrimary, fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.access_time_rounded,
                            color: AmaraColors.muted, size: 12),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(restaurant.deliveryTime,
                              style: AmaraTextStyles.caption,
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color get _imageBgColor {
    const colors = [
      Color(0xFFE8E0F5), Color(0xFFD4EDE3), Color(0xFFFCE4EC),
      Color(0xFFE3EDF9), Color(0xFFFFF3E0), Color(0xFFE0F4F4),
    ];
    return colors[restaurant.id.hashCode % colors.length];
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isOpen;
  const _StatusBadge({required this.isOpen});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isOpen ? AmaraColors.success : AmaraColors.muted,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5, height: 5,
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(isOpen ? 'Ouvert' : 'Fermé',
            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isHighlighted;

  const _InfoChip({
    required this.icon,
    required this.label,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: isHighlighted
            ? AmaraColors.success.withValues(alpha: 0.1)
            : AmaraColors.bgAlt,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isHighlighted
              ? AmaraColors.success.withValues(alpha: 0.3)
              : AmaraColors.divider,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12,
              color: isHighlighted ? AmaraColors.success : AmaraColors.muted),
          const SizedBox(width: 4),
          Text(label,
            style: TextStyle(
              color: isHighlighted ? AmaraColors.success : AmaraColors.muted,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
