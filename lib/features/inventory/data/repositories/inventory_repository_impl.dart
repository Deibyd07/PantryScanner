import '../../domain/entities/inventory_item.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../mappers/inventory_item_mapper.dart';
import '../../../../core/database/app_database.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  const InventoryRepositoryImpl(this._database);

  final AppDatabase _database;

  @override
  Stream<List<InventoryItem>> watchInventory() {
    return _database.watchAllProducts().map(
      (List<Product> rows) => rows.map((Product row) => row.toEntity()).toList(),
    );
  }

  @override
  Future<int> saveItem(InventoryItem item) {
    return _database.insertProduct(item.toCompanion());
  }

  @override
  Future<void> deleteItem(int id) async {
    await _database.deleteProductById(id);
  }
}
