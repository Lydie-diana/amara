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

  /// Temps relatif ("Il y a X min", "Hier", etc.)
  String get timeAgo {
    final now = DateTime.now();
    final dt = DateTime.fromMillisecondsSinceEpoch(createdAt);
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) return "A l'instant";
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours}h';
    if (diff.inDays == 1) return 'Hier';
    if (diff.inDays < 7) return 'Il y a ${diff.inDays} jours';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  /// Cle de regroupement temporel.
  String get groupKey {
    final now = DateTime.now();
    final dt = DateTime.fromMillisecondsSinceEpoch(createdAt);
    final diff = now.difference(dt);

    if (diff.inDays == 0) return "Aujourd'hui";
    if (diff.inDays < 7) return 'Cette semaine';
    return 'Plus ancien';
  }
}
