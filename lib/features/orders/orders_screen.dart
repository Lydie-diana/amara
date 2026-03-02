import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/core/constants/app_colors.dart';
import '../../app/core/constants/app_text_styles.dart';
import '../../app/core/l10n/app_localizations.dart';
import '../../app/core/widgets/error_dialog.dart';
import '../../app/providers/auth_provider.dart';
import '../../app/providers/restaurant_provider.dart';
import '../../app/services/convex_client.dart';
import '../menu_item/menu_item_detail_screen.dart';

// ─── Provider commandes (polling 5s pour temps réel) ──────────────────────────

final myOrdersProvider =
    StreamProvider<List<Map<String, dynamic>>>((ref) async* {
  final auth = ref.watch(authProvider);
  if (!auth.isAuthenticated) {
    yield [];
    return;
  }

  final client = ref.read(convexClientProvider);

  // Émission immédiate
  try {
    final orders = await client.getMyOrders();
    yield orders.map((o) => Map<String, dynamic>.from(o as Map)).toList();
  } catch (_) {
    yield [];
  }

  // Puis polling toutes les 5 secondes
  await for (final _ in Stream.periodic(const Duration(seconds: 5))) {
    try {
      final orders = await client.getMyOrders();
      yield orders.map((o) => Map<String, dynamic>.from(o as Map)).toList();
    } catch (_) {
      // Garder les données précédentes en cas d'erreur réseau
    }
  }
});

// ─── Provider : nombre de commandes actives (en cours) ───────────────────────

final activeOrdersCountProvider = Provider<int>((ref) {
  final ordersAsync = ref.watch(myOrdersProvider);
  return ordersAsync.when(
    data: (orders) => orders.where((o) {
      final status = o['status'] as String? ?? '';
      return status != 'delivered' && status != 'cancelled';
    }).length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});

// ─── Ecran commandes ──────────────────────────────────────────────────────────

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final ordersAsync = ref.watch(myOrdersProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: !auth.isAuthenticated
            ? const _NotLoggedIn()
            : ordersAsync.when(
                loading: () => const Center(
                  child:
                      CircularProgressIndicator(color: AmaraColors.primary),
                ),
                error: (e, _) => _ErrorState(error: e.toString()),
                data: (orders) => orders.isEmpty
                    ? const _EmptyOrders()
                    : _OrdersBody(orders: orders),
              ),
      ),
    );
  }
}

// ─── Corps principal avec tabs ───────────────────────────────────────────────

class _OrdersBody extends ConsumerStatefulWidget {
  final List<Map<String, dynamic>> orders;
  const _OrdersBody({required this.orders});

  @override
  ConsumerState<_OrdersBody> createState() => _OrdersBodyState();
}

