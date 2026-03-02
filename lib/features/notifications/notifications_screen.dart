import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/core/constants/app_colors.dart';
import '../../app/core/constants/app_text_styles.dart';
import '../../app/core/l10n/app_localizations.dart';
import '../../app/models/notification_model.dart';
import '../../app/providers/notification_provider.dart';
import '../../app/services/convex_client.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  bool _isSelecting = false;
  final Set<String> _selected = {};

  void _toggleSelection(String id) {
    setState(() {
      if (_selected.contains(id)) {
        _selected.remove(id);
      } else {
        _selected.add(id);
      }
    });
  }

  void _selectAll(List<AppNotification> notifications) {
    setState(() {
      _selected.addAll(notifications.map((n) => n.id));
    });
  }

  void _deselectAll() {
    setState(() => _selected.clear());
  }

  void _enterSelectionMode() {
    setState(() => _isSelecting = true);
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelecting = false;
      _selected.clear();
    });
  }

  Future<void> _markAllAsRead() async {
    HapticFeedback.mediumImpact();
    try {
      final client = ref.read(convexClientProvider);
      await client.markAllNotificationsRead();
      ref.invalidate(notificationsProvider);
      ref.invalidate(unreadNotificationCountProvider);
    } catch (_) {}
  }

  Future<void> _deleteSelected() async {
    if (_selected.isEmpty) return;
    HapticFeedback.mediumImpact();
    final client = ref.read(convexClientProvider);
    for (final id in _selected.toList()) {
      try {
        await client.deleteNotification(id);
      } catch (_) {}
    }
    _exitSelectionMode();
    ref.invalidate(notificationsProvider);
    ref.invalidate(unreadNotificationCountProvider);
  }

  Future<void> _deleteAll(List<AppNotification> notifications) async {
    HapticFeedback.mediumImpact();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(AppLocalizations.of(context).notificationsDeleteAllTitle,
            style:
                AmaraTextStyles.h3.copyWith(fontWeight: FontWeight.w700)),
        content: Text(
          AppLocalizations.of(context).notificationsDeleteAllMessage,
          style: AmaraTextStyles.bodySmall
              .copyWith(color: AmaraColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppLocalizations.of(context).notificationsCancel,
                style: TextStyle(
                    color: AmaraColors.textSecondary,
                    fontWeight: FontWeight.w600)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(AppLocalizations.of(context).notificationsDelete,
                style: TextStyle(
                    color: AmaraColors.error, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final client = ref.read(convexClientProvider);
    for (final notif in notifications) {
      try {
        await client.deleteNotification(notif.id);
      } catch (_) {}
    }
    _exitSelectionMode();
    ref.invalidate(notificationsProvider);
    ref.invalidate(unreadNotificationCountProvider);
  }

  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(notificationsProvider);
    final grouped = ref.watch(groupedNotificationsProvider);

    return Scaffold(
      backgroundColor: AmaraColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: AmaraColors.textPrimary, size: 22),
          onPressed: () {
            if (_isSelecting) {
              _exitSelectionMode();
            } else {
              HapticFeedback.lightImpact();
              Navigator.of(context).pop();
            }
          },
        ),
        centerTitle: true,
        title: Text(
          _isSelecting
              ? AppLocalizations.of(context).notificationsSelectedCount(_selected.length)
              : AppLocalizations.of(context).notificationsTitle,
          style: AmaraTextStyles.labelLarge.copyWith(
            fontWeight: FontWeight.w700,
            color: AmaraColors.textPrimary,
          ),
        ),
        actions: _buildActions(notificationsAsync),
      ),
      body: notificationsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AmaraColors.primary),
        ),
        error: (e, _) => _ErrorState(error: e.toString()),
        data: (notifications) {
          if (notifications.isEmpty) {
            return const _EmptyNotifications();
          }
          return Column(
            children: [
              // Barre d'actions en mode selection
              if (_isSelecting) _buildSelectionBar(notifications),
              // Liste
              Expanded(
                child: _NotificationsList(
                  grouped: grouped,
                  isSelecting: _isSelecting,
                  selected: _selected,
                  onToggle: _toggleSelection,
                  onLongPress: _enterSelectionMode,
                  onDelete: _deleteSingle,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildActions(AsyncValue<List<AppNotification>> async) {
    if (_isSelecting) {
      return [
        IconButton(
          onPressed: _deleteSelected,
          icon: Icon(Icons.delete_outline_rounded,
              color: _selected.isEmpty
                  ? AmaraColors.muted
                  : AmaraColors.error,
              size: 22),
        ),
      ];
    }

    return [
      async.when(
        data: (notifs) {
          if (notifs.isEmpty) return const SizedBox.shrink();
          return PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded,
                color: AmaraColors.textPrimary, size: 22),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            offset: const Offset(0, 48),
            onSelected: (value) {
              switch (value) {
                case 'read_all':
                  _markAllAsRead();
                  break;
                case 'select':
                  _enterSelectionMode();
                  break;
                case 'delete_all':
                  _deleteAll(notifs);
                  break;
              }
            },
            itemBuilder: (_) {
              final l10n = AppLocalizations.of(context);
              return [
              if (notifs.any((n) => !n.isRead))
                PopupMenuItem(
                  value: 'read_all',
                  child: Row(
                    children: [
                      const Icon(Icons.done_all_rounded,
                          color: AmaraColors.primary, size: 20),
                      const SizedBox(width: 12),
                      Text(l10n.notificationsMarkAllRead,
                          style: AmaraTextStyles.bodyMedium.copyWith(
                              color: AmaraColors.textPrimary)),
                    ],
                  ),
                ),
              PopupMenuItem(
                value: 'select',
                child: Row(
                  children: [
                    const Icon(Icons.checklist_rounded,
                        color: AmaraColors.textPrimary, size: 20),
                    const SizedBox(width: 12),
                    Text(l10n.notificationsSelect,
                        style: AmaraTextStyles.bodyMedium
                            .copyWith(color: AmaraColors.textPrimary)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete_all',
                child: Row(
                  children: [
                    const Icon(Icons.delete_sweep_rounded,
                        color: AmaraColors.error, size: 20),
                    const SizedBox(width: 12),
                    Text(l10n.notificationsDeleteAll,
                        style: AmaraTextStyles.bodyMedium
                            .copyWith(color: AmaraColors.error)),
                  ],
                ),
              ),
            ];},
          );
        },
        loading: () => const SizedBox.shrink(),
        error: (_, __) => const SizedBox.shrink(),
      ),
    ];
  }

  Widget _buildSelectionBar(List<AppNotification> notifications) {
    final allSelected = _selected.length == notifications.length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
              color: AmaraColors.divider.withValues(alpha: 0.5),
              width: 0.5),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              if (allSelected) {
                _deselectAll();
              } else {
                _selectAll(notifications);
              }
            },
            child: Row(
              children: [
                Icon(
                  allSelected
                      ? Icons.check_circle_rounded
                      : Icons.circle_outlined,
                  color: allSelected
                      ? AmaraColors.primary
                      : AmaraColors.muted,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  allSelected ? AppLocalizations.of(context).notificationsDeselectAll : AppLocalizations.of(context).notificationsSelectAll,
                  style: AmaraTextStyles.labelSmall.copyWith(
                    color: AmaraColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          if (_selected.isNotEmpty)
            GestureDetector(
              onTap: _deleteSelected,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: AmaraColors.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.delete_outline_rounded,
                        color: AmaraColors.error, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      AppLocalizations.of(context).notificationsDeleteCount(_selected.length),
                      style: AmaraTextStyles.labelSmall.copyWith(
                        color: AmaraColors.error,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _deleteSingle(String id, WidgetRef ref) async {
    HapticFeedback.lightImpact();
    try {
      final client = ref.read(convexClientProvider);
      await client.deleteNotification(id);
      ref.invalidate(notificationsProvider);
      ref.invalidate(unreadNotificationCountProvider);
    } catch (_) {}
  }
}

// ─── Liste groupee ──────────────────────────────────────────────────────────

class _NotificationsList extends StatelessWidget {
  final Map<String, List<AppNotification>> grouped;
  final bool isSelecting;
  final Set<String> selected;
  final ValueChanged<String> onToggle;
  final VoidCallback onLongPress;
  final Future<void> Function(String id, WidgetRef ref) onDelete;

  const _NotificationsList({
    required this.grouped,
    required this.isSelecting,
    required this.selected,
    required this.onToggle,
    required this.onLongPress,
    required this.onDelete,
  });

  static const _sectionOrder = ["Aujourd'hui", 'Cette semaine', 'Plus ancien'];

  static String _localizedSectionTitle(BuildContext context, String key) {
    final l10n = AppLocalizations.of(context);
    return switch (key) {
      "Aujourd'hui" => l10n.notificationsSectionToday,
      'Cette semaine' => l10n.notificationsSectionThisWeek,
      'Plus ancien' => l10n.notificationsSectionOlder,
      _ => key,
    };
  }

  @override
  Widget build(BuildContext context) {
    final sections = _sectionOrder
        .where((key) => grouped.containsKey(key) && grouped[key]!.isNotEmpty)
        .toList();

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 32),
      physics: const BouncingScrollPhysics(),
      itemCount: sections.length,
      itemBuilder: (context, sectionIndex) {
        final sectionTitle = sections[sectionIndex];
        final items = grouped[sectionTitle]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text(
                _localizedSectionTitle(context, sectionTitle),
                style: AmaraTextStyles.labelMedium.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AmaraColors.textPrimary,
                ),
              ),
            ),
            ...items.map((notif) => _NotificationTile(
                  notification: notif,
                  isSelecting: isSelecting,
                  isSelected: selected.contains(notif.id),
                  onToggle: () => onToggle(notif.id),
                  onLongPress: onLongPress,
                  onDelete: onDelete,
                )),
          ],
        );
      },
    );
  }
}

// ─── Tuile notification ─────────────────────────────────────────────────────

class _NotificationTile extends ConsumerWidget {
  final AppNotification notification;
  final bool isSelecting;
  final bool isSelected;
  final VoidCallback onToggle;
  final VoidCallback onLongPress;
  final Future<void> Function(String id, WidgetRef ref) onDelete;

  const _NotificationTile({
    required this.notification,
    required this.isSelecting,
    required this.isSelected,
    required this.onToggle,
    required this.onLongPress,
    required this.onDelete,
  });

  IconData get _icon => switch (notification.type) {
        NotificationType.orderUpdate => Icons.receipt_long_rounded,
        NotificationType.promotion => Icons.local_offer_rounded,
        NotificationType.system => Icons.info_outline_rounded,
      };

  Color get _iconColor => switch (notification.type) {
        NotificationType.orderUpdate => AmaraColors.primary,
        NotificationType.promotion => AmaraColors.warning,
        NotificationType.system => AmaraColors.textSecondary,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tile = InkWell(
      onTap: isSelecting ? onToggle : () => _markAsRead(ref),
      onLongPress: isSelecting ? null : onLongPress,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AmaraColors.primary.withValues(alpha: 0.06)
              : notification.isRead
                  ? Colors.transparent
                  : AmaraColors.primary.withValues(alpha: 0.03),
          border: Border(
            bottom: BorderSide(
              color: AmaraColors.divider.withValues(alpha: 0.5),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Checkbox en mode selection
            if (isSelecting)
              Padding(
                padding: const EdgeInsets.only(right: 12, top: 10),
                child: Icon(
                  isSelected
                      ? Icons.check_circle_rounded
                      : Icons.circle_outlined,
                  color: isSelected
                      ? AmaraColors.primary
                      : AmaraColors.muted,
                  size: 22,
                ),
              ),

            // Icone
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(_icon, color: _iconColor, size: 20),
            ),
            const SizedBox(width: 14),

            // Contenu
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.localizedTitle(l10n),
                    style: AmaraTextStyles.labelMedium.copyWith(
                      fontWeight: notification.isRead
                          ? FontWeight.w500
                          : FontWeight.w700,
                      color: AmaraColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    notification.localizedMessage(l10n),
                    style: AmaraTextStyles.bodySmall.copyWith(
                      color: AmaraColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.localizedTimeAgo(l10n),
                    style: AmaraTextStyles.caption.copyWith(
                      color: AmaraColors.muted,
                    ),
                  ),
                ],
              ),
            ),

            // Dot non-lu (hors mode selection)
            if (!isSelecting && !notification.isRead)
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 8),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AmaraColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    // Swipe to delete seulement hors mode selection
    if (isSelecting) return tile;

    return Dismissible(
      key: ValueKey(notification.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        await onDelete(notification.id, ref);
        return false; // On ne laisse pas Dismissible retirer le widget, le provider rebuild la liste
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        color: AmaraColors.error.withValues(alpha: 0.08),
        child: const Icon(Icons.delete_outline_rounded,
            color: AmaraColors.error, size: 22),
      ),
      child: tile,
    );
  }

  Future<void> _markAsRead(WidgetRef ref) async {
    if (notification.isRead) return;
    HapticFeedback.lightImpact();
    try {
      final client = ref.read(convexClientProvider);
      await client.markNotificationRead(notification.id);
      ref.invalidate(notificationsProvider);
      ref.invalidate(unreadNotificationCountProvider);
    } catch (_) {}
  }
}

// ─── Etat vide ──────────────────────────────────────────────────────────────

class _EmptyNotifications extends StatelessWidget {
  const _EmptyNotifications();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AmaraColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.notifications_none_rounded,
                  size: 36, color: AmaraColors.primary),
            ),
            const SizedBox(height: 20),
            Text(AppLocalizations.of(context).notificationsEmptyTitle,
                style: AmaraTextStyles.h3
                    .copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context).notificationsEmptyMessage,
              style: AmaraTextStyles.bodySmall
                  .copyWith(color: AmaraColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Etat erreur ────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  final String error;
  const _ErrorState({required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded,
                size: 48, color: AmaraColors.muted),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context).notificationsConnectionError, style: AmaraTextStyles.h3),
            const SizedBox(height: 8),
            Text(error,
                style: AmaraTextStyles.bodySmall
                    .copyWith(color: AmaraColors.textSecondary),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
