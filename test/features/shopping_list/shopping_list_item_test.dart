import 'package:flutter_test/flutter_test.dart';
import 'package:pantry_scanner/features/shopping_list/domain/entities/shopping_list_item.dart';

ShoppingListItem _item({
  int id = 1,
  String syncId = 'test-sync-id',
  String name = 'Leche',
  String? quantity,
  bool isChecked = false,
}) {
  return ShoppingListItem(
    id: id,
    syncId: syncId,
    name: name,
    quantity: quantity,
    isChecked: isChecked,
    createdAt: DateTime(2024),
  );
}

void main() {
  group('ShoppingListItem.copyWith', () {
    test('syncId is preserved when not overridden', () {
      final item = _item(syncId: 'original-uuid');
      final copy = item.copyWith(name: 'Leche entera');
      expect(copy.syncId, 'original-uuid');
      expect(copy.name, 'Leche entera');
    });

    test('syncId can be overridden', () {
      final item = _item(syncId: 'old-uuid');
      final copy = item.copyWith(syncId: 'new-uuid');
      expect(copy.syncId, 'new-uuid');
    });

    test('id is preserved when not overridden', () {
      final item = _item(id: 42);
      expect(item.copyWith(name: 'X').id, 42);
    });

    test('nullable quantity can be cleared via sentinel', () {
      final item = _item(quantity: '2 L');
      final copy = item.copyWith(quantity: null);
      expect(copy.quantity, isNull);
    });

    test('isChecked toggle', () {
      final item = _item(isChecked: false);
      expect(item.copyWith(isChecked: true).isChecked, isTrue);
      expect(item.copyWith(isChecked: false).isChecked, isFalse);
    });

    test('checkedAt can be set', () {
      final now = DateTime(2025, 1, 1);
      final item = _item();
      final copy = item.copyWith(checkedAt: now);
      expect(copy.checkedAt, now);
    });

    test('checkedAt can be cleared', () {
      final item = ShoppingListItem(
        id: 1,
        syncId: 'x',
        name: 'X',
        isChecked: true,
        createdAt: DateTime(2024),
        checkedAt: DateTime(2025),
      );
      final copy = item.copyWith(checkedAt: null);
      expect(copy.checkedAt, isNull);
    });

    test('all unchanged fields survive copyWith', () {
      final now = DateTime(2024, 6, 1);
      final item = ShoppingListItem(
        id: 7,
        syncId: 'abc',
        name: 'Yogur',
        quantity: '500 g',
        sourceRecipeId: 'recipe-1',
        sourceTitle: 'Tarta',
        isChecked: false,
        createdAt: now,
      );
      final copy = item.copyWith(name: 'Yogur griego');
      expect(copy.id, 7);
      expect(copy.syncId, 'abc');
      expect(copy.quantity, '500 g');
      expect(copy.sourceRecipeId, 'recipe-1');
      expect(copy.sourceTitle, 'Tarta');
      expect(copy.isChecked, false);
      expect(copy.createdAt, now);
    });
  });
}
