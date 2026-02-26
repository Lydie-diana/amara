import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/core/constants/app_colors.dart';
import '../../../app/core/constants/app_text_styles.dart';
import '../../../app/models/restaurant_model.dart';
import '../../../app/providers/cart_provider.dart';
import '../../menu_item/menu_item_detail_screen.dart';

class MenuCategorySection extends ConsumerWidget {
  final MenuCategory category;
  final String restaurantId;
  final String restaurantName;
  final List<MenuItem> allItems;
  final int animationDelay;

  const MenuCategorySection({
    super.key,
    required this.category,
    required this.restaurantId,
    required this.restaurantName,
    this.allItems = const [],
    this.animationDelay = 0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 4),
          child: Text(category.name, style: AmaraTextStyles.h3),
        ),
        ...category.items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final companions =
              allItems.where((i) => i.id != item.id).take(4).toList();
          return _MenuItemTile(
            item: item,
            restaurantId: restaurantId,
            restaurantName: restaurantName,
            companions: companions,
          )
              .animate()
              .fadeIn(
                delay: Duration(milliseconds: animationDelay + index * 60),
                duration: 350.ms,
              )
              .slideX(begin: 0.05, end: 0);
        }),
      ],
    );
  }
}

// ─── Tuile article ────────────────────────────────────────────────────────────

class _MenuItemTile extends ConsumerWidget {
  final MenuItem item;
  final String restaurantId;
  final String restaurantName;
  final List<MenuItem> companions;

  const _MenuItemTile({
    required this.item,
    required this.restaurantId,
    required this.restaurantName,
    this.companions = const [],
  });