class _OrdersBodyState extends ConsumerState<_OrdersBody>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Map<String, List<Map<String, dynamic>>> _groupByRestaurant(
      List<Map<String, dynamic>> orders) {
    final grouped = <String, List<Map<String, dynamic>>>{};
    for (final order in orders) {
      final rid = order['restaurantId'] as String? ?? 'unknown';
      grouped.putIfAbsent(rid, () => []);
      grouped[rid]!.add(order);
    }
    return grouped;
  }

  List<Map<String, dynamic>> _allUniqueItems(
      List<Map<String, dynamic>> orders) {
    final seen = <String>{};
    final items = <Map<String, dynamic>>[];
    for (final order in orders) {
      final orderItems = order['items'] as List? ?? [];
      for (final item in orderItems) {
        final d = Map<String, dynamic>.from(item as Map);
        final name = d['name'] as String? ?? '';
        if (name.isNotEmpty && seen.add(name)) {
          items.add({...d, 'restaurantId': order['restaurantId']});
        }
      }
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _groupByRestaurant(widget.orders);

    return Column(
      children: [
        // Header — meme taille que Explorer
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Row(
            children: [
              Text(
                AppLocalizations.of(context).ordersTitle,
                style: AmaraTextStyles.h2.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Tabs avec couleur primary
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: AmaraColors.bgAlt,
            borderRadius: BorderRadius.circular(14),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(11),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            labelColor: AmaraColors.textPrimary,
            unselectedLabelColor: AmaraColors.textSecondary,
            labelStyle: AmaraTextStyles.labelSmall.copyWith(
              fontWeight: FontWeight.w700,
            ),
            unselectedLabelStyle: AmaraTextStyles.labelSmall.copyWith(
              fontWeight: FontWeight.w500,
            ),
            padding: const EdgeInsets.all(4),
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.shopping_bag_outlined, size: 15),
                    const SizedBox(width: 5),
                    Text(AppLocalizations.of(context).ordersTabPastItems),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.receipt_long_outlined, size: 15),
                    const SizedBox(width: 5),
                    Text(AppLocalizations.of(context).ordersTabOrders),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _PastItemsTab(
                grouped: grouped,
                orders: widget.orders,
                allUniqueItems: _allUniqueItems,
              ),
              _PastOrdersTab(orders: widget.orders),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Tab 1 : Anciens articles ────────────────────────────────────────────────

class _PastItemsTab extends ConsumerWidget {
  final Map<String, List<Map<String, dynamic>>> grouped;
  final List<Map<String, dynamic>> orders;
  final List<Map<String, dynamic>> Function(List<Map<String, dynamic>>)
      allUniqueItems;

  const _PastItemsTab({
    required this.grouped,
    required this.orders,
    required this.allUniqueItems,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = grouped.entries.toList();

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
      physics: const BouncingScrollPhysics(),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final restaurantId = entries[index].key;
        final restaurantOrders = entries[index].value;
        final items = allUniqueItems(restaurantOrders);

        return _RestaurantSection(
          restaurantId: restaurantId,
          orders: restaurantOrders,
          items: items,
        );
      },
    );
  }
}

// ─── Section restaurant ──────────────────────────────────────────────────────

class _RestaurantSection extends ConsumerWidget {
  final String restaurantId;
  final List<Map<String, dynamic>> orders;
  final List<Map<String, dynamic>> items;

  const _RestaurantSection({
    required this.restaurantId,
    required this.orders,
    required this.items,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restaurantAsync = ref.watch(restaurantDetailProvider(restaurantId));
    final restaurant = restaurantAsync.valueOrNull;
    final restaurantName = restaurant?.name ?? 'Restaurant';
    final restaurantImage = restaurant?.imageUrl;
    final deliveryFee = restaurant?.deliveryFee ?? '';
    final deliveryTime = restaurant?.deliveryTime ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Restaurant header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: Row(
            children: [
              // Restaurant image
              ClipOval(
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: restaurantImage != null
                      ? Image.network(
                          restaurantImage,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: AmaraColors.primary.withValues(alpha: 0.1),
                            child: const Icon(Icons.restaurant_rounded,
                                color: AmaraColors.primary, size: 22),
                          ),
                        )
                      : Container(
                          color: AmaraColors.primary.withValues(alpha: 0.1),
                          child: const Icon(Icons.restaurant_rounded,
                              color: AmaraColors.primary, size: 22),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              // Name + info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      restaurantName,
                      style: AmaraTextStyles.labelLarge.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AmaraColors.textPrimary,
                      ),
                    ),
                    if (deliveryFee.isNotEmpty || deliveryTime.isNotEmpty)
                      Text(
                        AppLocalizations.of(context).ordersDeliveryFee(deliveryFee, deliveryTime),
                        style: AmaraTextStyles.caption.copyWith(
                          color: AmaraColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              // Arrow button
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.push('/restaurant/$restaurantId');
                },
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AmaraColors.bg,
                    shape: BoxShape.circle,
                    border: Border.all(color: AmaraColors.divider),
                  ),
                  child: const Icon(Icons.arrow_forward_rounded,
                      color: AmaraColors.textPrimary, size: 18),
                ),
              ),
            ],
          ),
        ),

        // Horizontal items scroll
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: items.length,
            itemBuilder: (context, index) {
              return _ItemCard(
                item: items[index],
                restaurantId: restaurantId,
              );
            },
          ),
        ),

        // Divider
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Divider(color: AmaraColors.divider, height: 24),
        ),
      ],
    );
  }
}

// ─── Carte article (horizontal scroll) ───────────────────────────────────────

class _ItemCard extends ConsumerWidget {
  final Map<String, dynamic> item;
  final String restaurantId;

