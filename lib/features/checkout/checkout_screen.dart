import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../app/core/constants/app_colors.dart';
import '../../app/core/constants/app_text_styles.dart';
import '../../app/core/widgets/error_dialog.dart';
import '../../app/providers/address_suggestions_provider.dart';
import '../../app/models/cart_model.dart';
import '../../app/providers/address_provider.dart';
import '../../app/providers/cart_provider.dart';
import '../../app/providers/auth_provider.dart';
import '../../app/models/restaurant_model.dart';
import '../../app/providers/restaurant_provider.dart';
import '../../app/services/convex_client.dart';
import '../orders/orders_screen.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  final String? restaurantId;
  const CheckoutScreen({super.key, this.restaurantId});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  String _selectedPayment = 'Mobile Money';
  String _selectedService = 'Livraison';
  bool _orderExpanded = true;
  bool _paymentExpanded = false;
  bool _isLoading = false;

  // Map
  final MapController _mapController = MapController();
  LatLng _deliveryLatLng = const LatLng(5.3600, -3.9800); // Cocody, Abidjan

  // Voucher
  final _voucherController = TextEditingController();
  String _voucherCode = '';
  bool _voucherApplied = false;
  double _discount = 0;

  // Infos client
  late final TextEditingController _addressController;
  final _streetController = TextEditingController();
  final _instructionsController = TextEditingController();
  late final TextEditingController _phoneController;

  final List<Map<String, dynamic>> _paymentMethods = [
    {'name': 'Mobile Money', 'value': 'mobile_money', 'icon': Icons.phone_android_rounded, 'key': 'Mobile Money'},
    {'name': 'Wave', 'value': 'mobile_money', 'icon': Icons.waves_rounded, 'key': 'Mobile Money'},
    {'name': 'Cash', 'value': 'cash', 'icon': Icons.payments_rounded, 'key': 'Cash'},
    {'name': 'Carte bancaire', 'value': 'card', 'icon': Icons.credit_card_rounded, 'key': 'Carte'},
  ];

  @override
  void initState() {
    super.initState();
    final defaultAddr = ref.read(defaultAddressProvider);
    final user = ref.read(authProvider).user;
    _addressController = TextEditingController(
      text: defaultAddr?.address ?? '',
    );
    _phoneController = TextEditingController(
      text: user?.phone ?? '',
    );
    if (defaultAddr?.lat != null && defaultAddr?.lng != null) {
      _deliveryLatLng = LatLng(defaultAddr!.lat!, defaultAddr.lng!);
    }
  }

  @override
  void dispose() {
    _voucherController.dispose();
    _addressController.dispose();
    _streetController.dispose();
    _instructionsController.dispose();
    _phoneController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  CartState _filteredCart(CartState fullCart) {
    if (widget.restaurantId == null) return fullCart;
    final filtered = fullCart.items
        .where((e) => e.restaurantId == widget.restaurantId)
        .toList();
    return CartState(items: filtered);
  }

  void _applyVoucher() {
    final code = _voucherController.text.trim().toUpperCase();
    final codes = {
      'MAMA1': 0.0,
      'MIDI15': 0.15,
      'WE20': 0.20,
      'LAGOS10': 0.10,
      'AMARA': 0.10,
    };
    if (codes.containsKey(code)) {
      setState(() {
        _voucherCode = code;
        _discount = codes[code]!;
        _voucherApplied = true;
      });
      HapticFeedback.mediumImpact();
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Code invalide',
              style: AmaraTextStyles.bodySmall
                  .copyWith(color: Colors.white)),
          backgroundColor: AmaraColors.error,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _removeVoucher() {
    setState(() {
      _voucherCode = '';
      _discount = 0;
      _voucherApplied = false;
      _voucherController.clear();
    });
  }

  Future<void> _placeOrder(CartState cart) async {
    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

    try {
      final client = ref.read(convexClientProvider);
      final authState = ref.read(authProvider);

      final items = cart.items.map((ci) => {
        'menuItemId': ci.item.id,
        'name': ci.item.name,
        'quantity': ci.quantity,
        'unitPrice': ci.item.price,
        if (ci.item.imageUrl != null) 'imageUrl': ci.item.imageUrl,
      }).toList();

      final targetRestaurantId = widget.restaurantId ?? cart.restaurantId;

      // Agréger les notes des articles du panier
      final itemNotes = cart.items
          .where((ci) => ci.note != null && ci.note!.trim().isNotEmpty)
          .map((ci) => '${ci.item.name}: ${ci.note!.trim()}')
          .toList();
      final clientNote = itemNotes.isNotEmpty ? itemNotes.join(' | ') : null;

      String orderId;
      if (authState.isAuthenticated && targetRestaurantId != null) {
        final isDelivery = _selectedService == 'Livraison';
        orderId = await client.createOrder(
          restaurantId: targetRestaurantId,
          items: items,
          orderType: isDelivery ? 'delivery' : 'pickup',
          deliveryAddress: isDelivery
              ? [
                  _addressController.text.trim(),
                  if (_streetController.text.trim().isNotEmpty)
                    _streetController.text.trim(),
                  if (_instructionsController.text.trim().isNotEmpty)
                    _instructionsController.text.trim(),
                ].join(' — ')
              : null,
          paymentMethod: _paymentMethods
              .firstWhere((m) => m['name'] == _selectedPayment)['value'] as String,
          deliveryLatitude: isDelivery ? _deliveryLatLng.latitude : null,
          deliveryLongitude: isDelivery ? _deliveryLatLng.longitude : null,
          clientNote: clientNote,
        );
      } else {
        await Future.delayed(const Duration(seconds: 1));
        orderId = 'ORD${DateTime.now().millisecondsSinceEpoch % 1000000}';
      }

      if (mounted) {
        setState(() => _isLoading = false);
        if (widget.restaurantId != null) {
          ref
              .read(cartProvider.notifier)
              .removeRestaurant(widget.restaurantId!);
        } else {
          ref.read(cartProvider.notifier).clear();
        }
        // Rafraîchir la liste des commandes
        ref.invalidate(myOrdersProvider);

        context.go(
          '/order/$orderId/confirmation',
          extra: {
            'restaurantName': cart.restaurantName ?? 'Restaurant',
            'items': cart.items
                .map((ci) => {
                      'name': ci.item.name,
                      'imageUrl': ci.item.imageUrl,
                      'imageEmoji': ci.item.imageEmoji,
                      'quantity': ci.quantity,
                      'unitPrice': ci.unitPrice,
                    })
                .toList(),
          },
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        showErrorDialog(context, e);
      }
    }
  }

  void _updateMapPosition(double lat, double lng) {
    setState(() => _deliveryLatLng = LatLng(lat, lng));
    _mapController.move(LatLng(lat, lng), 15);
  }

  // ── Bottom sheet modifier adresse (avec autocomplétion) ────────────────────
  void _showEditAddressSheet() {
    final suggestions = ref.read(addressSuggestionsProvider).valueOrNull ?? [];
    final tmpAddress = TextEditingController(text: _addressController.text);
    final tmpStreet = TextEditingController(text: _streetController.text);
    final tmpInstructions = TextEditingController(text: _instructionsController.text);
    final tmpPhone = TextEditingController(text: _phoneController.text);
    List<Map<String, dynamic>> filtered = [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          void onSearch(String query) {
            if (query.length < 2) {
              setSheetState(() => filtered = []);
              return;
            }
            final q = query.toLowerCase();
            setSheetState(() {
              filtered = suggestions
                  .where((s) =>
                      (s['address'] as String).toLowerCase().contains(q))
                  .toList();
            });
          }

          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.75,
              ),
              padding: EdgeInsets.fromLTRB(
                  20, 20, 20, MediaQuery.of(context).padding.bottom + 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: AmaraColors.divider,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Text('Modifier les informations',
                        style: AmaraTextStyles.labelLarge
                            .copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 16),

                    // Adresse avec autocomplétion
                    Text('Adresse de livraison',
                        style: AmaraTextStyles.caption
                            .copyWith(color: AmaraColors.textSecondary)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: tmpAddress,
                      onChanged: onSearch,
                      style: AmaraTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AmaraColors.textPrimary),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search_rounded,
                            color: AmaraColors.primary, size: 20),
                        hintText: 'Rechercher une adresse...',
                        hintStyle: AmaraTextStyles.bodyMedium
                            .copyWith(color: AmaraColors.muted),
                        filled: true,
                        fillColor: AmaraColors.bgAlt,
                        contentPadding: const EdgeInsets.all(14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: AmaraColors.primary, width: 1.5),
                        ),
                      ),
                    ),

                    // Suggestions
                    if (filtered.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        decoration: BoxDecoration(
                          color: AmaraColors.bgAlt,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: filtered.map((s) {
                            return GestureDetector(
                              onTap: () {
                                tmpAddress.text = s['address'] as String;
                                setSheetState(() => filtered = []);
                              },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 12),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                        color: AmaraColors.divider
                                            .withValues(alpha: 0.5)),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.location_on_outlined,
                                        color: AmaraColors.primary,
                                        size: 18),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        s['address'] as String,
                                        style: AmaraTextStyles.bodySmall
                                            .copyWith(
                                                fontWeight: FontWeight.w600,
                                                color: AmaraColors
                                                    .textPrimary),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                    const SizedBox(height: 14),

                    // Rue / Quartier
                    Text('Rue / Quartier',
                        style: AmaraTextStyles.caption
                            .copyWith(color: AmaraColors.textSecondary)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: tmpStreet,
                      style: AmaraTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AmaraColors.textPrimary),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.signpost_rounded,
                            color: AmaraColors.primary, size: 20),
                        hintText: 'Ex: Rue 123, à côté du marché...',
                        hintStyle: AmaraTextStyles.bodyMedium
                            .copyWith(color: AmaraColors.muted),
                        filled: true,
                        fillColor: AmaraColors.bgAlt,
                        contentPadding: const EdgeInsets.all(14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: AmaraColors.primary, width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Instructions pour le livreur
                    Text('Instructions pour le livreur',
                        style: AmaraTextStyles.caption
                            .copyWith(color: AmaraColors.textSecondary)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: tmpInstructions,
                      maxLines: 3,
                      style: AmaraTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AmaraColors.textPrimary),
                      decoration: InputDecoration(
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(bottom: 40),
                          child: Icon(Icons.info_outline_rounded,
                              color: AmaraColors.primary, size: 20),
                        ),
                        hintText: 'Ex: Bâtiment B, 2ème étage, porte 5...',
                        hintStyle: AmaraTextStyles.bodyMedium
                            .copyWith(color: AmaraColors.muted),
                        filled: true,
                        fillColor: AmaraColors.bgAlt,
                        contentPadding: const EdgeInsets.all(14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: AmaraColors.primary, width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Téléphone
                    Text('Numéro de téléphone',
                        style: AmaraTextStyles.caption
                            .copyWith(color: AmaraColors.textSecondary)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: tmpPhone,
                      keyboardType: TextInputType.phone,
                      style: AmaraTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AmaraColors.textPrimary),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.phone_outlined,
                            color: AmaraColors.primary, size: 20),
                        filled: true,
                        fillColor: AmaraColors.bgAlt,
                        contentPadding: const EdgeInsets.all(14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: AmaraColors.primary, width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () {
                        final addr = tmpAddress.text.trim();
                        setState(() {
                          _addressController.text = addr;
                          _streetController.text = tmpStreet.text.trim();
                          _instructionsController.text = tmpInstructions.text.trim();
                          _phoneController.text = tmpPhone.text;
                        });
                        // Update map if matching a known address
                        final match = suggestions.where(
                            (s) => s['address'] == addr);
                        if (match.isNotEmpty) {
                          _updateMapPosition(
                            match.first['lat'] as double,
                            match.first['lng'] as double,
                          );
                        }
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: AmaraColors.primary,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Text('Enregistrer',
                              style: AmaraTextStyles.labelMedium.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fullCart = ref.watch(cartProvider);
    final cart = _filteredCart(fullCart);
    final subtotal = cart.subtotal;
    final serviceFee = (subtotal * 0.05).roundToDouble();
    final deliveryFee =
        _selectedService == 'Livraison' ? cart.deliveryFee : 0.0;
    final discountAmount = subtotal * _discount;
    final total = subtotal + serviceFee + deliveryFee - discountAmount;
    final bottom = MediaQuery.of(context).padding.bottom;

    final group = cart.groups.isNotEmpty ? cart.groups.first : null;

    // Charger les modes supportés par le restaurant
    final targetRestaurantId = widget.restaurantId ?? cart.restaurantId;
    final restaurantAsync = targetRestaurantId != null
        ? ref.watch(restaurantDetailProvider(targetRestaurantId))
        : null;
    final restaurant = restaurantAsync?.valueOrNull;
    final supportedServices = restaurant?.serviceModes ?? ServiceMode.values.toList();
    final supportedPayments = restaurant?.paymentMethods ?? ['Mobile Money', 'Cash'];
    final deliveryEnabled = supportedServices.contains(ServiceMode.delivery);
    final takeawayEnabled = supportedServices.contains(ServiceMode.takeaway);

    // Auto-sélectionner le premier mode disponible si le courant est grisé
    if (_selectedService == 'Livraison' && !deliveryEnabled && takeawayEnabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _selectedService = 'À emporter');
      });
    } else if (_selectedService == 'À emporter' && !takeawayEnabled && deliveryEnabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _selectedService = 'Livraison');
      });
    }

    // Auto-sélectionner le premier mode de paiement disponible si le courant est grisé
    final currentPaymentKey = _paymentMethods
        .firstWhere((m) => m['name'] == _selectedPayment, orElse: () => _paymentMethods.first)['key'] as String;
    if (!supportedPayments.contains(currentPaymentKey)) {
      final firstAvailable = _paymentMethods
          .where((m) => supportedPayments.contains(m['key'] as String))
          .firstOrNull;
      if (firstAvailable != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _selectedPayment = firstAvailable['name'] as String);
        });
      }
    }

    return Scaffold(
      backgroundColor: AmaraColors.bg,
      body: Column(
        children: [
          // ── Header rouge ─────────────────────────────────────────────
          _CheckoutHeader(),

          // ── Contenu scrollable ───────────────────────────────────────
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              physics: const BouncingScrollPhysics(),
              children: [
                // ── Mode de service ────────────────────────────────────
                _buildCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mode de service',
                        style: AmaraTextStyles.labelLarge
                            .copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildServiceChip(
                            label: 'Livraison',
                            icon: Icons.delivery_dining_rounded,
                            isSelected: _selectedService == 'Livraison',
                            enabled: deliveryEnabled,
                            onTap: () => setState(
                                () => _selectedService = 'Livraison'),
                          ),
                          const SizedBox(width: 10),
                          _buildServiceChip(
                            label: 'À emporter',
                            icon: Icons.takeout_dining_rounded,
                            isSelected: _selectedService == 'À emporter',
                            enabled: takeawayEnabled,
                            onTap: () => setState(
                                () => _selectedService = 'À emporter'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // ── Map + Adresse ──────────────────────────────────────
                if (_selectedService == 'Livraison') ...[
                  // Carte OpenStreetMap
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SizedBox(
                      height: 180,
                      child: FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: _deliveryLatLng,
                          initialZoom: 15,
                          onTap: (tapPosition, latLng) {
                            _updateMapPosition(
                                latLng.latitude, latLng.longitude);
                          },
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.amara.client',
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: _deliveryLatLng,
                                width: 40,
                                height: 40,
                                child: const Icon(
                                  Icons.location_on,
                                  color: AmaraColors.primary,
                                  size: 40,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),
                ],

                // ── Adresse / Téléphone ────────────────────────────────
                GestureDetector(
                  onTap: _showEditAddressSheet,
                  behavior: HitTestBehavior.opaque,
                  child: _buildCard(
                    child: Column(
                      children: [
                        // Adresse
                        Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: AmaraColors.primary
                                    .withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                  Icons.location_on_rounded,
                                  color: AmaraColors.primary,
                                  size: 18),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _selectedService == 'Livraison'
                                        ? 'Livrer à'
                                        : 'À emporter chez',
                                    style: AmaraTextStyles.caption
                                        .copyWith(
                                            color: AmaraColors.muted),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _addressController.text,
                                    style: AmaraTextStyles.labelMedium
                                        .copyWith(
                                            fontWeight: FontWeight.w700),
                                  ),
                                  if (_streetController.text.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      _streetController.text,
                                      style: AmaraTextStyles.caption
                                          .copyWith(
                                              color: AmaraColors.textSecondary),
                                    ),
                                  ],
                                  if (_instructionsController.text.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      _instructionsController.text,
                                      style: AmaraTextStyles.caption
                                          .copyWith(
                                              color: AmaraColors.muted,
                                              fontStyle: FontStyle.italic),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AmaraColors.bgAlt,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.edit_outlined,
                                  color: AmaraColors.textSecondary,
                                  size: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                            height: 1, color: AmaraColors.divider),
                        const SizedBox(height: 12),
                        // Téléphone
                        Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: AmaraColors.primary
                                    .withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.phone_rounded,
                                  color: AmaraColors.primary, size: 18),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Téléphone',
                                    style: AmaraTextStyles.caption
                                        .copyWith(
                                            color: AmaraColors.muted),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _phoneController.text,
                                    style: AmaraTextStyles.labelMedium
                                        .copyWith(
                                            fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AmaraColors.bgAlt,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.edit_outlined,
                                  color: AmaraColors.textSecondary,
                                  size: 16),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // ── Récapitulatif de la commande ───────────────────────
                _buildCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Récapitulatif de la commande',
                        style: AmaraTextStyles.labelLarge
                            .copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 16),

                      if (group != null)
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            setState(
                                () => _orderExpanded = !_orderExpanded);
                          },
                          behavior: HitTestBehavior.opaque,
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: SizedBox(
                                  width: 44,
                                  height: 44,
                                  child: group.restaurantImageUrl != null
                                      ? Image.network(
                                          group.restaurantImageUrl!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              _restaurantFallback(),
                                        )
                                      : _restaurantFallback(),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      group.restaurantName,
                                      style: AmaraTextStyles.labelMedium
                                          .copyWith(
                                              fontWeight: FontWeight.w700),
                                    ),
                                    Text(
                                      '${group.totalItems} article${group.totalItems > 1 ? 's' : ''}',
                                      style: AmaraTextStyles.caption
                                          .copyWith(
                                              color: AmaraColors
                                                  .textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                              AnimatedRotation(
                                turns: _orderExpanded ? 0.5 : 0,
                                duration:
                                    const Duration(milliseconds: 200),
                                child: const Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: AmaraColors.textSecondary,
                                    size: 22),
                              ),
                            ],
                          ),
                        ),

                      AnimatedCrossFade(
                        firstChild: Column(
                          children: [
                            const SizedBox(height: 12),
                            Container(
                                height: 1,
                                color: AmaraColors.divider),
                            const SizedBox(height: 12),
                            ...cart.items.map((item) => Padding(
                                  padding:
                                      const EdgeInsets.only(bottom: 10),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(8),
                                        child: SizedBox(
                                          width: 40,
                                          height: 40,
                                          child: item.item.imageUrl !=
                                                  null
                                              ? Image.network(
                                                  item.item.imageUrl!,
                                                  fit: BoxFit.cover,
                                                  errorBuilder:
                                                      (_, __, ___) =>
                                                          _itemFallback(
                                                              item),
                                                )
                                              : _itemFallback(item),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.item.name,
                                              style: AmaraTextStyles
                                                  .bodySmall
                                                  .copyWith(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: AmaraColors
                                                          .textPrimary),
                                              maxLines: 1,
                                              overflow: TextOverflow
                                                  .ellipsis,
                                            ),
                                            Text(
                                              'x${item.quantity}',
                                              style: AmaraTextStyles
                                                  .caption
                                                  .copyWith(
                                                      color: AmaraColors
                                                          .muted),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        item.formattedSubtotal,
                                        style: AmaraTextStyles.labelSmall
                                            .copyWith(
                                                fontWeight:
                                                    FontWeight.w700,
                                                color: AmaraColors
                                                    .textPrimary),
                                      ),
                                    ],
                                  ),
                                )),
                          ],
                        ),
                        secondChild: const SizedBox.shrink(),
                        crossFadeState: _orderExpanded
                            ? CrossFadeState.showFirst
                            : CrossFadeState.showSecond,
                        duration: const Duration(milliseconds: 250),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // ── Code promotionnel ──────────────────────────────────
                GestureDetector(
                  onTap: _voucherApplied
                      ? null
                      : () => _showPromoSheet(context),
                  child: _buildCard(
                    child: _voucherApplied
                        ? Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AmaraColors.success
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                    Icons.check_circle_rounded,
                                    color: AmaraColors.success,
                                    size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Code "$_voucherCode" appliqué',
                                      style: AmaraTextStyles.labelSmall
                                          .copyWith(
                                              color: AmaraColors.success,
                                              fontWeight: FontWeight.w700),
                                    ),
                                    Text(
                                      _discount > 0
                                          ? '-${(_discount * 100).toStringAsFixed(0)}%'
                                          : 'Livraison offerte',
                                      style: AmaraTextStyles.caption
                                          .copyWith(
                                              color: AmaraColors.success),
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: _removeVoucher,
                                child: Text('Retirer',
                                    style: AmaraTextStyles.caption
                                        .copyWith(
                                            color: AmaraColors.error,
                                            fontWeight: FontWeight.w600)),
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AmaraColors.primary
                                      .withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                    Icons.local_offer_outlined,
                                    color: AmaraColors.primary,
                                    size: 18),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Ajouter un code promotionnel',
                                  style: AmaraTextStyles.labelMedium
                                      .copyWith(
                                          fontWeight: FontWeight.w600),
                                ),
                              ),
                              const Icon(Icons.chevron_right_rounded,
                                  color: AmaraColors.muted, size: 22),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: 12),

                // ── Récapitulatif prix ─────────────────────────────────
                _buildCard(
                  child: Column(
                    children: [
                      _PriceRow(
                        label: 'Sous-total',
                        value: '${subtotal.toStringAsFixed(0)} F',
                      ),
                      const SizedBox(height: 10),
                      _PriceRow(
                        label: 'Service',
                        value: '${serviceFee.toStringAsFixed(0)} F',
                      ),
                      const SizedBox(height: 10),
                      _PriceRow(
                        label: 'Livraison',
                        value: deliveryFee == 0
                            ? 'Gratuit'
                            : '${deliveryFee.toStringAsFixed(0)} F',
                        valueColor:
                            deliveryFee == 0 ? AmaraColors.success : null,
                      ),
                      if (_discount > 0) ...[
                        const SizedBox(height: 10),
                        _PriceRow(
                          label: 'Réduction',
                          value:
                              '-${discountAmount.toStringAsFixed(0)} F',
                          valueColor: AmaraColors.success,
                        ),
                      ],
                      const SizedBox(height: 14),
                      Container(height: 1, color: AmaraColors.divider),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Text(
                            'Total',
                            style: AmaraTextStyles.labelLarge
                                .copyWith(fontWeight: FontWeight.w800),
                          ),
                          const Spacer(),
                          Text(
                            '${total.toStringAsFixed(0)} F',
                            style: AmaraTextStyles.labelLarge.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AmaraColors.primary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // ── Mode de paiement (pliable) ─────────────────────────
                _buildCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          setState(() =>
                              _paymentExpanded = !_paymentExpanded);
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Mode de paiement',
                                style: AmaraTextStyles.labelLarge
                                    .copyWith(
                                        fontWeight: FontWeight.w800),
                              ),
                            ),
                            if (!_paymentExpanded)
                              Text(
                                _selectedPayment,
                                style: AmaraTextStyles.caption.copyWith(
                                    color: AmaraColors.primary,
                                    fontWeight: FontWeight.w600),
                              ),
                            const SizedBox(width: 8),
                            AnimatedRotation(
                              turns: _paymentExpanded ? 0.5 : 0,
                              duration:
                                  const Duration(milliseconds: 200),
                              child: const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: AmaraColors.textSecondary,
                                  size: 22),
                            ),
                          ],
                        ),
                      ),
                      AnimatedCrossFade(
                        firstChild: Column(
                          children: [
                            const SizedBox(height: 14),
                            ..._paymentMethods.map((method) {
                              final isSelected =
                                  _selectedPayment == method['name'];
                              final isEnabled = supportedPayments
                                  .contains(method['key'] as String);
                              return GestureDetector(
                                onTap: isEnabled
                                    ? () {
                                        HapticFeedback.selectionClick();
                                        setState(() => _selectedPayment =
                                            method['name']);
                                      }
                                    : null,
                                child: Opacity(
                                  opacity: isEnabled ? 1.0 : 0.4,
                                  child: Container(
                                    margin:
                                        const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 14),
                                    decoration: BoxDecoration(
                                      color: !isEnabled
                                          ? AmaraColors.bgAlt
                                          : isSelected
                                              ? AmaraColors.primary
                                                  .withValues(alpha: 0.06)
                                              : AmaraColors.bg,
                                      borderRadius:
                                          BorderRadius.circular(12),
                                      border: Border.all(
                                        color: !isEnabled
                                            ? AmaraColors.divider
                                            : isSelected
                                                ? AmaraColors.primary
                                                : AmaraColors.divider,
                                        width: isSelected && isEnabled
                                            ? 1.5
                                            : 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          method['icon'] as IconData,
                                          color: !isEnabled
                                              ? AmaraColors.muted
                                              : isSelected
                                                  ? AmaraColors.primary
                                                  : AmaraColors
                                                      .textSecondary,
                                          size: 22,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                method['name'] as String,
                                                style: AmaraTextStyles
                                                    .labelMedium
                                                    .copyWith(
                                                  fontWeight: isSelected &&
                                                          isEnabled
                                                      ? FontWeight.w700
                                                      : FontWeight.w500,
                                                  color: !isEnabled
                                                      ? AmaraColors.muted
                                                      : isSelected
                                                          ? AmaraColors
                                                              .primary
                                                          : AmaraColors
                                                              .textPrimary,
                                                ),
                                              ),
                                              if (!isEnabled)
                                                Text(
                                                  'Non disponible',
                                                  style: AmaraTextStyles
                                                      .caption
                                                      .copyWith(
                                                    color:
                                                        AmaraColors.muted,
                                                    fontSize: 10,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                        if (isSelected && isEnabled)
                                          const Icon(
                                              Icons.check_circle_rounded,
                                              color: AmaraColors.primary,
                                              size: 20)
                                        else
                                          Icon(
                                              Icons.circle_outlined,
                                              color: !isEnabled
                                                  ? AmaraColors.muted
                                                  : AmaraColors.divider,
                                              size: 20),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                        secondChild: const SizedBox.shrink(),
                        crossFadeState: _paymentExpanded
                            ? CrossFadeState.showFirst
                            : CrossFadeState.showSecond,
                        duration: const Duration(milliseconds: 250),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),

          // ── Barre "Commander et payer" ────────────────────────────────
          Container(
            padding: EdgeInsets.fromLTRB(16, 12, 16, bottom + 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border:
                  Border(top: BorderSide(color: AmaraColors.divider)),
            ),
            child: GestureDetector(
              onTap: cart.isEmpty || _isLoading
                  ? null
                  : () => _placeOrder(cart),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: cart.isEmpty
                      ? AmaraColors.muted
                      : AmaraColors.primary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: _isLoading
                    ? const Center(
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        ),
                      )
                    : Center(
                        child: Text(
                          'Commander et payer · ${total.toStringAsFixed(0)} F',
                          style: AmaraTextStyles.button,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Widget _buildCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: AmaraColors.divider.withValues(alpha: 0.5)),
      ),
      child: child,
    );
  }

  Widget _buildServiceChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    bool enabled = true,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: enabled
            ? () {
                HapticFeedback.selectionClick();
                onTap();
              }
            : null,
        child: Opacity(
          opacity: enabled ? 1.0 : 0.4,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: !enabled
                  ? AmaraColors.bgAlt
                  : isSelected
                      ? AmaraColors.primary.withValues(alpha: 0.08)
                      : AmaraColors.bgAlt,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: !enabled
                    ? AmaraColors.divider
                    : isSelected
                        ? AmaraColors.primary
                        : AmaraColors.divider,
                width: isSelected && enabled ? 1.5 : 1,
              ),
            ),
            child: Column(
              children: [
                Icon(icon,
                    color: !enabled
                        ? AmaraColors.muted
                        : isSelected
                            ? AmaraColors.primary
                            : AmaraColors.muted,
                    size: 22),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: AmaraTextStyles.caption.copyWith(
                    color: !enabled
                        ? AmaraColors.muted
                        : isSelected
                            ? AmaraColors.primary
                            : AmaraColors.textSecondary,
                    fontWeight:
                        isSelected && enabled ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
                if (!enabled) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Non disponible',
                    style: AmaraTextStyles.caption.copyWith(
                      color: AmaraColors.muted,
                      fontSize: 9,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _restaurantFallback() {
    return Container(
      color: AmaraColors.bgAlt,
      child: const Center(
        child: Icon(Icons.storefront_rounded,
            color: AmaraColors.muted, size: 22),
      ),
    );
  }

  Widget _itemFallback(CartItem item) {
    return Container(
      color: AmaraColors.bgAlt,
      child: Center(
        child: Text(item.item.imageEmoji,
            style: const TextStyle(fontSize: 18)),
      ),
    );
  }

  void _showPromoSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: EdgeInsets.fromLTRB(
              20, 20, 20, MediaQuery.of(context).padding.bottom + 20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AmaraColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text('Code promotionnel',
                  style: AmaraTextStyles.labelLarge
                      .copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 14),
              TextField(
                controller: _voucherController,
                autofocus: true,
                textCapitalization: TextCapitalization.characters,
                style: AmaraTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AmaraColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Entrez votre code promo',
                  hintStyle: AmaraTextStyles.bodyMedium
                      .copyWith(color: AmaraColors.muted),
                  filled: true,
                  fillColor: AmaraColors.bgAlt,
                  contentPadding: const EdgeInsets.all(14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: AmaraColors.primary, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: _applyVoucher,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: AmaraColors.primary,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text('Appliquer',
                        style: AmaraTextStyles.labelMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Header rouge ─────────────────────────────────────────────────────────────

class _CheckoutHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Container(
      color: AmaraColors.primary,
      padding: EdgeInsets.fromLTRB(16, top + 12, 16, 18),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.arrow_back_ios_rounded,
                  color: Colors.white, size: 16),
            ),
          ),
          const SizedBox(width: 14),
          Text(
            'Paiement',
            style: AmaraTextStyles.h1.copyWith(
                fontWeight: FontWeight.w800, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

// ─── Ligne de prix ────────────────────────────────────────────────────────────

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _PriceRow(
      {required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: AmaraTextStyles.bodyMedium
              .copyWith(color: AmaraColors.textSecondary),
        ),
        const Spacer(),
        Text(
          value,
          style: AmaraTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: valueColor ?? AmaraColors.textPrimary),
        ),
      ],
    );
  }
}
