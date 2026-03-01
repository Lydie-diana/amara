import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/core/constants/app_colors.dart';
import '../../app/core/constants/app_text_styles.dart';
import '../../app/models/restaurant_model.dart';
import '../../app/providers/categories_provider.dart';
import '../../app/providers/location_provider.dart';
import '../../app/providers/restaurant_provider.dart';
import '../shell/main_shell.dart';
import 'widgets/home_header.dart';
import 'widgets/promo_banner.dart';
import 'widgets/category_list.dart';
import 'widgets/section_header.dart';
import 'widgets/restaurant_card.dart';
import 'widgets/movement_banner.dart';
import 'widgets/location_picker_sheet.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentBanner = 0;
  final _searchController = TextEditingController();
  String _homeSearchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final location = ref.read(locationProvider);
      if (location.permissionDenied && !location.hasLocation) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => const LocationPickerSheet(),
        );
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final restaurantsAsync = ref.watch(restaurantListProvider);
    final location = ref.watch(locationProvider);

    return Scaffold(
      backgroundColor: AmaraColors.bg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Header (avatar + nom + localisation + message) ──
          SliverToBoxAdapter(
            child: const HomeHeader()
                .animate()
                .fadeIn(duration: 300.ms),
          ),

          // ── Search bar (filtre local) ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Container(
                height: 50,
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
                        controller: _searchController,
                        onChanged: (v) => setState(() => _homeSearchQuery = v),
                        textInputAction: TextInputAction.search,
                        style: AmaraTextStyles.bodyMedium.copyWith(
                          color: AmaraColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Chercher un restaurant, un plat...',
                          hintStyle: AmaraTextStyles.bodyMedium.copyWith(
                            color: AmaraColors.muted,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          isDense: true,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    if (_homeSearchQuery.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          setState(() => _homeSearchQuery = '');
                        },
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
                    const SizedBox(width: 14),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: 100.ms, duration: 300.ms),
          ),

          // ── Bannière déplacement ──
          if (location.hasMovedSignificantly)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: const MovementBanner(),
              ),
            ),

          // ── Promo banners (codes promo informatifs) ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: PromoBanner(
                currentIndex: _currentBanner,
                onPageChanged: (i) => setState(() => _currentBanner = i),
              ),
            ).animate().fadeIn(delay: 150.ms, duration: 400.ms),
          ),

          // ── Catégories ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SectionHeader(
                      title: 'Catégories',
                      subtitle: 'Voir tout',
                      onSubtitleTap: () =>
                          ref.read(shellIndexProvider.notifier).state = 1,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const CategoryList(),
                ],
              ),
            ).animate().fadeIn(delay: 250.ms, duration: 400.ms),
          ),

          // ── Restaurants ──
          restaurantsAsync.when(
            loading: () => const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child:
                      CircularProgressIndicator(color: AmaraColors.primary),
                ),
              ),
            ),
            error: (e, _) => SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Impossible de charger les restaurants. Vérifiez votre connexion.',
                  style: AmaraTextStyles.bodySmall
                      .copyWith(color: AmaraColors.error),
                ),
              ),
            ),
            data: (restaurants) {
              if (restaurants.isEmpty) {
                return SliverToBoxAdapter(
                  child: _EmptyState(
                    icon: Icons.storefront_outlined,
                    title: 'Aucun restaurant\ndans votre secteur',
                    subtitle:
                        'Essayez de modifier votre adresse\nou revenez plus tard.',
                    action: 'Changer de secteur',
                    onAction: () => showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => const LocationPickerSheet(),
                    ),
                  ),
                );
              }

              final selectedCat = ref.watch(selectedCategoryProvider);
              var filtered = _filterByCategory(restaurants, selectedCat);
              filtered = _filterBySearch(filtered, _homeSearchQuery);

              if (filtered.isEmpty) {
                return SliverToBoxAdapter(
                  child: _EmptyState(
                    icon: Icons.restaurant_rounded,
                    title: 'Aucun restaurant\npour cette catégorie',
                    subtitle: 'Essayez une autre catégorie',
                    action: 'Voir tous les restaurants',
                    onAction: () => ref
                        .read(selectedCategoryProvider.notifier)
                        .state = null,
                  ),
                );
              }

              // Séparer populaires (4 premiers) et nouveaux (le reste)
              final popular = filtered.take(4).toList();
              final newer = filtered.skip(4).toList();

              return SliverMainAxisGroup(slivers: [
                // ── Section "Populaires" ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                    child: SectionHeader(
                      title: 'Populaires',
                      subtitle: 'Voir tout',
                      onSubtitleTap: () =>
                          ref.read(shellIndexProvider.notifier).state = 1,
                    ),
                  ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
                ),

                // Populaires — full cards verticales
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: RestaurantCard(restaurant: popular[index])
                            .animate()
                            .fadeIn(
                              delay: Duration(
                                  milliseconds: 350 + index * 60),
                              duration: 350.ms,
                            )
                            .slideY(begin: 0.08, end: 0),
                      ),
                      childCount: popular.length,
                    ),
                  ),
                ),

                // ── Section "Nouveaux arrivants" ──
                if (newer.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      child: SectionHeader(
                        title: 'Nouveaux arrivants',
                        subtitle: 'Voir tout',
                        onSubtitleTap: () =>
                            ref.read(shellIndexProvider.notifier).state = 1,
                      ),
                    ).animate().fadeIn(delay: 500.ms, duration: 400.ms),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 230,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                        physics: const BouncingScrollPhysics(),
                        itemCount: newer.length,
                        itemBuilder: (context, index) => Padding(
                          padding: const EdgeInsets.only(right: 14),
                          child: RestaurantCard(
                            restaurant: newer[index],
                            compact: true,
                          )
                              .animate()
                              .fadeIn(
                                delay: Duration(
                                    milliseconds: 550 + index * 60),
                                duration: 350.ms,
                              ),
                        ),
                      ),
                    ),
                  ),
                ],

                // ── Section "Tous les restaurants" ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: SectionHeader(
                      title: 'Tous les restaurants',
                      subtitle: 'Voir tout',
                      onSubtitleTap: () =>
                          ref.read(shellIndexProvider.notifier).state = 1,
                    ),
                  ).animate().fadeIn(delay: 600.ms, duration: 400.ms),
                ),

                // Full cards pour tous
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: RestaurantCard(restaurant: filtered[index])
                              .animate()
                              .fadeIn(
                                delay: Duration(
                                    milliseconds: 650 + index * 50),
                                duration: 350.ms,
                              )
                              .slideY(begin: 0.06, end: 0),
                        );
                      },
                      childCount: filtered.length,
                    ),
                  ),
                ),
              ]);
            },
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  List<Restaurant> _filterByCategory(
      List<Restaurant> restaurants, String? category) {
    if (category == null) return restaurants;
    final q = category.toLowerCase();
    return restaurants.where((r) {
      return r.cuisine.toLowerCase().contains(q) ||
          r.tags.any((t) => t.toLowerCase().contains(q));
    }).toList();
  }

  List<Restaurant> _filterBySearch(
      List<Restaurant> restaurants, String query) {
    if (query.isEmpty) return restaurants;
    final q = query.toLowerCase().trim();
    return restaurants.where((r) {
      return r.name.toLowerCase().contains(q) ||
          r.cuisine.toLowerCase().contains(q) ||
          r.tags.any((t) => t.toLowerCase().contains(q));
    }).toList();
  }

}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String action;
  final VoidCallback onAction;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.action,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        children: [
          Icon(icon, size: 52, color: AmaraColors.muted),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AmaraTextStyles.h3
                .copyWith(color: AmaraColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(subtitle,
              textAlign: TextAlign.center,
              style: AmaraTextStyles.bodySmall),
          const SizedBox(height: 18),
          GestureDetector(
            onTap: onAction,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: AmaraColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                action,
                style: AmaraTextStyles.labelSmall.copyWith(
                  color: AmaraColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
