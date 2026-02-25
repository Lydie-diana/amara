import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/core/constants/app_colors.dart';
import '../../app/core/constants/app_text_styles.dart';
import '../../app/providers/auth_provider.dart';
import '../../app/services/convex_client.dart';

// ─── Provider commandes ───────────────────────────────────────────────────────

final myOrdersProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final auth = ref.watch(authProvider);
  if (!auth.isAuthenticated) return [];
  try {
    final client = ref.read(convexClientProvider);
    final orders = await client.getMyOrders();
    return orders
        .map((o) => Map<String, dynamic>.from(o as Map))
        .toList();
  } catch (_) {
    return [];
  }
});

// ─── Écran commandes ──────────────────────────────────────────────────────────

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final ordersAsync = ref.watch(myOrdersProvider);

    return Scaffold(
      backgroundColor: AmaraColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
              child: Text('Mes commandes', style: AmaraTextStyles.h2),
            ).animate().fadeIn(duration: 300.ms),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Text('Retrouvez l\'historique de vos commandes',
                style: AmaraTextStyles.bodySmall.copyWith(
                  color: AmaraColors.textSecondary,
                ),
              ),
            ).animate().fadeIn(delay: 100.ms, duration: 300.ms),

            // Contenu
            Expanded(
              child: !auth.isAuthenticated
                  ? _NotLoggedIn()
                  : ordersAsync.when(
                      loading: () => const Center(
                        child: CircularProgressIndicator(
                            color: AmaraColors.primary),
                      ),
                      error: (e, _) => _ErrorState(error: e.toString()),
                      data: (orders) => orders.isEmpty
                          ? _EmptyOrders()
                          : _OrdersList(orders: orders),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Non connecté ─────────────────────────────────────────────────────────────

class _NotLoggedIn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🔐', style: TextStyle(fontSize: 56))
                .animate()
                .scale(duration: 400.ms, curve: Curves.easeOutBack),
            const SizedBox(height: 20),
            Text('Connexion requise', style: AmaraTextStyles.h3)
                .animate()
                .fadeIn(delay: 100.ms),
            const SizedBox(height: 8),
            Text(
              'Connectez-vous pour voir vos commandes',
              style: AmaraTextStyles.bodySmall
                  .copyWith(color: AmaraColors.textSecondary),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 150.ms),
          ],
        ),
      ),
    );
  }
}

// ─── Aucune commande ──────────────────────────────────────────────────────────

class _EmptyOrders extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('📦', style: TextStyle(fontSize: 56))
                .animate()
                .scale(duration: 400.ms, curve: Curves.easeOutBack),
            const SizedBox(height: 20),
            Text('Aucune commande', style: AmaraTextStyles.h3)
                .animate()
                .fadeIn(delay: 100.ms),
            const SizedBox(height: 8),
            Text(
              'Vos futures commandes apparaîtront ici',
              style: AmaraTextStyles.bodySmall
                  .copyWith(color: AmaraColors.textSecondary),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 150.ms),
          ],
        ),
      ),
    );
  }
}

// ─── Erreur ───────────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  final String error;
  const _ErrorState({required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 48, color: AmaraColors.muted),
            const SizedBox(height: 16),
            Text('Erreur de connexion', style: AmaraTextStyles.h3),
            const SizedBox(height: 8),
            Text(error,
              style: AmaraTextStyles.bodySmall
                  .copyWith(color: AmaraColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Liste des commandes ──────────────────────────────────────────────────────

class _OrdersList extends StatelessWidget {
  final List<Map<String, dynamic>> orders;
  const _OrdersList({required this.orders});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      physics: const BouncingScrollPhysics(),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        return _OrderTile(order: orders[index])
            .animate()
            .fadeIn(delay: Duration(milliseconds: index * 60), duration: 300.ms)
            .slideY(begin: 0.1, end: 0);
      },
    );
  }
}

// ─── Tuile commande ───────────────────────────────────────────────────────────

class _OrderTile extends StatelessWidget {
  final Map<String, dynamic> order;
  const _OrderTile({required this.order});

  String get _statusLabel {
    return switch (order['status'] as String? ?? '') {
      'pending' => 'En attente',
      'confirmed' => 'Confirmée',
      'preparing' => 'En préparation',
      'ready' => 'Prête',
      'picked_up' => 'Récupérée',
      'delivering' => 'En livraison',
      'delivered' => 'Livrée',
      'cancelled' => 'Annulée',
      _ => 'Inconnue',
    };
  }

  Color get _statusColor {
    return switch (order['status'] as String? ?? '') {
      'delivered' => AmaraColors.success,
      'cancelled' => AmaraColors.error,
      'delivering' || 'picked_up' => AmaraColors.primary,
      _ => AmaraColors.warning,
    };
  }

  String get _formattedTotal {
    final total = (order['total'] as num?)?.toDouble() ?? 0;
    return '${total.toStringAsFixed(0)} F';
  }

  String get _formattedDate {
    final ts = order['createdAt'] as int?;
    if (ts == null) return '';
    final dt = DateTime.fromMillisecondsSinceEpoch(ts);
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) return 'Aujourd\'hui';
    if (diff.inDays == 1) return 'Hier';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  int get _itemCount {
    final items = order['items'] as List?;
    if (items == null) return 0;
    return items.fold<int>(
        0, (sum, item) => sum + ((item['quantity'] as num?)?.toInt() ?? 1));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AmaraColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AmaraColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Icône commande
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: AmaraColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.receipt_long_rounded,
                    color: AmaraColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Commande #${(order['_id'] as String?)?.substring(0, 8) ?? '...'}',
                      style: AmaraTextStyles.labelMedium
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$_itemCount article${_itemCount > 1 ? 's' : ''} · $_formattedDate',
                      style: AmaraTextStyles.caption.copyWith(
                        color: AmaraColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _statusColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  _statusLabel,
                  style: AmaraTextStyles.caption.copyWith(
                    color: _statusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Container(height: 1, color: AmaraColors.divider),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Méthode de paiement
              Row(
                children: [
                  const Icon(Icons.payment_rounded,
                      size: 14, color: AmaraColors.muted),
                  const SizedBox(width: 5),
                  Text(
                    _paymentLabel(order['paymentMethod'] as String? ?? ''),
                    style: AmaraTextStyles.caption.copyWith(
                      color: AmaraColors.textSecondary,
                    ),
                  ),
                ],
              ),
              // Total
              Text(
                _formattedTotal,
                style: AmaraTextStyles.labelMedium.copyWith(
                  color: AmaraColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _paymentLabel(String method) {
    return switch (method) {
      'mobile_money' => 'Mobile Money',
      'card' => 'Carte bancaire',
      'cash' => 'Espèces',
      _ => method,
    };
  }
}
