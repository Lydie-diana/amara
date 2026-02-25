import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/core/constants/app_colors.dart';
import '../../app/core/constants/app_text_styles.dart';
import '../../app/models/cart_model.dart';
import '../../app/providers/cart_provider.dart';
import '../../app/providers/auth_provider.dart';
import '../../app/services/convex_client.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _nameController = TextEditingController(text: 'Diana');
  final _phoneController = TextEditingController(text: '+225 07 00 00 00');
  final _addressController =
      TextEditingController(text: 'Cocody, Abidjan');
  String _selectedPayment = 'Mobile Money';
  String _selectedService = 'Livraison';
  String _voucherCode = '';
  bool _voucherApplied = false;
  double _discount = 0;
  bool _isLoading = false;

  final _voucherController = TextEditingController();
  final List<String> _paymentMethods = [
    'Mobile Money', 'Wave', 'Cash', 'Carte bancaire'
  ];
  final List<String> _serviceModes = ['Livraison', 'À emporter'];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _voucherController.dispose();
    super.dispose();
  }

  void _applyVoucher() {
    final code = _voucherController.text.trim().toUpperCase();
    // Mock codes
    final codes = {
      'MAMA1': 0.0,     // livraison gratuite
      'MIDI15': 0.15,   // -15%
      'WE20': 0.20,     // -20%
      'LAGOS10': 0.10,  // -10%
      'AMARA': 0.10,
    };
    if (codes.containsKey(code)) {
      setState(() {
        _voucherCode = code;
        _discount = codes[code]!;
        _voucherApplied = true;
      });
      HapticFeedback.mediumImpact();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Code invalide',
              style: AmaraTextStyles.bodySmall
                  .copyWith(color: Colors.white)),
          backgroundColor: AmaraColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
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

      // Construire la liste d'items pour Convex
      final items = cart.items.map((ci) => {
        'menuItemId': ci.item.id,
        'name': ci.item.name,
        'quantity': ci.quantity,
        'unitPrice': ci.item.price,
      }).toList();

      String orderId;
      if (authState.isAuthenticated && cart.restaurantId != null) {
        // Appel Convex réel
        orderId = await client.createOrder(
          restaurantId: cart.restaurantId!,
          items: items,
          deliveryAddress: _selectedService == 'Livraison'
              ? _addressController.text.trim()
              : 'À emporter',
          paymentMethod: _selectedPayment,
        );
      } else {
        // Fallback si non connecté (démo)
        await Future.delayed(const Duration(seconds: 1));
        orderId = 'ORD${DateTime.now().millisecondsSinceEpoch % 1000000}';
      }

      if (mounted) {
        setState(() => _isLoading = false);
        ref.read(cartProvider.notifier).clear();
        context.pushReplacement('/order/$orderId/confirmation');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur : ${e.toString().replaceFirst('Exception: ', '')}',
                style: AmaraTextStyles.bodySmall.copyWith(color: Colors.white)),
            backgroundColor: AmaraColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final subtotal = cart.subtotal;
    final deliveryFee = _selectedService == 'Livraison' ? cart.deliveryFee : 0.0;
    final discountAmount = subtotal * _discount;
    final total = subtotal + deliveryFee - discountAmount;

    return Scaffold(
      backgroundColor: AmaraColors.bg,
      appBar: AppBar(
        backgroundColor: AmaraColors.bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: AmaraColors.textPrimary, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text('Commander', style: AmaraTextStyles.h3),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        physics: const BouncingScrollPhysics(),
        children: [
          // ── Mode service ──────────────────────────────────────────────────
          _Section(
            title: 'Mode de service',
            child: Row(
              children: _serviceModes.map((mode) {
                final isSelected = _selectedService == mode;
                final icon = mode == 'Livraison'
                    ? Icons.delivery_dining_rounded
                    : Icons.takeout_dining_rounded;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedService = mode);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: EdgeInsets.only(
                          right: mode == _serviceModes.first ? 8 : 0),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AmaraColors.primary.withValues(alpha: 0.08)
                            : AmaraColors.bgAlt,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? AmaraColors.primary
                              : AmaraColors.divider,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(icon,
                              color: isSelected
                                  ? AmaraColors.primary
                                  : AmaraColors.muted,
                              size: 24),
                          const SizedBox(height: 4),
                          Text(mode,
                              style: AmaraTextStyles.caption.copyWith(
                                color: isSelected
                                    ? AmaraColors.primary
                                    : AmaraColors.textSecondary,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                              )),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // ── Infos client ──────────────────────────────────────────────────
          _Section(
            title: 'Informations client',
            trailing: TextButton(
              onPressed: () {},
              child: Text('Modifier',
                  style: AmaraTextStyles.caption.copyWith(
                      color: AmaraColors.primary,
                      fontWeight: FontWeight.w600)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _InputField(
                        label: 'Nom complet',
                        controller: _nameController,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _InputField(
                        label: 'Téléphone',
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                  ],
                ),
                if (_selectedService == 'Livraison') ...[
                  const SizedBox(height: 10),
                  _InputField(
                    label: 'Adresse de livraison',
                    controller: _addressController,
                  ),
                ],
              ],
            ),
          ),

          // ── Récapitulatif commande ────────────────────────────────────────
          _Section(
            title: 'Détail de la commande',
            child: Column(
              children: [
                ...cart.items.map((cartItem) => _OrderItemRow(
                      cartItem: cartItem,
                    )),
              ],
            ),
          ),

          // ── Mode de paiement ──────────────────────────────────────────────
          _Section(
            title: 'Mode de paiement',
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: _paymentMethods.map((method) {
                  final isSelected = _selectedPayment == method;
                  final icon = _paymentIcon(method);
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedPayment = method);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AmaraColors.primary.withValues(alpha: 0.08)
                            : AmaraColors.bgCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AmaraColors.primary
                              : AmaraColors.divider,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(icon, style: const TextStyle(fontSize: 24)),
                          const SizedBox(height: 4),
                          Text(method,
                              style: AmaraTextStyles.caption.copyWith(
                                color: isSelected
                                    ? AmaraColors.primary
                                    : AmaraColors.textSecondary,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                              )),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // ── Voucher ───────────────────────────────────────────────────────
          _Section(
            title: 'Code promo',
            child: _voucherApplied
                ? Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AmaraColors.success.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AmaraColors.success.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_rounded,
                            color: AmaraColors.success, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Code "$_voucherCode" appliqué',
                                  style: AmaraTextStyles.labelSmall.copyWith(
                                      color: AmaraColors.success,
                                      fontWeight: FontWeight.w700)),
                              Text(
                                _discount > 0
                                    ? 'Réduction de ${(_discount * 100).toStringAsFixed(0)}%'
                                    : 'Livraison offerte',
                                style: AmaraTextStyles.caption
                                    .copyWith(color: AmaraColors.success),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: _removeVoucher,
                          child: Text('Retirer',
                              style: AmaraTextStyles.caption.copyWith(
                                  color: AmaraColors.error,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  )
                : Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _voucherController,
                          style: AmaraTextStyles.bodySmall,
                          textCapitalization: TextCapitalization.characters,
                          decoration: InputDecoration(
                            hintText: 'Entrez votre code',
                            hintStyle: AmaraTextStyles.bodySmall
                                .copyWith(color: AmaraColors.muted),
                            filled: true,
                            fillColor: AmaraColors.bgAlt,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: AmaraColors.divider),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: AmaraColors.divider),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: AmaraColors.primary, width: 1.5),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: _applyVoucher,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: AmaraColors.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text('Appliquer',
                              style: AmaraTextStyles.labelSmall
                                  .copyWith(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
          ),

          // ── Récapitulatif prix ────────────────────────────────────────────
          _Section(
            title: 'Récapitulatif',
            child: Column(
              children: [
                _PriceRow(
                    label: 'Sous-total',
                    value: '${subtotal.toStringAsFixed(0)} F'),
                const SizedBox(height: 8),
                _PriceRow(
                  label: 'Livraison',
                  value: deliveryFee == 0
                      ? 'Gratuit'
                      : '${deliveryFee.toStringAsFixed(0)} F',
                  valueColor:
                      deliveryFee == 0 ? AmaraColors.success : null,
                ),
                if (_discount > 0) ...[
                  const SizedBox(height: 8),
                  _PriceRow(
                    label: 'Réduction ($voucherCode)',
                    value: '-${discountAmount.toStringAsFixed(0)} F',
                    valueColor: AmaraColors.success,
                  ),
                ],
                const SizedBox(height: 12),
                Container(height: 1, color: AmaraColors.divider),
                const SizedBox(height: 12),
                _PriceRow(
                  label: 'Total',
                  value: '${total.toStringAsFixed(0)} F',
                  bold: true,
                  valueColor: AmaraColors.primary,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),

      // ── Bouton Commander ──────────────────────────────────────────────────
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(
            20, 12, 20, MediaQuery.of(context).padding.bottom + 12),
        decoration: BoxDecoration(
          color: AmaraColors.bgCard,
          border: Border(top: BorderSide(color: AmaraColors.divider)),
        ),
        child: GestureDetector(
          onTap: cart.isEmpty || _isLoading ? null : () => _placeOrder(cart),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: cart.isEmpty ? AmaraColors.muted : AmaraColors.primary,
              borderRadius: BorderRadius.circular(16),
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
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle_outline_rounded,
                          color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Confirmer · ${total.toStringAsFixed(0)} F',
                        style: AmaraTextStyles.labelMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  String _paymentIcon(String method) {
    return switch (method) {
      'Mobile Money' => '📱',
      'Wave' => '🌊',
      'Cash' => '💵',
      'Carte bancaire' => '💳',
      _ => '💰',
    };
  }

  String get voucherCode => _voucherCode;
}

// ─── Composants ───────────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;

  const _Section({required this.title, required this.child, this.trailing});

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
              Expanded(
                child: Text(title,
                    style: AmaraTextStyles.labelMedium
                        .copyWith(fontWeight: FontWeight.w700)),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;

  const _InputField(
      {required this.label,
      required this.controller,
      this.keyboardType});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AmaraTextStyles.caption
                .copyWith(color: AmaraColors.muted)),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: AmaraColors.bgAlt,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AmaraColors.divider),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: AmaraTextStyles.bodySmall
                .copyWith(fontWeight: FontWeight.w600),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
        ),
      ],
    );
  }
}

class _OrderItemRow extends StatelessWidget {
  final CartItem cartItem;
  const _OrderItemRow({required this.cartItem});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AmaraColors.bgAlt,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(cartItem.item.imageEmoji,
                  style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(cartItem.item.name,
                    style: AmaraTextStyles.labelSmall
                        .copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text('${cartItem.quantity} pièce(s)',
                    style: AmaraTextStyles.caption
                        .copyWith(color: AmaraColors.muted)),
              ],
            ),
          ),
          Text(cartItem.formattedSubtotal,
              style: AmaraTextStyles.labelSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AmaraColors.textPrimary)),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  final Color? valueColor;

  const _PriceRow(
      {required this.label,
      required this.value,
      this.bold = false,
      this.valueColor});

  @override
  Widget build(BuildContext context) {
    final style = bold ? AmaraTextStyles.labelMedium : AmaraTextStyles.bodySmall;
    return Row(
      children: [
        Expanded(
          child: Text(label,
              style: style.copyWith(
                  color: bold
                      ? AmaraColors.textPrimary
                      : AmaraColors.textSecondary)),
        ),
        Text(value,
            style: style.copyWith(
              fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
              color: valueColor ??
                  (bold ? AmaraColors.primary : AmaraColors.textPrimary),
            )),
      ],
    );
  }
}
