import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../inventory/domain/entities/inventory_item.dart';
import '../../../inventory/presentation/providers/inventory_providers.dart';
import '../../data/sources/local_recipes_catalog.dart';
import '../../domain/entities/recipe.dart';
import '../../domain/entities/recipe_match.dart';
import '../../domain/usecases/find_matching_recipes_usecase.dart';

final Provider<LocalRecipesCatalog> recipesCatalogProvider =
    Provider<LocalRecipesCatalog>((_) => const LocalRecipesCatalog());

final Provider<FindMatchingRecipesUseCase> findMatchingRecipesProvider =
    Provider<FindMatchingRecipesUseCase>((_) => const FindMatchingRecipesUseCase());

/// Lista de recetas evaluadas contra la despensa actual, ordenadas por
/// relevancia: primero las cocinables completas, luego por score.
final Provider<AsyncValue<List<RecipeMatch>>> recipeMatchesProvider =
    Provider<AsyncValue<List<RecipeMatch>>>((Ref ref) {
  final AsyncValue<List<InventoryItem>> pantry =
      ref.watch(inventoryItemsProvider);
  final LocalRecipesCatalog catalog = ref.watch(recipesCatalogProvider);
  final FindMatchingRecipesUseCase matcher =
      ref.watch(findMatchingRecipesProvider);

  return pantry.whenData((List<InventoryItem> items) {
    return matcher(recipes: catalog.getAll(), pantry: items);
  });
});

/// Receta individual por id.
final ProviderFamily<Recipe?, String> recipeByIdProvider =
    Provider.family<Recipe?, String>((Ref ref, String id) {
  return ref.watch(recipesCatalogProvider).getById(id);
});
