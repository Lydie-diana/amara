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

// ─── Providers publics ────────────────────────────────────────────────────────

final searchQueryProvider = StateProvider<String>((ref) => '');

// Filtres avancés
final _sortProvider       = StateProvider<_SortOption>((ref) => _SortOption.recommended);
final _foodTypeProvider   = StateProvider<String?>((ref) => null);
final _maxDeliveryFeeProvider = StateProvider<bool>((ref) => false); // true = gratuit seulement
final _openNowProvider    = StateProvider<bool>((ref) => false);
final _minRatingProvider  = StateProvider<double>((ref) => 0.0);

enum _SortOption { recommended, rating, distance, deliveryTime, price }

extension _SortLabel on _SortOption {
  String get label {
    switch (this) {
      case _SortOption.recommended: return 'Recommandé';
      case _SortOption.rating:      return 'Mieux notés';
      case _SortOption.distance:    return 'Distance';
      case _SortOption.deliveryTime:return 'Rapidité';
      case _SortOption.price:       return 'Prix livraison';
    }
  }
}

// Position par défaut (Cocody, Abidjan) — sera remplacée par GPS réel plus tard
double _userLat = 5.3600;
double _userLng = -3.9800;

/// Calcul distance Haversine entre l'utilisateur et un restaurant
double _distanceFor(Restaurant r) {
  if (r.latitude == null || r.longitude == null) return 99.0;
  const earthRadius = 6371.0; // km
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
    final allAsync   = ref.watch(restaurantListProvider);
    final query      = ref.watch(searchQueryProvider).toLowerCase().trim();
    final foodType   = ref.watch(_foodTypeProvider);
    final freeOnly   = ref.watch(_maxDeliveryFeeProvider);
    final openOnly   = ref.watch(_openNowProvider);
    final minRating  = ref.watch(_minRatingProvider);
    final sort       = ref.watch(_sortProvider);

    return allAsync.whenData((list) {
      var r = list;
      if (foodType != null) {
        r = r.where((x) =>
            x.cuisine.toLowerCase().contains(foodType.toLowerCase()) ||
            x.tags.any((t) => t.toLowerCase().contains(foodType.toLowerCase()))).toList();
      }
      if (freeOnly) {
        r = r.where((x) => x.deliveryFee.toLowerCase().contains('gratuit')).toList();
      }
      if (openOnly) r = r.where((x) => x.isOpen).toList();
      if (minRating > 0) r = r.where((x) => x.rating >= minRating).toList();
      if (query.isNotEmpty) {
        r = r.where((x) =>
            x.name.toLowerCase().contains(query) ||
            x.cuisine.toLowerCase().contains(query) ||
            x.tags.any((t) => t.toLowerCase().contains(query))).toList();
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
            final fa = a.deliveryFee.toLowerCase().contains('gratuit') ? 0 : 1;
            final fb = b.deliveryFee.toLowerCase().contains('gratuit') ? 0 : 1;
            return fa.compareTo(fb);
          });
        case _SortOption.recommended:
          r.sort((a, b) => (b.isFeatured ? 1 : 0).compareTo(a.isFeatured ? 1 : 0));
      }
      return r;
    });
  },
);

// ─── Types de plats ───────────────────────────────────────────────────────────

const _foodTypes = [
  ('🍲', 'Ragoût'),
  ('🍗', 'Grillades'),
  ('🍚', 'Riz'),
  ('🥗', 'Salade'),
  ('🍕', 'Pizza'),
  ('🥪', 'Sandwich'),
  ('🍜', 'Soupe'),
  ('🧆', 'Végétarien'),
];

