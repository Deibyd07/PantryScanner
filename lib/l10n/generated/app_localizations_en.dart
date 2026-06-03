// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'PantryScanner';

  @override
  String get appTagline => 'Your pantry, under control';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonSave => 'Save';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonClose => 'Close';

  @override
  String get commonBack => 'Back';

  @override
  String get commonContinue => 'Continue';

  @override
  String get commonOk => 'OK';

  @override
  String get commonError => 'Error';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonLoading => 'Loading…';

  @override
  String get commonUndo => 'Undo';

  @override
  String get commonSee => 'See';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonAdd => 'Add';

  @override
  String get commonSearch => 'Search';

  @override
  String get navPantry => 'Pantry';

  @override
  String get navRecipes => 'Recipes';

  @override
  String get navAlerts => 'Alerts';

  @override
  String get navProfile => 'Profile';

  @override
  String get cartTooltip => 'Shopping list';

  @override
  String get popupLogoutTitle => 'Log out';

  @override
  String get popupLogoutBody => 'Are you sure you want to log out?';

  @override
  String get inventoryTitle => 'My pantry';

  @override
  String get inventoryTagline => 'Organize · Track · Save';

  @override
  String get inventorySearchHint => 'Search in your pantry...';

  @override
  String get inventoryClearSearch => 'Clear search';

  @override
  String get inventoryEmptyTitle => 'Your pantry is empty';

  @override
  String get inventoryEmptyHint =>
      'Tap the center button to scan your first product';

  @override
  String inventorySearchNoResults(String query) {
    return 'No results for \"$query\"';
  }

  @override
  String get inventorySearchTryOther => 'Try another name, brand, or category';

  @override
  String get inventoryLoadError => 'Could not load inventory';

  @override
  String get inventoryDeleteTitle => 'Delete product';

  @override
  String inventoryDeleteBody(String name) {
    return 'Are you sure you want to remove \"$name\" from your pantry?';
  }

  @override
  String inventoryDeletedSnack(String name) {
    return '\"$name\" removed';
  }

  @override
  String get inventoryConfirmDeleteTitle => 'Delete product?';

  @override
  String inventoryConfirmDeleteBody(String name) {
    return 'The quantity of \"$name\" will reach 0. Do you want to remove it from your inventory?';
  }

  @override
  String get categoryAll => 'All';

  @override
  String get categoryDairy => 'Dairy';

  @override
  String get categoryMeat => 'Meat';

  @override
  String get categoryFruitsVeg => 'Fruits & vegetables';

  @override
  String get categoryCanned => 'Canned';

  @override
  String get categoryDrinks => 'Drinks';

  @override
  String get categorySnacks => 'Snacks';

  @override
  String get categoryCereals => 'Cereals';

  @override
  String get categoryCondiments => 'Condiments';

  @override
  String get categoryUncategorized => 'Uncategorized';

  @override
  String get unitOne => 'unit';

  @override
  String get unitMany => 'units';

  @override
  String get insightsTitle => 'Smart summary';

  @override
  String get insightsMetricExpired => 'Expired';

  @override
  String get insightsMetricProducts => 'Products';

  @override
  String get insightsMetricExpiring => 'Expiring';

  @override
  String get insightsEmpty => 'You don\'t have any products in your pantry yet';

  @override
  String get insightsAllGood => 'All good: nothing expiring soon';

  @override
  String insightsMixed(int expired, int expiring) {
    return '$expired expired · $expiring expiring soon';
  }

  @override
  String insightsExpired(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count expired products',
      one: '1 expired product',
    );
    return '$_temp0';
  }

  @override
  String insightsExpiring(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count products expiring soon',
      one: '1 product expiring soon',
    );
    return '$_temp0';
  }

  @override
  String get sortTitle => 'Sort by';

  @override
  String get sortExpiryDate => 'Expiry date';

  @override
  String get sortName => 'Name A-Z';

  @override
  String get sortQuantity => 'Quantity';

  @override
  String get sortCategory => 'Category';

  @override
  String get sortAscending => 'Ascending';

  @override
  String get sortDescending => 'Descending';

  @override
  String get sortApply => 'Apply';

  @override
  String get cartTitle => 'Shopping list';

  @override
  String get cartEmpty => 'You haven\'t added anything yet';

  @override
  String get cartAllDone => 'All done!';

  @override
  String cartPendingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items to buy',
      one: '1 item to buy',
    );
    return '$_temp0';
  }

  @override
  String get cartStatTotal => 'Total';

  @override
  String get cartStatPending => 'Pending';

  @override
  String get cartStatDone => 'Done';

  @override
  String get cartSectionToBuy => 'To buy';

  @override
  String get cartSectionManual => 'Added manually';

  @override
  String get cartSectionRecipe => 'Missing to prepare this recipe';

  @override
  String get cartSectionDone => 'Already have';

  @override
  String get cartSectionDoneSubtitle => 'Marked as done';

  @override
  String get cartClearDoneTooltip => 'Clear done';

  @override
  String get cartClearDoneTitle => 'Clear done';

  @override
  String get cartClearDoneBody =>
      'Do you want to clear all items you\'ve already marked as done?';

  @override
  String get cartQuickAddHint => 'Add item (e.g. Milk 2 L, 3 eggs)';

  @override
  String cartDeletedSnack(String name) {
    return 'Deleted \"$name\"';
  }

  @override
  String cartClearedSnack(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Cleared $count done items',
      one: 'Cleared 1 done item',
    );
    return '$_temp0';
  }

  @override
  String get cartEmptyTitle => 'Your list is empty';

  @override
  String get cartEmptyHint =>
      'Add items with the field above or from a recipe using \"Add missing to list\".';

  @override
  String get cartMarkAll => 'All';

  @override
  String get cartEditItemTitle => 'Edit item';

  @override
  String get cartEditNameLabel => 'Name';

  @override
  String get cartEditQtyLabel => 'Quantity (optional)';

  @override
  String get cartEditQtyHint => 'E.g. 2 L, 500 g, 3 units';

  @override
  String get cartDeleteItemTooltip => 'Remove from list';

  @override
  String get cartEditTooltip => 'Edit';

  @override
  String get recipeDifficultyEasy => 'Easy';

  @override
  String get recipeDifficultyMedium => 'Medium';

  @override
  String get recipeDifficultyAdvanced => 'Advanced';

  @override
  String get recipeMealBreakfast => 'Breakfast';

  @override
  String get recipeMealLunch => 'Lunch';

  @override
  String get recipeMealDinner => 'Dinner';

  @override
  String get recipeMealSnack => 'Snack';

  @override
  String get recipeMealDessert => 'Dessert';

  @override
  String get recipesLoadError => 'Could not load recipes';

  @override
  String get recipesHeroTitle => 'Cook with what you have';

  @override
  String get recipesHeroEmpty => 'No recipes in the catalog yet';

  @override
  String get recipesHeroNoneCookable =>
      'You\'re missing some ingredients to cook a full recipe';

  @override
  String recipesHeroCookable(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recipes ready to cook now',
      one: '1 recipe ready to cook now',
    );
    return '$_temp0';
  }

  @override
  String get recipesStatCatalog => 'In catalog';

  @override
  String get recipesStatCookable => 'Can cook';

  @override
  String get recipesStatExpiring => 'Expiring';

  @override
  String get recipesViewPantry => 'View pantry';

  @override
  String get recipesFilterAll => 'All';

  @override
  String get recipesFilterCookable => 'Can cook';

  @override
  String get recipesFilterExpiring => 'Use expiring';

  @override
  String get recipesEmptyTitleAll => 'No recipes';

  @override
  String get recipesEmptyBodyAll =>
      'We\'ll add more recipes to the catalog soon.';

  @override
  String get recipesEmptyTitleCookable => 'Missing ingredients';

  @override
  String get recipesEmptyBodyCookable =>
      'You don\'t have all the ingredients to cook a full recipe yet. Check the rest and buy what you\'re missing.';

  @override
  String get recipesEmptyTitleExpiring => 'Nothing expiring';

  @override
  String get recipesEmptyBodyExpiring =>
      'No recipe in the catalog uses products you\'re about to lose. Good job!';

  @override
  String recipeMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get recipeReady => 'Ready';

  @override
  String recipeCoveragePercent(int percent) {
    return '$percent%';
  }

  @override
  String get recipeUseExpiringOne => 'Uses 1 expiring product';

  @override
  String recipeUseExpiringMany(int count) {
    return 'Uses $count expiring products';
  }

  @override
  String get recipeMissingOne => 'You\'re missing 1 ingredient';

  @override
  String recipeMissingMany(int count) {
    return 'You\'re missing $count ingredients';
  }

  @override
  String get recipeDetailNotFound => 'Recipe not found';

  @override
  String get recipeDetailCanCookNow => 'You can cook it now';

  @override
  String get recipeDetailServingsOne => 'serving';

  @override
  String get recipeDetailServingsMany => 'servings';

  @override
  String get recipeDetailDifficultyLabel => 'difficulty';

  @override
  String get recipeIngredientsTitle => 'Ingredients';

  @override
  String recipeIngredientsCountTotal(int count) {
    return '$count total';
  }

  @override
  String recipeIngredientsCountDetail(int inPantry, int missing) {
    return '$inPantry in your pantry · $missing to get';
  }

  @override
  String get recipeIngredientInPantry => 'In your pantry';

  @override
  String get recipeIngredientExpiring => 'Expiring · use it';

  @override
  String get recipeIngredientMissing => 'Buy';

  @override
  String get recipeIngredientOptional => 'Optional';

  @override
  String get recipeStepsTitle => 'Preparation';

  @override
  String recipeStepsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count steps',
      one: '1 step',
    );
    return '$_temp0';
  }

  @override
  String get recipeAddMissingOne => 'Add the missing one to the list';

  @override
  String recipeAddMissingMany(int count) {
    return 'Add $count missing to the list';
  }

  @override
  String get recipeAddedAllExisted => 'You already had those items on the list';

  @override
  String get recipeAddedOne => '1 item added to the list';

  @override
  String recipeAddedMany(int count) {
    return '$count items added to the list';
  }

  @override
  String recipeAddedMixed(int added, int skipped) {
    return '$added added · $skipped already there';
  }

  @override
  String get recipeViewList => 'View list';

  @override
  String get statusExpired => 'Expired';

  @override
  String get statusExpiringSoon => 'Expiring soon';

  @override
  String get statusOutOfStock => 'Out of stock';

  @override
  String get statusFresh => 'Fresh';

  @override
  String get statusOutOfStockShort => 'OUT OF STOCK';

  @override
  String get statusExpiredShort => 'EXPIRED';

  @override
  String statusDaysLeft(int days) {
    return '${days}d left';
  }

  @override
  String get profileTitle => 'My profile';

  @override
  String get profileUserFallback => 'User';

  @override
  String get profileAccountGoogle => 'Google account';

  @override
  String get profileAccountEmail => 'Email account';

  @override
  String get profileStatsProducts => 'Products';

  @override
  String get profileStatsCategories => 'Categories';

  @override
  String get profileStatsWithPhoto => 'With photo';

  @override
  String get profileAccountTitle => 'Your account';

  @override
  String get profileAccountSubtitle => 'Connected user information';

  @override
  String get profileAccountEmailLabel => 'Email';

  @override
  String get profileAccountNameLabel => 'Name';

  @override
  String get profileAccountTypeLabel => 'Account type';

  @override
  String get profileAccountTypeGoogle => 'Google';

  @override
  String get profileAccountTypePassword => 'Email & password';

  @override
  String get profilePrefsTitle => 'Preferences';

  @override
  String get profilePrefsSubtitle => 'Customize the app to your liking';

  @override
  String get profilePrefsNotifications => 'Alerts and notifications';

  @override
  String get profilePrefsLanguage => 'Language';

  @override
  String get profileAboutTitle => 'About';

  @override
  String get profileAboutSubtitle => 'App information';

  @override
  String get profileAboutVersion => 'Version';

  @override
  String get profileAboutTerms => 'Terms and conditions';

  @override
  String get profileAboutPrivacy => 'Privacy policy';

  @override
  String get profileLogout => 'Log out';

  @override
  String get profileLogoutConfirmTitle => 'Log out';

  @override
  String get profileLogoutConfirmBody =>
      'Are you sure you want to log out? You will need to sign in again.';

  @override
  String get languageSheetTitle => 'Choose language';

  @override
  String get languageSheetSubtitle => 'Changes apply instantly';

  @override
  String get languageSpanish => 'Spanish';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSavedSnack => 'Language updated';

  @override
  String get legalTermsTitle => 'Terms and conditions';

  @override
  String get legalTermsBody =>
      'Welcome to PantryScanner. By using this app you accept the following terms: the app is provided as is, without guarantees of absolute accuracy on expiry dates or inventory. The user is responsible for verifying information before making consumption or purchase decisions. PantryScanner does not store sensitive data outside your device and your Firebase account. The team reserves the right to modify features in future versions.';

  @override
  String get legalPrivacyTitle => 'Privacy policy';

  @override
  String get legalPrivacyBody =>
      'PantryScanner respects your privacy. We collect only: your email (for authentication), the products you register (stored locally on your device and synced with Firebase tied to your account), and app settings (language, preferences). We do not share your information with third parties for advertising purposes. You can delete your account and all related data by contacting the team. Product images are stored locally on your device.';
}
