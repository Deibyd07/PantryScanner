import 'package:firebase_analytics/firebase_analytics.dart';

/// Thin wrapper around [FirebaseAnalytics].
///
/// All event names follow the snake_case convention required by Firebase.
/// Custom events use the `fa_` prefix to distinguish them from Firebase
/// default events (sign_in, sign_up, etc.) which are sent via the standard
/// parameter names.
class AppAnalytics {
  AppAnalytics._();

  static final FirebaseAnalytics _fa = FirebaseAnalytics.instance;

  /// Observer to pass to GoRouter so Firebase tracks screen_view automatically.
  static FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _fa);

  // ── Auth ──────────────────────────────────────────────────────────────────

  /// Fired when a user successfully signs in (email or Google).
  static Future<void> logLogin({required String method}) =>
      _fa.logLogin(loginMethod: method);

  /// Fired when a new account is created successfully.
  static Future<void> logSignUp({required String method}) =>
      _fa.logSignUp(signUpMethod: method);

  // ── Inventory ─────────────────────────────────────────────────────────────

  /// Fired when the user saves a new product to the inventory.
  static Future<void> logProductAdded({
    required String name,
    String? category,
  }) =>
      _fa.logEvent(
        name: 'product_added',
        parameters: <String, Object>{
          'product_name': name,
          if (category != null) 'category': category,
        },
      );

  /// Fired when the user saves changes to an existing product.
  static Future<void> logProductEdited({required String name}) =>
      _fa.logEvent(
        name: 'product_edited',
        parameters: <String, Object>{'product_name': name},
      );

  /// Fired when the user deletes a product from the inventory.
  static Future<void> logProductDeleted() =>
      _fa.logEvent(name: 'product_deleted');

  // ── Scanner ───────────────────────────────────────────────────────────────

  /// Fired when the scanner successfully reads a barcode.
  static Future<void> logBarcodeScanned() =>
      _fa.logEvent(name: 'barcode_scanned');

  // ── Shopping list ─────────────────────────────────────────────────────────

  /// Fired when the user adds one or more items to the shopping list.
  static Future<void> logShoppingItemAdded() =>
      _fa.logEvent(name: 'shopping_item_added');

  /// Fired when the user clears all completed items from the shopping list.
  static Future<void> logShoppingListCleared() =>
      _fa.logEvent(name: 'shopping_list_cleared');

  // ── Recipes ───────────────────────────────────────────────────────────────

  /// Fired when the user opens a recipe detail.
  static Future<void> logRecipeViewed({required String recipeId}) =>
      _fa.logEvent(
        name: 'recipe_viewed',
        parameters: <String, Object>{'recipe_id': recipeId},
      );
}