// ─── Écran principal ──────────────────────────────────────────────────────────

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  final _focusNode  = FocusNode();

  @override
  void initState() {
    super.initState();
    // Sync controller avec le provider (pré-rempli depuis la home)
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
  }

  @override
  Widget build(BuildContext context) {
    // Sync controller si query changée depuis la home
    ref.listen(searchQueryProvider, (_, next) {
      if (_controller.text != next) _controller.text = next;
    });

    final query      = ref.watch(searchQueryProvider);
    final sort       = ref.watch(_sortProvider);
    final foodType   = ref.watch(_foodTypeProvider);
    final freeOnly   = ref.watch(_maxDeliveryFeeProvider);
    final openOnly   = ref.watch(_openNowProvider);
    final minRating  = ref.watch(_minRatingProvider);
    final filtered   = ref.watch(_filteredProvider);

    final hasFilters = foodType != null || freeOnly || openOnly || minRating > 0 ||
        sort != _SortOption.recommended;

    return Scaffold(
      backgroundColor: AmaraColors.bg,
      body: Column(
        children: [
          // ── Header ───────────────────────────────────────────────────
          _SearchHeader(
            controller: _controller,
            focusNode: _focusNode,
            onChanged: (v) => ref.read(searchQueryProvider.notifier).state = v,
            onClear: () {
              _controller.clear();
              ref.read(searchQueryProvider.notifier).state = '';
            },
            onFilterTap: () => _showFilterSheet(context),
            onSortTap: () => _showSortSheet(context),
          ),

          // ── Contenu ──────────────────────────────────────────────────
          Expanded(
            child: filtered.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AmaraColors.primary),
              ),
              error: (e, _) => _ErrorState(message: e.toString()),
              data: (restaurants) {
                if (query.isEmpty && !hasFilters) {
                  return _DiscoverView(
                    onFoodType: (t) =>
                        ref.read(_foodTypeProvider.notifier).state = t,
                  );
                }
                if (restaurants.isEmpty) return _NoResults(query: query, onReset: _resetAll);
                return _ResultsList(restaurants: restaurants, sort: sort);
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

// ─── Header ──────────────────────────────────────────────────────────────────

class _SearchHeader extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final VoidCallback onFilterTap;
  final VoidCallback onSortTap;

  const _SearchHeader({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onClear,
    required this.onFilterTap,
    required this.onSortTap,
  });

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Container(
      color: AmaraColors.primary,
      padding: EdgeInsets.fromLTRB(16, top + 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre
          Text('Explorer',
              style: AmaraTextStyles.h2.copyWith(
                  fontWeight: FontWeight.w800, color: Colors.white)),
          Text('Découvrez les meilleurs restaurants',
              style: AmaraTextStyles.caption.copyWith(
                  color: Colors.white.withValues(alpha: 0.7))),
          const SizedBox(height: 14),
          // Barre de recherche — blanche sur fond rouge, avec icône filtre
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                const SizedBox(width: 14),
                const Icon(Icons.search_rounded,
                    color: AmaraColors.primary, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    onChanged: onChanged,
                    textInputAction: TextInputAction.search,
                    style: AmaraTextStyles.bodySmall
                        .copyWith(color: AmaraColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Restaurant, plat, cuisine…',
                      hintStyle: AmaraTextStyles.bodySmall
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
                // Bouton clear si texte présent
                if (controller.text.isNotEmpty)
                  GestureDetector(
                    onTap: onClear,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AmaraColors.muted.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close_rounded,
                          color: AmaraColors.muted, size: 16),
                    ),
                  ),
                // Séparateur vertical
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  width: 1,
                  color: AmaraColors.divider,
                ),
                // Icône filtre/tri
                GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onFilterTap();
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AmaraColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.tune_rounded,
                        color: Colors.white, size: 16),
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

// ─── Vue découverte (état vide) ───────────────────────────────────────────────

class _DiscoverView extends StatelessWidget {
  final ValueChanged<String?> onFoodType;
  const _DiscoverView({required this.onFoodType});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text('Que voulez-vous manger ?',
                style: AmaraTextStyles.h3.copyWith(fontWeight: FontWeight.w800)),
          ),
          // Grille types de plats — 4 colonnes, ratio carré
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.05,
              ),
              itemCount: _foodTypes.length,
              itemBuilder: (context, i) {
                final (emoji, label) = _foodTypes[i];
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onFoodType(label);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: AmaraColors.bgCard,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AmaraColors.divider),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(emoji, style: const TextStyle(fontSize: 22)),
                        const SizedBox(height: 4),
                        Text(label,
                            style: AmaraTextStyles.caption.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 10),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 28),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('Près de vous',
                style: AmaraTextStyles.h3.copyWith(fontWeight: FontWeight.w800)),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('Restaurants à moins de 5 km',
                style: AmaraTextStyles.caption.copyWith(color: AmaraColors.muted)),
          ),
          const SizedBox(height: 14),
          _NearbyList(),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _NearbyList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(restaurantListProvider);
    return async.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(color: AmaraColors.primary),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (list) {
        final nearby = [...list]
          ..sort((a, b) => _distanceFor(a).compareTo(_distanceFor(b)));
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: nearby.length,
          itemBuilder: (context, i) => _RestaurantCard(
            restaurant: nearby[i],
            index: i,
          ),
        );
      },
    );
  }
}

