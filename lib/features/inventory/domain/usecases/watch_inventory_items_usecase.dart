import '../entities/inventory_item.dart';
import '../repositories/inventory_repository.dart';

class WatchInventoryItemsUseCase {
  const WatchInventoryItemsUseCase(this._repository);

  final InventoryRepository _repository;

  Stream<List<InventoryItem>> call() {
    return _repository.watchInventory();
  }
}
