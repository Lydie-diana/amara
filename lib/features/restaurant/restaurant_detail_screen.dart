import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/core/constants/app_colors.dart';
import '../../app/core/constants/app_text_styles.dart';
import '../../app/models/cart_model.dart';
import '../../app/models/restaurant_model.dart';
import '../../app/providers/cart_provider.dart';
import '../../app/providers/restaurant_provider.dart';
import '../../app/router/app_routes.dart';
import 'widgets/menu_category_section.dart';
import 'widgets/restaurant_info_header.dart';
import 'widgets/top_dishes_section.dart';

class RestaurantDetailScreen extends ConsumerStatefulWidget {
  final String restaurantId;
  const RestaurantDetailScreen({super.key, required this.restaurantId});

  @override
  ConsumerState<RestaurantDetailScreen> createState() =>
      _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState
    extends ConsumerState<RestaurantDetailScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  int _selectedCategoryIndex = 0;
  String _searchQuery = '';

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final restaurantAsync =
        ref.watch(restaurantDetailProvider(widget.restaurantId));
    final menuAsync = ref.watch(restaurantMenuProvider(widget.restaurantId));
    final cart = ref.watch(cartProvider);

    return Scaffold(
      backgroundColor: AmaraColors.bg,
      body: restaurantAsync.when(
        loading: () => const _LoadingState(),
        error: (e, _) => _ErrorState(onRetry: () {
          ref.invalidate(restaurantDetailProvider(widget.restaurantId));
        }),
        data: (restaurant) => menuAsync.when(
          loading: () => _buildContent(
            context,
            restaurant: restaurant,
            categories: [],
            isMenuLoading: true,
          ),
          error: (e, st) => _buildContent(
            context,
            restaurant: restaurant,
            categories: [],
            isMenuLoading: false,
          ),
          data: (categories) => _buildContent(
            context,
            restaurant: restaurant,
            categories: categories,
            isMenuLoading: false,
          ),
        ),
      ),
      bottomNavigationBar: cart.isEmpty
          ? null
          : _CartBottomBar(
              cart: cart,
              onTap: () => context.push(AppRoutes.cart),
            ),
    );
  }

  /// Filtre les catégories selon la recherche.
  List<MenuCategory> _filterCategories(List<MenuCategory> all) {
    if (_searchQuery.isEmpty) return all;
    final q = _searchQuery.toLowerCase();
    final result = <MenuCategory>[];
    for (final cat in all) {
      final filtered =
          cat.items.where((i) => i.name.toLowerCase().contains(q) || i.description.toLowerCase().contains(q)).toList();
      if (filtered.isNotEmpty) {
        result.add(MenuCategory(id: cat.id, name: cat.name, items: filtered));
      }
    }
    return result;
  }

  Widget _buildContent(
    BuildContext context, {
    required Restaurant restaurant,
    required List<MenuCategory> categories,
    required bool isMenuLoading,
  }) {
    final filtered = _filterCategories(categories);

    // Top plats : tous les items triés par likes
    final allItems = categories.expand((c) => c.items).toList()
      ..sort((a, b) => b.likeCount.compareTo(a.likeCount));
    final topItems = allItems.take(5).toList();

    return CustomScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      slivers: [
        // ── SliverAppBar avec partage ───────────────────────────────────────
        _RestaurantSliverAppBar(restaurant: restaurant),

        // ── Infos restaurant ────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: RestaurantInfoHeader(restaurant: restaurant)
              .animate()
              .fadeIn(duration: 400.ms),
        ),

        // ── Top plats ────────────────────────────────────────────────────────
        if (topItems.isNotEmpty)
          SliverToBoxAdapter(
            child: TopDishesSection(
              items: topItems,
              restaurantId: restaurant.id,
              restaurantName: restaurant.name,
            ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
          ),

        // ── Barre de recherche dans le menu ──────────────────────────────────
        SliverToBoxAdapter(
          child: _MenuSearchBar(
            controller: _searchController,
            onChanged: (v) => setState(() => _searchQuery = v),
          ).animate().fadeIn(delay: 150.ms),
        ),

        // ── Onglets catégories (sticky) ──────────────────────────────────────
        if (categories.isNotEmpty)
          SliverPersistentHeader(
            pinned: true,
            delegate: _CategoryTabsDelegate(
              categories: categories,
              selectedIndex: _selectedCategoryIndex,
              onCategoryTap: (index) =>
                  setState(() => _selectedCategoryIndex = index),
            ),
          ),

        // ── Loading menu ─────────────────────────────────────────────────────
        if (isMenuLoading)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: Center(
                child: CircularProgressIndicator(
                    color: AmaraColors.primary, strokeWidth: 2),
              ),
            ),
          ),

        // ── Résultat vide (recherche) ─────────────────────────────────────────
        if (!isMenuLoading && _searchQuery.isNotEmpty && filtered.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  const Text('🔍', style: TextStyle(fontSize: 36)),
                  const SizedBox(height: 12),
                  Text('Aucun plat trouvé pour "$_searchQuery"',
                      textAlign: TextAlign.center,
                      style: AmaraTextStyles.bodySmall
                          .copyWith(color: AmaraColors.muted)),
                ],
              ),
            ),
          ),

        // ── Menu par catégorie ───────────────────────────────────────────────
        ...filtered.asMap().entries.map((entry) => SliverToBoxAdapter(
              child: MenuCategorySection(
                category: entry.value,
                restaurantId: restaurant.id,
                restaurantName: restaurant.name,
                allItems: allItems,
                animationDelay: entry.key * 80,
              ),
            )),

        const SliverToBoxAdapter(child: SizedBox(height: 120)),
      ],
    );
  }
}

