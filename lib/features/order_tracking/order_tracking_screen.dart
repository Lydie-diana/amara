import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/core/constants/app_colors.dart';
import '../../app/core/constants/app_text_styles.dart';
import '../../app/router/app_routes.dart';
import '../../app/services/convex_client.dart';
import '../shell/main_shell.dart';

// ─── Provider de suivi commande (polling toutes les 10s) ─────────────────────

final _orderTrackingProvider =
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

// Statut → step index (0-based)
const _statusSteps = {
  'pending': 0,
  'confirmed': 0,
  'preparing': 1,
  'ready': 2,
  'delivering': 3,
  'delivered': 4,
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
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      ref.invalidate(_orderTrackingProvider(widget.orderId));
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
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
        ref.watch(_orderTrackingProvider(widget.orderId));

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
          'Suivi de commande',
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
              ref.invalidate(_orderTrackingProvider(widget.orderId)),
        ),
        data: (order) => _TrackingBody(
          order: order,
          orderId: widget.orderId,
          onBack: _goBack,
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

  const _TrackingBody({
    required this.order,
    required this.orderId,
    required this.onBack,
  });

  String get _status => order['status'] as String? ?? 'pending';
  int get _step => _statusSteps[_status] ?? 0;
  bool get _isCancelled => _status == 'cancelled';
  bool get _isDelivered => _status == 'delivered';

  @override
  Widget build(BuildContext context) {
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
          // ── Informations client ─────────────────────────────
          Text(
            'Informations client',
            style: AmaraTextStyles.labelLarge.copyWith(
              fontWeight: FontWeight.w800,
              color: AmaraColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _InfoChip(
                  label: 'Nom du destinataire',
                  value: 'Client Amara',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InfoChip(
                  label: 'Adresse',
                  value: address.isNotEmpty ? address : 'Cocody, Abidjan',
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // ── Progress bar horizontale ─────────────────────────
          _HorizontalProgress(
            currentStep: _step,
            isCancelled: _isCancelled,
          ),

          const SizedBox(height: 28),

          // ── Illustration chef + message ─────────────────────
          _ChefSection(
            status: _status,
            restaurantName: restaurantName,
            estimatedTime: estimatedTime,
            isCancelled: _isCancelled,
            isDelivered: _isDelivered,
          ),

          const SizedBox(height: 28),

          // ── Detail de la commande ───────────────────────────
          Text(
            'Detail de la commande',
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

  const _HorizontalProgress({
    required this.currentStep,
    required this.isCancelled,
  });

  static const _steps = [
    (Icons.receipt_long_rounded, 'En attente'),
    (Icons.restaurant_rounded, 'Preparation'),
    (Icons.inventory_2_rounded, 'Prete'),
    (Icons.delivery_dining_rounded, 'En livraison'),
    (Icons.home_rounded, 'Livree'),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(_steps.length * 2 - 1, (index) {
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
        final (icon, label) = _steps[stepIndex];
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

  const _ChefSection({
    required this.status,
    required this.restaurantName,
    required this.estimatedTime,
    required this.isCancelled,
    required this.isDelivered,
  });

  String get _emoji {
    if (isCancelled) return '❌';
    return switch (status) {
      'pending' || 'confirmed' => '⏳',
      'preparing' => '👨‍🍳',
      'ready' => '📦',
      'delivering' => '🛵',
      'delivered' => '🎉',
      _ => '📋',
    };
  }

  String get _title {
    if (isCancelled) return 'Commande annulee';
    return switch (status) {
      'pending' || 'confirmed' => 'En attente de confirmation',
      'preparing' => 'Le chef prepare votre commande',
      'ready' => 'Votre commande est prete !',
      'delivering' => 'Votre livreur est en route',
      'delivered' => 'Commande livree !',
      _ => 'En cours de traitement',
    };
  }

  String get _subtitle {
    if (isCancelled) return 'Votre commande a ete annulee.';
    return switch (status) {
      'pending' || 'confirmed' =>
        '$restaurantName va bientot confirmer votre commande.',
      'preparing' =>
        'Votre repas sera pret dans ~$estimatedTime min.\nBon appetit bientot !',
      'ready' =>
        'Un livreur va bientot recuperer votre commande.',
      'delivering' =>
        'Votre commande est en chemin. Restez disponible !',
      'delivered' =>
        'Votre commande a ete livree. Bon appetit ! 🎉',
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
            _title,
            style: AmaraTextStyles.h3.copyWith(
              fontWeight: FontWeight.w800,
              color: AmaraColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _subtitle,
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
            label: 'Commande',
            value: shortId,
          ),
          if (address.isNotEmpty) ...[
            const SizedBox(height: 10),
            _SummaryRow(
              icon: Icons.location_on_rounded,
              label: 'Livraison',
              value: address,
            ),
          ],
          if (payment.isNotEmpty) ...[
            const SizedBox(height: 10),
            _SummaryRow(
              icon: Icons.payment_rounded,
              label: 'Paiement',
              value: _paymentLabel(payment),
            ),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(color: AmaraColors.divider),
          ),
          _SummaryRow(
            icon: Icons.receipt_rounded,
            label: 'Total',
            value: '${total.toStringAsFixed(0)} F CFA',
            isBold: true,
            color: AmaraColors.primary,
          ),
        ],
      ),
    );
  }

  String _paymentLabel(String method) {
    return switch (method) {
      'mobile_money' => 'Mobile Money',
      'card' => 'Carte bancaire',
      'cash' => 'Especes',
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
            Text('Impossible de charger\nla commande',
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
                child: Text('Reessayer',
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
