import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app/core/constants/app_colors.dart';
import '../../../app/core/constants/app_text_styles.dart';
import '../../../app/models/restaurant_model.dart';

/// Header info restaurant — identité + infos dépliables.
class RestaurantInfoHeader extends StatefulWidget {
  final Restaurant restaurant;
  final int totalClients;
  const RestaurantInfoHeader({super.key, required this.restaurant, this.totalClients = 0});

  @override
  State<RestaurantInfoHeader> createState() => _RestaurantInfoHeaderState();
}

class _RestaurantInfoHeaderState extends State<RestaurantInfoHeader> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final r = widget.restaurant;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Bloc 1 : Identité ──────────────────────────────────────────────
        _IdentityBlock(restaurant: r),

        // ── Séparateur fin ────────────────────────────────────────────────
        _SectionDivider(),

        // ── Métriques (toujours visibles) ─────────────────────────────────
        _MetricsBlock(restaurant: r, totalClients: widget.totalClients),

        _SectionDivider(),

        // ── Services + paiements (toujours visibles) ──────────────────────
        _ServicesBlock(restaurant: r),

        if (r.promos.isNotEmpty) ...[
          _SectionDivider(),
          _PromosBlock(promos: r.promos),
        ],

        // ── Accordéon : adresse + téléphone + horaires ────────────────────
        _SectionDivider(),

        _InfoAccordion(
          restaurant: r,
          expanded: _expanded,
          onToggle: () => setState(() => _expanded = !_expanded),
        ),

        const SizedBox(height: 8),
      ],
    );
  }
}

// ─── Accordéon infos ──────────────────────────────────────────────────────────

class _InfoAccordion extends StatelessWidget {
  final Restaurant restaurant;
  final bool expanded;
  final VoidCallback onToggle;

