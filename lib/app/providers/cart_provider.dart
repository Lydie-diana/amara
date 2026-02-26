import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cart_model.dart';
import '../models/restaurant_model.dart';

/// Notifier gérant l'état du panier (multi-restaurant).
class CartNotifier extends Notifier<CartState> {
  @override
  CartState build() => const CartState();

  /// Ajouter un item au panier. Les items de restaurants différents coexistent.
  void addItem(
    MenuItem item,
    String restaurantId,
    String restaurantName, {
    Map<String, List<String>> selectedOptions = const {},
    double extraPrice = 0,
    String? note,
    int quantity = 1,
  }) {
    // Avec options personnalisées, on ajoute toujours un nouvel entry
    // (deux "mêmes plats" avec des options différentes = deux lignes)
    if (selectedOptions.isNotEmpty) {
      state = state.copyWith(
        items: [
          ...state.items,
          CartItem(
            item: item,
            quantity: quantity,
            restaurantId: restaurantId,
            restaurantName: restaurantName,
            selectedOptions: selectedOptions,
            extraPrice: extraPrice,
            note: note,
          ),
        ],
      );
      return;
    }

    final existing = state.itemFor(item.id);
    if (existing != null) {
      // Incrémente la quantité
      final updated = state.items.map((e) {
        if (e.item.id == item.id) return e.copyWith(quantity: e.quantity + 1);
        return e;
      }).toList();
      state = state.copyWith(items: updated);
    } else {
      state = state.copyWith(
        items: [
          ...state.items,
          CartItem(
            item: item,
            quantity: quantity,
            restaurantId: restaurantId,
            restaurantName: restaurantName,
            note: note,
          ),
        ],
      );
    }
  }

  /// Décrémenter la quantité d'un item (supprime si = 0).
  void removeItem(String itemId) {
    final existing = state.itemFor(itemId);
    if (existing == null) return;

    if (existing.quantity <= 1) {
      final updated = state.items.where((e) => e.item.id != itemId).toList();
      state = updated.isEmpty ? const CartState() : state.copyWith(items: updated);
    } else {
      final updated = state.items.map((e) {
        if (e.item.id == itemId) return e.copyWith(quantity: e.quantity - 1);
        return e;
      }).toList();
      state = state.copyWith(items: updated);
    }
  }

  /// Supprimer tous les items d'un restaurant.
  void removeRestaurant(String restaurantId) {
    final updated = state.items.where((e) => e.restaurantId != restaurantId).toList();
    state = updated.isEmpty ? const CartState() : state.copyWith(items: updated);
  }

  /// Vider entièrement le panier.
  void clear() {
    state = const CartState();
  }
}

final cartProvider = NotifierProvider<CartNotifier, CartState>(
  CartNotifier.new,
);
