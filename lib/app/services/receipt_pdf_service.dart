import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Génère un reçu PDF à partir des données d'une commande.
class ReceiptPdfService {
  static Future<Uint8List> generate({
    required String orderId,
    required Map<String, dynamic> order,
  }) async {
    final pdf = pw.Document();

    final restaurantName =
        order['restaurantName'] as String? ?? 'Restaurant';
    final items = (order['items'] as List?) ?? [];
    final total = (order['totalAmount'] as num?)?.toDouble() ??
        (order['total'] as num?)?.toDouble() ??
        0;
    final deliveryFee =
        (order['deliveryFee'] as num?)?.toDouble() ?? 500;
    final subtotal = total - deliveryFee;
    final paymentMethod = order['paymentMethod'] as String? ?? '';
    final address = order['deliveryAddress'] as String? ?? '';
    final orderType = order['orderType'] as String?;
    final isPickup = orderType == 'pickup' || address == 'À emporter';

    // Date
    final createdAt = order['createdAt'] as num?;
    final date = createdAt != null
        ? DateTime.fromMillisecondsSinceEpoch(createdAt.toInt())
        : DateTime.now();
    final dateStr =
        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} à ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

    // ID court
    final shortId = orderId.length > 8
        ? orderId.substring(orderId.length - 8).toUpperCase()
        : orderId.toUpperCase();

    // Payment label
    final paymentLabel = _paymentLabel(paymentMethod);

    final primaryColor = PdfColor.fromHex('#E62050');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      'AMARA',
                      style: pw.TextStyle(
                        fontSize: 28,
                        fontWeight: pw.FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Livraison de cuisine africaine',
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey600,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 24),
              pw.Divider(color: primaryColor, thickness: 2),
              pw.SizedBox(height: 16),

              // Titre + numéro
              pw.Center(
                child: pw.Text(
                  'REÇU DE COMMANDE',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Center(
                child: pw.Text(
                  'N° $shortId',
                  style: pw.TextStyle(
                    fontSize: 12,
                    color: PdfColors.grey700,
                  ),
                ),
              ),
              pw.SizedBox(height: 20),

              // Infos
              _infoRow('Date', dateStr),
              _infoRow('Restaurant', restaurantName),
              _infoRow('Mode', isPickup ? 'À emporter' : 'Livraison'),
              if (!isPickup && address.isNotEmpty)
                _infoRow('Adresse', address),
              _infoRow('Paiement', paymentLabel),
              pw.SizedBox(height: 20),

              // Tableau articles
              pw.Divider(color: PdfColors.grey300),
              pw.SizedBox(height: 8),
              pw.Row(
                children: [
                  pw.Expanded(
                    flex: 1,
                    child: pw.Text('Qté',
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold, fontSize: 11)),
                  ),
                  pw.Expanded(
                    flex: 4,
                    child: pw.Text('Article',
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold, fontSize: 11)),
                  ),
                  pw.Text('Prix',
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 11)),
                ],
              ),
              pw.SizedBox(height: 6),
              pw.Divider(color: PdfColors.grey300),
              pw.SizedBox(height: 6),

              // Items
              ...items.map((item) {
                final d = item as Map<String, dynamic>;
                final name = d['name'] as String? ?? '';
                final qty = (d['quantity'] as num?)?.toInt() ?? 1;
                final unitPrice =
                    (d['unitPrice'] as num?)?.toDouble() ?? 0;
                return pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 6),
                  child: pw.Row(
                    children: [
                      pw.Expanded(
                        flex: 1,
                        child: pw.Text('$qty',
                            style: const pw.TextStyle(fontSize: 11)),
                      ),
                      pw.Expanded(
                        flex: 4,
                        child: pw.Text(name,
                            style: const pw.TextStyle(fontSize: 11)),
                      ),
                      pw.Text(
                        '${(unitPrice * qty).toStringAsFixed(0)} F',
                        style: const pw.TextStyle(fontSize: 11),
                      ),
                    ],
                  ),
                );
              }),

              pw.SizedBox(height: 8),
              pw.Divider(color: PdfColors.grey300),
              pw.SizedBox(height: 10),

              // Sous-total
              _totalRow('Sous-total',
                  '${subtotal.toStringAsFixed(0)} F'),
              pw.SizedBox(height: 4),
              _totalRow('Frais de livraison',
                  isPickup ? 'Gratuit' : '${deliveryFee.toStringAsFixed(0)} F'),
              pw.SizedBox(height: 8),
              pw.Divider(color: PdfColors.grey600),
              pw.SizedBox(height: 8),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('TOTAL',
                      style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold)),
                  pw.Text(
                    '${total.toStringAsFixed(0)} F CFA',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 40),
              pw.Divider(color: PdfColors.grey300),
              pw.SizedBox(height: 16),

              // Footer
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      'Merci pour votre commande !',
                      style: pw.TextStyle(
                        fontSize: 13,
                        fontWeight: pw.FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    pw.SizedBox(height: 6),
                    pw.Text(
                      'Amara — La saveur de l\'Afrique livrée chez vous',
                      style: pw.TextStyle(
                        fontSize: 9,
                        color: PdfColors.grey500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _infoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 100,
            child: pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey700,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: const pw.TextStyle(fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _totalRow(String label, String value) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label,
            style: pw.TextStyle(fontSize: 11, color: PdfColors.grey700)),
        pw.Text(value, style: const pw.TextStyle(fontSize: 11)),
      ],
    );
  }

  static String _paymentLabel(String method) {
    switch (method) {
      case 'mobile_money':
        return 'Mobile Money';
      case 'card':
        return 'Carte bancaire';
      case 'cash':
        return 'Cash';
      default:
        return method.isNotEmpty ? method : 'Non spécifié';
    }
  }
}
