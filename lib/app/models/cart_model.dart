import 'restaurant_model.dart';

/// Un article dans le panier.
class CartItem {
  final MenuItem item;
  final int quantity;
  final String? note;

  const CartItem({
    required this.item,
    required this.quantity,
    this.note,
  });

  CartItem copyWith({int? quantity, String? note}) {
    return CartItem(
      item: item,
      quantity: quantity ?? this.quantity,
      note: note ?? this.note,
    );
  }

  double get subtotal => item.price * quantity;
  String get formattedSubtotal => '${subtotal.toStringAsFixed(0)} F';
}

/// État complet du panier.
class CartState {
  final String? restaurantId;
  final String? restaurantName;
  final List<CartItem> items;

  const CartState({
    this.restaurantId,
    this.restaurantName,
    this.items = const [],
  });

  CartState copyWith({
    String? restaurantId,
    String? restaurantName,
    List<CartItem>? items,
  }) {
    return CartState(
      restaurantId: restaurantId ?? this.restaurantId,
      restaurantName: restaurantName ?? this.restaurantName,
      items: items ?? this.items,
    );
  }

  int get totalItems => items.fold(0, (sum, e) => sum + e.quantity);

  double get subtotal => items.fold(0.0, (sum, e) => sum + e.subtotal);

  double get deliveryFee => subtotal > 0 ? 500.0 : 0.0;

  double get total => subtotal + deliveryFee;

  String get formattedSubtotal => '${subtotal.toStringAsFixed(0)} F';
  String get formattedDeliveryFee =>
      deliveryFee == 0 ? 'Gratuit' : '${deliveryFee.toStringAsFixed(0)} F';
  String get formattedTotal => '${total.toStringAsFixed(0)} F';

  bool get isEmpty => items.isEmpty;

  CartItem? itemFor(String itemId) {
    try {
      return items.firstWhere((e) => e.item.id == itemId);
    } catch (_) {
      return null;
    }
  }

  int quantityFor(String itemId) => itemFor(itemId)?.quantity ?? 0;
}