  const _ItemCard({required this.item, required this.restaurantId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = item['name'] as String? ?? '';
    final unitPrice = (item['unitPrice'] as num?)?.toDouble() ?? 0;
    final orderImageUrl = item['imageUrl'] as String?;
    final menuItemId = item['menuItemId'] as String?;

    final menuAsync = ref.watch(restaurantMenuProvider(restaurantId));

    // Resolve image: use order imageUrl first, fallback to menu item imageUrl
    String? resolvedImageUrl = orderImageUrl;
    final categories = menuAsync.valueOrNull;
    final allItems = categories?.expand((c) => c.items).toList();
    if ((resolvedImageUrl == null || resolvedImageUrl.isEmpty) &&
        allItems != null &&
        menuItemId != null) {
      final found = allItems.where((m) => m.id == menuItemId);
      if (found.isNotEmpty) {
        resolvedImageUrl = found.first.imageUrl;
      }
    }

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        if (allItems != null && menuItemId != null) {
          final found = allItems.where((m) => m.id == menuItemId);
          if (found.isNotEmpty) {
            final restaurant =
                ref.read(restaurantDetailProvider(restaurantId)).valueOrNull;
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => MenuItemDetailScreen(
                item: found.first,
                restaurantId: restaurantId,
                restaurantName: restaurant?.name ?? 'Restaurant',
                restaurantImageUrl: restaurant?.imageUrl,
                companions: allItems
                    .where((m) => m.id != menuItemId)
                    .take(4)
                    .toList(),
              ),
            ));
            return;
          }
        }
        context.push('/restaurant/$restaurantId');
      },
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image avec bouton +
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: SizedBox(
                    width: 140,
                    height: 120,
                    child: resolvedImageUrl != null && resolvedImageUrl.isNotEmpty
                        ? Image.network(
                            resolvedImageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _placeholderImage(),
                          )
                        : _placeholderImage(),
                  ),
                ),
                // Bouton +
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.add_rounded,
                        color: AmaraColors.textPrimary, size: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Name
            Text(
              name,
              style: AmaraTextStyles.labelSmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AmaraColors.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            // Price
            Text(
              '${unitPrice.toStringAsFixed(0)} F',
              style: AmaraTextStyles.caption.copyWith(
                color: AmaraColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderImage() {
    return Container(
      color: AmaraColors.primary.withValues(alpha: 0.06),
      child: const Center(
        child: Icon(Icons.restaurant_menu_rounded,
            color: AmaraColors.primary, size: 32),
      ),
    );
  }
}

// ─── Tab 2 : Anciennes commandes ──────────────────────────────────────────────

class _PastOrdersTab extends StatelessWidget {
  final List<Map<String, dynamic>> orders;
  const _PastOrdersTab({required this.orders});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      physics: const BouncingScrollPhysics(),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        return _OrderTile(order: orders[index]);
      },
    );
  }
}

// ─── Tuile commande ──────────────────────────────────────────────────────────

class _OrderTile extends ConsumerWidget {
  final Map<String, dynamic> order;
  const _OrderTile({required this.order});

  String get _status => order['status'] as String? ?? '';

  String _statusLabel(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return switch (_status) {
      'pending' => l10n.ordersStatusPending,
      'confirmed' => l10n.ordersStatusConfirmed,
      'preparing' => l10n.ordersStatusPreparing,
      'ready' => l10n.ordersStatusReady,
      'picked_up' => l10n.ordersStatusPickedUp,
      'delivering' => l10n.ordersStatusDelivering,
      'delivered' => l10n.ordersStatusDelivered,
      'cancelled' => l10n.ordersStatusCancelled,
      _ => l10n.ordersStatusUnknown,
    };
  }