// ─── Liste de résultats ────────────────────────────────────────────────────────

class _ResultsList extends StatelessWidget {
  final List<Restaurant> restaurants;
  final _SortOption sort;
  const _ResultsList({required this.restaurants, required this.sort});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Résumé résultats
        Container(
          color: AmaraColors.bgAlt,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text('${restaurants.length} restaurant${restaurants.length > 1 ? 's' : ''}',
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
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
            itemCount: restaurants.length,
            itemBuilder: (context, i) => _RestaurantCard(
              restaurant: restaurants[i],
              index: i,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Carte restaurant style Deliveroo ────────────────────────────────────────

class _RestaurantCard extends StatelessWidget {
  final Restaurant restaurant;
  final int index;
  const _RestaurantCard({required this.restaurant, required this.index});

  @override
  Widget build(BuildContext context) {
    final distance = _distanceLabel(restaurant);
    final isFree = restaurant.deliveryFee.toLowerCase().contains('gratuit');

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        context.push('${AppRoutes.restaurantPath}/${restaurant.id}');
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AmaraColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AmaraColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Photo ──────────────────────────────────────────────────
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              child: SizedBox(
                height: 150,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Image
                    if (restaurant.imageUrl != null)
                      Image.network(
                        restaurant.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _EmojiPlaceholder(
                            emoji: restaurant.imageEmoji,
                            color: _bgColor(restaurant.id)),
                        loadingBuilder: (_, child, progress) => progress == null
                            ? child
                            : _EmojiPlaceholder(
                                emoji: restaurant.imageEmoji,
                                color: _bgColor(restaurant.id)),
                      )
                    else
                      _EmojiPlaceholder(
                          emoji: restaurant.imageEmoji,
                          color: _bgColor(restaurant.id)),
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
                    // Distance badge (bas gauche)
                    Positioned(
                      bottom: 10, left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.location_on_rounded,
                                color: Colors.white, size: 11),
                            const SizedBox(width: 3),
                            Text(distance,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600)),
                          ],
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
                  ],
                ),
              ),
            ),

