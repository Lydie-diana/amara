import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/core/constants/app_colors.dart';
import '../../app/core/constants/app_text_styles.dart';
import '../../app/core/l10n/app_localizations.dart';
import '../../app/core/widgets/error_dialog.dart';
import '../../app/providers/auth_provider.dart';
import '../../app/router/app_routes.dart';
import '../../app/services/convex_client.dart';
import '../review/review_screen.dart';
import '../shell/main_shell.dart';
import 'receipt_screen.dart';

// ─── Provider de suivi commande (polling toutes les 10s) ─────────────────────

final orderTrackingProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, orderId) async {
  if (RegExp(r'^\d+$').hasMatch(orderId) || orderId.startsWith('ORD')) {
    return {
      '_id': orderId,
      'status': 'preparing',
      'restaurantName': 'Chez Mama Africa',
      'items': [
        {
          'name': 'Attieke Poisson Braise',
          'quantity': 2,
          'unitPrice': 2500,
          'imageUrl': null,
        },
        {
          'name': 'Jus de Bissap',
          'quantity': 1,
          'unitPrice': 800,
          'imageUrl': null,
        },
      ],
      'deliveryAddress': 'Cocody, Abidjan',
      'paymentMethod': 'mobile_money',
      'totalAmount': 5800,
      'estimatedDeliveryTime': 30,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    };
  }
  try {
    final client = ref.read(convexClientProvider);
    return await client.getOrder(orderId);
  } catch (_) {
    return {
      '_id': orderId,
      'status': 'preparing',
      'restaurantName': 'Restaurant',
      'items': <Map<String, dynamic>>[],
      'totalAmount': 0,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    };
  }
});

// Statut → step index (0-based) — Livraison
const _statusSteps = {
  'pending': 0,
  'confirmed': 0,
  'preparing': 1,
  'ready': 2,
  'delivering': 3,
  'delivered': 4,
  'cancelled': -1,
};

// Statut → step index (0-based) — À emporter (pas de "delivering")
const _pickupStatusSteps = {
  'pending': 0,
  'confirmed': 0,
  'preparing': 1,
  'ready': 2,
  'picked_up': 3,
  'delivered': 3,
  'cancelled': -1,
};

// ─── Ecran ─────────────────────────────────────────────────────────────────────

class OrderTrackingScreen extends ConsumerStatefulWidget {
  final String orderId;
  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  ConsumerState<OrderTrackingScreen> createState() =>
      _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends ConsumerState<OrderTrackingScreen> {
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      ref.invalidate(orderTrackingProvider(widget.orderId));
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _cancelOrder() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.ordersCancelTitle,
            style: AmaraTextStyles.h3.copyWith(fontWeight: FontWeight.w700)),
        content: Text(
          l10n.ordersCancelMessage,
          style: AmaraTextStyles.bodySmall
              .copyWith(color: AmaraColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.ordersCancelNo,
                style: TextStyle(
                    color: AmaraColors.textSecondary,
                    fontWeight: FontWeight.w600)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.ordersCancelYes,
                style: TextStyle(
                    color: AmaraColors.error, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      final client = ref.read(convexClientProvider);
      await client.cancelOrder(widget.orderId,
          reason: l10n.ordersCancelledByClient);
      ref.invalidate(orderTrackingProvider(widget.orderId));
      if (mounted) {
        HapticFeedback.mediumImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.ordersCancelledSuccess,
                style: AmaraTextStyles.bodySmall.copyWith(color: Colors.white)),
            backgroundColor: AmaraColors.error,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) showErrorDialog(context, e);
    }
  }

  Future<void> _confirmPickup() async {
    try {
      final client = ref.read(convexClientProvider);
      await client.confirmPickup(widget.orderId);
      ref.invalidate(orderTrackingProvider(widget.orderId));
    } catch (e) {
      if (mounted) {
        showErrorDialog(context, e);
      }
    }
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      ref.read(shellIndexProvider.notifier).state = 2;
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderAsync =
        ref.watch(orderTrackingProvider(widget.orderId));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: AmaraColors.textPrimary, size: 22),
          onPressed: _goBack,
        ),
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context).orderTrackingTitle,
          style: AmaraTextStyles.labelLarge.copyWith(
            fontWeight: FontWeight.w700,
            color: AmaraColors.textPrimary,
          ),
        ),
      ),
      body: orderAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AmaraColors.primary),
        ),
        error: (e, _) => _ErrorView(
          onRetry: () =>
              ref.invalidate(orderTrackingProvider(widget.orderId)),
        ),
        data: (order) => _TrackingBody(
          order: order,
          orderId: widget.orderId,
          onBack: _goBack,
          clientName: ref.watch(currentUserProvider)?.name ?? 'Client',
          clientPhone: ref.watch(currentUserProvider)?.phone ?? '',
          onConfirmPickup: () => _confirmPickup(),
          onCancelOrder: () => _cancelOrder(),
        ),
      ),
    );
  }
}

// ─── Corps de l'ecran ─────────────────────────────────────────────────────────