  Color get _statusColor {
    return switch (_status) {
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

  String _formattedDate(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ts = order['createdAt'] as num?;
    if (ts == null) return '';
    final dt = DateTime.fromMillisecondsSinceEpoch(ts.toInt());
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) return l10n.ordersToday;
    if (diff.inDays == 1) return l10n.ordersYesterday;
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  int get _itemCount {
    final items = order['items'] as List?;
    if (items == null) return 0;
    return items.fold<int>(
        0, (sum, item) => sum + ((item['quantity'] as num?)?.toInt() ?? 1));
  }

  bool get _canCancel => _status == 'pending';

  void _showCancelDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(AppLocalizations.of(context).ordersCancelTitle,
            style: AmaraTextStyles.h3.copyWith(fontWeight: FontWeight.w700)),
        content: Text(
          AppLocalizations.of(context).ordersCancelMessage,
          style: AmaraTextStyles.bodySmall
              .copyWith(color: AmaraColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.of(context).ordersCancelNo,
                style: TextStyle(
                    color: AmaraColors.textSecondary,
                    fontWeight: FontWeight.w600)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final orderId = order['_id'] as String? ?? '';
              if (orderId.isEmpty) return;
              try {
                final client = ref.read(convexClientProvider);
                await client.cancelOrder(orderId,
                    reason: AppLocalizations.of(context).ordersCancelledByClient);
                ref.invalidate(myOrdersProvider);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLocalizations.of(context).ordersCancelledSuccess),
                      backgroundColor: AmaraColors.success,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  showErrorDialog(context, e);
                }
              }
            },
            child: Text(AppLocalizations.of(context).ordersCancelYes,
                style: TextStyle(
                    color: AmaraColors.error, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  String get _allItemNames {
    final items = order['items'] as List?;
    if (items == null || items.isEmpty) return '';
    return items
        .map((i) => (i as Map<String, dynamic>)['name'] as String? ?? '')
        .where((n) => n.isNotEmpty)
        .join(', ');
  }

  String get _firstItemImage {
    final items = order['items'] as List?;
    if (items == null || items.isEmpty) return '';
    final first = items.first as Map<String, dynamic>;
    return first['imageUrl'] as String? ?? '';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderId = order['_id'] as String? ?? '';
    final restaurantId = order['restaurantId'] as String? ?? '';
    final restaurantAsync =
        ref.watch(restaurantDetailProvider(restaurantId));
    final restaurant = restaurantAsync.valueOrNull;
    final restaurantName = restaurant?.name ?? 'Restaurant';
    final imageUrl = _firstItemImage.isNotEmpty
        ? _firstItemImage
        : restaurant?.imageUrl;

    return GestureDetector(
      onTap: () {
        if (orderId.isNotEmpty) {
          HapticFeedback.lightImpact();
          context.push('/order/$orderId/tracking');
        }
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image ronde
                ClipOval(
                  child: SizedBox(
                    width: 70,
                    height: 70,
                    child: imageUrl != null
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _placeholderImage(),
                          )
                        : _placeholderImage(),
                  ),
                ),
                const SizedBox(width: 14),
                // Infos
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Restaurant name
                      Text(
                        restaurantName,
                        style: AmaraTextStyles.labelMedium.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AmaraColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      // Date + prix + nb articles
                      Text(
                        '${_formattedDate(context)} · $_formattedTotal · ${AppLocalizations.of(context).ordersItemCount(_itemCount)}',
                        style: AmaraTextStyles.caption.copyWith(
                          color: AmaraColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      // Noms des plats
                      if (_allItemNames.isNotEmpty)
                        Text(
                          _allItemNames,
                          style: AmaraTextStyles.caption.copyWith(
                            color: AmaraColors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                // Bouton action à droite
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: _canCancel
                      ? GestureDetector(
                          onTap: () => _showCancelDialog(context, ref),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: AmaraColors.error.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              AppLocalizations.of(context).ordersCancelButton,
                              style: AmaraTextStyles.caption.copyWith(
                                color: AmaraColors.error,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        )
                      : Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AmaraColors.bgAlt,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _status == 'delivered' ? AppLocalizations.of(context).ordersReorderButton : _statusLabel(context),
                            style: AmaraTextStyles.caption.copyWith(
                              color: AmaraColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AmaraColors.divider),
        ],
      ),
    );
  }

  Widget _placeholderImage() {
    return Container(
      color: AmaraColors.primary.withValues(alpha: 0.06),
      child: const Center(
        child: Icon(Icons.restaurant_rounded,
            color: AmaraColors.primary, size: 28),
      ),
    );
  }
}

// ─── Non connecte ─────────────────────────────────────────────────────────────

class _NotLoggedIn extends StatelessWidget {
  const _NotLoggedIn();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AmaraColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lock_outline_rounded,
                  size: 36, color: AmaraColors.primary),
            ),
            const SizedBox(height: 20),
            Text(AppLocalizations.of(context).ordersLoginRequired,
                style: AmaraTextStyles.h3
                    .copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context).ordersLoginMessage,
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

// ─── Aucune commande ──────────────────────────────────────────────────────────

class _EmptyOrders extends StatelessWidget {
  const _EmptyOrders();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AmaraColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.shopping_bag_outlined,
                  size: 36, color: AmaraColors.primary),
            ),
            const SizedBox(height: 20),
            Text(AppLocalizations.of(context).ordersEmptyTitle,
                style: AmaraTextStyles.h3
                    .copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context).ordersEmptyMessage,
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
            const Icon(Icons.wifi_off_rounded,
                size: 48, color: AmaraColors.muted),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context).ordersConnectionError, style: AmaraTextStyles.h3),
            const SizedBox(height: 8),
            Text(error,
                style: AmaraTextStyles.bodySmall
                    .copyWith(color: AmaraColors.textSecondary),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
