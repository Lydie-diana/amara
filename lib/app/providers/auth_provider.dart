import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/convex_client.dart';

// ─── Modèle utilisateur ───────────────────────────────────────────────────────

class AppUser {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String? imageUrl;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.imageUrl,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      role: json['role'] as String? ?? 'client',
      imageUrl: json['imageUrl'] as String?,
    );
  }
}

// ─── État auth ────────────────────────────────────────────────────────────────

enum AuthStatus { loading, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final AppUser? user;
  final String? error;

  const AuthState({
    this.status = AuthStatus.loading,
    this.user,
    this.error,
  });

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.loading;

  AuthState copyWith({AuthStatus? status, AppUser? user, String? error}) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error,
    );
  }
}

// ─── Notifier ─────────────────────────────────────────────────────────────────

class AuthNotifier extends Notifier<AuthState> {
  static const _tokenKey = 'amara_session_token';
  final _storage = const FlutterSecureStorage();

  @override
  AuthState build() {
    _init();
    return const AuthState(status: AuthStatus.loading);
  }

  /// Initialise la session depuis le stockage sécurisé
  Future<void> _init() async {
    try {
      final token = await _storage.read(key: _tokenKey);
      if (token == null) {
        state = const AuthState(status: AuthStatus.unauthenticated);
        return;
      }
      // Revalider le token auprès de Convex
      final client = ref.read(convexClientProvider);
      client.setToken(token);
      final userData = await client.me();
      if (userData == null) {
        await _storage.delete(key: _tokenKey);
        client.setToken(null);
        state = const AuthState(status: AuthStatus.unauthenticated);
        return;
      }
      state = AuthState(
        status: AuthStatus.authenticated,
        user: AppUser.fromJson(userData),
      );
    } catch (_) {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  /// Inscription email/password
  Future<void> signup({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    state = const AuthState(status: AuthStatus.loading);
    try {
      final client = ref.read(convexClientProvider);
      final result = await client.signup(
        name: name,
        email: email,
        phone: phone,
        password: password,
      );
      final token = result['token'] as String;
      await _storage.write(key: _tokenKey, value: token);
      client.setToken(token);
      final userData = await client.me();
      state = AuthState(
        status: AuthStatus.authenticated,
        user: userData != null ? AppUser.fromJson(userData) : null,
      );
    } catch (e) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        error: _extractError(e),
      );
    }
  }

  /// Connexion email/password
  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const AuthState(status: AuthStatus.loading);
    try {
      final client = ref.read(convexClientProvider);
      final result = await client.login(email: email, password: password);
      final token = result['token'] as String;
      await _storage.write(key: _tokenKey, value: token);
      client.setToken(token);
      final userData = await client.me();
      state = AuthState(
        status: AuthStatus.authenticated,
        user: userData != null ? AppUser.fromJson(userData) : null,
      );
    } catch (e) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        error: _extractError(e),
      );
    }
  }

  /// Déconnexion
  Future<void> logout() async {
    try {
      final client = ref.read(convexClientProvider);
      await client.logout();
    } catch (_) {}
    await _storage.delete(key: _tokenKey);
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  String _extractError(Object e) {
    if (e is Exception) {
      final msg = e.toString();
      // DioException contient le message du backend
      if (msg.contains('DioException')) {
        final match = RegExp(r'error: (.+)').firstMatch(msg);
        return match?.group(1) ?? 'Erreur réseau';
      }
      return msg.replaceFirst('Exception: ', '');
    }
    return e.toString();
  }
}

// ─── Provider ─────────────────────────────────────────────────────────────────

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

/// Accès direct à l'utilisateur courant (null si non connecté)
final currentUserProvider = Provider<AppUser?>((ref) {
  return ref.watch(authProvider).user;
});
