import 'package:flutter/foundation.dart';

import '../../domain/entities/notification_settings.dart';
import '../../domain/services/notification_scheduler.dart';
import 'local_notification_service.dart';

/// Real implementation of [NotificationScheduler] that uses
/// [LocalNotificationService] to schedule / cancel daily notifications
/// based on the user's [NotificationSettings].
///
/// When settings change, this class:
///   1. Cancels all pending notifications.
///   2. If enabled, re-schedules a daily notification at the preferred time.
class RealNotificationScheduler implements NotificationScheduler {
  const RealNotificationScheduler(this._service);

  final LocalNotificationService _service;

  /// Fixed notification ID for the daily expiry-check reminder.
  static const int _dailyReminderId = 1001;

  @override
  Future<void> applySettings(NotificationSettings settings) async {
    // Always cancel existing notifications first so we don't duplicate.
    await _service.cancelAll();

    if (!settings.enabled) {
      debugPrint('[PantryScanner] Notifications disabled — all cancelled.');
      return;
    }

    // Schedule a daily notification at the user's preferred time.
    await _service.scheduleDaily(
      id: _dailyReminderId,
      title: '🔔 Revisa tu despensa',
      body: 'Comprueba si tienes productos próximos a vencer.',
      hour: settings.preferredHour,
      minute: settings.preferredMinute,
      payload: 'daily_expiry_check',
    );

    debugPrint(
      '[PantryScanner] Daily notification scheduled at '
      '${settings.preferredHour.toString().padLeft(2, '0')}:'
      '${settings.preferredMinute.toString().padLeft(2, '0')}',
    );
  }
}
