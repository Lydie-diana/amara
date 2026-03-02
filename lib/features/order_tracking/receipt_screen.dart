import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';

import '../../app/core/constants/app_colors.dart';
import '../../app/core/constants/app_text_styles.dart';
import '../../app/services/receipt_pdf_service.dart';

/// Écran affichant le reçu d'une commande avec possibilité de télécharger en PDF.
class ReceiptScreen extends StatelessWidget {
  final String orderId;
  final Map<String, dynamic> order;

  const ReceiptScreen({
    super.key,
    required this.orderId,
    required this.order,
  });

  String get _restaurantName =>
      order['restaurantName'] as String? ?? 'Restaurant';

  List get _items => (order['items'] as List?) ?? [];

  double get _total =>
      (order['totalAmount'] as num?)?.toDouble() ??
      (order['total'] as num?)?.toDouble() ??
      0;

  double get _deliveryFee =>
      (order['deliveryFee'] as num?)?.toDouble() ?? 500;

  double get _subtotal => _total - _deliveryFee;

  String get _paymentMethod => order['paymentMethod'] as String? ?? '';

  String get _address => order['deliveryAddress'] as String? ?? '';

  bool get _isPickup =>
      order['orderType'] == 'pickup' || _address == 'À emporter';

  String get _shortId => orderId.length > 8
      ? orderId.substring(orderId.length - 8).toUpperCase()
      : orderId.toUpperCase();

  String get _dateStr {
    final createdAt = order['createdAt'] as num?;
    if (createdAt == null) return '';
    final date = DateTime.fromMillisecondsSinceEpoch(createdAt.toInt());
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} à ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String get _paymentLabel {
    switch (_paymentMethod) {
      case 'mobile_money':
        return 'Mobile Money';
      case 'card':
        return 'Carte bancaire';
      case 'cash':
        return 'Cash';
      default:
        return _paymentMethod.isNotEmpty ? _paymentMethod : 'Non spécifié';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AmaraColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: AmaraColors.textPrimary, size: 22),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          'Reçu',
          style: AmaraTextStyles.labelLarge.copyWith(
            fontWeight: FontWeight.w700,
            color: AmaraColors.textPrimary,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Logo
                    Text(
                      'AMARA',
                      style: AmaraTextStyles.display1.copyWith(
                        color: AmaraColors.primary,
                        fontWeight: FontWeight.w900,
                        fontSize: 28,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Livraison de cuisine africaine',
                      style: AmaraTextStyles.caption
                          .copyWith(color: AmaraColors.muted),
                    ),

                    const SizedBox(height: 20),
                    Container(height: 2, color: AmaraColors.primary),
                    const SizedBox(height: 20),

                    // Titre
                    Text(
                      'REÇU DE COMMANDE',
                      style: AmaraTextStyles.labelLarge.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'N° $_shortId',
                      style: AmaraTextStyles.bodySmall
                          .copyWith(color: AmaraColors.textSecondary),
                    ),

                    const SizedBox(height: 24),

                    // Infos
                    _buildInfoRow('Date', _dateStr),
                    _buildInfoRow('Restaurant', _restaurantName),
                    _buildInfoRow(
                        'Mode', _isPickup ? 'À emporter' : 'Livraison'),
                    if (!_isPickup && _address.isNotEmpty)
                      _buildInfoRow('Adresse', _address),
                    _buildInfoRow('Paiement', _paymentLabel),

                    const SizedBox(height: 20),
                    const Divider(color: AmaraColors.divider),
                    const SizedBox(height: 12),

                    // Header tableau
                    Row(
                      children: [
                        SizedBox(
                          width: 36,
                          child: Text('Qté',
                              style: AmaraTextStyles.caption.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AmaraColors.textPrimary)),
                        ),
                        Expanded(
                          child: Text('Article',
                              style: AmaraTextStyles.caption.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AmaraColors.textPrimary)),
                        ),
                        Text('Prix',
                            style: AmaraTextStyles.caption.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AmaraColors.textPrimary)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Divider(color: AmaraColors.divider),
                    const SizedBox(height: 8),

                    // Items
                    ..._items.map((item) {
                      final d = item as Map<String, dynamic>;
                      final name = d['name'] as String? ?? '';
                      final qty = (d['quantity'] as num?)?.toInt() ?? 1;
                      final unitPrice =
                          (d['unitPrice'] as num?)?.toDouble() ?? 0;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 36,
                              child: Text(
                                '$qty',
                                style: AmaraTextStyles.bodyMedium
                                    .copyWith(color: AmaraColors.textPrimary),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                name,
                                style: AmaraTextStyles.bodyMedium
                                    .copyWith(color: AmaraColors.textPrimary),
                              ),
                            ),
                            Text(
                              '${(unitPrice * qty).toStringAsFixed(0)} F',
                              style: AmaraTextStyles.bodyMedium.copyWith(
                                color: AmaraColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: 8),
                    const Divider(color: AmaraColors.divider),
                    const SizedBox(height: 12),

                    // Sous-total
                    _buildTotalRow('Sous-total',
                        '${_subtotal.toStringAsFixed(0)} F'),
                    const SizedBox(height: 6),
                    _buildTotalRow(
                      'Frais de livraison',
                      _isPickup
                          ? 'Gratuit'
                          : '${_deliveryFee.toStringAsFixed(0)} F',
                    ),
                    const SizedBox(height: 12),
                    Container(height: 1.5, color: AmaraColors.textPrimary),
                    const SizedBox(height: 12),

                    // Total
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'TOTAL',
                          style: AmaraTextStyles.labelLarge.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          '${_total.toStringAsFixed(0)} F CFA',
                          style: AmaraTextStyles.labelLarge.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AmaraColors.primary,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),
                    const Divider(color: AmaraColors.divider),
                    const SizedBox(height: 16),

                    // Footer
                    Text(
                      'Merci pour votre commande !',
                      style: AmaraTextStyles.labelMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AmaraColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Amara — La saveur de l\'Afrique livrée chez vous',
                      style: AmaraTextStyles.caption
                          .copyWith(color: AmaraColors.muted, fontSize: 10),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bouton télécharger
          Container(
            padding: EdgeInsets.fromLTRB(20, 14, 20, bottom + 14),
            decoration: BoxDecoration(
              color: Colors.white,
              border:
                  Border(top: BorderSide(color: AmaraColors.divider)),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: () => _downloadPdf(context),
                icon: const Icon(Icons.download_rounded, size: 20),
                label: Text(
                  'Télécharger le reçu',
                  style: AmaraTextStyles.labelLarge.copyWith(
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
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadPdf(BuildContext context) async {
    HapticFeedback.mediumImpact();
    try {
      final pdfBytes = await ReceiptPdfService.generate(
        orderId: orderId,
        order: order,
      );
      await Printing.sharePdf(
        bytes: pdfBytes,
        filename: 'recu_amara_$_shortId.pdf',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la génération du reçu'),
            backgroundColor: AmaraColors.error,
          ),
        );
      }
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: AmaraTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AmaraColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AmaraTextStyles.bodyMedium.copyWith(
                color: AmaraColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AmaraTextStyles.bodySmall.copyWith(
            color: AmaraColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: AmaraTextStyles.bodyMedium.copyWith(
            color: AmaraColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
