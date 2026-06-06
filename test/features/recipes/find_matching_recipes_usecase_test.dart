import 'package:flutter_test/flutter_test.dart';
import 'package:pantry_scanner/features/inventory/domain/entities/inventory_item.dart';
import 'package:pantry_scanner/features/recipes/domain/entities/recipe.dart';
import 'package:pantry_scanner/features/recipes/domain/entities/recipe_ingredient.dart';
import 'package:pantry_scanner/features/recipes/domain/usecases/find_matching_recipes_usecase.dart';

// ── Helpers ──────────────────────────────────────────────────────────────────

InventoryItem _pantryItem(
  String name, {
  int quantity = 1,
  bool expiringSoon = false,
  bool expired = false,
  bool deleted = false,
}) {
  final DateTime now = DateTime.now();
  DateTime? expiryDate;
  if (expiringSoon) expiryDate = now.add(const Duration(hours: 30));
  if (expired) expiryDate = now.subtract(const Duration(days: 2));

  return InventoryItem(
    id: name.hashCode,
    syncId: 'sync-$name',
    barcode: '',
    name: name,
    brand: null,
    category: null,
    quantity: quantity,
    createdAt: now,
    updatedAt: now,
    expiryDate: expiryDate,
    isDeleted: deleted,
  );
}

RecipeIngredient _ing(String name, List<String> keywords, {bool optional = false}) {
  return RecipeIngredient(name: name, keywords: keywords, isOptional: optional);
}

