import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/notification_model.dart';
import '../services/convex_client.dart';
import 'auth_provider.dart';

// ─── Provider : liste des notifications (fetch-on-open) ─────────────────────

final notificationsProvider =
    FutureProvider.autoDispose<List<AppNotification>>((ref) async {
  final auth = ref.watch(authProvider);
  if (!auth.isAuthenticated) return [];

  final client = ref.read(convexClientProvider);
  try {
    final data = await client.getNotifications();
    return data.map((json) => AppNotification.fromJson(json)).toList();
  } catch (e) {
    debugPrint('[Notifications] Fetch failed: $e');
    return [];
  }
});

// ─── Provider : nombre de non-lues (polling 15s pour badge temps réel) ──────

final unreadNotificationCountProvider =
    StreamProvider<int>((ref) async* {
  final auth = ref.watch(authProvider);
  if (!auth.isAuthenticated) {
    yield 0;
    return;
  }

  final client = ref.read(convexClientProvider);

  // Emission immediate
  try {
    yield await client.getUnreadNotificationCount();
  } catch (_) {
    yield 0;
  }

  // Polling toutes les 15 secondes
  await for (final _ in Stream.periodic(const Duration(seconds: 15))) {
    try {
      yield await client.getUnreadNotificationCount();
    } catch (_) {
      // Garder la valeur precedente
    }
  }
});

// ─── Provider : notifications groupees par section temporelle ───────────────

final groupedNotificationsProvider =
    Provider.autoDispose<Map<String, List<AppNotification>>>((ref) {
  final notificationsAsync = ref.watch(notificationsProvider);
  return notificationsAsync.when(
    data: (notifications) {
      final grouped = <String, List<AppNotification>>{};
      for (final notif in notifications) {
        grouped.putIfAbsent(notif.groupKey, () => []);
        grouped[notif.groupKey]!.add(notif);
      }
      return grouped;
    },
    loading: () => {},
    error: (_, __) => {},
  );
});
