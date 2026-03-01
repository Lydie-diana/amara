import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/core/constants/app_colors.dart';
import '../../app/core/constants/app_text_styles.dart';
import '../../app/models/restaurant_model.dart';
import '../../app/providers/restaurant_provider.dart';
import '../../app/router/app_routes.dart';
import '../home/widgets/restaurant_card.dart';

// ─── Providers publics ────────────────────────────────────────────────────────

final searchQueryProvider = StateProvider<String>((ref) => '');

// Filtres avancés
final _sortProvider = StateProvider<_SortOption>((ref) => _SortOption.recommended);
final _foodTypeProvider = StateProvider<String?>((ref) => null);
final _maxDeliveryFeeProvider = StateProvider<bool>((ref) => false);
final _openNowProvider = StateProvider<bool>((ref) => false);
final _minRatingProvider = StateProvider<double>((ref) => 0.0);
final _takeawayProvider = StateProvider<bool>((ref) => false);

enum _SortOption { recommended, rating, distance, deliveryTime, price }

extension _SortLabel on _SortOption {
  String get label {
    switch (this) {
      case _SortOption.recommended:
        return 'Recommandé';
      case _SortOption.rating:
        return 'Mieux notés';
      case _SortOption.distance:
        return 'Distance';
      case _SortOption.deliveryTime:
        return 'Rapidité';
      case _SortOption.price:
        return 'Prix livraison';
    }
  }

  IconData get icon {
    switch (this) {
      case _SortOption.recommended:
        return Icons.auto_awesome_rounded;
      case _SortOption.rating:
        return Icons.star_rounded;
      case _SortOption.distance:
        return Icons.near_me_rounded;
      case _SortOption.deliveryTime:
        return Icons.speed_rounded;
      case _SortOption.price:
        return Icons.savings_rounded;
    }
  }
}

double _userLat = 5.3600;
double _userLng = -3.9800;

double _distanceFor(Restaurant r) {
  if (r.latitude == null || r.longitude == null) return 99.0;
  const earthRadius = 6371.0;
  final dLat = _toRad(r.latitude! - _userLat);
  final dLng = _toRad(r.longitude! - _userLng);
  final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(_toRad(_userLat)) *
          math.cos(_toRad(r.latitude!)) *
          math.sin(dLng / 2) *
          math.sin(dLng / 2);
  final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  return earthRadius * c;
}

double _toRad(double deg) => deg * math.pi / 180;

String _distanceLabel(Restaurant r) {
  final d = _distanceFor(r);
  if (d >= 99) return '';
  return d < 1 ? '${(d * 1000).toInt()} m' : '${d.toStringAsFixed(1)} km';
}

// Provider filtré
final _filteredProvider = Provider<AsyncValue<List<Restaurant>>>(
  (ref) {
    final allAsync = ref.watch(restaurantListProvider);
    final query = ref.watch(searchQueryProvider).toLowerCase().trim();
    final foodType = ref.watch(_foodTypeProvider);
    final freeOnly = ref.watch(_maxDeliveryFeeProvider);
    final openOnly = ref.watch(_openNowProvider);
    final minRating = ref.watch(_minRatingProvider);
    final takeaway = ref.watch(_takeawayProvider);
    final sort = ref.watch(_sortProvider);

    return allAsync.whenData((list) {
      var r = list;
      if (foodType != null) {
        r = r
            .where((x) =>
                x.cuisine.toLowerCase().contains(foodType.toLowerCase()) ||
                x.tags.any(
                    (t) => t.toLowerCase().contains(foodType.toLowerCase())))
            .toList();
      }
      if (freeOnly) {
        r = r
            .where(
                (x) => x.deliveryFee.toLowerCase().contains('gratuit'))
            .toList();
      }
      if (openOnly) r = r.where((x) => x.isOpen).toList();
      if (takeaway) r = r.where((x) => x.serviceModes.contains(ServiceMode.takeaway)).toList();
      if (minRating > 0) r = r.where((x) => x.rating >= minRating).toList();
      if (query.isNotEmpty) {
        r = r
            .where((x) =>
                x.name.toLowerCase().contains(query) ||
                x.cuisine.toLowerCase().contains(query) ||
                x.tags.any((t) => t.toLowerCase().contains(query)))
            .toList();
      }

      switch (sort) {
        case _SortOption.rating:
          r.sort((a, b) => b.rating.compareTo(a.rating));
        case _SortOption.distance:
          r.sort((a, b) => _distanceFor(a).compareTo(_distanceFor(b)));
        case _SortOption.deliveryTime:
          r.sort((a, b) => a.deliveryTime.compareTo(b.deliveryTime));
        case _SortOption.price:
          r.sort((a, b) {
            final fa =
                a.deliveryFee.toLowerCase().contains('gratuit') ? 0 : 1;
            final fb =
                b.deliveryFee.toLowerCase().contains('gratuit') ? 0 : 1;
            return fa.compareTo(fb);
          });
        case _SortOption.recommended:
          r.sort((a, b) =>
              (b.isFeatured ? 1 : 0).compareTo(a.isFeatured ? 1 : 0));
      }
      return r;
    });
  },
);

