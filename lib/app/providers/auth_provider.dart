import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/convex_client.dart';

// ─── Modèle utilisateur ───────────────────────────────────────────────────────

class AppUser {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String? imageUrl;
  final int? createdAt;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.imageUrl,
    this.createdAt,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      role: json['role'] as String? ?? 'client',
      imageUrl: json['imageUrl'] as String?,
      createdAt: (json['createdAt'] as num?)?.toInt(),
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

// ─── Token storage avec fallback SharedPreferences ───────────────────────────

class _TokenStorage {
  static const _tokenKey = 'amara_session_token';
  static const _fallbackKey = 'amara_session_token_fb';

  final _secure = const FlutterSecureStorage(
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  bool _usesFallback = false;

  Future<String?> read() async {
    try {
      return await _secure.read(key: _tokenKey);
    } catch (e) {
      debugPrint('[TokenStorage] Keychain read failed, using fallback: $e');
      _usesFallback = true;
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_fallbackKey);
    }
  }

  Future<void> write(String token) async {
    try {
      await _secure.write(key: _tokenKey, value: token);
    } catch (e) {
      debugPrint('[TokenStorage] Keychain write failed, using fallback: $e');
      _usesFallback = true;
    }
    if (_usesFallback) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_fallbackKey, token);
    }
  }

  Future<void> delete() async {
    try {
      await _secure.delete(key: _tokenKey);
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_fallbackKey);
  }
}

// ─── Notifier ─────────────────────────────────────────────────────────────────

class AuthNotifier extends Notifier<AuthState> {
  final _storage = _TokenStorage();

  @override
  AuthState build() {
    _init();
    return const AuthState(status: AuthStatus.loading);
  }

  /// Initialise la session depuis le stockage sécurisé
  Future<void> _init() async {
    try {
      final token = await _storage.read();
      if (token == null) {
        state = const AuthState(status: AuthStatus.unauthenticated);
        return;
      }
      // Revalider le token auprès de Convex
      final client = ref.read(convexClientProvider);
      client.setToken(token);
      final userData = await client.me();
      if (userData == null) {
        await _storage.delete();
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

  /// Inscription email/password → retourne pendingUserId si succès, null si erreur
  Future<String?> signup({
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
      final pendingUserId = result['pendingUserId'] as String;
      state = const AuthState(status: AuthStatus.unauthenticated);
      return pendingUserId;
    } catch (e) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        error: _extractError(e),
      );
      return null;
    }
  }

  /// Vérification OTP email → connecte l'utilisateur si succès
  Future<void> verifyEmail({
    required String pendingUserId,
    required String code,
  }) async {
    state = const AuthState(status: AuthStatus.loading);
    try {
      final client = ref.read(convexClientProvider);
      final result = await client.verifyEmail(
        pendingUserId: pendingUserId,
        code: code,
      );
      final token = result['token'] as String;
      await _storage.write(token);
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
      rethrow;
    }
  }

  /// Renvoi du code OTP
  Future<void> resendVerification(String pendingUserId) async {
    final client = ref.read(convexClientProvider);
    await client.resendVerification(pendingUserId: pendingUserId);
  }

  // ─── Mot de passe oublié ──────────────────────────────────────────────────

  /// Demande de réinitialisation de mot de passe
  Future<String?> forgotPassword({required String email}) async {
    try {
      final client = ref.read(convexClientProvider);
      await client.forgotPassword(email: email);
      return null;
    } catch (e) {
      return _extractError(e);
    }
  }

  /// Vérification du code de réinitialisation
  Future<String?> verifyResetCode({
    required String email,
    required String code,
  }) async {
    try {
      final client = ref.read(convexClientProvider);
      await client.verifyResetCode(email: email, code: code);
      return null;
    } catch (e) {
      return _extractError(e);
    }
  }

  /// Réinitialisation du mot de passe
  Future<String?> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    try {
      final client = ref.read(convexClientProvider);
      await client.resetPassword(
        email: email,
        code: code,
        newPassword: newPassword,
      );
      return null;
    } catch (e) {
      return _extractError(e);
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
      await _storage.write(token);
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

  /// Mise à jour du profil
  Future<String?> updateProfile({String? name, String? phone, String? imageUrl}) async {
    try {
      final client = ref.read(convexClientProvider);
      final userData = await client.updateProfile(
        name: name,
        phone: phone,
        imageUrl: imageUrl,
      );
      state = state.copyWith(user: AppUser.fromJson(userData));
      return null;
    } catch (e) {
      return _extractError(e);
    }
  }

  /// Déconnexion
  Future<void> logout() async {
    try {
      final client = ref.read(convexClientProvider);
      await client.logout();
    } catch (_) {}
    await _storage.delete();
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
