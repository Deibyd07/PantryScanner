import 'package:flutter_test/flutter_test.dart';
import 'package:pantry_scanner/features/inventory/domain/entities/inventory_item.dart';
import 'package:pantry_scanner/features/inventory/domain/entities/sort_preference.dart';
import 'package:pantry_scanner/features/inventory/domain/usecases/sort_inventory_items_usecase.dart';

InventoryItem _item({
  required int id,
  required String name,
  int quantity = 5,
  DateTime? expiryDate,
  String? category,
}) {
  final DateTime now = DateTime.now();
  return InventoryItem(
    id: id,
    syncId: 'sync-$id',
    barcode: '',
    name: name,
    brand: null,
    category: category,
    quantity: quantity,
    createdAt: now,
    updatedAt: now,
    expiryDate: expiryDate,
  );
}

void main() {
  const SortInventoryItemsUseCase useCase = SortInventoryItemsUseCase();

  final DateTime d1 = DateTime(2025, 1, 10);
  final DateTime d2 = DateTime(2025, 3, 20);
  final DateTime d3 = DateTime(2025, 8, 5);

  final InventoryItem itemA = _item(id: 1, name: 'Arroz', quantity: 3, expiryDate: d2, category: 'Granos');
  final InventoryItem itemB = _item(id: 2, name: 'Leche', quantity: 1, expiryDate: d1, category: 'Lácteos');
  final InventoryItem itemC = _item(id: 3, name: 'Yogur', quantity: 5, expiryDate: d3, category: 'Lácteos');
  final InventoryItem itemNoExpiry = _item(id: 4, name: 'Sal', quantity: 10, category: 'Condimentos');
  final InventoryItem itemNoCat = _item(id: 5, name: 'Mantequilla', quantity: 2);

  final List<InventoryItem> items = <InventoryItem>[itemC, itemA, itemB, itemNoExpiry, itemNoCat];

  group('SortInventoryItemsUseCase — name', () {
    test('ascending: A → Z', () {
      final result = useCase.call(items, const SortPreference(criteria: SortCriteria.name));
      final names = result.map((e) => e.name).toList();
      expect(names, <String>['Arroz', 'Leche', 'Mantequilla', 'Sal', 'Yogur']);
    });

    test('descending: Z → A', () {
      final result = useCase.call(
        items,
        const SortPreference(criteria: SortCriteria.name, ascending: false),
      );
      final names = result.map((e) => e.name).toList();
      expect(names, <String>['Yogur', 'Sal', 'Mantequilla', 'Leche', 'Arroz']);
    });

    test('case-insensitive: lowercase sorts like uppercase', () {
      final a = _item(id: 10, name: 'arroz');
      final b = _item(id: 11, name: 'Banana');
      final result = useCase.call(
        <InventoryItem>[b, a],
        const SortPreference(criteria: SortCriteria.name),
      );
      expect(result.first.name, 'arroz');
    });
  });

  group('SortInventoryItemsUseCase — quantity', () {
    test('ascending: lowest first', () {
      final result = useCase.call(items, const SortPreference(criteria: SortCriteria.quantity));
      final qtys = result.map((e) => e.quantity).toList();
      expect(qtys.first, lessThanOrEqualTo(qtys[1]));
      expect(qtys[1], lessThanOrEqualTo(qtys[2]));
    });

    test('descending: highest first', () {
      final result = useCase.call(
        items,
        const SortPreference(criteria: SortCriteria.quantity, ascending: false),
      );
      final qtys = result.map((e) => e.quantity).toList();
      expect(qtys.first, greaterThanOrEqualTo(qtys[1]));
    });
  });

  group('SortInventoryItemsUseCase — expiryDate', () {
    test('ascending: earliest expiry first, null (no expiry) goes to end', () {
      final result = useCase.call(
        items,
        const SortPreference(criteria: SortCriteria.expiryDate),
      );
      expect(result.first.expiryDate, d1);
      expect(result.last.expiryDate, isNull);
    });

    test('descending: latest expiry first, null goes to front (DateTime 9999)', () {
      final result = useCase.call(
        items,
        const SortPreference(criteria: SortCriteria.expiryDate, ascending: false),
      );
      expect(result.first.expiryDate, isNull);
      expect(result.last.expiryDate, d1);
    });
  });

  group('SortInventoryItemsUseCase — category', () {
    test('ascending: null category (empty string) sorts before named categories', () {
      final result = useCase.call(
        items,
        const SortPreference(criteria: SortCriteria.category),
      );
      expect(result.first.category, isNull);
    });

    test('descending: named categories before null', () {
      final result = useCase.call(
        items,
        const SortPreference(criteria: SortCriteria.category, ascending: false),
      );
      expect(result.last.category, isNull);
    });
  });

  group('SortInventoryItemsUseCase — edge cases', () {
    test('empty list returns empty list', () {
      final result = useCase.call(
        <InventoryItem>[],
        const SortPreference(criteria: SortCriteria.name),
      );
      expect(result, isEmpty);
    });

    test('single item list returns same item', () {
      final result = useCase.call(
        <InventoryItem>[itemA],
        const SortPreference(criteria: SortCriteria.name),
      );
      expect(result.single.id, itemA.id);
    });

    test('does not mutate the original list', () {
      final original = <InventoryItem>[itemC, itemA, itemB];
      useCase.call(original, const SortPreference(criteria: SortCriteria.name));
      expect(original.first.id, itemC.id);
    });
  });
}
