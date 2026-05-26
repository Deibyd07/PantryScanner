import '../repositories/inventory_repository.dart';

/// Deletes an inventory item by [id] from the repository.
class DeleteInventoryItemUseCase {
  const DeleteInventoryItemUseCase(this._repository);

  final InventoryRepository _repository;

  Future<void> call(int id) => _repository.deleteItem(id);
}
