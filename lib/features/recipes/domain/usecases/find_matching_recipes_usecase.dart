import '../../../inventory/domain/entities/inventory_item.dart';
import '../entities/recipe.dart';
import '../entities/recipe_ingredient.dart';
import '../entities/recipe_match.dart';

/// Evalúa el catálogo de recetas contra la despensa actual y produce
/// una lista ordenada por relevancia: primero las que se pueden cocinar
/// completas, luego las que aprovechan productos por vencer, luego por
/// cobertura de ingredientes.
class FindMatchingRecipesUseCase {
  const FindMatchingRecipesUseCase();

  /// Bonus de score por cada ingrediente cubierto que está por vencer
  /// o vencido en la despensa.
  static const double _expiringBoost = 0.20;

  List<RecipeMatch> call({
    required List<Recipe> recipes,
    required List<InventoryItem> pantry,
  }) {
    final List<_PantryEntry> entries = pantry
        .where((InventoryItem item) => !item.isDeleted)
        .map(_PantryEntry.fromItem)
        .toList(growable: false);

    final List<RecipeMatch> matches = recipes
        .map((Recipe r) => _evaluate(r, entries))
        .toList();

    matches.sort((RecipeMatch a, RecipeMatch b) {
      // 1) Las que se pueden cocinar completas primero.
      if (a.canCookNow != b.canCookNow) {
        return a.canCookNow ? -1 : 1;
      }
      // 2) Mayor score (cobertura + bonus por vencer).
      final int byScore = b.score.compareTo(a.score);
      if (byScore != 0) return byScore;
      // 3) Menos tiempo a igualdad de score.
      return a.recipe.minutes.compareTo(b.recipe.minutes);
    });

    return matches;
  }

  RecipeMatch _evaluate(Recipe recipe, List<_PantryEntry> pantry) {
    final List<RecipeIngredient> matched = <RecipeIngredient>[];
    final List<RecipeIngredient> missing = <RecipeIngredient>[];
    final List<RecipeIngredient> expiring = <RecipeIngredient>[];

    for (final RecipeIngredient ing in recipe.requiredIngredients) {
      final _PantryEntry? hit = _findMatch(ing, pantry);
      if (hit == null) {
        missing.add(ing);
      } else {
        matched.add(ing);
        if (hit.isExpiringOrExpired) expiring.add(ing);
      }
    }

    final int total = matched.length + missing.length;
    final double coverage = total == 0 ? 0 : matched.length / total;
    final double score = coverage + (expiring.length * _expiringBoost);

    return RecipeMatch(
      recipe: recipe,
      matchedIngredients: matched,
      missingIngredients: missing,
      expiringIngredients: expiring,
      score: score,
    );
  }

  _PantryEntry? _findMatch(RecipeIngredient ing, List<_PantryEntry> pantry) {
    for (final _PantryEntry entry in pantry) {
      if (entry.quantity <= 0) continue;
      for (final String kw in ing.keywords) {
        if (entry.normalizedName.contains(kw)) return entry;
      }
    }
    return null;
  }
}

class _PantryEntry {
  _PantryEntry({
    required this.normalizedName,
    required this.quantity,
    required this.isExpiringOrExpired,
  });

  factory _PantryEntry.fromItem(InventoryItem item) {
    return _PantryEntry(
      normalizedName: _normalize(item.name),
      quantity: item.quantity,
      isExpiringOrExpired: item.status == ProductStatus.expired ||
          item.status == ProductStatus.expiringSoon,
    );
  }

  final String normalizedName;
  final int quantity;
  final bool isExpiringOrExpired;

  static const Map<String, String> _diacritics = <String, String>{
    'á': 'a', 'à': 'a', 'ä': 'a', 'â': 'a',
    'é': 'e', 'è': 'e', 'ë': 'e', 'ê': 'e',
    'í': 'i', 'ì': 'i', 'ï': 'i', 'î': 'i',
    'ó': 'o', 'ò': 'o', 'ö': 'o', 'ô': 'o',
    'ú': 'u', 'ù': 'u', 'ü': 'u', 'û': 'u',
    'ñ': 'n',
  };

  static String _normalize(String input) {
    final String lower = input.toLowerCase();
    final StringBuffer out = StringBuffer();
    for (int i = 0; i < lower.length; i++) {
      final String ch = lower[i];
      out.write(_diacritics[ch] ?? ch);
    }
    return out.toString();
  }
}
