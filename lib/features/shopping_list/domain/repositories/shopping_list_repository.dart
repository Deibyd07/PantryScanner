import '../entities/shopping_list_item.dart';

abstract class ShoppingListRepository {
  Stream<List<ShoppingListItem>> watchAll();

  /// Agrega un ítem. Si ya existe uno con el mismo nombre (normalizado)
  /// y proveniente del mismo recipe, no duplica.
  Future<int> addItem({
    required String name,
    String? quantity,
    String? sourceRecipeId,
    String? sourceTitle,
  });

  /// Agrega varios ítems en lote (transaccional). Devuelve cuántos se
  /// añadieron realmente (excluye los que ya existían).
  Future<int> addItems({
    required List<ShoppingListItemDraft> drafts,
  });

  /// Actualiza el nombre y/o la cantidad de un ítem existente.
  /// Pasar `null` en `quantity` lo limpia.
  Future<void> updateItem(
    int id, {
    required String name,
    required String? quantity,
  });

  Future<void> toggleChecked(int id, {required bool isChecked});

  /// Marca como conseguidos todos los ítems pendientes de [ids] en una
  /// sola operación atómica.
  Future<void> markManyChecked(List<int> ids);

  Future<void> deleteItem(int id);

  /// Restaura un ítem que se había borrado (para soportar Undo). Conserva
  /// el contenido pero genera un nuevo id. Devuelve el id generado.
  Future<int> restoreItem(ShoppingListItem item);

  Future<void> clearCompleted();
}

/// Estructura mínima para crear un ítem en lote.
class ShoppingListItemDraft {
  const ShoppingListItemDraft({
    required this.name,
    this.quantity,
    this.sourceRecipeId,
    this.sourceTitle,
  });

  final String name;
  final String? quantity;
  final String? sourceRecipeId;
  final String? sourceTitle;
}
