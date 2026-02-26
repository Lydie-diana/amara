import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Client HTTP pour les Convex HTTP Actions.
/// Base URL : https://confident-dachshund-484.eu-west-1.convex.site
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
      'https://confident-dachshund-484.eu-west-1.convex.site';

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

  /// Inscription → retourne {token, userId}
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

  // ─── RESTAURANTS ──────────────────────────────────────────────────────────

  /// Liste des restaurants d'une ville
  Future<List<dynamic>> getRestaurants({String city = 'Abidjan'}) async {
    final data = await get('/api/restaurants', params: {'city': city});
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
}

// ─── Provider ─────────────────────────────────────────────────────────────────

final convexClientProvider = Provider<ConvexClient>((ref) {
  return ConvexClient.instance;
});
