import '../entities/inventory_item.dart';
import '../repositories/inventory_repository.dart';

/// Updates the quantity of an existing [InventoryItem] by [delta] (+1 or -1).
/// Clamps the result to a minimum of 0.
class UpdateInventoryItemQuantityUseCase {
  const UpdateInventoryItemQuantityUseCase(this._repository);

  final InventoryRepository _repository;

  Future<int> call(InventoryItem item, int delta) async {
    final int newQuantity = (item.quantity + delta).clamp(0, 9999);
    final InventoryItem updated = item.copyWith(quantity: newQuantity);
    await _repository.saveItem(updated);
    return newQuantity;
  }
}
