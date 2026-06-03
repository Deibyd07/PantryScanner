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

  // Sentinel para distinguir "no se pasó argumento" de "se pasó null
  // explícitamente". Sin esto, copyWith no puede limpiar un campo nullable.
  static const Object _unset = Object();

  ShoppingListItem copyWith({
    int? id,
    String? name,
    Object? quantity = _unset,
    Object? sourceRecipeId = _unset,
    Object? sourceTitle = _unset,
    bool? isChecked,
    DateTime? createdAt,
    Object? checkedAt = _unset,
  }) {
    return ShoppingListItem(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: identical(quantity, _unset)
          ? this.quantity
          : quantity as String?,
      sourceRecipeId: identical(sourceRecipeId, _unset)
          ? this.sourceRecipeId
          : sourceRecipeId as String?,
      sourceTitle: identical(sourceTitle, _unset)
          ? this.sourceTitle
          : sourceTitle as String?,
      isChecked: isChecked ?? this.isChecked,
      createdAt: createdAt ?? this.createdAt,
      checkedAt: identical(checkedAt, _unset)
          ? this.checkedAt
          : checkedAt as DateTime?,
    );
  }
}
