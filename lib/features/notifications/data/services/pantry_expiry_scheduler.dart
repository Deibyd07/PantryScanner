import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:workmanager/workmanager.dart';

import '../../../../core/db/app_database.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Background task identifier
// ─────────────────────────────────────────────────────────────────────────────
const String pantryExpiryTaskName = 'pantryExpiryCheckTask';
const String pantryExpiryTaskTag  = 'pantry_expiry_check_task';

// ─────────────────────────────────────────────────────────────────────────────
// Workmanager entry-point — must run in a separate isolate so it CANNOT use
// Riverpod or any Flutter widget binding.  Uses AppDatabase directly.
// ─────────────────────────────────────────────────────────────────────────────
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    debugPrint('[PantryScanner-BG] Task fired: $taskName');

    if (taskName != pantryExpiryTaskName) return true;

    try {
      // 1 ─ timezone data (needed for local notifications)
      tz.initializeTimeZones();

      // 2 ─ open shared SQLite database (AppDatabase handles the path)
      final db = await AppDatabase.instance.database;

      // 3 ─ read notification settings; abort if notifications are disabled
      final settingsRows = await db.query(
        'configuracion_notificaciones',
        limit: 1,
      );
      if (settingsRows.isEmpty) return true;

      final settings = settingsRows.first;
      final bool enabled = (settings['enabled'] as int? ?? 1) == 1;
      if (!enabled) {
        debugPrint('[PantryScanner-BG] Notifications disabled — skipping.');
        return true;
      }

      final int globalDaysBefore = settings['global_days_before'] as int? ?? 3;
      final Map<String, int> categoryOverrides =
          _decodeOverrides(settings['category_overrides'] as String? ?? '{}');

      // 4 ─ prune old sent-notification records (housekeeping)
      await AppDatabase.instance.pruneOldSentNotifications();

      // 5 ─ fetch all active (non-deleted) products with an expiry date
      final now = DateTime.now();
      final items = await db.query(
        'inventory_items',
        where: 'is_deleted = 0 AND expiry_date IS NOT NULL',
      );

      // 6 ─ initialise the local notification plugin (background isolate)
      final plugin = FlutterLocalNotificationsPlugin();
      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const initSettings = InitializationSettings(android: androidInit);
      await plugin.initialize(initSettings);

      int notifId = 2000; // base ID for expiry notifications

      for (final row in items) {
        final int itemId       = row['id'] as int;
        final String name      = row['name'] as String? ?? 'Producto';
        final String? category = row['category'] as String?;
        final String? barcode  = row['barcode'] as String?;
        final int expiryMs     = row['expiry_date'] as int;

        final expiryDate = DateTime.fromMillisecondsSinceEpoch(expiryMs);
        final int daysLeft = expiryDate.difference(now).inDays;

        // Determine threshold for this product (category override or global)
        final int threshold = (category != null && categoryOverrides.containsKey(category))
            ? categoryOverrides[category]!
            : globalDaysBefore;

        // Only alert if within the threshold and not already expired
        if (daysLeft < 0 || daysLeft > threshold) continue;

        // 7 ─ deduplication check
        final alreadySent =
            await AppDatabase.instance.wasNotificationSentToday(itemId);
        if (alreadySent) {
          debugPrint('[PantryScanner-BG] Already notified today for $name — skipping.');
          continue;
        }

        // 8 ─ build and show immediate local notification
        final String body = daysLeft == 0
            ? 'Vence HOY — úsalo antes de que expire.'
            : 'Vence en $daysLeft ${daysLeft == 1 ? 'día' : 'días'}.';

        const channel = AndroidNotificationDetails(
          'pantry_expiry_alerts',
          'Alertas de vencimiento',
          channelDescription: 'Notificaciones de productos próximos a vencer',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
        );

        await plugin.show(
          notifId++,
          '⚠️ Expiración: $name',
          body,
          const NotificationDetails(android: channel),
          payload: barcode != null ? 'product_form:$barcode' : null,
        );

        // 9 ─ record the send so we don't duplicate
        await AppDatabase.instance.markNotificationSent(itemId);
        debugPrint('[PantryScanner-BG] Notification sent for $name ($daysLeft days left).');
      }
    } catch (e, st) {
      debugPrint('[PantryScanner-BG] Error in expiry task: $e\n$st');
      return false;
    }

    return true;
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

/// Registers the periodic expiry check with Workmanager.
/// Call once during app startup (non-web only).
Future<void> registerExpiryCheckTask() async {
  await Workmanager().initialize(
    callbackDispatcher,
  );

  await Workmanager().registerPeriodicTask(
    pantryExpiryTaskTag,
    pantryExpiryTaskName,
    frequency: const Duration(hours: 12),
    constraints: Constraints(
      networkType: NetworkType.notRequired,
      requiresBatteryNotLow: false,
    ),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
  );

  debugPrint('[PantryScanner] Expiry check task registered (every 12 h).');
}

Map<String, int> _decodeOverrides(String raw) {
  try {
    final decoded = jsonDecode(raw) as Map<String, dynamic>?;
    if (decoded == null) return {};
    return decoded.map((k, v) => MapEntry(k, (v as num).toInt()));
  } catch (_) {
    return {};
  }
}
