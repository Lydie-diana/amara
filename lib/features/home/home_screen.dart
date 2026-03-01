import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/core/constants/app_colors.dart';
import '../../app/core/constants/app_text_styles.dart';
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

  @override
  void initState() {
    super.initState();
    // Afficher le picker si permission refusée dès l'ouverture
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
  Widget build(BuildContext context) {
    final restaurantsAsync = ref.watch(restaurantListProvider);
    final location = ref.watch(locationProvider);

    return Scaffold(
      backgroundColor: AmaraColors.bg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Header rouge avec adresse dynamique
          SliverToBoxAdapter(
            child: HomeHeader()
                .animate()
                .fadeIn(duration: 400.ms),
          ),

          // Bannière déplacement détecté (style Uber Eats)
          if (location.hasMovedSignificantly)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: const MovementBanner(),
              ),
            ),

          // Promo banners
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: PromoBanner(
                currentIndex: _currentBanner,
                onPageChanged: (i) => setState(() => _currentBanner = i),
              ),
            ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
          ),

          // Categories
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SectionHeader(
                      title: 'Cuisines',
                      subtitle: 'Voir tout',
                      onSubtitleTap: () => ref.read(shellIndexProvider.notifier).state = 1,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const CategoryList(),
                ],
              ),
            ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
          ),

          // Featured restaurants
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
              child: SectionHeader(
                title: 'Populaires près de vous',
                subtitle: 'Voir tout',
                onSubtitleTap: () => ref.read(shellIndexProvider.notifier).state = 1,
              ),
            ).animate().fadeIn(delay: 350.ms, duration: 400.ms),
          ),

          // Liste restaurants
          restaurantsAsync.when(
            loading: () => const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: CircularProgressIndicator(color: AmaraColors.primary),
                ),
              ),
            ),
            error: (e, _) => SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text('Erreur : $e',
                    style: AmaraTextStyles.bodySmall.copyWith(
                        color: AmaraColors.error)),
              ),
            ),
            data: (restaurants) {
              if (restaurants.isEmpty) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 40),
                    child: Column(
                      children: [
                        const Icon(Icons.storefront_outlined,
                            size: 56, color: AmaraColors.muted),
                        const SizedBox(height: 16),
                        Text(
                          'Aucun restaurant\ndans votre secteur',
                          textAlign: TextAlign.center,
                          style: AmaraTextStyles.h3.copyWith(
                              color: AmaraColors.textSecondary),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Essayez de modifier votre adresse\nou revenez plus tard.',
                          textAlign: TextAlign.center,
                          style: AmaraTextStyles.bodySmall,
                        ),
                        const SizedBox(height: 20),
                        TextButton.icon(
                          onPressed: () => showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => const LocationPickerSheet(),
                          ),
                          icon: const Icon(Icons.location_on_outlined,
                              color: AmaraColors.primary),
                          label: Text('Changer de secteur',
                              style: AmaraTextStyles.labelMedium.copyWith(
                                  color: AmaraColors.primary)),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final popular = restaurants.take(4).toList();
              final newer = restaurants.skip(4).toList();

              return SliverMainAxisGroup(slivers: [
                // Popular (full cards)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: RestaurantCard(restaurant: popular[index])
                            .animate()
                            .fadeIn(
                              delay: Duration(milliseconds: 400 + index * 80),
                              duration: 400.ms,
                            )
                            .slideY(begin: 0.15, end: 0),
                      ),
                      childCount: popular.length,
                    ),
                  ),
                ),

                // Nouveaux (horizontal compact)
                if (newer.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      child: SectionHeader(
                        title: 'Nouveaux arrivants',
                        subtitle: 'Voir tout',
                        onSubtitleTap: () => ref.read(shellIndexProvider.notifier).state = 1,
                      ),
                    ).animate().fadeIn(delay: 500.ms, duration: 400.ms),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 220,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                        physics: const BouncingScrollPhysics(),
                        itemCount: newer.length,
                        itemBuilder: (context, index) => Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: RestaurantCard(
                            restaurant: newer[index],
                            compact: true,
                          )
                              .animate()
                              .fadeIn(
                                delay: Duration(
                                    milliseconds: 550 + index * 80),
                                duration: 400.ms,
                              ),
                        ),
                      ),
                    ),
                  ),
                ],
              ]);
            },
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}
