import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

/// Affiche un popup d'erreur user-friendly.
///
/// Traduit les erreurs techniques (DioException, etc.) en messages
/// compréhensibles par l'utilisateur.
void showErrorDialog(BuildContext context, dynamic error, {String? title}) {
  final message = _userFriendlyMessage(error);

  showDialog(
    context: context,
    builder: (ctx) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icône
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AmaraColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: AmaraColors.error,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),

            // Titre
            Text(
              title ?? 'Oups !',
              style: AmaraTextStyles.h3.copyWith(
                color: AmaraColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),

            // Message
            Text(
              message,
              style: AmaraTextStyles.bodyMedium.copyWith(
                color: AmaraColors.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Bouton
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AmaraColors.primary,
                  foregroundColor: AmaraColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Compris',
                  style: AmaraTextStyles.button.copyWith(
                    color: AmaraColors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Convertit une erreur technique en message lisible.
String _userFriendlyMessage(dynamic error) {
  final raw = _extractRawMessage(error);

  // Mapping des erreurs backend connues → messages user-friendly
  final mappings = <String, String>{
    'Adresse de livraison requise':
        'Veuillez renseigner votre adresse de livraison avant de commander.',
    'deliveryAddress':
        'Veuillez renseigner votre adresse de livraison avant de commander.',
    'Restaurant introuvable':
        'Ce restaurant n\'est plus disponible. Veuillez réessayer.',
    'restaurant not found':
        'Ce restaurant n\'est plus disponible. Veuillez réessayer.',
    'Non authentifié':
        'Votre session a expiré. Veuillez vous reconnecter.',
    'non authentifié':
        'Votre session a expiré. Veuillez vous reconnecter.',
    'Unauthorized':
        'Votre session a expiré. Veuillez vous reconnecter.',
    'Token invalide':
        'Votre session a expiré. Veuillez vous reconnecter.',
    'déjà noté':
        'Vous avez déjà donné votre avis sur cette commande.',
    'already reviewed':
        'Vous avez déjà donné votre avis sur cette commande.',
    'Transition invalide':
        'Cette action n\'est plus disponible. Rafraîchissez la page.',
    'Invalid state transition':
        'Cette action n\'est plus disponible. Rafraîchissez la page.',
    'panier vide':
        'Votre panier est vide. Ajoutez des articles avant de commander.',
    'Commande introuvable':
        'Cette commande est introuvable. Elle a peut-être été supprimée.',
  };

  // Chercher un match partiel dans les clés
  for (final entry in mappings.entries) {
    if (raw.toLowerCase().contains(entry.key.toLowerCase())) {
      return entry.value;
    }
  }

  // Erreurs réseau génériques
  if (_isNetworkError(error)) {
    return 'Impossible de se connecter au serveur. '
        'Vérifiez votre connexion internet et réessayez.';
  }

  // Timeout
  if (_isTimeoutError(error)) {
    return 'La connexion a pris trop de temps. '
        'Vérifiez votre connexion internet et réessayez.';
  }

  // Fallback : si le message backend est déjà propre (pas de stacktrace, etc.)
  if (raw.isNotEmpty && raw.length < 120 && !raw.contains('Exception')) {
    return raw;
  }

  // Dernier recours
  return 'Une erreur est survenue. Veuillez réessayer.';
}

String _extractRawMessage(dynamic error) {
  if (error is DioException) {
    // Le message extrait par notre intercepteur Convex
    final convexError = error.error;
    if (convexError is String && convexError.isNotEmpty) {
      return convexError;
    }
    // Fallback : chercher dans response.data
    final data = error.response?.data;
    if (data is Map && data['error'] is String) {
      return data['error'] as String;
    }
    return '';
  }
  if (error is Exception) {
    return error.toString().replaceFirst('Exception: ', '');
  }
  return error?.toString() ?? '';
}

bool _isNetworkError(dynamic error) {
  if (error is DioException) {
    return error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.unknown;
  }
  final s = error.toString().toLowerCase();
  return s.contains('socketexception') ||
      s.contains('connection refused') ||
      s.contains('network');
}

bool _isTimeoutError(dynamic error) {
  if (error is DioException) {
    return error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout;
  }
  return error.toString().toLowerCase().contains('timeout');
}