  void _openDetail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MenuItemDetailScreen(
          item: item,
          restaurantId: restaurantId,
          restaurantName: restaurantName,
          companions: companions,
        ),
      ),
    );
  }

  void _showCustomizationSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ItemCustomizationSheet(
        item: item,
        restaurantId: restaurantId,
        restaurantName: restaurantName,
        ref: ref,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final quantity = cart.quantityFor(item.id);
    final inCart = quantity > 0;
    final hasOptions = item.optionGroups.isNotEmpty;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _openDetail(context);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AmaraColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: inCart
                ? AmaraColors.primary.withValues(alpha: 0.3)
                : AmaraColors.divider,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image plat
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 72,
                height: 72,
                child: item.imageUrl != null
                    ? Image.network(
                        item.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: AmaraColors.bgAlt,
                          child: Center(
                            child: Text(item.imageEmoji,
                                style: const TextStyle(fontSize: 32)),
                          ),
                        ),
                        loadingBuilder: (_, child, progress) => progress == null
                            ? child
                            : Container(
                                color: AmaraColors.bgAlt,
                                child: Center(
                                  child: Text(item.imageEmoji,
                                      style: const TextStyle(fontSize: 32)),
                                ),
                              ),
                      )
                    : Container(
                        color: AmaraColors.bgAlt,
                        child: Center(
                          child: Text(item.imageEmoji,
                              style: const TextStyle(fontSize: 36)),
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nom + badges
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: AmaraTextStyles.labelMedium
                              .copyWith(fontWeight: FontWeight.w700),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Row(
                        children: [
                          if (item.isPopular)
                            _Badge(label: '⭐', bgColor: const Color(0xFFFFF3E0)),
                          if (item.isVegetarian)
                            _Badge(label: '🌱', bgColor: const Color(0xFFE8F5E9)),
                          if (item.isSpicy)
                            _Badge(label: '🌶️', bgColor: const Color(0xFFFFEBEE)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Description
                  if (item.description.isNotEmpty)
                    Text(
                      item.description,
                      style: AmaraTextStyles.caption.copyWith(
                        color: AmaraColors.textSecondary,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                  // Likes
                  if (item.likeCount > 0) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.favorite_rounded,
                            size: 11, color: AmaraColors.error),
                        const SizedBox(width: 3),
                        Text(
                          '${item.likeCount} personnes adorent ça',
                          style: AmaraTextStyles.caption
                              .copyWith(color: AmaraColors.muted),
                        ),
                      ],
                    ),
                  ],

                  // Accompagnements dispo
                  if (hasOptions) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.tune_rounded,
                            size: 11, color: AmaraColors.primary),
                        const SizedBox(width: 3),
                        Text(
                          'Options disponibles',
                          style: AmaraTextStyles.caption.copyWith(
                            color: AmaraColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 10),

                  // Prix + contrôle quantité
                  Row(
                    children: [
                      Text(
                        item.formattedPrice,
                        style: AmaraTextStyles.labelMedium.copyWith(
                          color: AmaraColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(),
                      if (!item.isAvailable)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AmaraColors.bgAlt,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AmaraColors.divider),
                          ),
                          child: Text('Indisponible',
                              style: AmaraTextStyles.caption
                                  .copyWith(color: AmaraColors.muted)),
                        )
                      else if (inCart)
                        _QuantityControl(
                          quantity: quantity,
                          onDecrement: () {
                            HapticFeedback.lightImpact();
                            ref.read(cartProvider.notifier).removeItem(item.id);
                          },
                          onIncrement: () {
                            HapticFeedback.lightImpact();
                            if (hasOptions) {
                              _showCustomizationSheet(context, ref);
                            } else {
                              ref.read(cartProvider.notifier).addItem(
                                    item,
                                    restaurantId,
                                    restaurantName,
                                  );
                            }
                          },
                        )
                      else
                        _AddButton(
                          hasOptions: hasOptions,
                          onTap: () {
                            HapticFeedback.lightImpact();
                            if (hasOptions) {
                              _showCustomizationSheet(context, ref);
                            } else {
                              ref.read(cartProvider.notifier).addItem(
                                    item,
                                    restaurantId,
                                    restaurantName,
                                  );
                            }
                          },
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
}

// ─── Bottom Sheet personnalisation ────────────────────────────────────────────

class _ItemCustomizationSheet extends StatefulWidget {
  final MenuItem item;
  final String restaurantId;
  final String restaurantName;
  final WidgetRef ref;

  const _ItemCustomizationSheet({
    required this.item,
    required this.restaurantId,
    required this.restaurantName,
    required this.ref,
  });

  @override
  State<_ItemCustomizationSheet> createState() =>
      _ItemCustomizationSheetState();
}

class _ItemCustomizationSheetState extends State<_ItemCustomizationSheet> {
  final _noteController = TextEditingController();

  // selectedOptions[groupId] = Set d'option ids sélectionnés
  final Map<String, Set<String>> _selectedOptions = {};

  @override
  void initState() {
    super.initState();
    for (final group in widget.item.optionGroups) {
      _selectedOptions[group.id] = {};
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  bool get _canConfirm {
    for (final group in widget.item.optionGroups) {
      if (group.required &&
          (_selectedOptions[group.id]?.isEmpty ?? true)) {
        return false;
      }
    }
    return true;
  }

  void _toggleOption(MenuItemOptionGroup group, String optionId) {
    setState(() {
      final selected = _selectedOptions[group.id]!;
      if (group.maxSelections == 1) {
        selected.clear();
        selected.add(optionId);
      } else {
        if (selected.contains(optionId)) {
          selected.remove(optionId);
        } else if (selected.length < group.maxSelections) {
          selected.add(optionId);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AmaraColors.bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 4),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AmaraColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Text(widget.item.imageEmoji,
                          style: const TextStyle(fontSize: 32)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.item.name,
                                style: AmaraTextStyles.h3),
                            Text(widget.item.formattedPrice,
                                style: AmaraTextStyles.labelSmall.copyWith(
                                    color: AmaraColors.primary,
                                    fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Groupes d'options
                  ...widget.item.optionGroups.map((group) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(group.title,
                                  style: AmaraTextStyles.labelMedium.copyWith(
                                      fontWeight: FontWeight.w700)),
                            ),
                            if (group.required)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AmaraColors.primary
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text('Requis',
                                    style: AmaraTextStyles.caption.copyWith(
                                        color: AmaraColors.primary,
                                        fontWeight: FontWeight.w700)),
                              )
                            else
                              Text('Optionnel',
                                  style: AmaraTextStyles.caption
                                      .copyWith(color: AmaraColors.muted)),
                          ],
                        ),
                        if (group.maxSelections > 1)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                                'Choisissez jusqu\'à ${group.maxSelections}',
                                style: AmaraTextStyles.caption
                                    .copyWith(color: AmaraColors.muted)),
                          ),
                        const SizedBox(height: 8),
                        ...group.options.map((option) {
                          final selected =
                              _selectedOptions[group.id]?.contains(option.id) ??
                                  false;
                          return GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              _toggleOption(group, option.id);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: selected
                                    ? AmaraColors.primary
                                        .withValues(alpha: 0.07)
                                    : AmaraColors.bgCard,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: selected
                                      ? AmaraColors.primary
                                          .withValues(alpha: 0.4)
                                      : AmaraColors.divider,
                                  width: selected ? 1.5 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  AnimatedContainer(
                                    duration:
                                        const Duration(milliseconds: 150),
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: selected
                                          ? AmaraColors.primary
                                          : Colors.transparent,
                                      borderRadius:
                                          BorderRadius.circular(
                                              group.maxSelections == 1
                                                  ? 10
                                                  : 6),
                                      border: Border.all(
                                        color: selected
                                            ? AmaraColors.primary
                                            : AmaraColors.muted,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: selected
                                        ? const Icon(Icons.check_rounded,
                                            size: 12,
                                            color: Colors.white)
                                        : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(option.name,
                                        style:
                                            AmaraTextStyles.bodySmall.copyWith(
                                          color: selected
                                              ? AmaraColors.textPrimary
                                              : AmaraColors.textSecondary,
                                          fontWeight: selected
                                              ? FontWeight.w600
                                              : FontWeight.w400,
                                        )),
                                  ),
                                  if (option.extraPrice > 0)
                                    Text(
                                      option.priceLabel,
                                      style: AmaraTextStyles.caption.copyWith(
                                        color: AmaraColors.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    )
                                  else
                                    Text(
                                      option.priceLabel,
                                      style: AmaraTextStyles.caption.copyWith(
                                          color: AmaraColors.muted),
                                    ),
                                ],
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: 8),
                      ],
                    );
                  }),

                  // Note personnelle
                  Text('Note pour le restaurant',
                      style: AmaraTextStyles.labelMedium
                          .copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _noteController,
                    maxLines: 3,
                    style: AmaraTextStyles.bodySmall,
                    decoration: InputDecoration(
                      hintText:
                          'Ex : sans oignons, sauce à part, cuisson à point...',
                      hintStyle: AmaraTextStyles.bodySmall
                          .copyWith(color: AmaraColors.muted),
                      filled: true,
                      fillColor: AmaraColors.bgAlt,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide:
                            const BorderSide(color: AmaraColors.divider),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide:
                            const BorderSide(color: AmaraColors.divider),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                            color: AmaraColors.primary, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Bouton confirmer
          Padding(
            padding: EdgeInsets.fromLTRB(
                20,
                8,
                20,
                MediaQuery.of(context).padding.bottom + 16),
            child: GestureDetector(
              onTap: _canConfirm
                  ? () {
                      HapticFeedback.lightImpact();
                      widget.ref.read(cartProvider.notifier).addItem(
                            widget.item,
                            widget.restaurantId,
                            widget.restaurantName,
                          );
                      Navigator.of(context).pop();
                    }
                  : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: _canConfirm ? AmaraColors.primary : AmaraColors.muted,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_shopping_cart_rounded,
                        color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Ajouter au panier',
                      style: AmaraTextStyles.labelMedium
                          .copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Composants communs ───────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  final String label;
  final Color bgColor;
  const _Badge({required this.label, required this.bgColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 4),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label, style: const TextStyle(fontSize: 10)),
    );
  }
}

class _AddButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool hasOptions;
  const _AddButton({required this.onTap, this.hasOptions = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: hasOptions
            ? const EdgeInsets.symmetric(horizontal: 12, vertical: 8)
            : null,
        width: hasOptions ? null : 36,
        height: 36,
        decoration: BoxDecoration(
          color: AmaraColors.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_rounded, color: Colors.white, size: 18),
            if (hasOptions) ...[
              const SizedBox(width: 4),
              Text('Choisir',
                  style: AmaraTextStyles.caption
                      .copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
            ],
          ],
        ),
      ),
    );
  }
}

class _QuantityControl extends StatelessWidget {
  final int quantity;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const _QuantityControl({
    required this.quantity,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AmaraColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AmaraColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _CtrlBtn(icon: Icons.remove_rounded, onTap: onDecrement),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text('$quantity',
                style: AmaraTextStyles.labelMedium.copyWith(
                    color: AmaraColors.primary, fontWeight: FontWeight.w800)),
          ),
          _CtrlBtn(icon: Icons.add_rounded, onTap: onIncrement),
        ],
      ),
    );
  }
}

class _CtrlBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CtrlBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AmaraColors.primary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }
}
