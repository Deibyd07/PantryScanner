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

  /// Agrega varios ítems en lote. Devuelve cuántos se añadieron realmente
  /// (excluye los que ya existían).
  Future<int> addItems({
    required List<ShoppingListItemDraft> drafts,
  });

  Future<void> toggleChecked(int id, {required bool isChecked});

  Future<void> deleteItem(int id);

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