// ─── SliverAppBar avec partage ────────────────────────────────────────────────

class _RestaurantSliverAppBar extends StatelessWidget {
  final Restaurant restaurant;
  const _RestaurantSliverAppBar({required this.restaurant});

  Color get _bgColor {
    const colors = [
      Color(0xFFE8E0F5),
      Color(0xFFD4EDE3),
      Color(0xFFFCE4EC),
      Color(0xFFE3EDF9),
      Color(0xFFFFF3E0),
      Color(0xFFE0F4F4),
    ];
    return colors[restaurant.id.hashCode % colors.length];
  }

  void _share(BuildContext context) {
    HapticFeedback.lightImpact();
    // TODO: intégrer share_plus pour partage natif
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Partager "${restaurant.name}" — bientôt disponible'),
        backgroundColor: AmaraColors.dark,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: AmaraColors.bg,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Photo réelle ou fond coloré + emoji
            if (restaurant.imageUrl != null)
              Image.network(
                restaurant.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: _bgColor,
                  child: Center(child: Text(restaurant.imageEmoji,
                      style: const TextStyle(fontSize: 90)))),
                loadingBuilder: (_, child, progress) => progress == null
                    ? child
                    : Container(color: _bgColor,
                        child: Center(child: Text(restaurant.imageEmoji,
                            style: const TextStyle(fontSize: 90)))),
              )
            else
              Container(color: _bgColor,
                child: Center(child: Text(restaurant.imageEmoji,
                    style: const TextStyle(fontSize: 90)))),

            // Dégradé haut (pour lisibilité des boutons)
            Positioned(
              top: 0, left: 0, right: 0,
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.45),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Dégradé bas (fondu vers fond app)
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: Container(
                height: 70,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      AmaraColors.bg,
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Boutons en haut (back + actions)
            Positioned(
              top: topPadding + 8,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  // Retour
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_back_ios_rounded,
                          color: Colors.white, size: 16),
                    ),
                  ),
                  const Spacer(),
                  // Partage
                  GestureDetector(
                    onTap: () => _share(context),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.share_rounded,
                          color: Colors.white, size: 16),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Favoris
                  GestureDetector(
                    onTap: () => HapticFeedback.lightImpact(),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.favorite_border_rounded,
                          color: AmaraColors.textPrimary, size: 16),
                    ),
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

// ─── Barre de recherche dans le menu ──────────────────────────────────────────

class _MenuSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  const _MenuSearchBar(
      {required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: AmaraTextStyles.bodySmall,
        decoration: InputDecoration(
          hintText: 'Rechercher un plat...',
          hintStyle: AmaraTextStyles.bodySmall
              .copyWith(color: AmaraColors.muted),
          prefixIcon: const Icon(Icons.search_rounded,
              color: AmaraColors.muted, size: 20),
          suffixIcon: controller.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    controller.clear();
                    onChanged('');
                  },
                  child: const Icon(Icons.close_rounded,
                      color: AmaraColors.muted, size: 18),
                )
              : null,
          filled: true,
          fillColor: AmaraColors.bgAlt,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: AmaraColors.divider),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: AmaraColors.divider),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                const BorderSide(color: AmaraColors.primary, width: 1.5),
          ),
        ),
      ),
    );
  }
}

// ─── Tabs catégories (sticky) ─────────────────────────────────────────────────

class _CategoryTabsDelegate extends SliverPersistentHeaderDelegate {
  final List<MenuCategory> categories;
  final int selectedIndex;
  final ValueChanged<int> onCategoryTap;

  const _CategoryTabsDelegate({
    required this.categories,
    required this.selectedIndex,
    required this.onCategoryTap,
  });

  @override
  double get minExtent => 56;
  @override
  double get maxExtent => 56;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AmaraColors.bg,
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 10),
              physics: const BouncingScrollPhysics(),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final isSelected = selectedIndex == index;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onCategoryTap(index);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AmaraColors.primary
                          : AmaraColors.bgAlt,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? AmaraColors.primary
                            : AmaraColors.divider,
                      ),
                    ),
                    child: Text(
                      categories[index].name,
                      style: AmaraTextStyles.labelSmall.copyWith(
                        color: isSelected
                            ? Colors.white
                            : AmaraColors.textSecondary,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(height: 1, color: AmaraColors.divider),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_CategoryTabsDelegate old) =>
      selectedIndex != old.selectedIndex ||
      categories.length != old.categories.length;
}

// ─── Cart Bottom Bar ──────────────────────────────────────────────────────────

class _CartBottomBar extends StatelessWidget {
  final CartState cart;
  final VoidCallback onTap;
  const _CartBottomBar({required this.cart, required this.onTap});

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
        onTap: onTap,
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: AmaraColors.primary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${cart.totalItems}',
                  style: AmaraTextStyles.labelMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Voir mon panier',
                  style: AmaraTextStyles.labelMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                cart.formattedSubtotal,
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

// ─── Loading / Error ──────────────────────────────────────────────────────────

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AmaraColors.bg,
      body: Center(
        child: CircularProgressIndicator(
            color: AmaraColors.primary, strokeWidth: 2),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AmaraColors.bg,
      appBar: AppBar(
        backgroundColor: AmaraColors.bg,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: AmaraColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('😕', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text('Impossible de charger le restaurant',
                style: AmaraTextStyles.bodyMedium),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: AmaraColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('Réessayer',
                    style: AmaraTextStyles.labelMedium
                        .copyWith(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