            // ── Infos ──────────────────────────────────────────────────
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
                  const SizedBox(height: 3),
                  Text(restaurant.cuisine,
                      style: AmaraTextStyles.caption.copyWith(
                          color: AmaraColors.muted)),
                  const SizedBox(height: 10),
                  // Chips infos
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
                      const SizedBox(width: 8),
                      if (restaurant.minOrder > 0)
                        _InfoPill(
                          icon: Icons.shopping_bag_outlined,
                          label: 'Min ${restaurant.minOrder.toStringAsFixed(0)} F',
                          color: AmaraColors.muted,
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

  Color _bgColor(String id) {
    const colors = [
      Color(0xFFE8E0F5), Color(0xFFD4EDE3), Color(0xFFFCE4EC),
      Color(0xFFE3EDF9), Color(0xFFFFF3E0), Color(0xFFE0F4F4),
    ];
    return colors[id.hashCode % colors.length];
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
      child: Center(child: Text(emoji, style: const TextStyle(fontSize: 52))),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _InfoPill({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ─── Aucun résultat ────────────────────────────────────────────────────────────

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
            const Text('😔', style: TextStyle(fontSize: 52)),
            const SizedBox(height: 16),
            Text('Aucun résultat',
                style: AmaraTextStyles.h3.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(
              query.isNotEmpty
                  ? 'Aucun restaurant trouvé pour "$query".\nEssayez un autre terme ou ajustez vos filtres.'
                  : 'Aucun restaurant correspond à vos filtres.\nEssayez de les modifier.',
              style: AmaraTextStyles.bodySmall
                  .copyWith(color: AmaraColors.textSecondary, height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                onReset();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: AmaraColors.primary,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AmaraColors.primary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
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

// ─── Erreur ────────────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  final String message;
  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_off_rounded, color: AmaraColors.muted, size: 48),
          const SizedBox(height: 12),
          Text('Erreur de connexion', style: AmaraTextStyles.labelMedium),
          const SizedBox(height: 4),
          Text(message,
              style: AmaraTextStyles.caption.copyWith(color: AmaraColors.muted),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// ─── Bottom sheet Tri ─────────────────────────────────────────────────────────

class _SortSheet extends StatelessWidget {
  final _SortOption current;
  final ValueChanged<_SortOption> onSelect;
  const _SortSheet({required this.current, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: AmaraColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Trier par', style: AmaraTextStyles.h3.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          ..._SortOption.values.map((s) {
            final isSelected = s == current;
            return GestureDetector(
              onTap: () => onSelect(s),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AmaraColors.primary.withValues(alpha: 0.06)
                      : AmaraColors.bgAlt,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? AmaraColors.primary : AmaraColors.divider,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(s.label,
                          style: AmaraTextStyles.bodySmall.copyWith(
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
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

// ─── Bottom sheet Filtres + Tri ───────────────────────────────────────────────

class _FilterSheet extends StatefulWidget {
  final _SortOption sort;
  final bool freeOnly;
  final bool openOnly;
  final double minRating;
  final void Function(_SortOption sort, bool free, bool open, double rating) onApply;

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
    _sort      = widget.sort;
    _freeOnly  = widget.freeOnly;
    _openOnly  = widget.openOnly;
    _minRating = widget.minRating;
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, 24 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Poignée
          Center(
            child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                  color: AmaraColors.divider,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),

          // ── Section Tri ──────────────────────────────────────────────
          Text('Trier par', style: AmaraTextStyles.labelSmall.copyWith(
              fontWeight: FontWeight.w800, color: AmaraColors.textPrimary)),
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
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected ? AmaraColors.primary : AmaraColors.bgAlt,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected ? AmaraColors.primary : AmaraColors.divider,
                      ),
                    ),
                    child: Text(s.label,
                        style: AmaraTextStyles.caption.copyWith(
                          color: selected ? Colors.white : AmaraColors.textSecondary,
                          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                        )),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 16),
          const Divider(color: AmaraColors.divider),
          const SizedBox(height: 12),

          // ── Section Filtres ──────────────────────────────────────────
          Text('Filtres', style: AmaraTextStyles.labelSmall.copyWith(
              fontWeight: FontWeight.w800, color: AmaraColors.textPrimary)),
          const SizedBox(height: 14),

          // Livraison gratuite
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

          // Ouvert maintenant
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
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: AmaraColors.primary.withValues(alpha: 0.08),
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
                        style: AmaraTextStyles.bodySmall.copyWith(
                            fontWeight: FontWeight.w700)),
                    Text(_minRating == 0 ? 'Toutes les notes'
                        : '${_minRating.toStringAsFixed(1)} ★ et plus',
                        style: AmaraTextStyles.caption.copyWith(
                            color: AmaraColors.muted)),
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
              overlayColor: AmaraColors.primary.withValues(alpha: 0.12),
              trackHeight: 3,
            ),
            child: Slider(
              value: _minRating,
              min: 0, max: 5,
              divisions: 10,
              onChanged: (v) => setState(() => _minRating = v),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Toutes', style: AmaraTextStyles.caption.copyWith(color: AmaraColors.muted)),
              Text('5 ★', style: AmaraTextStyles.caption.copyWith(color: AmaraColors.muted)),
            ],
          ),

          const SizedBox(height: 20),

          // Boutons
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _sort      = _SortOption.recommended;
                      _freeOnly  = false;
                      _openOnly  = false;
                      _minRating = 0;
                    });
                  },
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: AmaraColors.bgAlt,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AmaraColors.divider),
                    ),
                    child: Center(
                      child: Text('Réinitialiser',
                          style: AmaraTextStyles.bodySmall.copyWith(
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: () => widget.onApply(_sort, _freeOnly, _openOnly, _minRating),
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: AmaraColors.primary,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text('Appliquer',
                          style: AmaraTextStyles.bodySmall.copyWith(
                              color: Colors.white, fontWeight: FontWeight.w700)),
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
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: AmaraColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AmaraColors.primary, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: AmaraTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w700)),
              Text(subtitle,
                  style: AmaraTextStyles.caption.copyWith(
                      color: AmaraColors.muted),
                  maxLines: 2),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AmaraColors.primary,
          activeTrackColor: AmaraColors.primary.withValues(alpha: 0.4),
        ),
      ],
    );
  }
}
