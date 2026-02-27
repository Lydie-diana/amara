import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/core/constants/app_colors.dart';
import '../../../app/core/constants/app_text_styles.dart';
import '../../../app/models/restaurant_model.dart';
import '../../../app/providers/favorites_provider.dart';
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
    final isFree = restaurant.deliveryFee.toLowerCase().contains('gratuit');

    return GestureDetector(
      onTap: () => context.push('${AppRoutes.restaurantPath}/${restaurant.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: AmaraColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AmaraColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Photo ───────────────────────────────────────────────
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              child: SizedBox(
                height: 160,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (restaurant.imageUrl != null)
                      Image.network(
                        restaurant.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _EmojiPlaceholder(
                            emoji: restaurant.imageEmoji, color: _bgColor),
                        loadingBuilder: (_, child, progress) => progress == null
                            ? child
                            : _EmojiPlaceholder(
                                emoji: restaurant.imageEmoji, color: _bgColor),
                      )
                    else
                      _EmojiPlaceholder(
                          emoji: restaurant.imageEmoji, color: _bgColor),
                    // Gradient bas
                    Positioned(
                      bottom: 0, left: 0, right: 0,
                      child: Container(
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.45),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Statut (haut gauche)
                    Positioned(
                      top: 12, left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: restaurant.isOpen
                              ? AmaraColors.success
                              : AmaraColors.muted,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 5, height: 5,
                              decoration: const BoxDecoration(
                                  color: Colors.white, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 4),
                            Text(restaurant.isOpen ? 'Ouvert' : 'Fermé',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ),
                    // Populaire (haut droit)
                    if (restaurant.isFeatured)
                      Positioned(
                        top: 12, right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AmaraColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('⭐ Populaire',
                              style: AmaraTextStyles.caption.copyWith(
                                  color: Colors.white, fontWeight: FontWeight.w700)),
                        ),
                      ),
                    // Favoris (haut droit, sous le badge populaire)
                    Positioned(
                      top: restaurant.isFeatured ? 40 : 12,
                      right: 12,
                      child: Consumer(
                        builder: (context, ref, _) {
                          final isFav = ref.watch(isFavoriteProvider(restaurant.id));
                          return GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              ref.read(favoritesProvider.notifier).toggleFavorite(restaurant.id);
                            },
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.9),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                color: isFav ? AmaraColors.primary : AmaraColors.textSecondary,
                                size: 16,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Infos ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(restaurant.name,
                            style: AmaraTextStyles.labelSmall.copyWith(
                                fontWeight: FontWeight.w800),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded,
                              color: Color(0xFFFFC107), size: 14),
                          const SizedBox(width: 3),
                          Text(restaurant.rating.toStringAsFixed(1),
                              style: AmaraTextStyles.caption.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AmaraColors.textPrimary)),
                          Text(' (${restaurant.reviewCount})',
                              style: AmaraTextStyles.caption.copyWith(
                                  color: AmaraColors.muted)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(restaurant.cuisine,
                          style: AmaraTextStyles.caption.copyWith(
                              color: AmaraColors.muted)),
                      const Spacer(),
                      if (restaurant.likePercent > 0) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE74C3C).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.thumb_up_rounded,
                                  size: 10, color: Color(0xFFE74C3C)),
                              const SizedBox(width: 3),
                              Text('${restaurant.likePercent}%',
                                  style: AmaraTextStyles.caption.copyWith(
                                      color: const Color(0xFFE74C3C),
                                      fontWeight: FontWeight.w800,
                                      fontSize: 10)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(_formatCustomers(restaurant.totalCustomers),
                            style: AmaraTextStyles.caption.copyWith(
                                color: AmaraColors.muted, fontSize: 10)),
                      ],
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Chips sans bordure
                  Row(
                    children: [
                      _InfoPill(
                        icon: Icons.access_time_rounded,
                        label: restaurant.deliveryTime,
                        color: const Color(0xFF1F172B),
                      ),
                      const SizedBox(width: 8),
                      _InfoPill(
                        icon: Icons.delivery_dining_rounded,
                        label: restaurant.deliveryFee,
                        color: isFree ? AmaraColors.success : AmaraColors.primary,
                      ),
                      if (restaurant.minOrder > 0) ...[
                        const SizedBox(width: 8),
                        _InfoPill(
                          icon: Icons.shopping_bag_outlined,
                          label: 'Min ${restaurant.minOrder.toStringAsFixed(0)} F',
                          color: AmaraColors.muted,
                        ),
                      ],
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
        width: 180,
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
                child: SizedBox(
                  height: 112,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (restaurant.imageUrl != null)
                        Image.network(
                          restaurant.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _EmojiPlaceholder(
                              emoji: restaurant.imageEmoji, color: _bgColor),
                          loadingBuilder: (_, child, progress) => progress == null
                              ? child
                              : _EmojiPlaceholder(
                                  emoji: restaurant.imageEmoji, color: _bgColor),
                        )
                      else
                        _EmojiPlaceholder(
                            emoji: restaurant.imageEmoji, color: _bgColor),
                      Positioned(
                        bottom: 0, left: 0, right: 0,
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
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
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(restaurant.name,
                        style: AmaraTextStyles.labelMedium,
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(restaurant.cuisine,
                        style: AmaraTextStyles.caption.copyWith(
                            color: AmaraColors.muted),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            color: Color(0xFFFFC107), size: 12),
                        const SizedBox(width: 3),
                        Text(restaurant.rating.toStringAsFixed(1),
                            style: AmaraTextStyles.caption.copyWith(
                                fontWeight: FontWeight.w700)),
                        const SizedBox(width: 6),
                        _InfoPill(
                          icon: Icons.access_time_rounded,
                          label: restaurant.deliveryTime,
                          color: const Color(0xFF1F172B),
                          small: true,
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

  Color get _bgColor {
    const colors = [
      Color(0xFFE8E0F5), Color(0xFFD4EDE3), Color(0xFFFCE4EC),
      Color(0xFFE3EDF9), Color(0xFFFFF3E0), Color(0xFFE0F4F4),
    ];
    return colors[restaurant.id.hashCode % colors.length];
  }
}

class _EmojiPlaceholder extends StatelessWidget {
  final String emoji;
  final Color color;
  const _EmojiPlaceholder({required this.emoji, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      child: Center(child: Text(emoji, style: const TextStyle(fontSize: 48))),
    );
  }
}

// Pill sans bordure — fond coloré léger uniquement
class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool small;

  const _InfoPill({
    required this.icon,
    required this.label,
    required this.color,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    final fontSize = small ? 10.0 : 11.0;
    final iconSize = small ? 11.0 : 12.0;

    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: small ? 6 : 8,
          vertical: small ? 3 : 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: iconSize, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  color: color,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

String _formatCustomers(int count) {
  if (count <= 0) return '';
  if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}k clients';
  return '$count clients';
}
