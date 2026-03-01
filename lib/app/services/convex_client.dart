import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Client HTTP pour les Convex HTTP Actions.
/// Base URL : https://disciplined-kudu-592.eu-west-1.convex.site
class ConvexClient {
  ConvexClient._() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    );
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (e, handler) {
          // Extraire le message d'erreur du body JSON Convex
          final data = e.response?.data;
          if (data is Map && data['error'] != null) {
            handler.reject(
              DioException(
                requestOptions: e.requestOptions,
                response: e.response,
                error: data['error'],
                type: DioExceptionType.badResponse,
              ),
            );
            return;
          }
          handler.next(e);
        },
      ),
    );
  }

  static final ConvexClient instance = ConvexClient._();

  static const String _baseUrl =
      'https://disciplined-kudu-592.eu-west-1.convex.site';

  late final Dio _dio;

  // ─── Token d'authentification (mis à jour après login) ───────────────────

  String? _authToken;

  void setToken(String? token) {
    _authToken = token;
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    } else {
      _dio.options.headers.remove('Authorization');
    }
  }

  String? get authToken => _authToken;

  // ─── Helpers HTTP ─────────────────────────────────────────────────────────

  Future<dynamic> get(String path, {Map<String, dynamic>? params}) async {
    final response = await _dio.get(path, queryParameters: params);
    return response.data;
  }

  Future<dynamic> post(String path, {Map<String, dynamic>? body}) async {
    final response = await _dio.post(path, data: jsonEncode(body ?? {}));
    return response.data;
  }

  // ─── AUTH ─────────────────────────────────────────────────────────────────

  /// Inscription → retourne {pendingUserId, email} (vérification email requise)
  Future<Map<String, dynamic>> signup({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final data = await post('/api/auth/signup', body: {
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
    });
    return Map<String, dynamic>.from(data as Map);
  }

  /// Vérifier le code OTP email → retourne {token, userId}
  Future<Map<String, dynamic>> verifyEmail({
    required String pendingUserId,
    required String code,
  }) async {
    final data = await post('/api/auth/verify-email', body: {
      'pendingUserId': pendingUserId,
      'code': code,
    });
    return Map<String, dynamic>.from(data as Map);
  }

  /// Renvoyer le code de vérification
  Future<void> resendVerification({required String pendingUserId}) async {
    await post('/api/auth/resend-verification', body: {
      'pendingUserId': pendingUserId,
    });
  }

  /// Connexion → retourne {token, userId}
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final data = await post('/api/auth/login', body: {
      'email': email,
      'password': password,
    });
    return Map<String, dynamic>.from(data as Map);
  }

  /// Déconnexion
  Future<void> logout() async {
    if (_authToken == null) return;
    await post('/api/auth/logout', body: {'token': _authToken});
    setToken(null);
  }

  /// Récupère l'utilisateur courant via le token
  Future<Map<String, dynamic>?> me() async {
    if (_authToken == null) return null;
    try {
      final data = await get('/api/auth/me');
      return Map<String, dynamic>.from(data as Map);
    } catch (_) {
      return null;
    }
  }

  /// Mise à jour du profil utilisateur
  Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? phone,
    String? imageUrl,
  }) async {
    final data = await post('/api/auth/update-profile', body: {
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (imageUrl != null) 'imageUrl': imageUrl,
    });
    return Map<String, dynamic>.from(data as Map);
  }

  // ─── FAVORIS ─────────────────────────────────────────────────────────────

  /// Liste des IDs de restaurants favoris
  Future<List<String>> getFavorites() async {
    final data = await get('/api/favorites');
    return List<String>.from(data as List);
  }

  /// Toggle favori → retourne {isFavorite: bool}
  Future<bool> toggleFavorite(String restaurantId) async {
    final data = await post('/api/favorites/toggle', body: {
      'restaurantId': restaurantId,
    });
    final result = Map<String, dynamic>.from(data as Map);
    return result['isFavorite'] as bool;
  }

  // ─── PROMOTIONS ──────────────────────────────────────────────────────────

  /// Banners promotionnels actifs (optionnel: filtrés par ville)
  Future<List<dynamic>> getPromotions({String? city}) async {
    final data = await get('/api/promotions', params: {
      if (city != null) 'city': city,
    });
    return List<dynamic>.from(data as List);
  }

  // ─── CATÉGORIES CUISINE ─────────────────────────────────────────────────

  /// Catégories cuisine actives
  Future<List<dynamic>> getCategories() async {
    final data = await get('/api/categories');
    return List<dynamic>.from(data as List);
  }

  // ─── SUGGESTIONS D'ADRESSES ──────────────────────────────────────────────

  /// Suggestions d'adresses (optionnel: filtrées par ville)
  Future<List<dynamic>> getAddressSuggestions({String? city}) async {
    final data = await get('/api/addresses', params: {
      if (city != null) 'city': city,
    });
    return List<dynamic>.from(data as List);
  }

  // ─── RESTAURANTS ──────────────────────────────────────────────────────────

  /// Liste des restaurants d'une ville
  Future<List<dynamic>> getRestaurants({String city = 'Abidjan'}) async {
    final data = await get('/api/restaurants', params: {'city': city});
    return List<dynamic>.from(data as List);
  }

  /// Liste des restaurants à proximité d'une position GPS
  Future<List<dynamic>> getRestaurantsNearby({
    required double latitude,
    required double longitude,
    double radiusKm = 15,
  }) async {
    final data = await get('/api/restaurants/nearby', params: {
      'lat': latitude.toString(),
      'lng': longitude.toString(),
      'radius': radiusKm.toString(),
    });
    return List<dynamic>.from(data as List);
  }

  /// Détail d'un restaurant par ID
  Future<Map<String, dynamic>> getRestaurant(String id) async {
    final data = await get('/api/restaurant', params: {'id': id});
    return Map<String, dynamic>.from(data as Map);
  }

  // ─── MENU ─────────────────────────────────────────────────────────────────

  /// Menu items d'un restaurant
  Future<List<dynamic>> getMenu(String restaurantId) async {
    final data =
        await get('/api/menu', params: {'restaurantId': restaurantId});
    return List<dynamic>.from(data as List);
  }

  // ─── COMMANDES ────────────────────────────────────────────────────────────

  /// Mes commandes (client connecté)
  Future<List<dynamic>> getMyOrders() async {
    final data = await get('/api/orders');
    return List<dynamic>.from(data as List);
  }

  /// Créer une commande
  Future<String> createOrder({
    required String restaurantId,
    required List<Map<String, dynamic>> items,
    required String deliveryAddress,
    required String paymentMethod,
    double? deliveryLatitude,
    double? deliveryLongitude,
    String? clientNote,
  }) async {
    final data = await post('/api/orders', body: {
      'restaurantId': restaurantId,
      'items': items,
      'deliveryAddress': deliveryAddress,
      'deliveryLatitude': deliveryLatitude ?? 5.3484,
      'deliveryLongitude': deliveryLongitude ?? -4.0083,
      'paymentMethod': paymentMethod,
      if (clientNote != null) 'clientNote': clientNote,
    });
    final result = Map<String, dynamic>.from(data as Map);
    return result['orderId'] as String;
  }

  /// Détail d'une commande
  Future<Map<String, dynamic>> getOrder(String orderId) async {
    final data = await get('/api/order', params: {'id': orderId});
    return Map<String, dynamic>.from(data as Map);
  }

  /// Annuler une commande (client, seulement si pending)
  Future<void> cancelOrder(String orderId, {String? reason}) async {
    await post('/api/order/status', body: {
      'orderId': orderId,
      'status': 'cancelled',
      if (reason != null) 'reason': reason,
    });
  }

  // ─── TRACKING LIVREUR ───────────────────────────────────────────────────────

  /// Position GPS du livreur en temps réel
  Future<Map<String, dynamic>?> getDriverLocation(String livreurId) async {
    try {
      final data = await get('/api/driver/location/track', params: {
        'livreurId': livreurId,
      });
      if (data == null) return null;
      return Map<String, dynamic>.from(data as Map);
    } catch (_) {
      return null;
    }
  }

  // ─── AVIS / REVIEWS ────────────────────────────────────────────────────────

  /// Soumettre un avis (restaurant + livreur)
  Future<Map<String, dynamic>> submitReview({
    required String orderId,
    required int rating,
    int? driverRating,
    String? comment,
  }) async {
    final data = await post('/api/review', body: {
      'orderId': orderId,
      'rating': rating,
      if (driverRating != null) 'driverRating': driverRating,
      if (comment != null && comment.trim().isNotEmpty) 'comment': comment.trim(),
    });
    return Map<String, dynamic>.from(data as Map);
  }

  /// Vérifier si une commande a déjà un avis
  Future<bool> hasReview(String orderId) async {
    try {
      final data = await get('/api/review/check', params: {'orderId': orderId});
      return (data as Map)['hasReview'] == true;
    } catch (_) {
      return false;
    }
  }

}

// ─── Provider ─────────────────────────────────────────────────────────────────

final convexClientProvider = Provider<ConvexClient>((ref) {
  return ConvexClient.instance;
});
