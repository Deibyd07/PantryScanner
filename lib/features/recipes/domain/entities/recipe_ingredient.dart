/// Ingrediente de una receta. Contiene metadatos suficientes para hacer
/// matching contra los productos de la despensa: una lista de [keywords]
/// (sinónimos del ingrediente, en minúsculas y sin tildes) y opcionalmente
/// la [pantryCategory] interna usada por PantryScanner.
class RecipeIngredient {
  const RecipeIngredient({
    required this.name,
    required this.keywords,
    this.quantity,
    this.unit,
    this.pantryCategory,
    this.isOptional = false,
  });

  /// Nombre humano del ingrediente, ej. "Aguacate".
  final String name;

  /// Sinónimos/alias normalizados (lowercase, sin tildes) usados para hacer
  /// match contra el nombre del producto de la despensa.
  final List<String> keywords;

  /// Cantidad mostrada al usuario, ej. "200", "1", "al gusto".
  final String? quantity;

  /// Unidad mostrada al usuario, ej. "g", "ml", "taza".
  final String? unit;

  /// Categoría interna de despensa con la que mapea, ej. "Lácteos".
  /// Usada como fallback de matching cuando no hay match por keyword.
  final String? pantryCategory;

  /// Si es true, no penaliza la cobertura cuando falta.
  final bool isOptional;

  String get displayQuantity {
    if (quantity == null && unit == null) return '';
    final String q = quantity ?? '';
    final String u = unit ?? '';
    return (q.isEmpty ? u : '$q $u').trim();
  }
}
