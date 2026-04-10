import '../entities/inventory_item.dart';

abstract class InventoryRepository {
  Stream<List<InventoryItem>> watchInventory();

  Future<int> saveItem(InventoryItem item);

  Future<void> deleteItem(int id);
}
