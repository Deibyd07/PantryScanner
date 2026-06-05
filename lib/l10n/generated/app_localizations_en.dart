// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Foodly';

  @override
  String get appTagline => 'Your pantry, under control';

  @override
  String get offlineBanner => 'No internet connection';

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
  String get commonConfirm => 'Confirm';

  @override
  String get commonCreate => 'Create';

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
  String get profileEditNameTitle => 'Edit name';

  @override
  String get profileNameUpdated => 'Name updated';

  @override
  String profileNameUpdateError(String error) {
    return 'Could not update name: $error';
  }

  @override
  String get profileSecurityTitle => 'Security';

  @override
  String get profileSecuritySubtitle => 'Password and account access';

  @override
  String get profileChangePassword => 'Change password';

  @override
  String get profileChangePasswordTitle => 'Change password';

  @override
  String get profileCurrentPasswordLabel => 'Current password';

  @override
  String get profileNewPasswordLabel => 'New password';

  @override
  String get profileConfirmNewPasswordLabel => 'Confirm new password';

  @override
  String get profilePasswordUpdated => 'Password updated';

  @override
  String profilePasswordUpdateError(String error) {
    return 'Error changing password: $error';
  }

  @override
  String get profileDeleteAccount => 'Delete account';

  @override
  String get profileDeleteAccountTitle => 'Delete your account?';

  @override
  String get profileDeleteAccountBody =>
      'All your Foodly data will be permanently deleted. This action cannot be undone.';

  @override
  String get profileDeleteAccountConfirmBtn => 'Yes, delete my account';

  @override
  String get profileDeletePasswordHint => 'Enter your password to confirm';

  @override
  String get profileDeleteReauthGoogle =>
      'Your Google identity will be verified before deleting your account.';

  @override
  String get profileDeleteSuccess => 'Account deleted';

  @override
  String profileDeleteError(String error) {
    return 'Could not delete account: $error';
  }

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
      'Welcome to Foodly. By using this app you accept the following terms: the app is provided as is, without guarantees of absolute accuracy on expiry dates or inventory. The user is responsible for verifying information before making consumption or purchase decisions. Foodly does not store sensitive data outside your device and your Firebase account. The team reserves the right to modify features in future versions.';

  @override
  String get legalPrivacyTitle => 'Privacy policy';

  @override
  String get legalPrivacyBody =>
      'Foodly respects your privacy. We collect only: your email (for authentication), the products you register (stored locally on your device and synced with Firebase tied to your account), and app settings (language, preferences). We do not share your information with third parties for advertising purposes. You can delete your account and all related data by contacting the team. Product images are stored locally on your device.';

  @override
  String get productFormHeroTitleAdd => 'Add product';

  @override
  String get productFormHeroTitleEdit => 'Edit product';

  @override
  String get productFormHeroSubtitle =>
      'Fill in the data and save it to your pantry';

  @override
  String get productFormSectionPhoto => 'Product photo';

  @override
  String get productFormSectionBasic => 'Basic information';

  @override
  String get productFormSectionCategory => 'Category';

  @override
  String get productFormSectionQuantity => 'Quantity';

  @override
  String get productFormSectionMinStock => 'Minimum stock';

  @override
  String get productFormSectionExpiry => 'Expiry date';

  @override
  String get productFormSectionNotes => 'Optional notes';

  @override
  String get productFormMinStockHint =>
      'You\'ll get an alert when the quantity reaches this value.';

  @override
  String get productFormUnitsLabel => 'Units in inventory';

  @override
  String get productFormMinStockLabel => 'Minimum alert quantity';

  @override
  String get productFormNoExpiry => 'No expiry date';

  @override
  String get productFormNotesLabel => 'Notes (optional)';

  @override
  String get productFormNotesHint => 'E.g. Bought on sale, check before using…';

  @override
  String get productFormSave => 'Save to inventory';

  @override
  String productFormSaveError(String error) {
    return 'Save error: $error';
  }

  @override
  String productFormSavedSnack(String name) {
    return '$name added to inventory!';
  }

  @override
  String productFormUpdatedSnack(String name) {
    return '$name updated!';
  }

  @override
  String get productFormDatePickerHelp => 'Select expiry date';

  @override
  String get productFormNameLabel => 'Product name';

  @override
  String get productFormNameHint => 'E.g. Whole milk, Brown rice…';

  @override
  String get productFormNameRequired => 'Name is required';

  @override
  String get productFormNameMin => 'Name must be at least 2 characters';

  @override
  String get productFormBarcodeLabel => 'Barcode';

  @override
  String get productFormBarcodeScanned => 'Scanned code';

  @override
  String get productFormCreateNewCategory => 'Create new';

  @override
  String get productFormNewCategoryTitle => 'New category';

  @override
  String get productFormNewCategoryHint => 'Category name';

  @override
  String get productFormImagePickerTitle => 'Add product photo';

  @override
  String get productFormTakePhoto => 'Take photo';

  @override
  String get productFormTakePhotoSubtitle => 'Opens the device camera';

  @override
  String get productFormUploadImage => 'Upload image';

  @override
  String get productFormUploadFromGallery => 'Upload from gallery';

  @override
  String get productFormUploadFromComputerSubtitle =>
      'Choose an image from your computer';

  @override
  String get productFormUploadFromGallerySubtitle => 'Choose a saved image';

  @override
  String get productFormCameraWebNotice =>
      'Camera is only available in the mobile app.';

  @override
  String get productFormRemovePhoto => 'Remove photo';

  @override
  String get productFormRemovePhotoSubtitle => 'Delete the selected image';

  @override
  String get productFormChangePhoto => 'Change photo';

  @override
  String get productFormPhotoOptionsHint => 'Camera · Gallery · Optional';

  @override
  String productFormImagePickerError(String error) {
    return 'Camera/gallery error: $error';
  }

  @override
  String get productFormImageUploading => 'Uploading image…';

  @override
  String get productFormImageUploadError =>
      'Could not upload the image. Please try again.';

  @override
  String get productLookupLoadingTitle => 'Looking up product…';

  @override
  String get productLookupLoadingSubtitle => 'Querying global food database.';

  @override
  String get productLookupFoundTitle => 'Product found';

  @override
  String get productLookupFoundCacheSubtitle =>
      'Loaded from local cache. Review the data before saving.';

  @override
  String get productLookupFoundApiSubtitle =>
      'Data auto-filled from OpenFoodFacts. Review before saving.';

  @override
  String get productLookupNotFoundTitle => 'Product not recognized';

  @override
  String get productLookupNotFoundSubtitle =>
      'Fill in the fields manually to add it to your pantry.';

  @override
  String get productLookupFoundSnack => 'Product found and auto-filled.';

  @override
  String get productLookupNotFoundSnack =>
      'Product not recognized. Enter it manually.';

  @override
  String get productDetailLoadError => 'Could not load product';

  @override
  String get productDetailNotInPantry =>
      'This product is no longer in your pantry';

  @override
  String get productDetailUnitOne => 'unit';

  @override
  String get productDetailUnitMany => 'units';

  @override
  String get productDetailNoExpiryShort => 'no expiry';

  @override
  String get productDetailDaysExpiredMany => 'days expired';

  @override
  String get productDetailExpiresToday => 'expires today';

  @override
  String get productDetailDayLeft => 'day left';

  @override
  String get productDetailDaysLeftMany => 'days left';

  @override
  String get productDetailMinStockShort => 'min. stock';

  @override
  String get productDetailQtyCardTitle => 'Quantity';

  @override
  String get productDetailQtyCardCaption => 'Adjust how many units you have';

  @override
  String get productDetailDetailsCardTitle => 'Details';

  @override
  String get productDetailDetailsCardCaption => 'Product information';

  @override
  String get productDetailNotesCardTitle => 'Notes';

  @override
  String get productDetailNotesCardCaption => 'Your notes about this product';

  @override
  String get productDetailRowBarcode => 'Barcode';

  @override
  String get productDetailRowBarcodeMissing => 'No code';

  @override
  String get productDetailRowCategory => 'Category';

  @override
  String get productDetailRowExpiry => 'Expiry';

  @override
  String get productDetailRowExpiryMissing => 'Not set';

  @override
  String get productDetailRowAdded => 'Added';

  @override
  String get productDetailRowUpdated => 'Last edit';

  @override
  String get productDetailActionReplenish => 'Replenish · add to cart';

  @override
  String get productDetailActionEdit => 'Edit product';

  @override
  String get productDetailActionAddToCart => 'Add to cart';

  @override
  String get productDetailActionDelete => 'Delete product';

  @override
  String productDetailCartAlreadyHad(String name) {
    return '\"$name\" was already in your cart';
  }

  @override
  String productDetailCartAdded(String name) {
    return 'Added \"$name\" to your cart';
  }

  @override
  String get commonChange => 'Change';

  @override
  String get notifHeroTitle => 'Alerts';

  @override
  String get notifHeroEnabledSubtitle =>
      'Configure when and how you receive pantry warnings.';

  @override
  String get notifHeroDisabledSubtitle =>
      'Alerts are paused. Turn them on so nothing slips by.';

  @override
  String get notifViewInboxTooltip => 'View received notifications';

  @override
  String get notifConfigTooltip => 'Configure alerts';

  @override
  String notifSaveError(String error) {
    return 'Could not save settings: $error';
  }

  @override
  String get notifLoadError => 'Could not load settings.';

  @override
  String get notifPermissionDenied =>
      'Permission denied. Enable it in system settings.';

  @override
  String get notifMasterEnabled => 'Alerts on';

  @override
  String get notifMasterDisabled => 'Alerts paused';

  @override
  String get notifMasterEnabledSub =>
      'We\'ll warn you before anything expires.';

  @override
  String get notifMasterDisabledSub =>
      'Turn them on to receive expiry warnings.';

  @override
  String get notifThresholdTitle => 'Global threshold';

  @override
  String get notifThresholdSubtitle => 'Warn X days before something expires.';

  @override
  String notifDaysCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get notifTimeCardTitle => 'Preferred time';

  @override
  String get notifTimeCardSubtitle => 'Alerts will be sent at this time.';

  @override
  String get notifTimePickerHelp => 'Preferred alert time';

  @override
  String get notifCategoryRulesTitle => 'Category rules';

  @override
  String get notifCategoryRulesSubtitle =>
      'Override the global threshold for a specific category.';

  @override
  String get notifChangeThresholdTooltip => 'Change threshold';

  @override
  String get notifUseGlobal => 'Use global';

  @override
  String get notifLabelGlobal => 'Global';

  @override
  String get notifInstantBanner => 'Changes apply instantly to your alerts.';

  @override
  String get notifInboxTitle => 'Notifications';

  @override
  String get notifInboxLoadError => 'Could not load notifications';

  @override
  String get notifInboxAllGood => 'Everything\'s fine for now';

  @override
  String notifInboxAttentionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count products need your attention',
      one: '1 product needs your attention',
    );
    return '$_temp0';
  }

  @override
  String get notifInboxChipExpired => 'Expired';

  @override
  String get notifInboxChipExpiring => 'Expiring';

  @override
  String get notifInboxChipLowStock => 'Low stock';

  @override
  String get notifInboxSectionExpiredTitle => 'Expired';

  @override
  String get notifInboxSectionExpiredCaption => 'Remove them from your pantry';

  @override
  String get notifInboxSectionExpiringTitle => 'Expiring soon';

  @override
  String get notifInboxSectionExpiringCaption =>
      'Use them in the next few days';

  @override
  String get notifInboxSectionLowStockTitle => 'Low stock';

  @override
  String get notifInboxSectionLowStockCaption => 'You\'ll need to restock soon';

  @override
  String get notifExpiredToday => 'Expired today';

  @override
  String get notifExpiredOneDay => 'Expired 1 day ago';

  @override
  String notifExpiredManyDays(int days) {
    return 'Expired $days days ago';
  }

  @override
  String get notifExpiresToday => 'Expires today';

  @override
  String get notifExpiresTomorrow => 'Expires tomorrow';

  @override
  String notifExpiresInDays(int days, String date) {
    return 'Expires in $days days · $date';
  }

  @override
  String notifLowStockRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count units left',
      one: '1 unit left',
    );
    return '$_temp0';
  }

  @override
  String get notifInboxEmptyTitle => 'No notifications';

  @override
  String get notifInboxEmptyBody =>
      'Your pantry is in order. When a product is about to expire or runs low, alerts will appear here.';

  @override
  String get scannerTitle => 'Product scanner';

  @override
  String get scannerManualBtn => 'Manual';

  @override
  String get scannerCameraError =>
      'Could not start the camera. Check permissions and try again.';

  @override
  String scannerDetectedCode(String code) {
    return 'Code detected: $code';
  }

  @override
  String get scannerInvalidCode =>
      'Code not recognized. Use a valid EAN-13 or UPC-A.';

  @override
  String get scannerAddProduct => 'Add product';

  @override
  String get scannerPermDisabledTitle => 'Camera permission disabled';

  @override
  String get scannerPermRequestTitle => 'We need camera access';

  @override
  String get scannerPermDisabledBody =>
      'Enable the camera permission in system settings to scan barcodes again.';

  @override
  String get scannerPermRequestBody =>
      'We use the camera only to read EAN-13 and UPC-A codes from your products. You can continue with manual entry if you prefer.';

  @override
  String get scannerPermRequesting => 'Requesting permission…';

  @override
  String get scannerPermAllow => 'Allow camera';

  @override
  String get scannerPermOpenSettings => 'Open settings';

  @override
  String get scannerManualEntry => 'Enter code manually';

  @override
  String get scannerGuideHint => 'Align the code inside the frame';

  @override
  String get scannerFlashOn => 'Turn on flashlight';

  @override
  String get scannerFlashOff => 'Turn off flashlight';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authPasswordLabel => 'Password';

  @override
  String get authEmailRequired => 'Enter your email address';

  @override
  String get authEmailInvalid => 'Invalid email format';

  @override
  String get authPasswordRequired => 'Enter your password';

  @override
  String get authUnexpectedError => 'Unexpected error. Please try again.';

  @override
  String get authWelcomeBack => 'Welcome back';

  @override
  String get authWelcomeBackSub => 'Enter your details to continue';

  @override
  String get authSignInBtn => 'Sign in';

  @override
  String get authForgotPassword => 'Forgot your password?';

  @override
  String get authOrContinueWith => 'or continue with';

  @override
  String get authNoAccount => 'Don\'t have an account? ';

  @override
  String get authCreateAccount => 'Create account';

  @override
  String get authCreateAccountSub => 'Complete your details to register';

  @override
  String get authFullNameLabel => 'Full name';

  @override
  String get authNameRequired => 'Enter your name';

  @override
  String get authConfirmPasswordLabel => 'Confirm password';

  @override
  String get authPasswordMin => 'Minimum 8 characters';

  @override
  String get authPasswordUppercase =>
      'Must include at least 1 uppercase letter';

  @override
  String get authPasswordNumber => 'Must include at least 1 number';

  @override
  String get authConfirmPasswordRequired => 'Confirm your password';

  @override
  String get authPasswordMismatch => 'Passwords don\'t match';

  @override
  String get authRegisterHeroSub => 'Join and organize your pantry';

  @override
  String get authAlreadyHaveAccount => 'Already have an account? ';

  @override
  String get authRecoverTitle => 'Recover password';

  @override
  String get authRecoverSub =>
      'Enter your email and we\'ll send you a link to reset it.';

  @override
  String get authSendResetLink => 'Send link';

  @override
  String get authRememberedPassword => 'Remembered your password? ';

  @override
  String get authEmailSentTitle => 'Email sent!';

  @override
  String authEmailSentBody(String email) {
    return 'Check your inbox at\n$email\nand follow the link to reset your password.';
  }

  @override
  String get authBackToLogin => 'Back to login';

  @override
  String get authRecoverHeroSub => 'Recover access to your account.';
}
