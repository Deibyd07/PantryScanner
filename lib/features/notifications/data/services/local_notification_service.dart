import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

/// Singleton wrapper around [FlutterLocalNotificationsPlugin].
///
/// Provides a thin API for initializing the plugin, requesting permissions,
/// scheduling daily repeating notifications, and cancelling them.
class LocalNotificationService {
  LocalNotificationService._();

  static final LocalNotificationService instance =
      LocalNotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Android notification channel for expiry alerts.
  static const String _channelId = 'pantry_expiry_alerts';
  static const String _channelName = 'Alertas de vencimiento';
  static const String _channelDesc =
      'Notificaciones de productos próximos a vencer';

  // ── Initialization ──────────────────────────────────────────────────────────

  /// Must be called once during app startup (before any scheduling).
  Future<void> init() async {
    if (_initialized) return;

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    _initialized = true;
  }

  /// Called when the user taps a notification.
  static void _onNotificationTap(NotificationResponse response) {
    // Deep-link handling will be added in HU-14.
    debugPrint('[PantryScanner] Notification tapped: ${response.payload}');
  }

  // ── Permissions ─────────────────────────────────────────────────────────────

  /// Requests the POST_NOTIFICATIONS runtime permission on Android 13+.
  /// Returns `true` if granted, `false` otherwise.
  Future<bool> requestPermission() async {
    if (kIsWeb) return false;

    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? android =
          _plugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (android == null) return false;
      final bool? granted = await android.requestNotificationsPermission();
      return granted ?? false;
    }

    if (Platform.isIOS) {
      final IOSFlutterLocalNotificationsPlugin? ios =
          _plugin.resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      if (ios == null) return false;
      final bool? granted = await ios.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return false;
  }

  // ── Scheduling ──────────────────────────────────────────────────────────────

  /// Notification details shared across all scheduled alerts.
  NotificationDetails get _details {
    const AndroidNotificationDetails android = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const DarwinNotificationDetails ios = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    return const NotificationDetails(android: android, iOS: ios);
  }

  /// Schedules a **daily repeating** notification at the given [hour]:[minute].
  ///
  /// Uses [matchDateTimeComponents: DateTimeComponents.time] so the
  /// notification fires every day at the specified time.
  Future<void> scheduleDaily({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    String? payload,
  }) async {
    _ensureInitialized();

    final tz.TZDateTime scheduledTime = _nextInstanceOfTime(hour, minute);

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduledTime,
      _details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: payload,
    );
  }

  /// Cancels the notification with the given [id].
  Future<void> cancel(int id) async {
    _ensureInitialized();
    await _plugin.cancel(id);
  }

  /// Cancels all pending notifications.
  Future<void> cancelAll() async {
    _ensureInitialized();
    await _plugin.cancelAll();
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  void _ensureInitialized() {
    if (!_initialized) {
      throw StateError(
        'LocalNotificationService has not been initialized. '
        'Call init() before using any other method.',
      );
    }
  }

  /// Returns the next [tz.TZDateTime] instance of [hour]:[minute].
  /// If today's time has already passed, it returns tomorrow's.
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