Recipe _recipe({
  required String id,
  required List<RecipeIngredient> ingredients,
  int minutes = 30,
}) {
  return Recipe(
    id: id,
    title: 'Receta $id',
    description: '',
    minutes: minutes,
    difficulty: RecipeDifficulty.facil,
    servings: 2,
    meal: RecipeMeal.almuerzo,
    ingredients: ingredients,
    steps: <String>['Preparar', 'Cocinar'],
  );
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  const FindMatchingRecipesUseCase useCase = FindMatchingRecipesUseCase();

  group('FindMatchingRecipesUseCase — matching básico', () {
    test('empty pantry → all ingredients missing, canCookNow = false', () {
      final recipe = _recipe(
        id: 'r1',
        ingredients: <RecipeIngredient>[_ing('Leche', <String>['leche'])],
      );
      final result = useCase.call(recipes: <Recipe>[recipe], pantry: <InventoryItem>[]);
      expect(result.single.canCookNow, isFalse);
      expect(result.single.missingIngredients.length, 1);
      expect(result.single.matchedIngredients, isEmpty);
    });

    test('all ingredients present → canCookNow = true, score = 1.0', () {
      final recipe = _recipe(
        id: 'r1',
        ingredients: <RecipeIngredient>[
          _ing('Leche', <String>['leche']),
          _ing('Huevo', <String>['huevo']),
        ],
      );
      final pantry = <InventoryItem>[
        _pantryItem('Leche entera'),
        _pantryItem('Huevo fresco'),
      ];
      final result = useCase.call(recipes: <Recipe>[recipe], pantry: pantry);
      expect(result.single.canCookNow, isTrue);
      expect(result.single.score, closeTo(1.0, 0.01));
      expect(result.single.missingIngredients, isEmpty);
    });

    test('partial match → canCookNow = false, 0 < score < 1', () {
      final recipe = _recipe(
        id: 'r1',
        ingredients: <RecipeIngredient>[
          _ing('Leche', <String>['leche']),
          _ing('Harina', <String>['harina']),
        ],
      );
      final pantry = <InventoryItem>[_pantryItem('Leche')];
      final result = useCase.call(recipes: <Recipe>[recipe], pantry: pantry);
      expect(result.single.canCookNow, isFalse);
      expect(result.single.score, greaterThan(0.0));
      expect(result.single.score, lessThan(1.0));
      expect(result.single.missingIngredients.length, 1);
      expect(result.single.matchedIngredients.length, 1);
    });

    test('item with quantity 0 is excluded from matching', () {
      final recipe = _recipe(
        id: 'r1',
        ingredients: <RecipeIngredient>[_ing('Leche', <String>['leche'])],
      );
      final pantry = <InventoryItem>[_pantryItem('Leche', quantity: 0)];
      final result = useCase.call(recipes: <Recipe>[recipe], pantry: pantry);
      expect(result.single.canCookNow, isFalse);
      expect(result.single.missingIngredients.length, 1);
    });

    test('deleted item is excluded from matching', () {
      final recipe = _recipe(
        id: 'r1',
        ingredients: <RecipeIngredient>[_ing('Leche', <String>['leche'])],
      );
      final pantry = <InventoryItem>[_pantryItem('Leche', deleted: true)];
      final result = useCase.call(recipes: <Recipe>[recipe], pantry: pantry);
      expect(result.single.canCookNow, isFalse);
    });
  });

  group('FindMatchingRecipesUseCase — diacríticos y normalización', () {
    test('name with diacritics matches keyword without diacritics', () {
      final recipe = _recipe(
        id: 'r1',
        ingredients: <RecipeIngredient>[_ing('Ñame', <String>['name'])],
      );
      final pantry = <InventoryItem>[_pantryItem('Ñame tropical')];
      final result = useCase.call(recipes: <Recipe>[recipe], pantry: pantry);
      expect(result.single.canCookNow, isTrue);
    });

    test('keyword matches regardless of uppercase in pantry name', () {
      final recipe = _recipe(
        id: 'r1',
        ingredients: <RecipeIngredient>[_ing('Leche', <String>['leche'])],
      );
      final pantry = <InventoryItem>[_pantryItem('LECHE ENTERA')];
      final result = useCase.call(recipes: <Recipe>[recipe], pantry: pantry);
      expect(result.single.canCookNow, isTrue);
    });

    test('accented pantry name matches normalized keyword', () {
      final recipe = _recipe(
        id: 'r1',
        ingredients: <RecipeIngredient>[_ing('Azúcar', <String>['azucar'])],
      );
      final pantry = <InventoryItem>[_pantryItem('Azúcar morena')];
      final result = useCase.call(recipes: <Recipe>[recipe], pantry: pantry);
      expect(result.single.canCookNow, isTrue);
    });
  });

  group('FindMatchingRecipesUseCase — expiring boost', () {
    test('matched expiring ingredient adds 0.20 boost to score', () {
      final recipe = _recipe(
        id: 'r1',
        ingredients: <RecipeIngredient>[_ing('Leche', <String>['leche'])],
      );
      final pantryNormal = <InventoryItem>[_pantryItem('Leche')];
      final pantryExpiring = <InventoryItem>[_pantryItem('Leche', expiringSoon: true)];

      final scoreNormal = useCase.call(recipes: <Recipe>[recipe], pantry: pantryNormal).single.score;
      final scoreExpiring = useCase.call(recipes: <Recipe>[recipe], pantry: pantryExpiring).single.score;

      expect(scoreExpiring, closeTo(scoreNormal + 0.20, 0.001));
    });

    test('expired item also triggers boost', () {
      final recipe = _recipe(
        id: 'r1',
        ingredients: <RecipeIngredient>[_ing('Leche', <String>['leche'])],
      );
      final pantryExpired = <InventoryItem>[_pantryItem('Leche', expired: true)];
      final result = useCase.call(recipes: <Recipe>[recipe], pantry: pantryExpired);
      expect(result.single.expiringIngredients.length, 1);
    });

    test('non-expiring item does not trigger boost', () {
      final recipe = _recipe(
        id: 'r1',
        ingredients: <RecipeIngredient>[_ing('Leche', <String>['leche'])],
      );
      final pantry = <InventoryItem>[_pantryItem('Leche')];
      final result = useCase.call(recipes: <Recipe>[recipe], pantry: pantry);
      expect(result.single.expiringIngredients, isEmpty);
      expect(result.single.score, closeTo(1.0, 0.001));
    });
  });

  group('FindMatchingRecipesUseCase — ingredientes opcionales', () {
    test('missing optional ingredient does not reduce coverage', () {
      final recipe = _recipe(
        id: 'r1',
        ingredients: <RecipeIngredient>[
          _ing('Leche', <String>['leche']),
          _ing('Canela', <String>['canela'], optional: true),
        ],
      );
      final pantry = <InventoryItem>[_pantryItem('Leche')];
      final result = useCase.call(recipes: <Recipe>[recipe], pantry: pantry);
      // Canela is optional → not in requiredIngredients → denominator = 1
      expect(result.single.canCookNow, isTrue);
    });

    test('recipe with only optional ingredients and empty pantry has score 0', () {
      final recipe = _recipe(
        id: 'r1',
        ingredients: <RecipeIngredient>[
          _ing('Canela', <String>['canela'], optional: true),
        ],
      );
      final result = useCase.call(recipes: <Recipe>[recipe], pantry: <InventoryItem>[]);
      // 0 required ingredients → coverage = 0/0 → 0
      expect(result.single.score, 0.0);
    });
  });

  group('FindMatchingRecipesUseCase — ordenamiento', () {
    test('canCookNow recipes sort before partial matches', () {
      final fullMatch = _recipe(
        id: 'full',
        ingredients: <RecipeIngredient>[_ing('Leche', <String>['leche'])],
      );
      final partial = _recipe(
        id: 'partial',
        ingredients: <RecipeIngredient>[
          _ing('Leche', <String>['leche']),
          _ing('Harina', <String>['harina']),
        ],
      );
      final pantry = <InventoryItem>[_pantryItem('Leche')];
      final result = useCase.call(recipes: <Recipe>[partial, fullMatch], pantry: pantry);
      expect(result.first.recipe.id, 'full');
    });

    test('higher score sorts before lower score when both canCookNow = false', () {
      final better = _recipe(
        id: 'better',
        ingredients: <RecipeIngredient>[
          _ing('Leche', <String>['leche']),
          _ing('Huevo', <String>['huevo']),
          _ing('Harina', <String>['harina']),
        ],
      );
      final worse = _recipe(
        id: 'worse',
        ingredients: <RecipeIngredient>[
          _ing('Leche', <String>['leche']),
          _ing('Atún', <String>['atun']),
        ],
      );
      final pantry = <InventoryItem>[
        _pantryItem('Leche'),
        _pantryItem('Huevo'),
      ];
      final result = useCase.call(recipes: <Recipe>[worse, better], pantry: pantry);
      expect(result.first.recipe.id, 'better');
    });

    test('equal score: fewer minutes sorts first', () {
      final fast = _recipe(
        id: 'fast',
        ingredients: <RecipeIngredient>[_ing('Leche', <String>['leche'])],
        minutes: 10,
      );
      final slow = _recipe(
        id: 'slow',
        ingredients: <RecipeIngredient>[_ing('Leche', <String>['leche'])],
        minutes: 60,
      );
      final pantry = <InventoryItem>[_pantryItem('Leche')];
      final result = useCase.call(recipes: <Recipe>[slow, fast], pantry: pantry);
      expect(result.first.recipe.id, 'fast');
    });
  });

  group('FindMatchingRecipesUseCase — edge cases', () {
    test('empty recipe list returns empty result', () {
      final result = useCase.call(
        recipes: <Recipe>[],
        pantry: <InventoryItem>[_pantryItem('Leche')],
      );
      expect(result, isEmpty);
    });

    test('multiple keywords: any matching keyword counts', () {
      final recipe = _recipe(
        id: 'r1',
        ingredients: <RecipeIngredient>[
          _ing('Tomate', <String>['tomate', 'jitomate', 'tomato']),
        ],
      );
      final pantry = <InventoryItem>[_pantryItem('Jitomate guaje')];
      final result = useCase.call(recipes: <Recipe>[recipe], pantry: pantry);
      expect(result.single.canCookNow, isTrue);
    });
  });
}
