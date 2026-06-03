import 'recipe.dart';
import 'recipe_ingredient.dart';

/// Resultado de evaluar una receta contra el inventario del usuario.
class RecipeMatch {
  const RecipeMatch({
    required this.recipe,
    required this.matchedIngredients,
    required this.missingIngredients,
    required this.expiringIngredients,
    required this.score,
  });

  final Recipe recipe;

  /// Ingredientes requeridos cubiertos por la despensa.
  final List<RecipeIngredient> matchedIngredients;

  /// Ingredientes requeridos no cubiertos.
  final List<RecipeIngredient> missingIngredients;

  /// Subconjunto de [matchedIngredients] cuyo producto en despensa
  /// está vencido o por vencer (≤ 3 días).
  final List<RecipeIngredient> expiringIngredients;

  /// Score normalizado en [0, 1]+ — usado para ordenar.
  /// Combina cobertura de ingredientes y bonus por usar productos
  /// que están por vencer.
  final double score;

  int get totalRequired => matchedIngredients.length + missingIngredients.length;

  /// Cobertura como porcentaje entero, ej. 80.
  int get coveragePercent {
    if (totalRequired == 0) return 0;
    return ((matchedIngredients.length / totalRequired) * 100).round();
  }

  bool get canCookNow => missingIngredients.isEmpty;
  bool get usesExpiring => expiringIngredients.isNotEmpty;
}