  const _InfoAccordion({
    required this.restaurant,
    required this.expanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header tap
        GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            onToggle();
          },
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: AmaraColors.bgAlt,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.info_outline_rounded,
                      size: 16, color: AmaraColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Infos du restaurant',
                    style: AmaraTextStyles.labelSmall.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 250),
                  child: const Icon(Icons.keyboard_arrow_down_rounded,
                      size: 22, color: AmaraColors.muted),
                ),
              ],
            ),
          ),
        ),

        // Contenu dépliable : adresse + téléphone + horaires
        AnimatedSize(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeInOut,
          child: expanded
              ? _AddressScheduleBlock(restaurant: restaurant)
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

// ─── BLOC 1 : Identité ────────────────────────────────────────────────────────

class _IdentityBlock extends StatelessWidget {
  final Restaurant restaurant;
  const _IdentityBlock({required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nom + badge ouvert
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  restaurant.name,
                  style: AmaraTextStyles.h1,
                ),
              ),
              const SizedBox(width: 12),
              _OpenBadge(isOpen: restaurant.isOpen),
            ],
          ),

          const SizedBox(height: 6),

          // Type de cuisine
          Text(
            restaurant.cuisine,
            style: AmaraTextStyles.bodySmall.copyWith(
              color: AmaraColors.textSecondary,
            ),
          ),

          const SizedBox(height: 12),

          // Description courte
          Text(
            restaurant.description,
            style: AmaraTextStyles.bodySmall.copyWith(
              color: AmaraColors.textSecondary,
              height: 1.55,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),


          // Badge "déjà commandé" discret
          if (restaurant.hasOrdered) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_rounded,
                    size: 13, color: AmaraColors.primary),
                const SizedBox(width: 5),
                Text(
                  'Vous avez déjà commandé ici',
                  style: AmaraTextStyles.caption.copyWith(
                    color: AmaraColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ─── BLOC 2 : Métriques ───────────────────────────────────────────────────────

class _MetricsBlock extends StatelessWidget {
  final Restaurant restaurant;
  final int totalClients;
  const _MetricsBlock({required this.restaurant, this.totalClients = 0});

  String _formatClients(int count) {
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}k';
    return '$count';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AmaraColors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          // Note
          _Metric(
            value: restaurant.rating.toStringAsFixed(1),
            label: '${restaurant.reviewCount} avis',
            icon: Icons.star_rounded,
            iconColor: const Color(0xFFF39C12),
            onDark: true,
          ),
          _MetricDivider(onDark: true),
          // Nombre d'avis
          _Metric(
            value: '${restaurant.reviewCount}',
            label: 'Avis',
            icon: Icons.reviews_rounded,
            iconColor: const Color(0xFF80E5A8),
            onDark: true,
          ),
          _MetricDivider(onDark: true),
          // Nombre total de clients
          _Metric(
            value: _formatClients(totalClients),
            label: 'Clients',
            icon: Icons.people_alt_rounded,
            iconColor: const Color(0xFF80D4FF),
            onDark: true,
          ),
          _MetricDivider(onDark: true),
          // Temps livraison (tappable → popup)
          _TappableMetric(
            value: restaurant.deliveryTime,
            label: 'Livraison',
            icon: Icons.access_time_rounded,
            iconColor: Colors.white,
            onDark: true,
            onTap: () => _showDeliveryTimePopup(context, restaurant.deliveryTime),
          ),
        ],
      ),
    );
  }

  void _showDeliveryTimePopup(BuildContext context, String deliveryTime) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom +
              MediaQuery.of(context).padding.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Poignée
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AmaraColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),

            // Titre
            Text(
              'Au plus tôt',
              style: AmaraTextStyles.h2.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 24),

            // Illustration
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Center(
                child: Text('🕐🥗', style: TextStyle(fontSize: 64)),
              ),
            ),
            const SizedBox(height: 24),

            // Texte explicatif
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Remplissez votre panier pour obtenir une estimation '
                'plus précise en fonction des articles sélectionnés, des '
                'conditions en temps réel et des options de livraison '
                'lors du paiement. Cette estimation correspond à '
                "l'heure d'arrivée au plus tôt, avant la sélection "
                "d'articles.",
                textAlign: TextAlign.center,
                style: AmaraTextStyles.bodySmall.copyWith(
                  color: AmaraColors.textSecondary,
                  height: 1.55,
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Bouton OK
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: AmaraColors.textPrimary,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        'OK',
                        style: AmaraTextStyles.labelMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color iconColor;
  final bool onDark;

  const _Metric({
    required this.value,
    required this.label,
    required this.icon,
    required this.iconColor,
    this.onDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(height: 4),
          Text(
            value,
            style: AmaraTextStyles.labelMedium.copyWith(
              fontWeight: FontWeight.w800,
              color: onDark ? Colors.white : AmaraColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AmaraTextStyles.caption.copyWith(
              color: onDark
                  ? Colors.white.withValues(alpha: 0.7)
                  : AmaraColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}

class _TappableMetric extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color iconColor;
  final bool onDark;
  final VoidCallback onTap;

  const _TappableMetric({
    required this.value,
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.onTap,
    this.onDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          children: [
            Icon(icon, size: 18, color: iconColor),
            const SizedBox(height: 4),
            Text(
              value,
              style: AmaraTextStyles.labelMedium.copyWith(
                fontWeight: FontWeight.w800,
                color: onDark ? Colors.white : AmaraColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AmaraTextStyles.caption.copyWith(
                color: onDark
                    ? Colors.white.withValues(alpha: 0.7)
                    : AmaraColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricDivider extends StatelessWidget {
  final bool onDark;
  const _MetricDivider({this.onDark = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 32,
      color: onDark
          ? Colors.white.withValues(alpha: 0.3)
          : AmaraColors.divider,
      margin: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}

// ─── BLOC 3 : Services + paiements ───────────────────────────────────────────

class _ServicesBlock extends StatelessWidget {
  final Restaurant restaurant;
  const _ServicesBlock({required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        children: [
          // Modes de service
          if (restaurant.serviceModes.isNotEmpty)
            _InfoRow(
              icon: Icons.local_shipping_outlined,
              label: 'Service',
              child: Row(
                children: restaurant.serviceModes.map((m) {
                  final (emoji, txt) = switch (m) {
                    ServiceMode.delivery => ('🛵', 'Livraison'),
                    ServiceMode.takeaway => ('🥡', 'À emporter'),
                    ServiceMode.dineIn => ('🍽', 'Sur place'),
                  };
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(emoji, style: const TextStyle(fontSize: 13)),
                        const SizedBox(width: 4),
                        Text(
                          txt,
                          style: AmaraTextStyles.caption.copyWith(
                            color: AmaraColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

          if (restaurant.serviceModes.isNotEmpty &&
              restaurant.paymentMethods.isNotEmpty)
            const SizedBox(height: 12),

          // Paiements
          if (restaurant.paymentMethods.isNotEmpty)
            _InfoRow(
              icon: Icons.payment_rounded,
              label: 'Paiement',
              child: Wrap(
                spacing: 6,
                runSpacing: 4,
                children: restaurant.paymentMethods
                    .map((m) => _PaymentChip(method: m))
                    .toList(),
              ),
            ),

          // Commande minimum
          if (restaurant.minOrder > 0) ...[
            const SizedBox(height: 12),
            _InfoRow(
              icon: Icons.shopping_bag_outlined,
              label: 'Min. commande',
              child: Text(
                '${restaurant.minOrder.toStringAsFixed(0)} F',
                style: AmaraTextStyles.caption.copyWith(
                  color: AmaraColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],

          // Frais livraison
          const SizedBox(height: 12),
          _InfoRow(
            icon: Icons.delivery_dining_rounded,
            label: 'Livraison',
            child: Text(
              restaurant.deliveryFee,
              style: AmaraTextStyles.caption.copyWith(
                color: restaurant.deliveryFee == 'Gratuit'
                    ? AmaraColors.success
                    : AmaraColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget child;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: AmaraColors.muted),
        const SizedBox(width: 10),
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: AmaraTextStyles.caption.copyWith(
              color: AmaraColors.muted,
            ),
          ),
        ),
        Expanded(child: child),
      ],
    );
  }
}

class _PaymentChip extends StatelessWidget {
  final String method;
  const _PaymentChip({required this.method});

  IconData get _icon {
    final m = method.toLowerCase();
    if (m.contains('mobile') || m.contains('wave') || m.contains('momo')) {
      return Icons.phone_android_rounded;
    }
    if (m.contains('carte') || m.contains('card')) {
      return Icons.credit_card_rounded;
    }
    return Icons.payments_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AmaraColors.bgAlt,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AmaraColors.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 11, color: AmaraColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            method,
            style: AmaraTextStyles.caption.copyWith(
              color: AmaraColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── BLOC 4 : Promos ──────────────────────────────────────────────────────────

class _PromosBlock extends StatelessWidget {
  final List<RestaurantPromo> promos;
  const _PromosBlock({required this.promos});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre section
          Row(
            children: [
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  color: AmaraColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Promotions en cours',
                style: AmaraTextStyles.labelSmall.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Promos
          ...promos.map((p) => _PromoCard(promo: p)),
        ],
      ),
    );
  }
}

class _PromoCard extends StatelessWidget {
  final RestaurantPromo promo;
  const _PromoCard({required this.promo});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AmaraColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: AmaraColors.primary.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          // Emoji avec fond coloré
          Container(
            width: 52,
            height: 52,
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AmaraColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(promo.emoji,
                  style: const TextStyle(fontSize: 22)),
            ),
          ),

          // Texte
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  promo.title,
                  style: AmaraTextStyles.labelSmall.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  promo.description,
                  style: AmaraTextStyles.caption.copyWith(
                    color: AmaraColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Code à copier
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Clipboard.setData(ClipboardData(text: promo.code));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Code "${promo.code}" copié !'),
                  backgroundColor: AmaraColors.dark,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AmaraColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                promo.code,
                style: AmaraTextStyles.caption.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── BLOC 5 : Horaires (accordéon) ───────────────────────────────────────────

class _ScheduleBlock extends StatefulWidget {
  final Restaurant restaurant;
  const _ScheduleBlock({required this.restaurant});

  @override
  State<_ScheduleBlock> createState() => _ScheduleBlockState();
}

class _ScheduleBlockState extends State<_ScheduleBlock> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Header accordéon
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _expanded = !_expanded);
            },
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AmaraColors.bgCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AmaraColors.divider),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AmaraColors.bgAlt,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.schedule_rounded,
                        size: 16, color: AmaraColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Horaires & informations',
                          style: AmaraTextStyles.labelSmall.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          widget.restaurant.isOpen
                              ? 'Ouvert maintenant'
                              : 'Actuellement fermé',
                          style: AmaraTextStyles.caption.copyWith(
                            color: widget.restaurant.isOpen
                                ? AmaraColors.success
                                : AmaraColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: const Icon(Icons.keyboard_arrow_down_rounded,
                        size: 22, color: AmaraColors.muted),
                  ),
                ],
              ),
            ),
          ),

          // Contenu expandable
          AnimatedSize(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeInOut,
            child: _expanded
                ? _ExpandedSchedule(restaurant: widget.restaurant)
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _ExpandedSchedule extends StatelessWidget {
  final Restaurant restaurant;
  const _ExpandedSchedule({required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 2),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AmaraColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AmaraColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Adresse
          _ContactRow(
            icon: Icons.location_on_rounded,
            text: restaurant.address,
            color: AmaraColors.error,
          ),
          if (restaurant.schedule.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(height: 1, color: AmaraColors.divider),
            const SizedBox(height: 16),

            Text(
              'Horaires d\'ouverture',
              style: AmaraTextStyles.caption.copyWith(
                fontWeight: FontWeight.w700,
                color: AmaraColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            ...restaurant.schedule.map((s) => _DayRow(schedule: s)),
          ],
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  const _ContactRow(
      {required this.icon, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: AmaraTextStyles.caption
                .copyWith(color: AmaraColors.textSecondary),
          ),
        ),
      ],
    );
  }
}

class _DayRow extends StatelessWidget {
  final DaySchedule schedule;
  const _DayRow({required this.schedule});

  bool get _isToday {
    final today = DateTime.now().weekday;
    const days = [
      'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'
    ];
    return days.indexOf(schedule.day) + 1 == today;
  }

  @override
  Widget build(BuildContext context) {
    final isToday = _isToday;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 84,
            child: Text(
              schedule.day,
              style: AmaraTextStyles.caption.copyWith(
                color: isToday
                    ? AmaraColors.primary
                    : AmaraColors.textSecondary,
                fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ),
          Expanded(
            child: Text(
              schedule.display,
              style: AmaraTextStyles.caption.copyWith(
                color: schedule.isClosed
                    ? AmaraColors.muted
                    : (isToday
                        ? AmaraColors.primary
                        : AmaraColors.textPrimary),
                fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ),
          if (isToday)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: AmaraColors.primary,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                "Aujourd'hui",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w700),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Composants transversaux ──────────────────────────────────────────────────

class _OpenBadge extends StatelessWidget {
  final bool isOpen;
  const _OpenBadge({required this.isOpen});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isOpen
            ? AmaraColors.success.withValues(alpha: 0.1)
            : AmaraColors.bgAlt,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isOpen
              ? AmaraColors.success.withValues(alpha: 0.3)
              : AmaraColors.divider,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: isOpen ? AmaraColors.success : AmaraColors.muted,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            isOpen ? 'Ouvert' : 'Fermé',
            style: AmaraTextStyles.caption.copyWith(
              color: isOpen ? AmaraColors.success : AmaraColors.muted,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  const _Tag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AmaraColors.bgAlt,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AmaraColors.divider),
      ),
      child: Text(
        label,
        style: AmaraTextStyles.caption.copyWith(
          color: AmaraColors.textSecondary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// ─── Adresse + Téléphone + Horaires ──────────────────────────────────────────

class _AddressScheduleBlock extends StatelessWidget {
  final Restaurant restaurant;
  const _AddressScheduleBlock({required this.restaurant});

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];

    if (restaurant.address.isNotEmpty) {
      rows.add(_ContactRow(
        icon: Icons.location_on_rounded,
        text: restaurant.address,
        color: AmaraColors.error,
      ));
    }

    if (restaurant.phone.isNotEmpty) {
      if (rows.isNotEmpty) rows.add(const SizedBox(height: 10));
      rows.add(_ContactRow(
        icon: Icons.phone_rounded,
        text: restaurant.phone,
        color: AmaraColors.success,
      ));
    }

    if (restaurant.schedule.isNotEmpty) {
      rows.add(const SizedBox(height: 16));
      rows.add(Container(height: 1, color: AmaraColors.divider));
      rows.add(const SizedBox(height: 16));
      rows.add(Text(
        'Horaires d\'ouverture',
        style: AmaraTextStyles.caption.copyWith(
          fontWeight: FontWeight.w700,
          color: AmaraColors.textPrimary,
        ),
      ));
      rows.add(const SizedBox(height: 10));
      rows.addAll(restaurant.schedule.map((s) => _DayRow(schedule: s)));
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: rows,
      ),
    );
  }
}

class _SectionDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(height: 8, color: AmaraColors.bgAlt);
  }
}
