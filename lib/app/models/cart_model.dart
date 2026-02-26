import 'restaurant_model.dart';

/// Un article dans le panier, avec son restaurant d'origine.
class CartItem {
  final MenuItem item;
  final int quantity;
  final String? note;
  final String restaurantId;
  final String restaurantName;
  final Map<String, List<String>> selectedOptions; // groupId → optionIds
  final double extraPrice; // total des suppléments

  const CartItem({
    required this.item,
    required this.quantity,
    required this.restaurantId,
    required this.restaurantName,
    this.note,
    this.selectedOptions = const {},
    this.extraPrice = 0,
  });

  CartItem copyWith({int? quantity, String? note}) {
    return CartItem(
      item: item,
      quantity: quantity ?? this.quantity,
      restaurantId: restaurantId,
      restaurantName: restaurantName,
      note: note ?? this.note,
      selectedOptions: selectedOptions,
      extraPrice: extraPrice,
    );
  }

  double get unitPrice => item.price + extraPrice;
  double get subtotal => unitPrice * quantity;
  String get formattedSubtotal => '${subtotal.toStringAsFixed(0)} F';
}

/// Groupe d'articles d'un même restaurant dans le panier.
class CartRestaurantGroup {
  final String restaurantId;
  final String restaurantName;
  final List<CartItem> items;

  const CartRestaurantGroup({
    required this.restaurantId,
    required this.restaurantName,
    required this.items,
  });

  double get subtotal => items.fold(0.0, (sum, e) => sum + e.subtotal);
  double get deliveryFee => 500.0;
  double get total => subtotal + deliveryFee;
  int get totalItems => items.fold(0, (sum, e) => sum + e.quantity);
}

/// État complet du panier (multi-restaurant).
class CartState {
  final List<CartItem> items;

  const CartState({
    this.items = const [],
  });

  CartState copyWith({List<CartItem>? items}) {
    return CartState(items: items ?? this.items);
  }

  int get totalItems => items.fold(0, (sum, e) => sum + e.quantity);

  double get subtotal => items.fold(0.0, (sum, e) => sum + e.subtotal);

  /// Frais de livraison par restaurant unique (500 F / restaurant)
  double get deliveryFee {
    final restaurantCount = items.map((e) => e.restaurantId).toSet().length;
    return restaurantCount * 500.0;
  }

  double get total => subtotal + deliveryFee;

  String get formattedSubtotal => '${subtotal.toStringAsFixed(0)} F';
  String get formattedDeliveryFee =>
      deliveryFee == 0 ? 'Gratuit' : '${deliveryFee.toStringAsFixed(0)} F';
  String get formattedTotal => '${total.toStringAsFixed(0)} F';

  bool get isEmpty => items.isEmpty;

  /// Groupes par restaurant
  List<CartRestaurantGroup> get groups {
    final map = <String, List<CartItem>>{};
    for (final item in items) {
      map.putIfAbsent(item.restaurantId, () => []).add(item);
    }
    return map.entries.map((e) {
      final first = e.value.first;
      return CartRestaurantGroup(
        restaurantId: e.key,
        restaurantName: first.restaurantName,
        items: e.value,
      );
    }).toList();
  }

  CartItem? itemFor(String itemId) {
    try {
      return items.firstWhere((e) => e.item.id == itemId);
    } catch (_) {
      return null;
    }
  }

  int quantityFor(String itemId) => itemFor(itemId)?.quantity ?? 0;

  // Compat legacy — premier restaurant du panier
  String? get restaurantId => items.isNotEmpty ? items.first.restaurantId : null;
  String? get restaurantName => items.isNotEmpty ? items.first.restaurantName : null;
}