// ─── Écran principal ──────────────────────────────────────────────────────────

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final q = ref.read(searchQueryProvider);
      if (q.isNotEmpty && _controller.text != q) {
        _controller.text = q;
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _resetAll() {
    _controller.clear();
    ref.read(searchQueryProvider.notifier).state = '';
    ref.read(_sortProvider.notifier).state = _SortOption.recommended;
    ref.read(_foodTypeProvider.notifier).state = null;
    ref.read(_maxDeliveryFeeProvider.notifier).state = false;
    ref.read(_openNowProvider.notifier).state = false;
    ref.read(_minRatingProvider.notifier).state = 0.0;
    ref.read(_takeawayProvider.notifier).state = false;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(searchQueryProvider, (_, next) {
      if (_controller.text != next) _controller.text = next;
    });

    final query = ref.watch(searchQueryProvider);
    final sort = ref.watch(_sortProvider);
    final foodType = ref.watch(_foodTypeProvider);
    final freeOnly = ref.watch(_maxDeliveryFeeProvider);
    final openOnly = ref.watch(_openNowProvider);
    final takeaway = ref.watch(_takeawayProvider);
    final minRating = ref.watch(_minRatingProvider);
    final filtered = ref.watch(_filteredProvider);

    final hasFilters = foodType != null ||
        freeOnly ||
        openOnly ||
        takeaway ||
        minRating > 0 ||
        sort != _SortOption.recommended;

    return Scaffold(
      backgroundColor: AmaraColors.bg,
      body: Column(
        children: [
          // ── Header + Search bar ──
          _SearchHeader(
            controller: _controller,
            focusNode: _focusNode,
            onChanged: (v) =>
                ref.read(searchQueryProvider.notifier).state = v,
            onClear: () {
              _controller.clear();
              ref.read(searchQueryProvider.notifier).state = '';
            },
            onFilterTap: () => _showFilterSheet(context),
          ),

          // ── Chips filtres ──
          _FilterChips(
            sort: sort,
            freeOnly: freeOnly,
            openOnly: openOnly,
            takeaway: takeaway,
            hasFilters: hasFilters,
            onSortTap: () => _showSortSheet(context),
            onFreeTap: () => ref
                .read(_maxDeliveryFeeProvider.notifier)
                .state = !freeOnly,
            onOpenTap: () =>
                ref.read(_openNowProvider.notifier).state = !openOnly,
            onTakeawayTap: () =>
                ref.read(_takeawayProvider.notifier).state = !takeaway,
            onBestRatedTap: () {
              final current = ref.read(_sortProvider);
              ref.read(_sortProvider.notifier).state =
                  current == _SortOption.rating
                      ? _SortOption.recommended
                      : _SortOption.rating;
            },
            onResetFilters: _resetAll,
          ),

          // ── Contenu ──
          Expanded(
            child: filtered.when(
              loading: () => const Center(
                child:
                    CircularProgressIndicator(color: AmaraColors.primary),
              ),
              error: (e, _) => _ErrorState(message: e.toString()),
              data: (restaurants) {
                if (query.isEmpty && !hasFilters) {
                  return _DiscoverView(
                    restaurants: restaurants,
                    onFoodType: (t) =>
                        ref.read(_foodTypeProvider.notifier).state = t,
                  );
                }
                if (restaurants.isEmpty) {
                  return _NoResults(query: query, onReset: _resetAll);
                }
                return _ResultsList(restaurants: restaurants);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showSortSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _SortSheet(
        current: ref.read(_sortProvider),
        onSelect: (s) {
          ref.read(_sortProvider.notifier).state = s;
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _FilterSheet(
        sort: ref.read(_sortProvider),
        freeOnly: ref.read(_maxDeliveryFeeProvider),
        openOnly: ref.read(_openNowProvider),
        minRating: ref.read(_minRatingProvider),
        onApply: (sort, free, open, rating) {
          ref.read(_sortProvider.notifier).state = sort;
          ref.read(_maxDeliveryFeeProvider.notifier).state = free;
          ref.read(_openNowProvider.notifier).state = open;
          ref.read(_minRatingProvider.notifier).state = rating;
          Navigator.pop(context);
        },
      ),
    );
  }
}

// ─── Header avec search ─────────────────────────────────────────────────────

class _SearchHeader extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final VoidCallback onFilterTap;

  const _SearchHeader({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onClear,
    required this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Container(
      color: AmaraColors.bg,
      padding: EdgeInsets.fromLTRB(20, top + 10, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre + sous-titre
          Text('Explorer',
              style: AmaraTextStyles.h2
                  .copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text('Les meilleurs restaurants autour de vous',
              style: AmaraTextStyles.caption
                  .copyWith(color: AmaraColors.textSecondary)),
          const SizedBox(height: 12),
          // Search bar
          Container(
            height: 46,
            decoration: BoxDecoration(
              color: AmaraColors.bgAlt,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AmaraColors.divider),
            ),
            child: Row(
              children: [
                const SizedBox(width: 14),
                Icon(Icons.search_rounded,
                    color: AmaraColors.muted, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    onChanged: onChanged,
                    textInputAction: TextInputAction.search,
                    style: AmaraTextStyles.bodyMedium
                        .copyWith(color: AmaraColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Restaurant, plat, cuisine…',
                      hintStyle: AmaraTextStyles.bodyMedium
                          .copyWith(color: AmaraColors.muted),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: true,
                      fillColor: Colors.transparent,
                      isDense: true,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                if (controller.text.isNotEmpty)
                  GestureDetector(
                    onTap: onClear,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: AmaraColors.muted.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close_rounded,
                            color: AmaraColors.muted, size: 14),
                      ),
                    ),
                  ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 1,
                  color: AmaraColors.divider,
                ),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onFilterTap();
                  },
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12),
                    child: Icon(Icons.tune_rounded,
                        color: AmaraColors.textSecondary, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Chips filtres horizontaux ───────────────────────────────────────────────

class _FilterChips extends StatelessWidget {
  final _SortOption sort;
  final bool freeOnly;
  final bool openOnly;
  final bool takeaway;
  final bool hasFilters;
  final VoidCallback onSortTap;
  final VoidCallback onFreeTap;
  final VoidCallback onOpenTap;
  final VoidCallback onTakeawayTap;
  final VoidCallback onBestRatedTap;
  final VoidCallback onResetFilters;

  const _FilterChips({
    required this.sort,
    required this.freeOnly,
    required this.openOnly,
    required this.takeaway,
    required this.hasFilters,
    required this.onSortTap,
    required this.onFreeTap,
    required this.onOpenTap,
    required this.onTakeawayTap,
    required this.onBestRatedTap,
    required this.onResetFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SizedBox(
        height: 34,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          physics: const BouncingScrollPhysics(),
          children: [
            _Chip(
              icon: Icons.swap_vert_rounded,
              label: sort.label,
              isActive: sort != _SortOption.recommended,
              onTap: onSortTap,
            ),
            const SizedBox(width: 6),
            _Chip(
              label: 'Livraison gratuite',
              isActive: freeOnly,
              onTap: onFreeTap,
            ),
            const SizedBox(width: 6),
            _Chip(
              label: 'Ouvert',
              isActive: openOnly,
              onTap: onOpenTap,
            ),
            const SizedBox(width: 6),
            _Chip(
              label: 'À emporter',
              isActive: takeaway,
              onTap: onTakeawayTap,
            ),
            const SizedBox(width: 6),
            _Chip(
              label: 'Mieux notés',
              isActive: sort == _SortOption.rating,
              onTap: onBestRatedTap,
            ),
            if (hasFilters) ...[
              const SizedBox(width: 6),
              _Chip(
                icon: Icons.close_rounded,
                label: 'Reset',
                isActive: false,
                isReset: true,
                onTap: onResetFilters,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData? icon;
  final String label;
  final bool isActive;
  final bool isReset;
  final VoidCallback onTap;

  const _Chip({
    this.icon,
    required this.label,
    required this.isActive,
    this.isReset = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isReset
        ? AmaraColors.error
        : isActive
            ? AmaraColors.primary
            : AmaraColors.textSecondary;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? AmaraColors.primary.withValues(alpha: 0.08)
              : isReset
                  ? AmaraColors.error.withValues(alpha: 0.06)
                  : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive
                ? AmaraColors.primary.withValues(alpha: 0.4)
                : isReset
                    ? AmaraColors.error.withValues(alpha: 0.3)
                    : AmaraColors.divider,
            width: 0.8,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 13, color: color),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Vue découverte ──────────────────────────────────────────────────────────

class _DiscoverView extends StatelessWidget {
  final List<Restaurant> restaurants;
  final ValueChanged<String?> onFoodType;
  const _DiscoverView(
      {required this.restaurants, required this.onFoodType});

  @override
  Widget build(BuildContext context) {
    final topRated = [...restaurants]
      ..sort((a, b) => b.rating.compareTo(a.rating));

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),

          // ── Section "Mieux notés" — horizontal compact ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Mieux notés',
                    style: AmaraTextStyles.h3
                        .copyWith(fontWeight: FontWeight.w800)),
                Text('Voir tout',
                    style: AmaraTextStyles.labelSmall.copyWith(
                      color: AmaraColors.primary,
                      fontWeight: FontWeight.w600,
                    )),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 230,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              physics: const BouncingScrollPhysics(),
              itemCount: topRated.take(6).length,
              itemBuilder: (context, i) => Padding(
                padding: const EdgeInsets.only(right: 14),
                child: RestaurantCard(
                  restaurant: topRated[i],
                  compact: true,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ── Section "Tous les restaurants" — full cards ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text('Tous les restaurants',
                style: AmaraTextStyles.h3
                    .copyWith(fontWeight: FontWeight.w800)),
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: restaurants.length,
            itemBuilder: (context, i) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: RestaurantCard(restaurant: restaurants[i]),
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

// ─── Liste de résultats ──────────────────────────────────────────────────────

class _ResultsList extends StatelessWidget {
  final List<Restaurant> restaurants;
  const _ResultsList({required this.restaurants});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          child: Row(
            children: [
              Text(
                  '${restaurants.length} restaurant${restaurants.length > 1 ? 's' : ''}',
                  style: AmaraTextStyles.caption.copyWith(
                    color: AmaraColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  )),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 80),
            itemCount: restaurants.length,
            itemBuilder: (context, i) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: RestaurantCard(restaurant: restaurants[i]),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Card restaurant (compact horizontal pour carousel) ─────────────────────

class _RestaurantCard extends StatelessWidget {
  final Restaurant restaurant;
  final int index;
  const _RestaurantCard(
      {required this.restaurant, required this.index});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        context
            .push('${AppRoutes.restaurantPath}/${restaurant.id}');
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
            // Photo
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(15)),
              child: SizedBox(
                height: 140,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (restaurant.imageUrl != null)
                      Image.network(
                        restaurant.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _EmojiPlaceholder(
                                emoji: restaurant.imageEmoji,
                                color: _bgColor(restaurant.id)),
                        loadingBuilder: (_, child, progress) =>
                            progress == null
                                ? child
                                : _EmojiPlaceholder(
                                    emoji: restaurant.imageEmoji,
                                    color:
                                        _bgColor(restaurant.id)),
                      )
                    else
                      _EmojiPlaceholder(
                          emoji: restaurant.imageEmoji,
                          color: _bgColor(restaurant.id)),
                    // Gradient
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black
                                  .withValues(alpha: 0.35),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Badge gratuit
                    if (restaurant.deliveryFee
                        .toLowerCase()
                        .contains('gratuit'))
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          padding:
                              const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AmaraColors.success,
                            borderRadius:
                                BorderRadius.circular(8),
                          ),
                          child: Text('Livraison gratuite',
                              style: AmaraTextStyles.caption
                                  .copyWith(
                                      color: Colors.white,
                                      fontWeight:
                                          FontWeight.w700,
                                      fontSize: 9)),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // Infos
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(restaurant.name,
                      style: AmaraTextStyles.labelSmall
                          .copyWith(fontWeight: FontWeight.w800),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 3),
                  Text(restaurant.cuisine,
                      style: AmaraTextStyles.caption.copyWith(
                          color: AmaraColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          color: Color(0xFFFFC107), size: 14),
                      const SizedBox(width: 3),
                      Text(
                          restaurant.rating
                              .toStringAsFixed(1),
                          style: AmaraTextStyles.caption
                              .copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AmaraColors
                                      .textPrimary)),
                      Text(' (${restaurant.reviewCount})',
                          style: AmaraTextStyles.caption
                              .copyWith(
                                  color: AmaraColors.muted)),
                      const Spacer(),
                      Icon(Icons.access_time_rounded,
                          size: 12,
                          color: AmaraColors.textSecondary),
                      const SizedBox(width: 3),
                      Text(restaurant.deliveryTime,
                          style: AmaraTextStyles.caption
                              .copyWith(
                                  color: AmaraColors
                                      .textSecondary,
                                  fontWeight:
                                      FontWeight.w600)),
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
}

// ─── Tile restaurant (liste verticale) ──────────────────────────────────────

class _RestaurantListTile extends StatelessWidget {
  final Restaurant restaurant;
  const _RestaurantListTile({required this.restaurant});

  @override
  Widget build(BuildContext context) {
    final distance = _distanceLabel(restaurant);
    final isFree =
        restaurant.deliveryFee.toLowerCase().contains('gratuit');

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        context
            .push('${AppRoutes.restaurantPath}/${restaurant.id}');
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AmaraColors.bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AmaraColors.divider),
        ),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 80,
                height: 80,
                child: restaurant.imageUrl != null
                    ? Image.network(
                        restaurant.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _EmojiPlaceholder(
                                emoji: restaurant.imageEmoji,
                                color: _bgColor(restaurant.id)),
                      )
                    : _EmojiPlaceholder(
                        emoji: restaurant.imageEmoji,
                        color: _bgColor(restaurant.id)),
              ),
            ),
            const SizedBox(width: 12),
            // Détails
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(restaurant.name,
                      style: AmaraTextStyles.labelSmall
                          .copyWith(fontWeight: FontWeight.w700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(restaurant.cuisine,
                      style: AmaraTextStyles.caption.copyWith(
                          color: AmaraColors.textSecondary)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          color: Color(0xFFFFC107), size: 13),
                      const SizedBox(width: 3),
                      Text(
                          restaurant.rating
                              .toStringAsFixed(1),
                          style: AmaraTextStyles.caption
                              .copyWith(
                                  fontWeight: FontWeight.w700)),
                      const SizedBox(width: 10),
                      Icon(Icons.access_time_rounded,
                          size: 12,
                          color: AmaraColors.textSecondary),
                      const SizedBox(width: 3),
                      Text(restaurant.deliveryTime,
                          style: AmaraTextStyles.caption
                              .copyWith(
                                  color: AmaraColors
                                      .textSecondary)),
                      if (distance.isNotEmpty) ...[
                        const SizedBox(width: 10),
                        Icon(Icons.near_me_rounded,
                            size: 11,
                            color: AmaraColors.textSecondary),
                        const SizedBox(width: 3),
                        Text(distance,
                            style: AmaraTextStyles.caption
                                .copyWith(
                                    color: AmaraColors
                                        .textSecondary)),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // Prix / badge
            Column(
              children: [
                if (isFree)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color:
                          AmaraColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text('Gratuit',
                        style: AmaraTextStyles.caption.copyWith(
                            color: AmaraColors.success,
                            fontWeight: FontWeight.w700,
                            fontSize: 10)),
                  )
                else
                  Text(restaurant.deliveryFee,
                      style: AmaraTextStyles.caption.copyWith(
                          color: AmaraColors.textSecondary,
                          fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Icon(Icons.chevron_right_rounded,
                    color: AmaraColors.muted, size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Composants utilitaires ─────────────────────────────────────────────────

Color _bgColor(String id) {
  const colors = [
    Color(0xFFE8E0F5),
    Color(0xFFD4EDE3),
    Color(0xFFFCE4EC),
    Color(0xFFE3EDF9),
    Color(0xFFFFF3E0),
    Color(0xFFE0F4F4),
  ];
  return colors[id.hashCode % colors.length];
}

class _EmojiPlaceholder extends StatelessWidget {
  final String emoji;
  final Color color;
  const _EmojiPlaceholder(
      {required this.emoji, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      child: Center(
          child: Text(emoji, style: const TextStyle(fontSize: 40))),
    );
  }
}

// ─── Aucun résultat ─────────────────────────────────────────────────────────

class _NoResults extends StatelessWidget {
  final String query;
  final VoidCallback onReset;
  const _NoResults({required this.query, required this.onReset});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('😔', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text('Aucun résultat',
                style: AmaraTextStyles.h3
                    .copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(
              query.isNotEmpty
                  ? 'Aucun restaurant trouvé pour "$query"'
                  : 'Aucun restaurant correspond à vos filtres',
              style: AmaraTextStyles.bodySmall.copyWith(
                  color: AmaraColors.textSecondary, height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                onReset();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: AmaraColors.primary,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text('Réinitialiser',
                    style: AmaraTextStyles.bodySmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Erreur ─────────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  final String message;
  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_off_rounded,
              color: AmaraColors.muted, size: 48),
          const SizedBox(height: 12),
          Text('Erreur de connexion',
              style: AmaraTextStyles.labelMedium),
          const SizedBox(height: 4),
          Text(message,
              style: AmaraTextStyles.caption
                  .copyWith(color: AmaraColors.muted),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// ─── Bottom sheet Tri ───────────────────────────────────────────────────────

class _SortSheet extends StatelessWidget {
  final _SortOption current;
  final ValueChanged<_SortOption> onSelect;
  const _SortSheet(
      {required this.current, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AmaraColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Trier par',
              style: AmaraTextStyles.h3
                  .copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          ..._SortOption.values.map((s) {
            final isSelected = s == current;
            return GestureDetector(
              onTap: () => onSelect(s),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AmaraColors.primary
                          .withValues(alpha: 0.06)
                      : AmaraColors.bgAlt,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? AmaraColors.primary
                        : AmaraColors.divider,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(s.icon,
                        size: 18,
                        color: isSelected
                            ? AmaraColors.primary
                            : AmaraColors.textSecondary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(s.label,
                          style: AmaraTextStyles.bodySmall
                              .copyWith(
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w400,
                            color: isSelected
                                ? AmaraColors.primary
                                : AmaraColors.textPrimary,
                          )),
                    ),
                    if (isSelected)
                      const Icon(Icons.check_circle_rounded,
                          color: AmaraColors.primary, size: 20),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─── Bottom sheet Filtres ────────────────────────────────────────────────────

class _FilterSheet extends StatefulWidget {
  final _SortOption sort;
  final bool freeOnly;
  final bool openOnly;
  final double minRating;
  final void Function(
          _SortOption sort, bool free, bool open, double rating)
      onApply;

  const _FilterSheet({
    required this.sort,
    required this.freeOnly,
    required this.openOnly,
    required this.minRating,
    required this.onApply,
  });

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late _SortOption _sort;
  late bool _freeOnly;
  late bool _openOnly;
  late double _minRating;

  @override
  void initState() {
    super.initState();
    _sort = widget.sort;
    _freeOnly = widget.freeOnly;
    _openOnly = widget.openOnly;
    _minRating = widget.minRating;
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, 24 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                  color: AmaraColors.divider,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),

          // Tri
          Text('Trier par',
              style: AmaraTextStyles.labelSmall.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AmaraColors.textPrimary)),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _SortOption.values.map((s) {
                final selected = s == _sort;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _sort = s);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected
                          ? AmaraColors.primary
                          : AmaraColors.bgAlt,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected
                            ? AmaraColors.primary
                            : AmaraColors.divider,
                      ),
                    ),
                    child: Text(s.label,
                        style: AmaraTextStyles.caption.copyWith(
                          color: selected
                              ? Colors.white
                              : AmaraColors.textSecondary,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                        )),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 16),
          const Divider(color: AmaraColors.divider),
          const SizedBox(height: 12),

          // Filtres
          Text('Filtres',
              style: AmaraTextStyles.labelSmall.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AmaraColors.textPrimary)),
          const SizedBox(height: 14),

          _FilterToggleRow(
            icon: Icons.delivery_dining_rounded,
            label: 'Livraison gratuite',
            subtitle: 'Uniquement avec livraison offerte',
            value: _freeOnly,
            onChanged: (v) => setState(() => _freeOnly = v),
          ),
          const SizedBox(height: 10),
          const Divider(color: AmaraColors.divider),
          const SizedBox(height: 10),

          _FilterToggleRow(
            icon: Icons.schedule_rounded,
            label: 'Ouvert maintenant',
            subtitle: 'Masquer les restaurants fermés',
            value: _openOnly,
            onChanged: (v) => setState(() => _openOnly = v),
          ),
          const SizedBox(height: 10),
          const Divider(color: AmaraColors.divider),
          const SizedBox(height: 10),

          // Note minimale
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AmaraColors.primary
                      .withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.star_rounded,
                    color: AmaraColors.primary, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Note minimale',
                        style: AmaraTextStyles.bodySmall
                            .copyWith(fontWeight: FontWeight.w700)),
                    Text(
                        _minRating == 0
                            ? 'Toutes les notes'
                            : '${_minRating.toStringAsFixed(1)} ★ et plus',
                        style: AmaraTextStyles.caption
                            .copyWith(color: AmaraColors.muted)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AmaraColors.primary,
              inactiveTrackColor: AmaraColors.divider,
              thumbColor: AmaraColors.primary,
              overlayColor:
                  AmaraColors.primary.withValues(alpha: 0.12),
              trackHeight: 3,
            ),
            child: Slider(
              value: _minRating,
              min: 0,
              max: 5,
              divisions: 10,
              onChanged: (v) => setState(() => _minRating = v),
            ),
          ),

          const SizedBox(height: 16),

          // Boutons
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _sort = _SortOption.recommended;
                      _freeOnly = false;
                      _openOnly = false;
                      _minRating = 0;
                    });
                  },
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: AmaraColors.bgAlt,
                      borderRadius: BorderRadius.circular(14),
                      border:
                          Border.all(color: AmaraColors.divider),
                    ),
                    child: Center(
                      child: Text('Réinitialiser',
                          style: AmaraTextStyles.bodySmall
                              .copyWith(
                                  fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: () => widget.onApply(
                      _sort, _freeOnly, _openOnly, _minRating),
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: AmaraColors.primary,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text('Appliquer',
                          style: AmaraTextStyles.bodySmall
                              .copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterToggleRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _FilterToggleRow({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color:
                AmaraColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon,
              color: AmaraColors.primary, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: AmaraTextStyles.bodySmall
                      .copyWith(fontWeight: FontWeight.w700)),
              Text(subtitle,
                  style: AmaraTextStyles.caption
                      .copyWith(color: AmaraColors.muted),
                  maxLines: 2),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AmaraColors.primary,
          activeTrackColor:
              AmaraColors.primary.withValues(alpha: 0.4),
        ),
      ],
    );
  }
}
