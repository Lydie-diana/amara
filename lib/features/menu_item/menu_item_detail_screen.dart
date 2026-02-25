import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/core/constants/app_colors.dart';
import '../../app/core/constants/app_text_styles.dart';
import '../../app/models/restaurant_model.dart';
import '../../app/providers/cart_provider.dart';
import '../../app/router/app_routes.dart';

class MenuItemDetailScreen extends ConsumerStatefulWidget {
  final MenuItem item;
  final String restaurantId;
  final String restaurantName;
  final List<MenuItem> companions; // plats suggérés du même restaurant

  const MenuItemDetailScreen({
    super.key,
    required this.item,
    required this.restaurantId,
    required this.restaurantName,
    this.companions = const [],
  });

  @override
  ConsumerState<MenuItemDetailScreen> createState() =>
      _MenuItemDetailScreenState();
}

class _MenuItemDetailScreenState extends ConsumerState<MenuItemDetailScreen> {
  final _noteController = TextEditingController();
  final Map<String, Set<String>> _selectedOptions = {};
  int _quantity = 1;

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

  bool get _canAdd {
    for (final group in widget.item.optionGroups) {
      if (group.required && (_selectedOptions[group.id]?.isEmpty ?? true)) {
        return false;
      }
    }
    return true;
  }

  double get _extraPrice {
    double extra = 0;
    for (final group in widget.item.optionGroups) {
      final selected = _selectedOptions[group.id] ?? {};
      for (final opt in group.options) {
        if (selected.contains(opt.id)) extra += opt.extraPrice;
      }
    }
    return extra;
  }

  double get _totalPrice => (widget.item.price + _extraPrice) * _quantity;

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

  void _addToCart() {
    HapticFeedback.mediumImpact();
    for (var i = 0; i < _quantity; i++) {
      ref.read(cartProvider.notifier).addItem(
            widget.item,
            widget.restaurantId,
            widget.restaurantName,
          );
    }
    // Afficher snackbar puis retour
    if (mounted) {
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Text(widget.item.imageEmoji,
                  style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${widget.item.name} ajouté au panier !',
                  style: AmaraTextStyles.bodySmall
                      .copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: AmaraColors.dark,
          behavior: SnackBarBehavior.floating,
          margin:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          duration: const Duration(seconds: 2),
          action: SnackBarAction(
            label: 'Voir panier',
            textColor: AmaraColors.primary,
            onPressed: () => context.push(AppRoutes.cart),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AmaraColors.bg,
      body: Column(
        children: [
          // ── Contenu scrollable ─────────────────────────────────────────────
          Expanded(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Hero image
                _buildHeroSliver(context),

                // Détails
                SliverToBoxAdapter(
                  child: _buildDetails(context),
                ),
              ],
            ),
          ),

          // ── Barre d'action fixe en bas ─────────────────────────────────────
          _buildBottomBar(context),
        ],
      ),
    );
  }

  // ─── Hero image ────────────────────────────────────────────────────────────