class _TrackingBody extends StatelessWidget {
  final Map<String, dynamic> order;
  final String orderId;
  final VoidCallback onBack;
  final String clientName;
  final String clientPhone;
  final VoidCallback? onConfirmPickup;
  final VoidCallback? onCancelOrder;

  const _TrackingBody({
    required this.order,
    required this.orderId,
    required this.onBack,
    required this.clientName,
    this.clientPhone = '',
    this.onConfirmPickup,
    this.onCancelOrder,
  });

  String get _status => order['status'] as String? ?? 'pending';
  bool get _isPickup =>
      order['orderType'] == 'pickup' ||
      (order['orderType'] == null && order['deliveryAddress'] == 'À emporter');
  int get _step => _isPickup
      ? (_pickupStatusSteps[_status] ?? 0)
      : (_statusSteps[_status] ?? 0);
  bool get _isCancelled => _status == 'cancelled';
  bool get _isDelivered => _status == 'delivered';

  @override
  Widget build(BuildContext context) {
    // ── Vue post-livraison style Uber Eats ──────────────────
    if (_isDelivered) {
      return _DeliveredView(order: order, orderId: orderId);
    }

    // ── Vue commande annulée ──────────────────────────────
    if (_isCancelled) {
      return _CancelledView(order: order, orderId: orderId);
    }

    final restaurantName =
        order['restaurantName'] as String? ?? 'Restaurant';
    final estimatedTime = order['estimatedDeliveryTime'] as int? ?? 30;
    final items = (order['items'] as List?) ?? [];
    final address = order['deliveryAddress'] as String? ?? '';

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Informations client / pickup ─────────────────────
          Text(
            _isPickup ? AppLocalizations.of(context).orderTrackingPickupOrder : AppLocalizations.of(context).orderTrackingClientInfo,
            style: AmaraTextStyles.labelLarge.copyWith(
              fontWeight: FontWeight.w800,
              color: AmaraColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          if (_isPickup)
            Row(
              children: [
                Expanded(
                  child: _InfoChip(
                    label: AppLocalizations.of(context).orderTrackingRestaurant,
                    value: restaurantName,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _InfoChip(
                    label: AppLocalizations.of(context).orderTrackingRestaurantAddress,
                    value: address.isNotEmpty ? address : AppLocalizations.of(context).orderTrackingSeeOnMap,
                  ),
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: _InfoChip(
                    label: AppLocalizations.of(context).orderTrackingRecipientName,
                    value: clientName,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _InfoChip(
                    label: AppLocalizations.of(context).orderTrackingPhone,
                    value: clientPhone.isNotEmpty ? clientPhone : AppLocalizations.of(context).orderTrackingPhoneNotProvided,
                  ),
                ),
              ],
            ),

          const SizedBox(height: 28),

          // ── Progress bar horizontale ─────────────────────────
          _HorizontalProgress(
            currentStep: _step,
            isCancelled: _isCancelled,
            isPickup: _isPickup,
          ),

          const SizedBox(height: 28),

          // ── Carte tracking livreur (livraison uniquement) ──────────
          if (!_isPickup &&
              (_status == 'delivering' || _status == 'picked_up') &&
              order['livreurId'] != null)
            _DriverTrackingMap(
              livreurId: order['livreurId'] as String,
              deliveryLat: (order['deliveryLatitude'] as num?)?.toDouble(),
              deliveryLng: (order['deliveryLongitude'] as num?)?.toDouble(),
              restaurantLat: (order['restaurantLatitude'] as num?)?.toDouble(),
              restaurantLng: (order['restaurantLongitude'] as num?)?.toDouble(),
              deliveryAddress: address,
            ),

          if (!_isPickup &&
              (_status == 'delivering' || _status == 'picked_up') &&
              order['livreurId'] != null)
            const SizedBox(height: 20),

          // ── Illustration chef + message ─────────────────────
          _ChefSection(
            status: _status,
            restaurantName: restaurantName,
            estimatedTime: estimatedTime,
            isCancelled: _isCancelled,
            isDelivered: _isDelivered,
            isPickup: _isPickup,
          ),

          // ── Bouton "Annuler la commande" (pending/confirmed) ──────
          if ((_status == 'pending' || _status == 'confirmed') && onCancelOrder != null) ...[
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: onCancelOrder,
                icon: const Icon(Icons.close_rounded, size: 20),
                label: Text(
                  AppLocalizations.of(context).ordersCancelButton,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AmaraColors.error,
                  side: const BorderSide(color: AmaraColors.error, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],

          // ── Bouton "J'ai récupéré" (pickup + ready) ──────────
          if (_isPickup && _status == 'ready' && onConfirmPickup != null) ...[
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: onConfirmPickup,
                icon: const Icon(Icons.check_circle_rounded, size: 22),
                label: Text(
                  AppLocalizations.of(context).orderTrackingConfirmPickup,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AmaraColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],

          const SizedBox(height: 28),

          // ── Detail de la commande ───────────────────────────
          Text(
            AppLocalizations.of(context).orderTrackingOrderDetail,
            style: AmaraTextStyles.labelLarge.copyWith(
              fontWeight: FontWeight.w800,
              color: AmaraColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          ...items.map((item) {
            final d = item as Map<String, dynamic>;
            return _OrderItemCard(item: d);
          }),

          const SizedBox(height: 16),

          // ── Resume ─────────────────────────────────────────
          _OrderSummary(order: order, orderId: orderId),
        ],
      ),
    );
  }
}

// ─── Vue post-livraison style Uber Eats ─────────────────────────────────────

class _DeliveredView extends StatefulWidget {
  final Map<String, dynamic> order;
  final String orderId;

  const _DeliveredView({required this.order, required this.orderId});

  @override
  State<_DeliveredView> createState() => _DeliveredViewState();
}

class _DeliveredViewState extends State<_DeliveredView> {
  bool _alreadyReviewed = false;
  bool _checkingReview = true;
  int _selectedRating = 0;

  @override
  void initState() {
    super.initState();
    _checkReview();
  }

  Future<void> _checkReview() async {
    try {
      final has = await ConvexClient.instance.hasReview(widget.orderId);
      if (mounted) {
        setState(() {
          _alreadyReviewed = has;
          _checkingReview = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _checkingReview = false);
    }
  }

  void _openReview({int initialRating = 0}) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ReviewScreen(
          orderId: widget.orderId,
          restaurantName:
              widget.order['restaurantName'] as String? ?? 'Restaurant',
          hasDriver: widget.order['livreurId'] != null,
          initialRating: initialRating,
        ),
      ),
    );
    if (result == true && mounted) {
      setState(() => _alreadyReviewed = true);
    }
  }

  String _formatDeliveryDate(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final createdAt = widget.order['createdAt'] as num?;
    if (createdAt == null) return '';
    final date = DateTime.fromMillisecondsSinceEpoch(createdAt.toInt());
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final orderDay = DateTime(date.year, date.month, date.day);
    final diff = today.difference(orderDay).inDays;

    final time =
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    if (diff == 0) return l10n.orderTrackingTodayAt(time);
    if (diff == 1) return l10n.orderTrackingYesterdayAt(time);
    return l10n.orderTrackingDateAt('${date.day}/${date.month}', time);
  }

  @override
  Widget build(BuildContext context) {
    final restaurantName =
        widget.order['restaurantName'] as String? ?? 'Restaurant';
    final restaurantImageUrl =
        widget.order['restaurantImageUrl'] as String?;
    final items = (widget.order['items'] as List?) ?? [];
    final total = (widget.order['totalAmount'] as num?)?.toDouble() ??
        (widget.order['total'] as num?)?.toDouble() ??
        0;
    final livreurName = widget.order['livreurName'] as String?;
    final hasDriver = widget.order['livreurId'] != null;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Photo restaurant en bandeau ────────────────────────
          SizedBox(
            height: 200,
            width: double.infinity,
            child: restaurantImageUrl != null
                ? Image.network(
                    restaurantImageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        _buildRestaurantFallback(restaurantName),
                  )
                : _buildRestaurantFallback(restaurantName),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Nom restaurant + statut ────────────────────────
                Text(
                  restaurantName,
                  style: AmaraTextStyles.h2.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AmaraColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AmaraColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context).orderTrackingOrderCompleted(_formatDeliveryDate(context)),
                      style: AmaraTextStyles.bodySmall.copyWith(
                        color: AmaraColors.textSecondary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // ── Section notation ────────────────────────────────
                if (!_checkingReview) ...[
                  if (_alreadyReviewed) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AmaraColors.success.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color:
                              AmaraColors.success.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle_rounded,
                              color: AmaraColors.success, size: 20),
                          const SizedBox(width: 10),
                          Text(
                            AppLocalizations.of(context).orderTrackingReviewSubmitted,
                            style: AmaraTextStyles.labelMedium.copyWith(
                              color: AmaraColors.success,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    Text(
                      AppLocalizations.of(context).orderTrackingRateEstablishment,
                      style: AmaraTextStyles.labelLarge.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AmaraColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      AppLocalizations.of(context).orderTrackingDidYouLike(restaurantName),
                      style: AmaraTextStyles.bodySmall.copyWith(
                        color: AmaraColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    // ── 5 étoiles interactives ──────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: List.generate(5, (i) {
                        final starIndex = i + 1;
                        return GestureDetector(
                          onTap: () {
                            setState(() => _selectedRating = starIndex);
                            _openReview(initialRating: starIndex);
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Icon(
                              starIndex <= _selectedRating
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              size: 40,
                              color: starIndex <= _selectedRating
                                  ? const Color(0xFFFFC107)
                                  : AmaraColors.divider,
                            ),
                          ),
                        );
                      }),
                    ),
                  ],

                  const SizedBox(height: 28),
                ],

                // ── Votre commande ──────────────────────────────────
                Text(
                  AppLocalizations.of(context).orderTrackingYourOrder,
                  style: AmaraTextStyles.labelLarge.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AmaraColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 14),

                // Liste d'items simple (quantité + nom)
                ...items.map((item) {
                  final d = item as Map<String, dynamic>;
                  final name = d['name'] as String? ?? '';
                  final qty = (d['quantity'] as num?)?.toInt() ?? 1;
                  final unitPrice =
                      (d['unitPrice'] as num?)?.toDouble() ?? 0;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: AmaraColors.bg,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AmaraColors.divider),
                          ),
                          child: Center(
                            child: Text(
                              '$qty',
                              style: AmaraTextStyles.labelSmall.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AmaraColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            name,
                            style: AmaraTextStyles.bodyMedium.copyWith(
                              color: AmaraColors.textPrimary,
                            ),
                          ),
                        ),
                        Text(
                          '${(unitPrice * qty).toStringAsFixed(0)} F',
                          style: AmaraTextStyles.bodySmall.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AmaraColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                // Total
                const Divider(color: AmaraColors.divider),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context).orderTrackingTotal,
                      style: AmaraTextStyles.labelLarge.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AmaraColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${total.toStringAsFixed(0)} F CFA',
                      style: AmaraTextStyles.labelLarge.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AmaraColors.primary,
                      ),
                    ),
                  ],
                ),

                // ── Bouton Reçu ────────────────────────────────────
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ReceiptScreen(
                            orderId: widget.orderId,
                            order: widget.order,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.receipt_long_rounded, size: 20),
                    label: Text(
                      AppLocalizations.of(context).orderTrackingViewReceipt,
                      style: AmaraTextStyles.labelMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AmaraColors.primary,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AmaraColors.primary,
                      side: const BorderSide(
                          color: AmaraColors.primary, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),

                // ── Info livreur ────────────────────────────────────
                if (hasDriver) ...[
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AmaraColors.bg,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AmaraColors.primary
                                .withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.delivery_dining_rounded,
                            color: AmaraColors.primary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(context).orderTrackingYourDelivery,
                                style: AmaraTextStyles.caption.copyWith(
                                  color: AmaraColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                AppLocalizations.of(context).orderTrackingByDriver(livreurName ?? AppLocalizations.of(context).orderTrackingDefaultDriver),
                                style:
                                    AmaraTextStyles.labelMedium.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AmaraColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // ── Bouton recommander ──────────────────────────────
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () {
                      final restaurantId =
                          widget.order['restaurantId'] as String?;
                      if (restaurantId != null) {
                        context.push('/restaurant/$restaurantId');
                      } else {
                        context.go(AppRoutes.home);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AmaraColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      AppLocalizations.of(context).orderTrackingReorder,
                      style: AmaraTextStyles.labelLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestaurantFallback(String name) {
    return Container(
      color: AmaraColors.primary.withValues(alpha: 0.08),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.restaurant_rounded,
              size: 48,
              color: AmaraColors.primary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: AmaraTextStyles.h3.copyWith(
                color: AmaraColors.primary.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Vue commande annulée (même layout que delivered) ─────────────────────────

class _CancelledView extends StatelessWidget {
  final Map<String, dynamic> order;
  final String orderId;

  const _CancelledView({required this.order, required this.orderId});

  String _formatDate(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final createdAt = order['createdAt'] as num?;
    if (createdAt == null) return '';
    final date = DateTime.fromMillisecondsSinceEpoch(createdAt.toInt());
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final orderDay = DateTime(date.year, date.month, date.day);
    final diff = today.difference(orderDay).inDays;

    final time =
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    if (diff == 0) return l10n.orderTrackingTodayAt(time);
    if (diff == 1) return l10n.orderTrackingYesterdayAt(time);
    return l10n.orderTrackingDateAt('${date.day}/${date.month}', time);
  }

  @override
  Widget build(BuildContext context) {
    final restaurantName =
        order['restaurantName'] as String? ?? 'Restaurant';
    final restaurantImageUrl =
        order['restaurantImageUrl'] as String?;
    final items = (order['items'] as List?) ?? [];
    final total = (order['totalAmount'] as num?)?.toDouble() ??
        (order['total'] as num?)?.toDouble() ??
        0;
    final address = order['deliveryAddress'] as String? ?? '';
    final paymentMethod = order['paymentMethod'] as String? ?? '';
    final isPickup = order['orderType'] == 'pickup' ||
        address == 'À emporter';

    final l10n = AppLocalizations.of(context);
    String paymentLabel;
    switch (paymentMethod) {
      case 'mobile_money':
        paymentLabel = l10n.orderTrackingPaymentMobileMoney;
        break;
      case 'card':
        paymentLabel = l10n.orderTrackingPaymentCard;
        break;
      case 'cash':
        paymentLabel = l10n.orderTrackingPaymentCash;
        break;
      default:
        paymentLabel = paymentMethod.isNotEmpty ? paymentMethod : l10n.orderTrackingPaymentNotSpecified;
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Photo restaurant en bandeau ────────────────────────
          SizedBox(
            height: 200,
            width: double.infinity,
            child: restaurantImageUrl != null
                ? Image.network(
                    restaurantImageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        _buildFallback(restaurantName),
                  )
                : _buildFallback(restaurantName),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Nom restaurant + statut ────────────────────────
                Text(
                  restaurantName,
                  style: AmaraTextStyles.h2.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AmaraColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AmaraColors.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.orderTrackingOrderCancelled(_formatDate(context)),
                      style: AmaraTextStyles.bodySmall.copyWith(
                        color: AmaraColors.textSecondary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // ── Badge annulée ─────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AmaraColors.error.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AmaraColors.error.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.cancel_rounded,
                          color: AmaraColors.error, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        l10n.orderTrackingCancelledBadge,
                        style: AmaraTextStyles.labelMedium.copyWith(
                          color: AmaraColors.error,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // ── Votre commande ──────────────────────────────────
                Text(
                  l10n.orderTrackingYourOrder,
                  style: AmaraTextStyles.labelLarge.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AmaraColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 14),

                // Liste d'items
                ...items.map((item) {
                  final d = item as Map<String, dynamic>;
                  final name = d['name'] as String? ?? '';
                  final qty = (d['quantity'] as num?)?.toInt() ?? 1;
                  final unitPrice =
                      (d['unitPrice'] as num?)?.toDouble() ?? 0;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: AmaraColors.bg,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AmaraColors.divider),
                          ),
                          child: Center(
                            child: Text(
                              '$qty',
                              style: AmaraTextStyles.labelSmall.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AmaraColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            name,
                            style: AmaraTextStyles.bodyMedium.copyWith(
                              color: AmaraColors.textPrimary,
                            ),
                          ),
                        ),
                        Text(
                          '${(unitPrice * qty).toStringAsFixed(0)} F',
                          style: AmaraTextStyles.bodySmall.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AmaraColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                // Infos commande
                const Divider(color: AmaraColors.divider),
                const SizedBox(height: 8),

                if (!isPickup && address.isNotEmpty) ...[
                  _cancelledInfoRow(
                    Icons.location_on_outlined,
                    l10n.orderTrackingDelivery,
                    address,
                  ),
                  const SizedBox(height: 8),
                ],
                _cancelledInfoRow(
                  Icons.payment_rounded,
                  l10n.orderTrackingPayment,
                  paymentLabel,
                ),

                const SizedBox(height: 12),
                const Divider(color: AmaraColors.divider),
                const SizedBox(height: 8),

                // Total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.orderTrackingTotal,
                      style: AmaraTextStyles.labelLarge.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AmaraColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${total.toStringAsFixed(0)} F CFA',
                      style: AmaraTextStyles.labelLarge.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AmaraColors.primary,
                      ),
                    ),
                  ],
                ),

                // ── Bouton recommander ──────────────────────────────
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () {
                      final restaurantId =
                          order['restaurantId'] as String?;
                      if (restaurantId != null) {
                        context.push('/restaurant/$restaurantId');
                      } else {
                        context.go(AppRoutes.home);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AmaraColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      l10n.orderTrackingReorder,
                      style: AmaraTextStyles.labelLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallback(String name) {
    return Container(
      color: AmaraColors.error.withValues(alpha: 0.06),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.restaurant_rounded,
              size: 48,
              color: AmaraColors.error.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: AmaraTextStyles.h3.copyWith(
                color: AmaraColors.error.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cancelledInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(icon, size: 18, color: AmaraColors.muted),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: AmaraTextStyles.bodySmall.copyWith(
              color: AmaraColors.textSecondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: AmaraTextStyles.bodyMedium.copyWith(
                color: AmaraColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Info chip (nom, adresse) ────────────────────────────────────────────────

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  const _InfoChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AmaraColors.bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AmaraColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AmaraTextStyles.caption.copyWith(
              color: AmaraColors.textSecondary,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AmaraTextStyles.labelMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: AmaraColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ─── Progress bar horizontale ────────────────────────────────────────────────

class _HorizontalProgress extends StatelessWidget {
  final int currentStep;
  final bool isCancelled;
  final bool isPickup;

  const _HorizontalProgress({
    required this.currentStep,
    required this.isCancelled,
    this.isPickup = false,
  });

  static List<(IconData, String)> _deliverySteps(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return [
      (Icons.receipt_long_rounded, l10n.orderTrackingStepPending),
      (Icons.restaurant_rounded, l10n.orderTrackingStepPreparation),
      (Icons.inventory_2_rounded, l10n.orderTrackingStepReady),
      (Icons.delivery_dining_rounded, l10n.orderTrackingStepDelivering),
      (Icons.home_rounded, l10n.orderTrackingStepDelivered),
    ];
  }

  static List<(IconData, String)> _pickupSteps(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return [
      (Icons.receipt_long_rounded, l10n.orderTrackingStepOrdered),
      (Icons.restaurant_rounded, l10n.orderTrackingStepPreparation),
      (Icons.inventory_2_rounded, l10n.orderTrackingStepReady),
      (Icons.shopping_bag_rounded, l10n.orderTrackingStepPickedUp),
    ];
  }

  List<(IconData, String)> _steps(BuildContext context) => isPickup ? _pickupSteps(context) : _deliverySteps(context);

  @override
  Widget build(BuildContext context) {
    final steps = _steps(context);
    return Row(
      children: List.generate(steps.length * 2 - 1, (index) {
        if (index.isOdd) {
          // Connector line
          final stepBefore = index ~/ 2;
          final isDone = !isCancelled && stepBefore < currentStep;
          return Expanded(
            child: Container(
              height: 3,
              decoration: BoxDecoration(
                color: isDone
                    ? AmaraColors.primary
                    : AmaraColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }

        final stepIndex = index ~/ 2;
        final (icon, label) = steps[stepIndex];
        final isDone = !isCancelled && stepIndex < currentStep;
        final isActive = !isCancelled && stepIndex == currentStep;

        return Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDone || isActive
                    ? AmaraColors.primary
                    : AmaraColors.bg,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDone || isActive
                      ? AmaraColors.primary
                      : AmaraColors.divider,
                  width: 2,
                ),
              ),
              child: Icon(
                isDone ? Icons.check_rounded : icon,
                color: isDone || isActive
                    ? Colors.white
                    : AmaraColors.muted,
                size: 18,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight:
                    isActive ? FontWeight.w700 : FontWeight.w500,
                color: isDone || isActive
                    ? AmaraColors.textPrimary
                    : AmaraColors.muted,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        );
      }),
    );
  }
}

// ─── Section chef illustration ───────────────────────────────────────────────

class _ChefSection extends StatelessWidget {
  final String status;
  final String restaurantName;
  final int estimatedTime;
  final bool isCancelled;
  final bool isDelivered;
  final bool isPickup;

  const _ChefSection({
    required this.status,
    required this.restaurantName,
    required this.estimatedTime,
    required this.isCancelled,
    required this.isDelivered,
    this.isPickup = false,
  });

  String get _emoji {
    if (isCancelled) return '❌';
    if (isPickup) {
      return switch (status) {
        'pending' || 'confirmed' => '⏳',
        'preparing' => '👨‍🍳',
        'ready' => '🥡',
        'picked_up' || 'delivered' => '🎉',
        _ => '📋',
      };
    }
    return switch (status) {
      'pending' || 'confirmed' => '⏳',
      'preparing' => '👨‍🍳',
      'ready' => '📦',
      'delivering' => '🛵',
      'delivered' => '🎉',
      _ => '📋',
    };
  }

  String _title(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (isCancelled) return l10n.orderTrackingChefCancelled;
    if (isPickup) {
      return switch (status) {
        'pending' || 'confirmed' => l10n.orderTrackingChefPending,
        'preparing' => l10n.orderTrackingChefPreparing,
        'ready' => l10n.orderTrackingChefReady,
        'picked_up' || 'delivered' => l10n.orderTrackingChefPickedUp,
        _ => l10n.orderTrackingChefProcessing,
      };
    }
    return switch (status) {
      'pending' || 'confirmed' => l10n.orderTrackingChefPending,
      'preparing' => l10n.orderTrackingChefPreparing,
      'ready' => l10n.orderTrackingChefReady,
      'delivering' => l10n.orderTrackingChefDelivering,
      'delivered' => l10n.orderTrackingChefDelivered,
      _ => l10n.orderTrackingChefProcessing,
    };
  }

  String _subtitle(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (isCancelled) return l10n.orderTrackingSubCancelled;
    if (isPickup) {
      return switch (status) {
        'pending' || 'confirmed' =>
          l10n.orderTrackingSubPendingPickup(restaurantName),
        'preparing' =>
          l10n.orderTrackingSubPreparingPickup(estimatedTime),
        'ready' =>
          l10n.orderTrackingSubReadyPickup(restaurantName),
        'picked_up' || 'delivered' =>
          l10n.orderTrackingSubPickedUp,
        _ => '',
      };
    }
    return switch (status) {
      'pending' || 'confirmed' =>
        l10n.orderTrackingSubPendingDelivery(restaurantName),
      'preparing' =>
        l10n.orderTrackingSubPreparingDelivery(estimatedTime),
      'ready' =>
        l10n.orderTrackingSubReadyDelivery,
      'delivering' =>
        l10n.orderTrackingSubDeliveringDelivery,
      'delivered' =>
        l10n.orderTrackingSubDeliveredDelivery,
      _ => '',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: BoxDecoration(
        color: AmaraColors.bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(_emoji, style: const TextStyle(fontSize: 72)),
          const SizedBox(height: 16),
          Text(
            _title(context),
            style: AmaraTextStyles.h3.copyWith(
              fontWeight: FontWeight.w800,
              color: AmaraColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _subtitle(context),
            style: AmaraTextStyles.bodySmall.copyWith(
              color: AmaraColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─── Carte article commande ──────────────────────────────────────────────────

class _OrderItemCard extends StatelessWidget {
  final Map<String, dynamic> item;
  const _OrderItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final name = item['name'] as String? ?? '';
    final quantity = (item['quantity'] as num?)?.toInt() ?? 1;
    final unitPrice = (item['unitPrice'] as num?)?.toDouble() ?? 0;
    final imageUrl = item['imageUrl'] as String?;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AmaraColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 56,
              height: 56,
              child: imageUrl != null
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AmaraColors.bgAlt,
                        child: const Icon(Icons.restaurant_rounded,
                            color: AmaraColors.muted, size: 24),
                      ),
                    )
                  : Container(
                      color: AmaraColors.bgAlt,
                      child: const Icon(Icons.restaurant_rounded,
                          color: AmaraColors.muted, size: 24),
                    ),
            ),
          ),
          const SizedBox(width: 14),
          // Name + details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AmaraTextStyles.labelMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AmaraColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Price + qty
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${unitPrice.toStringAsFixed(0)} F',
                style: AmaraTextStyles.labelMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AmaraColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${quantity}Pcs',
                style: AmaraTextStyles.caption.copyWith(
                  color: AmaraColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Resume commande ─────────────────────────────────────────────────────────

class _OrderSummary extends StatelessWidget {
  final Map<String, dynamic> order;
  final String orderId;

  const _OrderSummary({required this.order, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final total = (order['totalAmount'] as num?)?.toDouble() ??
        (order['total'] as num?)?.toDouble() ??
        0;
    final address = order['deliveryAddress'] as String? ?? '';
    final payment = order['paymentMethod'] as String? ?? '';
    final isPickup = order['orderType'] == 'pickup' ||
        (order['orderType'] == null && address == 'À emporter');
    final shortId = orderId.length > 10
        ? '#${orderId.substring(0, 8).toUpperCase()}...'
        : '#$orderId';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AmaraColors.bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _SummaryRow(
            icon: Icons.tag_rounded,
            label: AppLocalizations.of(context).orderTrackingSummaryOrder,
            value: shortId,
          ),
          const SizedBox(height: 10),
          _SummaryRow(
            icon: isPickup ? Icons.store_rounded : Icons.location_on_rounded,
            label: isPickup ? AppLocalizations.of(context).orderTrackingSummaryMode : AppLocalizations.of(context).orderTrackingDelivery,
            value: isPickup ? AppLocalizations.of(context).orderTrackingSummaryTakeaway : (address.isNotEmpty ? address : AppLocalizations.of(context).orderTrackingSummaryNotProvided),
          ),
          if (payment.isNotEmpty) ...[
            const SizedBox(height: 10),
            _SummaryRow(
              icon: Icons.payment_rounded,
              label: AppLocalizations.of(context).orderTrackingPayment,
              value: _paymentLabel(context, payment),
            ),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(color: AmaraColors.divider),
          ),
          _SummaryRow(
            icon: Icons.receipt_rounded,
            label: AppLocalizations.of(context).orderTrackingTotal,
            value: '${total.toStringAsFixed(0)} F CFA',
            isBold: true,
            color: AmaraColors.primary,
          ),
        ],
      ),
    );
  }

  String _paymentLabel(BuildContext context, String method) {
    final l10n = AppLocalizations.of(context);
    return switch (method) {
      'mobile_money' => l10n.orderTrackingPaymentMobileMoney,
      'card' => l10n.orderTrackingPaymentCard,
      'cash' => l10n.orderTrackingPaymentCash,
      _ => method,
    };
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isBold;
  final Color? color;

  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isBold = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color ?? AmaraColors.muted),
        const SizedBox(width: 8),
        Text(
          label,
          style: AmaraTextStyles.caption.copyWith(
            color: AmaraColors.textSecondary,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: AmaraTextStyles.caption.copyWith(
            color: color ?? AmaraColors.textPrimary,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ─── Bouton noter la commande ────────────────────────────────────────────────

class _ReviewButton extends StatefulWidget {
  final String orderId;
  final String restaurantName;
  final bool hasDriver;

  const _ReviewButton({
    required this.orderId,
    required this.restaurantName,
    required this.hasDriver,
  });

  @override
  State<_ReviewButton> createState() => _ReviewButtonState();
}

class _ReviewButtonState extends State<_ReviewButton> {
  bool _alreadyReviewed = false;
  bool _checking = true;

  @override
  void initState() {
    super.initState();
    _checkReview();
  }

  Future<void> _checkReview() async {
    try {
      final has = await ConvexClient.instance.hasReview(widget.orderId);
      if (mounted) setState(() { _alreadyReviewed = has; _checking = false; });
    } catch (_) {
      if (mounted) setState(() => _checking = false);
    }
  }

  void _openReview() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ReviewScreen(
          orderId: widget.orderId,
          restaurantName: widget.restaurantName,
          hasDriver: widget.hasDriver,
        ),
      ),
    );
    if (result == true && mounted) {
      setState(() => _alreadyReviewed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) return const SizedBox.shrink();

    if (_alreadyReviewed) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        decoration: BoxDecoration(
          color: AmaraColors.success.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AmaraColors.success.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_rounded,
                color: AmaraColors.success, size: 18),
            const SizedBox(width: 8),
            Text(
              AppLocalizations.of(context).orderTrackingReviewSubmitted,
              style: AmaraTextStyles.labelMedium.copyWith(
                color: AmaraColors.success,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: _openReview,
        icon: const Icon(Icons.star_rounded, size: 20),
        label: Text(
          AppLocalizations.of(context).orderTrackingRateOrder,
          style: AmaraTextStyles.labelMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AmaraColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}

// ─── Carte tracking livreur ──────────────────────────────────────────────────

class _DriverTrackingMap extends StatefulWidget {
  final String livreurId;
  final double? deliveryLat;
  final double? deliveryLng;
  final double? restaurantLat;
  final double? restaurantLng;
  final String deliveryAddress;

  const _DriverTrackingMap({
    required this.livreurId,
    this.deliveryLat,
    this.deliveryLng,
    this.restaurantLat,
    this.restaurantLng,
    this.deliveryAddress = '',
  });

  @override
  State<_DriverTrackingMap> createState() => _DriverTrackingMapState();
}

class _DriverTrackingMapState extends State<_DriverTrackingMap> {
  Timer? _locationTimer;
  LatLng? _driverPosition;
  bool _loading = true;
  final MapController _mapController = MapController();

  // Abidjan par défaut
  static const _defaultCenter = LatLng(5.3484, -4.0083);

  @override
  void initState() {
    super.initState();
    _fetchDriverLocation();
    _locationTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _fetchDriverLocation();
    });
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _fetchDriverLocation() async {
    try {
      final data =
          await ConvexClient.instance.getDriverLocation(widget.livreurId);
      if (data != null && mounted) {
        final lat = (data['latitude'] as num?)?.toDouble();
        final lng = (data['longitude'] as num?)?.toDouble();
        if (lat != null && lng != null) {
          setState(() {
            _driverPosition = LatLng(lat, lng);
            _loading = false;
          });
        }
      } else if (mounted) {
        setState(() => _loading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  LatLng get _center {
    if (_driverPosition != null) return _driverPosition!;
    if (widget.deliveryLat != null && widget.deliveryLng != null) {
      return LatLng(widget.deliveryLat!, widget.deliveryLng!);
    }
    return _defaultCenter;
  }

  LatLngBounds? get _bounds {
    final points = <LatLng>[];
    if (_driverPosition != null) points.add(_driverPosition!);
    if (widget.deliveryLat != null && widget.deliveryLng != null) {
      points.add(LatLng(widget.deliveryLat!, widget.deliveryLng!));
    }
    if (widget.restaurantLat != null && widget.restaurantLng != null) {
      points.add(LatLng(widget.restaurantLat!, widget.restaurantLng!));
    }
    if (points.length < 2) return null;
    return LatLngBounds.fromPoints(points);
  }

  void _openInMaps() async {
    final lat = widget.deliveryLat ?? _defaultCenter.latitude;
    final lng = widget.deliveryLng ?? _defaultCenter.longitude;
    final uri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final markers = <Marker>[];

    // Marqueur livreur
    if (_driverPosition != null) {
      markers.add(
        Marker(
          point: _driverPosition!,
          width: 44,
          height: 44,
          child: Container(
            decoration: BoxDecoration(
              color: AmaraColors.primary,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: AmaraColors.primary.withValues(alpha: 0.4),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.delivery_dining_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
        ),
      );
    }

    // Marqueur adresse livraison
    if (widget.deliveryLat != null && widget.deliveryLng != null) {
      markers.add(
        Marker(
          point: LatLng(widget.deliveryLat!, widget.deliveryLng!),
          width: 40,
          height: 40,
          child: Container(
            decoration: BoxDecoration(
              color: AmaraColors.success,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2.5),
            ),
            child: const Icon(Icons.home_rounded,
                color: Colors.white, size: 20),
          ),
        ),
      );
    }

    // Marqueur restaurant
    if (widget.restaurantLat != null && widget.restaurantLng != null) {
      markers.add(
        Marker(
          point: LatLng(widget.restaurantLat!, widget.restaurantLng!),
          width: 40,
          height: 40,
          child: Container(
            decoration: BoxDecoration(
              color: AmaraColors.warning,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2.5),
            ),
            child: const Icon(Icons.restaurant_rounded,
                color: Colors.white, size: 20),
          ),
        ),
      );
    }

    final bounds = _bounds;

    return Container(
      height: 240,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AmaraColors.divider),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _center,
              initialZoom: 14,
              initialCameraFit: bounds != null
                  ? CameraFit.bounds(
                      bounds: bounds,
                      padding: const EdgeInsets.all(40),
                    )
                  : null,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.amara.client',
              ),
              MarkerLayer(markers: markers),
            ],
          ),

          // Loading overlay
          if (_loading)
            Container(
              color: Colors.white.withValues(alpha: 0.7),
              child: const Center(
                child: CircularProgressIndicator(
                  color: AmaraColors.primary,
                  strokeWidth: 2.5,
                ),
              ),
            ),

          // Légende en bas
          Positioned(
            bottom: 8,
            left: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: AmaraColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    AppLocalizations.of(context).orderTrackingMapDriver,
                    style: AmaraTextStyles.caption.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: AmaraColors.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    AppLocalizations.of(context).orderTrackingMapYou,
                    style: AmaraTextStyles.caption.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                    ),
                  ),
                  const Spacer(),
                  if (_driverPosition != null)
                    GestureDetector(
                      onTap: _openInMaps,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AmaraColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          AppLocalizations.of(context).orderTrackingMapFollow,
                          style: AmaraTextStyles.caption.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Erreur ────────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('📡', style: TextStyle(fontSize: 52)),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context).orderTrackingLoadError,
                style: AmaraTextStyles.h3
                    .copyWith(fontWeight: FontWeight.w800),
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 13),
                decoration: BoxDecoration(
                  color: AmaraColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(AppLocalizations.of(context).orderTrackingRetry,
                    style: AmaraTextStyles.labelSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
