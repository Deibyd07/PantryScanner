import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../features/inventory/domain/entities/inventory_item.dart';
import '../../../../features/settings/domain/entities/app_language.dart';
import '../../domain/entities/notification_settings.dart';
import 'local_notification_service.dart';

/// Schedules one-time local notifications for each product that is approaching
/// its expiry date, based on [NotificationSettings.globalDaysBefore] (and
/// per-category overrides).
///
/// Notification IDs live in the range 10000–19999 to avoid collisions with
/// the daily reminder (1001) and low-stock alert (2001).
class ExpiryNotificationScheduler {
  ExpiryNotificationScheduler._();

  static final ExpiryNotificationScheduler instance =
      ExpiryNotificationScheduler._();

  StreamSubscription<List<InventoryItem>>? _inventorySub;
  Timer? _debounce;

  NotificationSettings? _settings;
  AppLanguage _lang = AppLanguage.spanish;

  // IDs currently scheduled so we can cancel them before rescheduling
  final Set<int> _scheduledIds = <int>{};

  // ── Public API ──────────────────────────────────────────────────────────────

  void start({
    required Stream<List<InventoryItem>> inventoryStream,
    required NotificationSettings settings,
    AppLanguage lang = AppLanguage.spanish,
  }) {
    _settings = settings;
    _lang = lang;

    _inventorySub?.cancel();
    _inventorySub =
        inventoryStream.listen(_onInventoryUpdate);
  }

  void updateSettings(NotificationSettings settings, AppLanguage lang) {
    _settings = settings;
    _lang = lang;
    // Reschedule will fire on the next inventory stream event, which comes
    // naturally since watchInventory is a broadcast stream that emits on any
    // change. For an immediate reaction we rely on the provider rebuild that
    // calls start() again with the new settings.
  }

  void stop() {
    _debounce?.cancel();
    _inventorySub?.cancel();
    _inventorySub = null;
  }

  // ── Internal ────────────────────────────────────────────────────────────────

  void _onInventoryUpdate(List<InventoryItem> items) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(seconds: 2), () => _reschedule(items));
  }

  Future<void> _reschedule(List<InventoryItem> items) async {
    if (kIsWeb) return;

    // Cancel all previously scheduled expiry notifications
    for (final int id in _scheduledIds) {
      await LocalNotificationService.instance.cancel(id);
    }
    _scheduledIds.clear();

    final NotificationSettings? s = _settings;
    if (s == null || !s.enabled) return;

    final DateTime now = DateTime.now();
    final bool isEn = _lang == AppLanguage.english;

    for (final InventoryItem item in items) {
      if (item.isDeleted || item.expiryDate == null) continue;

      final int daysBefore = _daysForCategory(item.category, s);
      final DateTime alertDate =
          item.expiryDate!.subtract(Duration(days: daysBefore));

      // Fire at the user's preferred time on the alert date
      final DateTime alertTime = DateTime(
        alertDate.year,
        alertDate.month,
        alertDate.day,
        s.preferredHour,
        s.preferredMinute,
      );

      if (alertTime.isAfter(now)) {
        final int notifId = _idForItem(item);
        final String title = isEn
            ? '⏰ ${item.name} expires soon'
            : '⏰ ${item.name} vence pronto';
        final String body = isEn
            ? 'Expires on ${_formatDate(item.expiryDate!)}. Use it or restock.'
            : 'Vence el ${_formatDate(item.expiryDate!)}. ¿Lo usas o lo repones?';

        await LocalNotificationService.instance.scheduleOnce(
          id: notifId,
          title: title,
          body: body,
          when: alertTime,
          payload: 'expiry_${item.syncId}',
        );
        _scheduledIds.add(notifId);
      }
    }

    debugPrint(
        '[PantryScanner] Expiry notifications scheduled: ${_scheduledIds.length}');
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  /// Stable notification ID derived from [item.syncId] hash (range 10000–19999).
  int _idForItem(InventoryItem item) =>
      10000 + (item.syncId.hashCode.abs() % 9999);

  int _daysForCategory(String? category, NotificationSettings s) {
    if (category != null && s.categoryOverrides.containsKey(category)) {
      return s.categoryOverrides[category]!;
    }
    return s.globalDaysBefore;
  }

  String _formatDate(DateTime date) {
    final String d = date.day.toString().padLeft(2, '0');
    final String m = date.month.toString().padLeft(2, '0');
    return '$d/$m/${date.year}';
  }
}
