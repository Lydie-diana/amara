import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_provider.dart';
import '../services/convex_client.dart';

class FavoritesNotifier extends Notifier<Set<String>> {
  static const _storageKey = 'amara_favorite_restaurants';

  @override
  Set<String> build() {
    _loadFromStorage();
    _syncFromConvex();
    return {};
  }

  /// Charge le cache local (affichage instantané)
  Future<void> _loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_storageKey) ?? [];
    if (ids.isNotEmpty) {
      state = ids.toSet();
    }
  }

  /// Sync depuis Convex (source de vérité, si connecté)
  Future<void> _syncFromConvex() async {
    final auth = ref.read(authProvider);
    if (!auth.isAuthenticated) return;
    try {
      final client = ref.read(convexClientProvider);
      final ids = await client.getFavorites();
      state = ids.toSet();
      _saveToStorage(state);
    } catch (e) {
      debugPrint('[Favorites] Sync Convex failed: $e');
    }
  }

  Future<void> _saveToStorage(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_storageKey, ids.toList());
  }

  Future<void> toggleFavorite(String restaurantId) async {
    // Optimistic update local
    final updated = Set<String>.from(state);
    final wasAdded = !updated.contains(restaurantId);
    if (wasAdded) {
      updated.add(restaurantId);
    } else {
      updated.remove(restaurantId);
    }
    state = updated;
    _saveToStorage(updated);

    // Sync avec Convex si connecté
    final auth = ref.read(authProvider);
    if (auth.isAuthenticated) {
      try {
        final client = ref.read(convexClientProvider);
        await client.toggleFavorite(restaurantId);
      } catch (e) {
        debugPrint('[Favorites] Toggle Convex failed: $e');
        // Rollback en cas d'erreur
        if (wasAdded) {
          updated.remove(restaurantId);
        } else {
          updated.add(restaurantId);
        }
        state = Set<String>.from(updated);
        _saveToStorage(updated);
      }
    }
  }

  bool isFavorite(String restaurantId) => state.contains(restaurantId);
}

final favoritesProvider =
    NotifierProvider<FavoritesNotifier, Set<String>>(FavoritesNotifier.new);

/// Provider famille pour vérifier un restaurant spécifique (rebuild granulaire)
final isFavoriteProvider = Provider.family<bool, String>((ref, restaurantId) {
  return ref.watch(favoritesProvider).contains(restaurantId);
});
