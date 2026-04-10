import '../entities/inventory_item.dart';
import '../repositories/inventory_repository.dart';

class SaveInventoryItemUseCase {
  const SaveInventoryItemUseCase(this._repository);

  final InventoryRepository _repository;

  Future<int> call(InventoryItem item) {
    return _repository.saveItem(item);
  }
}
