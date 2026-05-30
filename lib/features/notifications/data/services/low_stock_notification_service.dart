import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../features/inventory/domain/entities/inventory_item.dart';
import 'local_notification_service.dart';

/// Watches the inventory stream and fires a low-stock notification whenever
/// new items fall at or below their [InventoryItem.minStock] threshold.
class LowStockNotificationService {
  LowStockNotificationService._();

  static final LowStockNotificationService instance =
      LowStockNotificationService._();

  /// IDs of items already notified this session — avoids spamming.
  final Set<int> _notifiedIds = <int>{};

  StreamSubscription<List<InventoryItem>>? _subscription;

  void startWatching(Stream<List<InventoryItem>> inventoryStream) {
    _subscription?.cancel();
    _subscription = inventoryStream.listen(_onInventoryUpdate);
  }

  void stopWatching() {
    _subscription?.cancel();
    _subscription = null;
  }

  Future<void> _onInventoryUpdate(List<InventoryItem> items) async {
    if (kIsWeb) return;

    final List<InventoryItem> lowStock = items
        .where((InventoryItem i) => !i.isDeleted && i.isLowStock)
        .toList();

    // Find newly low-stock items not yet notified
    final List<InventoryItem> newLowStock = lowStock
        .where((InventoryItem i) => !_notifiedIds.contains(i.id))
        .toList();

    // Remove items that recovered (quantity > minStock) from notified set
    final Set<int> currentLowIds = lowStock.map((InventoryItem i) => i.id).toSet();
    _notifiedIds.removeWhere((int id) => !currentLowIds.contains(id));

    if (newLowStock.isEmpty) {
      // If no low stock at all, cancel the notification
      if (lowStock.isEmpty) {
        await LocalNotificationService.instance.showLowStockNotification(<String>[]);
      }
      return;
    }

    // Add new IDs to notified set
    for (final InventoryItem item in newLowStock) {
      _notifiedIds.add(item.id);
    }

    // Show grouped notification with ALL current low-stock items
    final List<String> names = lowStock.map((InventoryItem i) => i.name).toList();
    await LocalNotificationService.instance.showLowStockNotification(names);
  }
}
