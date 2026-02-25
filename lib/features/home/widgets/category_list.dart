import 'package:flutter/material.dart';
import '../../../app/core/constants/app_colors.dart';
import '../../../app/core/constants/app_text_styles.dart';

class CategoryList extends StatefulWidget {
  const CategoryList({super.key});

  @override
  State<CategoryList> createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 96,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        physics: const BouncingScrollPhysics(),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = _selected == index;

          return GestureDetector(
            onTap: () => setState(() => _selected = index),
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AmaraColors.primary
                          : AmaraColors.bgAlt,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? AmaraColors.primary
                            : AmaraColors.divider,
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        cat.emoji,
                        style: const TextStyle(fontSize: 26),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    cat.label,
                    style: AmaraTextStyles.caption.copyWith(
                      color: isSelected
                          ? AmaraColors.primary
                          : AmaraColors.muted,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Category {
  final String emoji;
  final String label;
  const _Category({required this.emoji, required this.label});
}

const _categories = [
  _Category(emoji: '🍽️', label: 'Tout'),
  _Category(emoji: '🍲', label: 'Ragoût'),
  _Category(emoji: '🍗', label: 'Grillades'),
  _Category(emoji: '🥘', label: 'Riz'),
  _Category(emoji: '🥗', label: 'Salade'),
  _Category(emoji: '🍕', label: 'Pizza'),
  _Category(emoji: '🍔', label: 'Burger'),
  _Category(emoji: '🥤', label: 'Boisson'),
  _Category(emoji: '🍰', label: 'Dessert'),
];
