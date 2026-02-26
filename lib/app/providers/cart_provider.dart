import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cart_model.dart';
import '../models/restaurant_model.dart';

/// Notifier gérant l'état du panier (multi-restaurant).
class CartNotifier extends Notifier<CartState> {
  @override
  CartState build() => const CartState();

  /// Ajouter un item au panier. Les items de restaurants différents coexistent.
  void addItem(MenuItem item, String restaurantId, String restaurantName) {
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
            quantity: 1,
            restaurantId: restaurantId,
            restaurantName: restaurantName,
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
