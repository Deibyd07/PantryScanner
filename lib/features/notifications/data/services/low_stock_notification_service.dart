import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../features/inventory/domain/entities/inventory_item.dart';
import '../../../../features/settings/domain/entities/app_language.dart';
import 'local_notification_service.dart';

/// Watches the inventory stream and fires a grouped low-stock notification
/// whenever new items fall at or below their [InventoryItem.minStock] threshold.
///
/// Notified item IDs are persisted in SharedPreferences with a daily TTL so
/// the notification is not re-fired every time the app restarts (BUG-05).
class LowStockNotificationService {
  LowStockNotificationService._();

  static final LowStockNotificationService instance =
      LowStockNotificationService._();

  static const String _prefKeyIds = 'lowstock_notified_ids';
  static const String _prefKeyDate = 'lowstock_notified_date';

  /// IDs notified today — loaded from SharedPreferences on first use.
  final Set<int> _notifiedIds = <int>{};
  bool _idsLoaded = false;
  AppLanguage _lang = AppLanguage.spanish;

  StreamSubscription<List<InventoryItem>>? _subscription;

  // ── Public API ──────────────────────────────────────────────────────────────

  void setLanguage(AppLanguage lang) => _lang = lang;

  /// Limpia el estado de IDs notificados al cambiar de usuario.
  /// Llamar al inicio de sesión con una cuenta distinta para evitar que los
  /// IDs del usuario anterior supriman notificaciones del nuevo usuario.
  void resetForUser() {
    _notifiedIds.clear();
    _idsLoaded = false;
  }

  void startWatching(Stream<List<InventoryItem>> inventoryStream) {
    _subscription?.cancel();
    _subscription = inventoryStream.listen(_onInventoryUpdate);
  }

  void stopWatching() {
    _subscription?.cancel();
    _subscription = null;
  }

  // ── Internal ────────────────────────────────────────────────────────────────

  Future<void> _onInventoryUpdate(List<InventoryItem> items) async {
    if (kIsWeb) return;

    await _ensureIdsLoaded();

    final List<InventoryItem> lowStock = items
        .where((InventoryItem i) => !i.isDeleted && i.isLowStock)
        .toList();

    // Items that recovered: remove from notified set
    final Set<int> currentLowIds = lowStock.map((i) => i.id).toSet();
    _notifiedIds.removeWhere((int id) => !currentLowIds.contains(id));

    // New items not yet notified today
    final List<InventoryItem> newLowStock =
        lowStock.where((i) => !_notifiedIds.contains(i.id)).toList();

    if (newLowStock.isEmpty) {
      if (lowStock.isEmpty) {
        await LocalNotificationService.instance
            .showLowStockNotification(<String>[], isEn: _lang == AppLanguage.english);
      }
      return;
    }

    for (final InventoryItem item in newLowStock) {
      _notifiedIds.add(item.id);
    }

    await _persistIds();

    final List<String> names = lowStock.map((i) => i.name).toList();
    await LocalNotificationService.instance.showLowStockNotification(
      names,
      isEn: _lang == AppLanguage.english,
    );
  }

  /// Loads persisted IDs from SharedPreferences; clears them if the date
  /// changed (new day → user should be notified again).
  Future<void> _ensureIdsLoaded() async {
    if (_idsLoaded) return;
    _idsLoaded = true;

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String today = _todayKey();
      final String savedDate = prefs.getString(_prefKeyDate) ?? '';

      if (savedDate == today) {
        final List<String> raw = prefs.getStringList(_prefKeyIds) ?? <String>[];
        for (final String s in raw) {
          final int? id = int.tryParse(s);
          if (id != null) _notifiedIds.add(id);
        }
      }
      // If date differs, _notifiedIds stays empty → fresh start for the new day
    } catch (e) {
      debugPrint('[LowStock] Could not load persisted IDs: $e');
    }
  }

  Future<void> _persistIds() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKeyDate, _todayKey());
      await prefs.setStringList(
        _prefKeyIds,
        _notifiedIds.map((id) => id.toString()).toList(),
      );
    } catch (e) {
      debugPrint('[LowStock] Could not persist notified IDs: $e');
    }
  }

  String _todayKey() {
    final DateTime now = DateTime.now();
    return '${now.year}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }
}
