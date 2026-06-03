import 'recipe_ingredient.dart';

enum RecipeDifficulty { facil, medio, avanzado }

enum RecipeMeal { desayuno, almuerzo, cena, snack, postre }

class Recipe {
  const Recipe({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.minutes,
    required this.difficulty,
    required this.servings,
    required this.meal,
    required this.ingredients,
    required this.steps,
  });

  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final int minutes;
  final RecipeDifficulty difficulty;
  final int servings;
  final RecipeMeal meal;
  final List<RecipeIngredient> ingredients;
  final List<String> steps;

  /// Ingredientes no opcionales — usados como denominador del score.
  Iterable<RecipeIngredient> get requiredIngredients =>
      ingredients.where((RecipeIngredient i) => !i.isOptional);
}
