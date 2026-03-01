import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/core/constants/app_colors.dart';
import '../../app/core/constants/app_text_styles.dart';
import '../../app/providers/favorites_provider.dart';
import '../../app/providers/restaurant_provider.dart';
import '../home/widgets/restaurant_card.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteIds = ref.watch(favoritesProvider);
    final restaurantsAsync = ref.watch(restaurantListProvider);

    return Scaffold(
      backgroundColor: AmaraColors.bg,
      appBar: AppBar(
        backgroundColor: AmaraColors.bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).pop();
          },
          child: const Icon(Icons.arrow_back_rounded,
              color: AmaraColors.textPrimary),
        ),
        centerTitle: true,
        title: Text(
          'Mes favoris',
          style: AmaraTextStyles.h3.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      body: restaurantsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AmaraColors.primary),
        ),
        error: (_, __) => Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.wifi_off_rounded,
                    color: AmaraColors.muted, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Erreur de chargement',
                  style: AmaraTextStyles.h3
                      .copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  'Impossible de charger les restaurants.',
                  style: AmaraTextStyles.bodyMedium
                      .copyWith(color: AmaraColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        data: (allRestaurants) {
          final favorites = allRestaurants
              .where((r) => favoriteIds.contains(r.id))
              .toList();

          if (favorites.isEmpty) {
            return _EmptyFavorites();
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            physics: const BouncingScrollPhysics(),
            itemCount: favorites.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (_, index) => RestaurantCard(
              restaurant: favorites[index],
            ),
          );
        },
      ),
    );
  }
}

class _EmptyFavorites extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AmaraColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.favorite_outline_rounded,
                  color: AmaraColors.primary, size: 40),
            ),
            const SizedBox(height: 20),
            Text(
              'Aucun favori',
              style:
                  AmaraTextStyles.h2.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'Appuyez sur le coeur d\'un restaurant pour l\'ajouter à vos favoris.',
              style: AmaraTextStyles.bodySmall.copyWith(
                color: AmaraColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
