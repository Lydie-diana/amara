import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../l10n/app_localizations.dart';

/// Affiche un popup d'erreur user-friendly.
///
/// Traduit les erreurs techniques (DioException, etc.) en messages
/// compréhensibles par l'utilisateur.
void showErrorDialog(BuildContext context, dynamic error, {String? title}) {
  final l10n = AppLocalizations.of(context);
  final message = _userFriendlyMessage(error, l10n);

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
              title ?? l10n.errorDialogDefaultTitle,
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
                  l10n.errorDialogDismiss,
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
String _userFriendlyMessage(dynamic error, AppLocalizations l10n) {
  final raw = _extractRawMessage(error);

  // Mapping des erreurs backend connues → messages user-friendly
  final mappings = <String, String>{
    'Adresse de livraison requise': l10n.errorDialogDeliveryAddress,
    'deliveryAddress': l10n.errorDialogDeliveryAddress,
    'Restaurant introuvable': l10n.errorDialogRestaurantNotFound,
    'restaurant not found': l10n.errorDialogRestaurantNotFound,
    'Non authentifié': l10n.errorDialogSessionExpired,
    'non authentifié': l10n.errorDialogSessionExpired,
    'Unauthorized': l10n.errorDialogSessionExpired,
    'Token invalide': l10n.errorDialogSessionExpired,
    'déjà noté': l10n.errorDialogAlreadyReviewed,
    'already reviewed': l10n.errorDialogAlreadyReviewed,
    'Transition invalide': l10n.errorDialogInvalidTransition,
    'Invalid state transition': l10n.errorDialogInvalidTransition,
    'panier vide': l10n.errorDialogEmptyCart,
    'Commande introuvable': l10n.errorDialogOrderNotFound,
  };

  // Chercher un match partiel dans les clés
  for (final entry in mappings.entries) {
    if (raw.toLowerCase().contains(entry.key.toLowerCase())) {
      return entry.value;
    }
  }

  // Erreurs réseau génériques
  if (_isNetworkError(error)) {
    return l10n.errorDialogNetwork;
  }

  // Timeout
  if (_isTimeoutError(error)) {
    return l10n.errorDialogTimeout;
  }

  // Fallback : si le message backend est déjà propre (pas de stacktrace, etc.)
  if (raw.isNotEmpty && raw.length < 120 && !raw.contains('Exception')) {
    return raw;
  }

  // Dernier recours
  return l10n.errorDialogFallback;
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
