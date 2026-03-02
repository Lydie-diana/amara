import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/core/constants/app_colors.dart';
import '../../../app/core/constants/app_text_styles.dart';
import '../../../app/core/l10n/app_localizations.dart';
import '../../../app/providers/categories_provider.dart';

class CategoryList extends ConsumerWidget {
  const CategoryList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final selectedCat = ref.watch(selectedCategoryProvider);
    final l10n = AppLocalizations.of(context);

    return categoriesAsync.when(
      loading: () => const SizedBox(height: 100),
      error: (_, __) => const SizedBox.shrink(),
      data: (categories) {
        if (categories.isEmpty) return const SizedBox.shrink();

        final allCategories = [
          const FoodCategory(emoji: '🍽️', label: 'Tout'),
          ...categories,
        ];

        return SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            physics: const BouncingScrollPhysics(),
            itemCount: allCategories.length,
            itemBuilder: (context, index) {
              final cat = allCategories[index];
              final isSelected = index == 0
                  ? selectedCat == null
                  : selectedCat == cat.label;

              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  ref.read(selectedCategoryProvider.notifier).state =
                      index == 0 ? null : cat.label;
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AmaraColors.primary.withValues(alpha: 0.1)
                              : AmaraColors.bgAlt,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? AmaraColors.primary
                                : AmaraColors.divider,
                            width: isSelected ? 2.0 : 1.0,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            cat.emoji,
                            style: const TextStyle(fontSize: 28),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _localizedLabel(cat.label, l10n),
                        style: AmaraTextStyles.caption.copyWith(
                          color: isSelected
                              ? AmaraColors.primary
                              : AmaraColors.textSecondary,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

/// Mapping des labels backend (français) vers les clés l10n.
String _localizedLabel(String label, AppLocalizations l10n) {
  return _categoryTranslations[label]?.call(l10n) ?? label;
}

final Map<String, String Function(AppLocalizations)> _categoryTranslations = {
  'Tout': (l10n) => l10n.categoryAll,
  'Poulet': (l10n) => l10n.categoryChicken,
  'Poisson': (l10n) => l10n.categoryFish,
  'Grillades': (l10n) => l10n.categoryGrill,
  'Riz': (l10n) => l10n.categoryRice,
  'Végétarien': (l10n) => l10n.categoryVegetarian,
  'Pâtes': (l10n) => l10n.categoryPasta,
  'Burgers': (l10n) => l10n.categoryBurger,
  'Épicé': (l10n) => l10n.categorySpicy,
  'Plats locaux': (l10n) => l10n.categoryLocal,
  'Desserts': (l10n) => l10n.categoryDessert,
  'Boissons': (l10n) => l10n.categoryDrink,
  'Africain': (l10n) => l10n.categoryAfrican,
  'Ragoût': (l10n) => l10n.categoryStew,
  'Salade': (l10n) => l10n.categorySalad,
  'Pizza': (l10n) => l10n.categoryPizza,
};
