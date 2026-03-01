import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/core/constants/app_colors.dart';
import '../../../app/core/constants/app_text_styles.dart';
import '../../../app/providers/categories_provider.dart';

class CategoryList extends ConsumerWidget {
  const CategoryList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final selectedCat = ref.watch(selectedCategoryProvider);

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
                        cat.label,
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