  Widget _buildHeroSliver(BuildContext context) {
    final bgColor = _itemBgColor(widget.item.id);
    return SliverAppBar(
      expandedHeight: 320,
      pinned: true,
      backgroundColor: AmaraColors.bg,
      surfaceTintColor: Colors.transparent,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            decoration: BoxDecoration(
              color: AmaraColors.bgCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AmaraColors.divider),
            ),
            child: const Icon(Icons.arrow_back_ios_rounded,
                color: AmaraColors.textPrimary, size: 18),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
          child: Container(
            decoration: BoxDecoration(
              color: AmaraColors.bgCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AmaraColors.divider),
            ),
            child: IconButton(
              onPressed: () => HapticFeedback.lightImpact(),
              icon: const Icon(Icons.share_rounded,
                  color: AmaraColors.textPrimary, size: 18),
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              color: bgColor,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(widget.item.imageEmoji,
                      style: const TextStyle(fontSize: 120)),
                  // Indicateurs pagination (comme les maquettes)
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      4,
                      (i) => Container(
                        width: i == 0 ? 20 : 6,
                        height: 6,
                        margin:
                            const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          color: i == 0
                              ? AmaraColors.primary
                              : AmaraColors.divider,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Badges
            Positioned(
              top: MediaQuery.of(context).padding.top + 60,
              left: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.item.isPopular)
                    _HeroBadge(
                        label: '⭐ Populaire',
                        color: const Color(0xFFF39C12)),
                  if (widget.item.isVegetarian)
                    _HeroBadge(label: '🌱 Végétarien', color: AmaraColors.success),
                  if (widget.item.isSpicy)
                    _HeroBadge(label: '🌶️ Épicé', color: AmaraColors.error),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Détails ───────────────────────────────────────────────────────────────

  Widget _buildDetails(BuildContext context) {
    return Container(
      color: AmaraColors.bg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nom + prix + likes
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(widget.item.name,
                          style: AmaraTextStyles.h1),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          widget.item.formattedPrice,
                          style: AmaraTextStyles.h2.copyWith(
                            color: AmaraColors.primary,
                          ),
                        ),
                        if (_extraPrice > 0)
                          Text(
                            '+${_extraPrice.toStringAsFixed(0)} F options',
                            style: AmaraTextStyles.caption
                                .copyWith(color: AmaraColors.muted),
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Likes + restaurant
                Row(
                  children: [
                    const Icon(Icons.favorite_rounded,
                        size: 14, color: AmaraColors.error),
                    const SizedBox(width: 4),
                    Text('${widget.item.likeCount} personnes adorent ça',
                        style: AmaraTextStyles.caption
                            .copyWith(color: AmaraColors.muted)),
                    const SizedBox(width: 12),
                    const Icon(Icons.storefront_rounded,
                        size: 14, color: AmaraColors.muted),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        widget.restaurantName,
                        style: AmaraTextStyles.caption
                            .copyWith(color: AmaraColors.muted),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Description
                if (widget.item.description.isNotEmpty)
                  Text(
                    widget.item.description,
                    style: AmaraTextStyles.bodySmall.copyWith(
                        color: AmaraColors.textSecondary, height: 1.6),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          _Divider(),

          // ── Companion (plat suggéré) ─────────────────────────────────────
          if (widget.companions.isNotEmpty)
            _CompanionSection(
              companions: widget.companions,
              restaurantId: widget.restaurantId,
              restaurantName: widget.restaurantName,
            ),

          // ── Groupes d'options / accompagnements ──────────────────────────
          if (widget.item.optionGroups.isNotEmpty)
            _OptionsSection(
              optionGroups: widget.item.optionGroups,
              selectedOptions: _selectedOptions,
              onToggle: _toggleOption,
            ),

          // ── Note personnelle ─────────────────────────────────────────────
          _NoteSection(controller: _noteController),

          // Espace pour la barre du bas
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ─── Barre action bas ──────────────────────────────────────────────────────

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 12, 20, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: AmaraColors.bgCard,
        border: Border(top: BorderSide(color: AmaraColors.divider)),
      ),
      child: Row(
        children: [
          // Contrôle quantité
          Container(
            decoration: BoxDecoration(
              color: AmaraColors.bgAlt,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AmaraColors.divider),
            ),
            child: Row(
              children: [
                _QtyBtn(
                  icon: Icons.remove_rounded,
                  onTap: () {
                    if (_quantity > 1) setState(() => _quantity--);
                  },
                  enabled: _quantity > 1,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    '$_quantity',
                    style: AmaraTextStyles.h3.copyWith(
                        color: AmaraColors.textPrimary),
                  ),
                ),
                _QtyBtn(
                  icon: Icons.add_rounded,
                  onTap: () => setState(() => _quantity++),
                  enabled: true,
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),

          // Bouton Ajouter
          Expanded(
            child: GestureDetector(
              onTap: _canAdd ? _addToCart : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color:
                      _canAdd ? AmaraColors.primary : AmaraColors.muted,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.shopping_bag_rounded,
                        color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Ajouter · ${_totalPrice.toStringAsFixed(0)} F',
                      style: AmaraTextStyles.labelMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700),
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

  Color _itemBgColor(String id) {
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
}

// ─── Hero Badge ───────────────────────────────────────────────────────────────

class _HeroBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _HeroBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label,
          style: const TextStyle(
              color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }
}

// ─── Companion Section ────────────────────────────────────────────────────────

class _CompanionSection extends ConsumerWidget {
  final List<MenuItem> companions;
  final String restaurantId;
  final String restaurantName;

  const _CompanionSection({
    required this.companions,
    required this.restaurantId,
    required this.restaurantName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: AmaraColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text('Parfait avec ce plat 😋',
                  style: AmaraTextStyles.labelMedium
                      .copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
        ),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 20, right: 8),
            physics: const BouncingScrollPhysics(),
            itemCount: companions.take(4).length,
            itemBuilder: (context, index) {
              final companion = companions[index];
              final qty = ref.watch(
                  cartProvider.select((c) => c.quantityFor(companion.id)));
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  ref.read(cartProvider.notifier).addItem(
                        companion,
                        restaurantId,
                        restaurantName,
                      );
                },
                child: Container(
                  width: 200,
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AmaraColors.bgCard,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: qty > 0
                          ? AmaraColors.primary.withValues(alpha: 0.4)
                          : AmaraColors.divider,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(companion.imageEmoji,
                          style: const TextStyle(fontSize: 28)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(companion.name,
                                style: AmaraTextStyles.caption.copyWith(
                                    fontWeight: FontWeight.w700),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                            Text(companion.formattedPrice,
                                style: AmaraTextStyles.caption.copyWith(
                                    color: AmaraColors.primary,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: qty > 0
                              ? AmaraColors.primary.withValues(alpha: 0.15)
                              : AmaraColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: qty > 0
                            ? Center(
                                child: Text('$qty',
                                    style: AmaraTextStyles.caption.copyWith(
                                        color: AmaraColors.primary,
                                        fontWeight: FontWeight.w800)))
                            : const Icon(Icons.add_rounded,
                                color: Colors.white, size: 16),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        _Divider(),
      ],
    );
  }
}

// ─── Options Section ──────────────────────────────────────────────────────────

class _OptionsSection extends StatelessWidget {
  final List<MenuItemOptionGroup> optionGroups;
  final Map<String, Set<String>> selectedOptions;
  final Function(MenuItemOptionGroup, String) onToggle;

  const _OptionsSection({
    required this.optionGroups,
    required this.selectedOptions,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: AmaraColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text('Ingrédients & accompagnements',
                  style: AmaraTextStyles.labelMedium
                      .copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
        ),
        ...optionGroups.map((group) => _OptionGroup(
              group: group,
              selected: selectedOptions[group.id] ?? {},
              onToggle: (id) => onToggle(group, id),
            )),
        _Divider(),
      ],
    );
  }
}

class _OptionGroup extends StatelessWidget {
  final MenuItemOptionGroup group;
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  const _OptionGroup({
    required this.group,
    required this.selected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(group.title,
                    style: AmaraTextStyles.bodySmall
                        .copyWith(fontWeight: FontWeight.w600)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: group.required
                      ? AmaraColors.primary.withValues(alpha: 0.1)
                      : AmaraColors.bgAlt,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  group.required ? 'Requis' : 'Optionnel',
                  style: AmaraTextStyles.caption.copyWith(
                    color: group.required
                        ? AmaraColors.primary
                        : AmaraColors.muted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        ...group.options.map((option) {
          final isSelected = selected.contains(option.id);
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              onToggle(option.id);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: isSelected
                    ? AmaraColors.primary.withValues(alpha: 0.06)
                    : AmaraColors.bgCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected
                      ? AmaraColors.primary.withValues(alpha: 0.4)
                      : AmaraColors.divider,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  // Radio / Checkbox
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AmaraColors.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(
                          group.maxSelections == 1 ? 11 : 6),
                      border: Border.all(
                        color: isSelected
                            ? AmaraColors.primary
                            : AmaraColors.muted,
                        width: 1.5,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check_rounded,
                            size: 13, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 14),

                  // Nom
                  Expanded(
                    child: Text(option.name,
                        style: AmaraTextStyles.bodySmall.copyWith(
                          color: isSelected
                              ? AmaraColors.textPrimary
                              : AmaraColors.textSecondary,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        )),
                  ),

                  // Prix extra
                  Text(
                    option.extraPrice > 0
                        ? '+${option.extraPrice.toStringAsFixed(0)} F'
                        : 'Inclus',
                    style: AmaraTextStyles.caption.copyWith(
                      color: option.extraPrice > 0
                          ? AmaraColors.primary
                          : AmaraColors.muted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

// ─── Note Section ─────────────────────────────────────────────────────────────

class _NoteSection extends StatelessWidget {
  final TextEditingController controller;
  const _NoteSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: AmaraColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text('Note pour le restaurant',
                  style: AmaraTextStyles.labelMedium
                      .copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AmaraColors.bgAlt,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AmaraColors.divider),
            ),
            child: TextField(
              controller: controller,
              maxLines: 3,
              style: AmaraTextStyles.bodySmall,
              decoration: InputDecoration(
                hintText:
                    'Ex: sans oignons, cuisson bien cuite, sauce à part...',
                hintStyle: AmaraTextStyles.bodySmall
                    .copyWith(color: AmaraColors.muted),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Divider ──────────────────────────────────────────────────────────────────

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        height: 8, color: AmaraColors.bgAlt, margin: const EdgeInsets.symmetric(vertical: 4));
  }
}

// ─── Bouton quantité ──────────────────────────────────────────────────────────

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;
  const _QtyBtn(
      {required this.icon, required this.onTap, required this.enabled});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 44,
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon,
            color: enabled ? AmaraColors.textPrimary : AmaraColors.muted,
            size: 20),
      ),
    );
  }
}
