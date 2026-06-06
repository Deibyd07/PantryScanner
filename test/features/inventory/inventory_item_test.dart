import 'package:flutter_test/flutter_test.dart';
import 'package:pantry_scanner/features/inventory/domain/entities/inventory_item.dart';

InventoryItem _item({
  int id = 1,
  String name = 'Leche',
  int quantity = 5,
  DateTime? expiryDate,
  int minStock = 1,
}) {
  final DateTime now = DateTime.now();
  return InventoryItem(
    id: id,
    syncId: 'sync-$id',
    barcode: '0000000000000',
    name: name,
    brand: null,
    category: null,
    quantity: quantity,
    createdAt: now,
    updatedAt: now,
    expiryDate: expiryDate,
    minStock: minStock,
  );
}

void main() {
  group('InventoryItem.status', () {
    test('outOfStock when quantity is 0', () {
      expect(_item(quantity: 0).status, ProductStatus.outOfStock);
    });

    test('outOfStock overrides expiry — expired product with qty 0 is still outOfStock', () {
      final pastDate = DateTime.now().subtract(const Duration(days: 2));
      expect(_item(quantity: 0, expiryDate: pastDate).status, ProductStatus.outOfStock);
    });

    test('normal when quantity > 0 and no expiry date', () {
      expect(_item(quantity: 3).status, ProductStatus.normal);
    });

    test('expired when expiryDate is in the past', () {
      final pastDate = DateTime.now().subtract(const Duration(days: 2));
      expect(_item(expiryDate: pastDate).status, ProductStatus.expired);
    });

    test('expired when expiryDate is today (same calendar day)', () {
      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);
      expect(_item(expiryDate: todayStart).status, ProductStatus.expired);
    });

    test('expiringSoon when expiryDate is 1 day ahead', () {
      final soon = DateTime.now().add(const Duration(hours: 30));
      expect(_item(expiryDate: soon).status, ProductStatus.expiringSoon);
    });

    test('expiringSoon when expiryDate is 2 days ahead', () {
      final soon = DateTime.now().add(const Duration(hours: 54));
      expect(_item(expiryDate: soon).status, ProductStatus.expiringSoon);
    });

    test('normal when expiryDate is more than 3 days ahead', () {
      final far = DateTime.now().add(const Duration(days: 7));
      expect(_item(expiryDate: far).status, ProductStatus.normal);
    });
  });

  group('InventoryItem.isLowStock', () {
    test('false when quantity is 0 (outOfStock, not lowStock)', () {
      expect(_item(quantity: 0, minStock: 1).isLowStock, isFalse);
    });

    test('true when quantity equals minStock', () {
      expect(_item(quantity: 1, minStock: 1).isLowStock, isTrue);
    });

    test('true when quantity is below minStock', () {
      expect(_item(quantity: 2, minStock: 3).isLowStock, isTrue);
    });

    test('false when quantity is above minStock', () {
      expect(_item(quantity: 5, minStock: 3).isLowStock, isFalse);
    });

    test('true at minStock boundary of 5', () {
      expect(_item(quantity: 5, minStock: 5).isLowStock, isTrue);
    });
  });

  group('InventoryItem.copyWith', () {
    test('all unchanged fields survive copyWith', () {
      final now = DateTime(2025, 1, 1);
      final expiry = DateTime(2025, 6, 1);
      final item = InventoryItem(
        id: 42,
        syncId: 'uuid-abc',
        barcode: '7501234567890',
        name: 'Yogur',
        brand: 'Alpina',
        category: 'Lácteos',
        quantity: 3,
        expiryDate: expiry,
        imageUrl: 'https://cdn.example.com/img.jpg',
        notes: 'Sin azúcar',
        createdAt: now,
        updatedAt: now,
        minStock: 2,
      );
      final copy = item.copyWith(name: 'Yogur griego');
      expect(copy.id, 42);
      expect(copy.syncId, 'uuid-abc');
      expect(copy.barcode, '7501234567890');
      expect(copy.brand, 'Alpina');
      expect(copy.category, 'Lácteos');
      expect(copy.quantity, 3);
      expect(copy.expiryDate, expiry);
      expect(copy.imageUrl, 'https://cdn.example.com/img.jpg');
      expect(copy.notes, 'Sin azúcar');
      expect(copy.createdAt, now);
      expect(copy.minStock, 2);
      expect(copy.isDeleted, isFalse);
    });

    test('quantity can be updated', () {
      final item = _item(quantity: 5);
      expect(item.copyWith(quantity: 2).quantity, 2);
    });

    test('isDeleted can be set to true', () {
      final item = _item();
      expect(item.copyWith(isDeleted: true).isDeleted, isTrue);
    });

    test('minStock can be updated', () {
      final item = _item(minStock: 1);
      expect(item.copyWith(minStock: 5).minStock, 5);
    });
  });
}
