/// Ítem de la lista de compras. Puede venir manualmente o haberse añadido
/// desde el detalle de una receta (en cuyo caso lleva `sourceRecipeId` y
/// `sourceTitle` para agrupar y mostrar la procedencia).
class ShoppingListItem {
  const ShoppingListItem({
    required this.id,
    required this.name,
    required this.isChecked,
    required this.createdAt,
    this.quantity,
    this.sourceRecipeId,
    this.sourceTitle,
    this.checkedAt,
  });

  final int id;
  final String name;
  final String? quantity;
  final String? sourceRecipeId;
  final String? sourceTitle;
  final bool isChecked;
  final DateTime createdAt;
  final DateTime? checkedAt;

  ShoppingListItem copyWith({
    int? id,
    String? name,
    String? quantity,
    String? sourceRecipeId,
    String? sourceTitle,
    bool? isChecked,
    DateTime? createdAt,
    DateTime? checkedAt,
  }) {
    return ShoppingListItem(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      sourceRecipeId: sourceRecipeId ?? this.sourceRecipeId,
      sourceTitle: sourceTitle ?? this.sourceTitle,
      isChecked: isChecked ?? this.isChecked,
      createdAt: createdAt ?? this.createdAt,
      checkedAt: checkedAt ?? this.checkedAt,
    );
  }
}
