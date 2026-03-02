import '../core/l10n/app_localizations.dart';

/// Type de notification.
enum NotificationType { orderUpdate, promotion, system }

/// Modele de notification Amara.
class AppNotification {
  final String id;
  final String userId;
  final String title;
  final String message;
  final NotificationType type;
  final bool isRead;
  final int createdAt;

  const AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['_id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      type: _parseType(json['type'] as String?),
      isRead: json['isRead'] as bool? ?? false,
      createdAt: (json['_creationTime'] as num?)?.toInt() ??
          (json['createdAt'] as num?)?.toInt() ??
          0,
    );
  }

  static NotificationType _parseType(String? raw) {
    return switch (raw) {
      'order_update' => NotificationType.orderUpdate,
      'promotion' => NotificationType.promotion,
      'system' => NotificationType.system,
      _ => NotificationType.system,
    };
  }

  /// Titre traduit selon la langue de l'utilisateur.
  String localizedTitle(AppLocalizations l10n) {
    return _notifTranslations[title]?.call(l10n).title ?? title;
  }

  /// Message traduit selon la langue de l'utilisateur.
  String localizedMessage(AppLocalizations l10n) {
    return _notifTranslations[title]?.call(l10n).message ?? message;
  }

  /// Temps relatif localisé.
  String localizedTimeAgo(AppLocalizations l10n) {
    final now = DateTime.now();
    final dt = DateTime.fromMillisecondsSinceEpoch(createdAt);
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) return l10n.timeAgoJustNow;
    if (diff.inMinutes < 60) return l10n.timeAgoMinutes(diff.inMinutes);
    if (diff.inHours < 24) return l10n.timeAgoHours(diff.inHours);
    if (diff.inDays == 1) return l10n.timeAgoYesterday;
    if (diff.inDays < 7) return l10n.timeAgoDays(diff.inDays);
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  /// Cle de regroupement temporel (interne, non affichée directement).
  String get groupKey {
    final now = DateTime.now();
    final dt = DateTime.fromMillisecondsSinceEpoch(createdAt);
    final diff = now.difference(dt);

    if (diff.inDays == 0) return "Aujourd'hui";
    if (diff.inDays < 7) return 'Cette semaine';
    return 'Plus ancien';
  }
}

/// Mapping des titres backend (français) vers les traductions l10n.
typedef _NotifContent = ({String title, String message});

final Map<String, _NotifContent Function(AppLocalizations)> _notifTranslations = {
  'Commande envoyee': (l10n) => (title: l10n.notifOrderSentTitle, message: l10n.notifOrderSentMessage),
  'Commande confirmee': (l10n) => (title: l10n.notifConfirmedTitle, message: l10n.notifConfirmedMessage),
  'En preparation': (l10n) => (title: l10n.notifPreparingTitle, message: l10n.notifPreparingMessage),
  'Commande prete': (l10n) => (title: l10n.notifReadyTitle, message: l10n.notifReadyMessage),
  'Commande recuperee': (l10n) => (title: l10n.notifPickedUpTitle, message: l10n.notifPickedUpMessage),
  'En livraison': (l10n) => (title: l10n.notifDeliveringTitle, message: l10n.notifDeliveringMessage),
  'Commande livree': (l10n) => (title: l10n.notifDeliveredTitle, message: l10n.notifDeliveredMessage),
  'Commande annulee': (l10n) => (title: l10n.notifCancelledTitle, message: l10n.notifCancelledMessage),
};
