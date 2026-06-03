/// Maps OpenFoodFacts taxonomy tags (e.g. "en:dairies") to the
/// internal categories used by PantryScanner.
class OpenFoodFactsCategoryMapper {
  const OpenFoodFactsCategoryMapper();

  static const Map<String, String> _tagToCategory = <String, String>{
    'dairies': 'Lácteos',
    'milks': 'Lácteos',
    'yogurts': 'Lácteos',
    'cheeses': 'Lácteos',
    'butters': 'Lácteos',
    'creams': 'Lácteos',
    'fermented-dairy-desserts': 'Lácteos',
    'meats': 'Carnes',
    'meat-preparations': 'Carnes',
    'poultries': 'Carnes',
    'sausages': 'Carnes',
    'cold-cuts': 'Carnes',
    'fishes': 'Carnes',
    'seafood': 'Carnes',
    'fruits-and-vegetables-based-foods': 'Frutas y verduras',
    'fruits': 'Frutas y verduras',
    'vegetables': 'Frutas y verduras',
    'fresh-vegetables': 'Frutas y verduras',
    'fresh-fruits': 'Frutas y verduras',
    'legumes': 'Frutas y verduras',
    'canned-foods': 'Enlatados',
    'canned-vegetables': 'Enlatados',
    'canned-meats': 'Enlatados',
    'canned-fishes': 'Enlatados',
    'preserves': 'Enlatados',
    'beverages': 'Bebidas',
    'waters': 'Bebidas',
    'sodas': 'Bebidas',
    'juices': 'Bebidas',
    'coffees': 'Bebidas',
    'teas': 'Bebidas',
    'alcoholic-beverages': 'Bebidas',
    'snacks': 'Snacks',
    'sweet-snacks': 'Snacks',
    'salty-snacks': 'Snacks',
    'biscuits': 'Snacks',
    'chocolates': 'Snacks',
    'candies': 'Snacks',
    'chips-and-fries': 'Snacks',
    'cereals-and-potatoes': 'Cereales',
    'cereals': 'Cereales',
    'breakfast-cereals': 'Cereales',
    'pastas': 'Cereales',
    'rices': 'Cereales',
    'breads': 'Cereales',
    'condiments': 'Condimentos',
    'sauces': 'Condimentos',
    'spices': 'Condimentos',
    'salts': 'Condimentos',
    'vinegars': 'Condimentos',
    'oils': 'Condimentos',
  };

  /// Resolves the best matching internal category for a list of OFF tags.
  /// Tags arrive as `en:dairies`, `en:yogurts`, ... — the more specific tag
  /// (usually the last) wins when more than one matches.
  String? resolve(List<String>? categoriesTags) {
    if (categoriesTags == null || categoriesTags.isEmpty) return null;
    String? best;
    for (final String raw in categoriesTags) {
      final String tag = raw.startsWith('en:') ? raw.substring(3) : raw;
      final String? category = _tagToCategory[tag];
      if (category != null) best = category;
    }
    return best;
  }
}
