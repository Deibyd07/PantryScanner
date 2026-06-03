import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es')
  ];

  /// No description provided for @appName.
  ///
  /// In es, this message translates to:
  /// **'PantryScanner'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In es, this message translates to:
  /// **'Tu despensa, bajo control'**
  String get appTagline;

  /// No description provided for @commonCancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get commonCancel;

  /// No description provided for @commonSave.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get commonSave;

  /// No description provided for @commonDelete.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get commonDelete;

  /// No description provided for @commonClose.
  ///
  /// In es, this message translates to:
  /// **'Cerrar'**
  String get commonClose;

  /// No description provided for @commonBack.
  ///
  /// In es, this message translates to:
  /// **'Atrás'**
  String get commonBack;

  /// No description provided for @commonContinue.
  ///
  /// In es, this message translates to:
  /// **'Continuar'**
  String get commonContinue;

  /// No description provided for @commonOk.
  ///
  /// In es, this message translates to:
  /// **'OK'**
  String get commonOk;

  /// No description provided for @commonError.
  ///
  /// In es, this message translates to:
  /// **'Error'**
  String get commonError;

  /// No description provided for @commonRetry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get commonRetry;

  /// No description provided for @commonLoading.
  ///
  /// In es, this message translates to:
  /// **'Cargando…'**
  String get commonLoading;

  /// No description provided for @commonUndo.
  ///
  /// In es, this message translates to:
  /// **'Deshacer'**
  String get commonUndo;

  /// No description provided for @commonSee.
  ///
  /// In es, this message translates to:
  /// **'Ver'**
  String get commonSee;

  /// No description provided for @commonEdit.
  ///
  /// In es, this message translates to:
  /// **'Editar'**
  String get commonEdit;

  /// No description provided for @commonAdd.
  ///
  /// In es, this message translates to:
  /// **'Añadir'**
  String get commonAdd;

  /// No description provided for @commonSearch.
  ///
  /// In es, this message translates to:
  /// **'Buscar'**
  String get commonSearch;

  /// No description provided for @navPantry.
  ///
  /// In es, this message translates to:
  /// **'Despensa'**
  String get navPantry;

  /// No description provided for @navRecipes.
  ///
  /// In es, this message translates to:
  /// **'Recetas'**
  String get navRecipes;

  /// No description provided for @navAlerts.
  ///
  /// In es, this message translates to:
  /// **'Alertas'**
  String get navAlerts;

  /// No description provided for @navProfile.
  ///
  /// In es, this message translates to:
  /// **'Perfil'**
  String get navProfile;

  /// No description provided for @cartTooltip.
  ///
  /// In es, this message translates to:
  /// **'Lista de compras'**
  String get cartTooltip;

  /// No description provided for @popupLogoutTitle.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get popupLogoutTitle;

  /// No description provided for @popupLogoutBody.
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro de que deseas cerrar tu sesión?'**
  String get popupLogoutBody;

  /// No description provided for @inventoryTitle.
  ///
  /// In es, this message translates to:
  /// **'Mi despensa'**
  String get inventoryTitle;

  /// No description provided for @inventoryTagline.
  ///
  /// In es, this message translates to:
  /// **'Organiza · Controla · Ahorra'**
  String get inventoryTagline;

  /// No description provided for @inventorySearchHint.
  ///
  /// In es, this message translates to:
  /// **'Busca en tu despensa...'**
  String get inventorySearchHint;

  /// No description provided for @inventoryClearSearch.
  ///
  /// In es, this message translates to:
  /// **'Limpiar búsqueda'**
  String get inventoryClearSearch;

  /// No description provided for @inventoryEmptyTitle.
  ///
  /// In es, this message translates to:
  /// **'Tu despensa está vacía'**
  String get inventoryEmptyTitle;

  /// No description provided for @inventoryEmptyHint.
  ///
  /// In es, this message translates to:
  /// **'Toca el botón central para escanear tu primer producto'**
  String get inventoryEmptyHint;

  /// No description provided for @inventorySearchNoResults.
  ///
  /// In es, this message translates to:
  /// **'Sin resultados para \"{query}\"'**
  String inventorySearchNoResults(String query);

  /// No description provided for @inventorySearchTryOther.
  ///
  /// In es, this message translates to:
  /// **'Intenta con otro nombre, marca o categoría'**
  String get inventorySearchTryOther;

  /// No description provided for @inventoryLoadError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo cargar el inventario'**
  String get inventoryLoadError;

  /// No description provided for @inventoryDeleteTitle.
  ///
  /// In es, this message translates to:
  /// **'Eliminar producto'**
  String get inventoryDeleteTitle;

  /// No description provided for @inventoryDeleteBody.
  ///
  /// In es, this message translates to:
  /// **'¿Seguro que quieres eliminar \"{name}\" de tu despensa?'**
  String inventoryDeleteBody(String name);

  /// No description provided for @inventoryDeletedSnack.
  ///
  /// In es, this message translates to:
  /// **'\"{name}\" eliminado'**
  String inventoryDeletedSnack(String name);

  /// No description provided for @inventoryConfirmDeleteTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar producto?'**
  String get inventoryConfirmDeleteTitle;

  /// No description provided for @inventoryConfirmDeleteBody.
  ///
  /// In es, this message translates to:
  /// **'La cantidad de \"{name}\" llegará a 0. ¿Quieres eliminarlo del inventario?'**
  String inventoryConfirmDeleteBody(String name);

  /// No description provided for @categoryAll.
  ///
  /// In es, this message translates to:
  /// **'Todos'**
  String get categoryAll;

  /// No description provided for @categoryDairy.
  ///
  /// In es, this message translates to:
  /// **'Lácteos'**
  String get categoryDairy;

  /// No description provided for @categoryMeat.
  ///
  /// In es, this message translates to:
  /// **'Carnes'**
  String get categoryMeat;

  /// No description provided for @categoryFruitsVeg.
  ///
  /// In es, this message translates to:
  /// **'Frutas y verduras'**
  String get categoryFruitsVeg;

  /// No description provided for @categoryCanned.
  ///
  /// In es, this message translates to:
  /// **'Enlatados'**
  String get categoryCanned;

  /// No description provided for @categoryDrinks.
  ///
  /// In es, this message translates to:
  /// **'Bebidas'**
  String get categoryDrinks;

  /// No description provided for @categorySnacks.
  ///
  /// In es, this message translates to:
  /// **'Snacks'**
  String get categorySnacks;

  /// No description provided for @categoryCereals.
  ///
  /// In es, this message translates to:
  /// **'Cereales'**
  String get categoryCereals;

  /// No description provided for @categoryCondiments.
  ///
  /// In es, this message translates to:
  /// **'Condimentos'**
  String get categoryCondiments;

  /// No description provided for @categoryUncategorized.
  ///
  /// In es, this message translates to:
  /// **'Sin categoría'**
  String get categoryUncategorized;

  /// No description provided for @unitOne.
  ///
  /// In es, this message translates to:
  /// **'unidad'**
  String get unitOne;

  /// No description provided for @unitMany.
  ///
  /// In es, this message translates to:
  /// **'unidades'**
  String get unitMany;

  /// No description provided for @insightsTitle.
  ///
  /// In es, this message translates to:
  /// **'Resumen inteligente'**
  String get insightsTitle;

  /// No description provided for @insightsMetricExpired.
  ///
  /// In es, this message translates to:
  /// **'Vencidos'**
  String get insightsMetricExpired;

  /// No description provided for @insightsMetricProducts.
  ///
  /// In es, this message translates to:
  /// **'Productos'**
  String get insightsMetricProducts;

  /// No description provided for @insightsMetricExpiring.
  ///
  /// In es, this message translates to:
  /// **'Por vencer'**
  String get insightsMetricExpiring;

  /// No description provided for @insightsEmpty.
  ///
  /// In es, this message translates to:
  /// **'Aún no tienes productos en tu despensa'**
  String get insightsEmpty;

  /// No description provided for @insightsAllGood.
  ///
  /// In es, this message translates to:
  /// **'Todo en orden: nada por vencer pronto'**
  String get insightsAllGood;

  /// No description provided for @insightsMixed.
  ///
  /// In es, this message translates to:
  /// **'{expired} vencidos · {expiring} por vencer pronto'**
  String insightsMixed(int expired, int expiring);

  /// No description provided for @insightsExpired.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 producto vencido} other{{count} productos vencidos}}'**
  String insightsExpired(int count);

  /// No description provided for @insightsExpiring.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 producto vence pronto} other{{count} productos vencen pronto}}'**
  String insightsExpiring(int count);

  /// No description provided for @sortTitle.
  ///
  /// In es, this message translates to:
  /// **'Ordenar por'**
  String get sortTitle;

  /// No description provided for @sortExpiryDate.
  ///
  /// In es, this message translates to:
  /// **'Fecha de vencimiento'**
  String get sortExpiryDate;

  /// No description provided for @sortName.
  ///
  /// In es, this message translates to:
  /// **'Nombre A-Z'**
  String get sortName;

  /// No description provided for @sortQuantity.
  ///
  /// In es, this message translates to:
  /// **'Cantidad'**
  String get sortQuantity;

  /// No description provided for @sortCategory.
  ///
  /// In es, this message translates to:
  /// **'Categoría'**
  String get sortCategory;

  /// No description provided for @sortAscending.
  ///
  /// In es, this message translates to:
  /// **'Ascendente'**
  String get sortAscending;

  /// No description provided for @sortDescending.
  ///
  /// In es, this message translates to:
  /// **'Descendente'**
  String get sortDescending;

  /// No description provided for @sortApply.
  ///
  /// In es, this message translates to:
  /// **'Aplicar'**
  String get sortApply;

  /// No description provided for @cartTitle.
  ///
  /// In es, this message translates to:
  /// **'Lista de compras'**
  String get cartTitle;

  /// No description provided for @cartEmpty.
  ///
  /// In es, this message translates to:
  /// **'Aún no has añadido nada'**
  String get cartEmpty;

  /// No description provided for @cartAllDone.
  ///
  /// In es, this message translates to:
  /// **'¡Todo conseguido!'**
  String get cartAllDone;

  /// No description provided for @cartPendingCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 ítem por comprar} other{{count} ítems por comprar}}'**
  String cartPendingCount(int count);

  /// No description provided for @cartStatTotal.
  ///
  /// In es, this message translates to:
  /// **'Total'**
  String get cartStatTotal;

  /// No description provided for @cartStatPending.
  ///
  /// In es, this message translates to:
  /// **'Pendientes'**
  String get cartStatPending;

  /// No description provided for @cartStatDone.
  ///
  /// In es, this message translates to:
  /// **'Conseguidos'**
  String get cartStatDone;

  /// No description provided for @cartSectionToBuy.
  ///
  /// In es, this message translates to:
  /// **'Por comprar'**
  String get cartSectionToBuy;

  /// No description provided for @cartSectionManual.
  ///
  /// In es, this message translates to:
  /// **'Agregados manualmente'**
  String get cartSectionManual;

  /// No description provided for @cartSectionRecipe.
  ///
  /// In es, this message translates to:
  /// **'Faltan para preparar esta receta'**
  String get cartSectionRecipe;

  /// No description provided for @cartSectionDone.
  ///
  /// In es, this message translates to:
  /// **'Ya tienes'**
  String get cartSectionDone;

  /// No description provided for @cartSectionDoneSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Marcados como conseguidos'**
  String get cartSectionDoneSubtitle;

  /// No description provided for @cartClearDoneTooltip.
  ///
  /// In es, this message translates to:
  /// **'Borrar conseguidos'**
  String get cartClearDoneTooltip;

  /// No description provided for @cartClearDoneTitle.
  ///
  /// In es, this message translates to:
  /// **'Quitar conseguidos'**
  String get cartClearDoneTitle;

  /// No description provided for @cartClearDoneBody.
  ///
  /// In es, this message translates to:
  /// **'¿Quieres borrar todos los ítems que ya marcaste como conseguidos?'**
  String get cartClearDoneBody;

  /// No description provided for @cartQuickAddHint.
  ///
  /// In es, this message translates to:
  /// **'Añadir ítem (ej. Leche 2 L, 3 huevos)'**
  String get cartQuickAddHint;

  /// No description provided for @cartDeletedSnack.
  ///
  /// In es, this message translates to:
  /// **'Eliminaste \"{name}\"'**
  String cartDeletedSnack(String name);

  /// No description provided for @cartClearedSnack.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{Borraste 1 conseguido} other{Borraste {count} conseguidos}}'**
  String cartClearedSnack(int count);

  /// No description provided for @cartEmptyTitle.
  ///
  /// In es, this message translates to:
  /// **'Tu lista está vacía'**
  String get cartEmptyTitle;

  /// No description provided for @cartEmptyHint.
  ///
  /// In es, this message translates to:
  /// **'Añade ítems con el campo de arriba o desde una receta usando \"Añadir faltantes a la lista\".'**
  String get cartEmptyHint;

  /// No description provided for @cartMarkAll.
  ///
  /// In es, this message translates to:
  /// **'Todos'**
  String get cartMarkAll;

  /// No description provided for @cartEditItemTitle.
  ///
  /// In es, this message translates to:
  /// **'Editar ítem'**
  String get cartEditItemTitle;

  /// No description provided for @cartEditNameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get cartEditNameLabel;

  /// No description provided for @cartEditQtyLabel.
  ///
  /// In es, this message translates to:
  /// **'Cantidad (opcional)'**
  String get cartEditQtyLabel;

  /// No description provided for @cartEditQtyHint.
  ///
  /// In es, this message translates to:
  /// **'Ej. 2 L, 500 g, 3 unidades'**
  String get cartEditQtyHint;

  /// No description provided for @cartDeleteItemTooltip.
  ///
  /// In es, this message translates to:
  /// **'Eliminar de la lista'**
  String get cartDeleteItemTooltip;

  /// No description provided for @cartEditTooltip.
  ///
  /// In es, this message translates to:
  /// **'Editar'**
  String get cartEditTooltip;

  /// No description provided for @recipeDifficultyEasy.
  ///
  /// In es, this message translates to:
  /// **'Fácil'**
  String get recipeDifficultyEasy;

  /// No description provided for @recipeDifficultyMedium.
  ///
  /// In es, this message translates to:
  /// **'Medio'**
  String get recipeDifficultyMedium;

  /// No description provided for @recipeDifficultyAdvanced.
  ///
  /// In es, this message translates to:
  /// **'Avanzado'**
  String get recipeDifficultyAdvanced;

  /// No description provided for @recipeMealBreakfast.
  ///
  /// In es, this message translates to:
  /// **'Desayuno'**
  String get recipeMealBreakfast;

  /// No description provided for @recipeMealLunch.
  ///
  /// In es, this message translates to:
  /// **'Almuerzo'**
  String get recipeMealLunch;

  /// No description provided for @recipeMealDinner.
  ///
  /// In es, this message translates to:
  /// **'Cena'**
  String get recipeMealDinner;

  /// No description provided for @recipeMealSnack.
  ///
  /// In es, this message translates to:
  /// **'Snack'**
  String get recipeMealSnack;

  /// No description provided for @recipeMealDessert.
  ///
  /// In es, this message translates to:
  /// **'Postre'**
  String get recipeMealDessert;

  /// No description provided for @recipesLoadError.
  ///
  /// In es, this message translates to:
  /// **'No se pudieron cargar las recetas'**
  String get recipesLoadError;

  /// No description provided for @recipesHeroTitle.
  ///
  /// In es, this message translates to:
  /// **'Cocina con lo que tienes'**
  String get recipesHeroTitle;

  /// No description provided for @recipesHeroEmpty.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay recetas en el catálogo'**
  String get recipesHeroEmpty;

  /// No description provided for @recipesHeroNoneCookable.
  ///
  /// In es, this message translates to:
  /// **'Te faltan algunos ingredientes para cocinar completo'**
  String get recipesHeroNoneCookable;

  /// No description provided for @recipesHeroCookable.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 receta lista para cocinar ahora} other{{count} recetas listas para cocinar ahora}}'**
  String recipesHeroCookable(int count);

  /// No description provided for @recipesStatCatalog.
  ///
  /// In es, this message translates to:
  /// **'En catálogo'**
  String get recipesStatCatalog;

  /// No description provided for @recipesStatCookable.
  ///
  /// In es, this message translates to:
  /// **'Puedes cocinar'**
  String get recipesStatCookable;

  /// No description provided for @recipesStatExpiring.
  ///
  /// In es, this message translates to:
  /// **'Por vencer'**
  String get recipesStatExpiring;

  /// No description provided for @recipesViewPantry.
  ///
  /// In es, this message translates to:
  /// **'Ver despensa'**
  String get recipesViewPantry;

  /// No description provided for @recipesFilterAll.
  ///
  /// In es, this message translates to:
  /// **'Todas'**
  String get recipesFilterAll;

  /// No description provided for @recipesFilterCookable.
  ///
  /// In es, this message translates to:
  /// **'Puedo cocinar'**
  String get recipesFilterCookable;

  /// No description provided for @recipesFilterExpiring.
  ///
  /// In es, this message translates to:
  /// **'Aprovecha por vencer'**
  String get recipesFilterExpiring;

  /// No description provided for @recipesEmptyTitleAll.
  ///
  /// In es, this message translates to:
  /// **'Sin recetas'**
  String get recipesEmptyTitleAll;

  /// No description provided for @recipesEmptyBodyAll.
  ///
  /// In es, this message translates to:
  /// **'Pronto añadiremos más recetas al catálogo.'**
  String get recipesEmptyBodyAll;

  /// No description provided for @recipesEmptyTitleCookable.
  ///
  /// In es, this message translates to:
  /// **'Te faltan ingredientes'**
  String get recipesEmptyTitleCookable;

  /// No description provided for @recipesEmptyBodyCookable.
  ///
  /// In es, this message translates to:
  /// **'Aún no tienes en despensa todos los ingredientes para cocinar una receta completa. Mira el resto y compra lo que te falte.'**
  String get recipesEmptyBodyCookable;

  /// No description provided for @recipesEmptyTitleExpiring.
  ///
  /// In es, this message translates to:
  /// **'Nada por vencer'**
  String get recipesEmptyTitleExpiring;

  /// No description provided for @recipesEmptyBodyExpiring.
  ///
  /// In es, this message translates to:
  /// **'Ninguna receta del catálogo usa productos que estés por perder. ¡Buena gestión!'**
  String get recipesEmptyBodyExpiring;

  /// No description provided for @recipeMinutes.
  ///
  /// In es, this message translates to:
  /// **'{minutes} min'**
  String recipeMinutes(int minutes);

  /// No description provided for @recipeReady.
  ///
  /// In es, this message translates to:
  /// **'Listo'**
  String get recipeReady;

  /// No description provided for @recipeCoveragePercent.
  ///
  /// In es, this message translates to:
  /// **'{percent}%'**
  String recipeCoveragePercent(int percent);

  /// No description provided for @recipeUseExpiringOne.
  ///
  /// In es, this message translates to:
  /// **'Aprovecha 1 producto por vencer'**
  String get recipeUseExpiringOne;

  /// No description provided for @recipeUseExpiringMany.
  ///
  /// In es, this message translates to:
  /// **'Aprovecha {count} productos por vencer'**
  String recipeUseExpiringMany(int count);

  /// No description provided for @recipeMissingOne.
  ///
  /// In es, this message translates to:
  /// **'Te falta 1 ingrediente'**
  String get recipeMissingOne;

  /// No description provided for @recipeMissingMany.
  ///
  /// In es, this message translates to:
  /// **'Te faltan {count} ingredientes'**
  String recipeMissingMany(int count);

  /// No description provided for @recipeDetailNotFound.
  ///
  /// In es, this message translates to:
  /// **'Receta no encontrada'**
  String get recipeDetailNotFound;

  /// No description provided for @recipeDetailCanCookNow.
  ///
  /// In es, this message translates to:
  /// **'Puedes cocinarla ahora'**
  String get recipeDetailCanCookNow;

  /// No description provided for @recipeDetailServingsOne.
  ///
  /// In es, this message translates to:
  /// **'porción'**
  String get recipeDetailServingsOne;

  /// No description provided for @recipeDetailServingsMany.
  ///
  /// In es, this message translates to:
  /// **'porciones'**
  String get recipeDetailServingsMany;

  /// No description provided for @recipeDetailDifficultyLabel.
  ///
  /// In es, this message translates to:
  /// **'dificultad'**
  String get recipeDetailDifficultyLabel;

  /// No description provided for @recipeIngredientsTitle.
  ///
  /// In es, this message translates to:
  /// **'Ingredientes'**
  String get recipeIngredientsTitle;

  /// No description provided for @recipeIngredientsCountTotal.
  ///
  /// In es, this message translates to:
  /// **'{count} en total'**
  String recipeIngredientsCountTotal(int count);

  /// No description provided for @recipeIngredientsCountDetail.
  ///
  /// In es, this message translates to:
  /// **'{inPantry} en tu despensa · {missing} por conseguir'**
  String recipeIngredientsCountDetail(int inPantry, int missing);

  /// No description provided for @recipeIngredientInPantry.
  ///
  /// In es, this message translates to:
  /// **'En tu despensa'**
  String get recipeIngredientInPantry;

  /// No description provided for @recipeIngredientExpiring.
  ///
  /// In es, this message translates to:
  /// **'Por vencer · aprovéchalo'**
  String get recipeIngredientExpiring;

  /// No description provided for @recipeIngredientMissing.
  ///
  /// In es, this message translates to:
  /// **'Comprar'**
  String get recipeIngredientMissing;

  /// No description provided for @recipeIngredientOptional.
  ///
  /// In es, this message translates to:
  /// **'Opcional'**
  String get recipeIngredientOptional;

  /// No description provided for @recipeStepsTitle.
  ///
  /// In es, this message translates to:
  /// **'Preparación'**
  String get recipeStepsTitle;

  /// No description provided for @recipeStepsCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 paso} other{{count} pasos}}'**
  String recipeStepsCount(int count);

  /// No description provided for @recipeAddMissingOne.
  ///
  /// In es, this message translates to:
  /// **'Añadir el faltante a la lista'**
  String get recipeAddMissingOne;

  /// No description provided for @recipeAddMissingMany.
  ///
  /// In es, this message translates to:
  /// **'Añadir {count} faltantes a la lista'**
  String recipeAddMissingMany(int count);

  /// No description provided for @recipeAddedAllExisted.
  ///
  /// In es, this message translates to:
  /// **'Ya tenías esos ítems en la lista'**
  String get recipeAddedAllExisted;

  /// No description provided for @recipeAddedOne.
  ///
  /// In es, this message translates to:
  /// **'1 ítem añadido a la lista'**
  String get recipeAddedOne;

  /// No description provided for @recipeAddedMany.
  ///
  /// In es, this message translates to:
  /// **'{count} ítems añadidos a la lista'**
  String recipeAddedMany(int count);

  /// No description provided for @recipeAddedMixed.
  ///
  /// In es, this message translates to:
  /// **'{added} añadidos · {skipped} ya estaban'**
  String recipeAddedMixed(int added, int skipped);

  /// No description provided for @recipeViewList.
  ///
  /// In es, this message translates to:
  /// **'Ver lista'**
  String get recipeViewList;

  /// No description provided for @statusExpired.
  ///
  /// In es, this message translates to:
  /// **'Vencido'**
  String get statusExpired;

  /// No description provided for @statusExpiringSoon.
  ///
  /// In es, this message translates to:
  /// **'Vence pronto'**
  String get statusExpiringSoon;

  /// No description provided for @statusOutOfStock.
  ///
  /// In es, this message translates to:
  /// **'Agotado'**
  String get statusOutOfStock;

  /// No description provided for @statusFresh.
  ///
  /// In es, this message translates to:
  /// **'Fresco'**
  String get statusFresh;

  /// No description provided for @statusOutOfStockShort.
  ///
  /// In es, this message translates to:
  /// **'SIN STOCK'**
  String get statusOutOfStockShort;

  /// No description provided for @statusExpiredShort.
  ///
  /// In es, this message translates to:
  /// **'VENCIDO'**
  String get statusExpiredShort;

  /// No description provided for @statusDaysLeft.
  ///
  /// In es, this message translates to:
  /// **'{days}d restantes'**
  String statusDaysLeft(int days);

  /// No description provided for @profileTitle.
  ///
  /// In es, this message translates to:
  /// **'Mi perfil'**
  String get profileTitle;

  /// No description provided for @profileUserFallback.
  ///
  /// In es, this message translates to:
  /// **'Usuario'**
  String get profileUserFallback;

  /// No description provided for @profileAccountGoogle.
  ///
  /// In es, this message translates to:
  /// **'Cuenta Google'**
  String get profileAccountGoogle;

  /// No description provided for @profileAccountEmail.
  ///
  /// In es, this message translates to:
  /// **'Cuenta con correo'**
  String get profileAccountEmail;

  /// No description provided for @profileStatsProducts.
  ///
  /// In es, this message translates to:
  /// **'Productos'**
  String get profileStatsProducts;

  /// No description provided for @profileStatsCategories.
  ///
  /// In es, this message translates to:
  /// **'Categorías'**
  String get profileStatsCategories;

  /// No description provided for @profileStatsWithPhoto.
  ///
  /// In es, this message translates to:
  /// **'Con foto'**
  String get profileStatsWithPhoto;

  /// No description provided for @profileAccountTitle.
  ///
  /// In es, this message translates to:
  /// **'Tu cuenta'**
  String get profileAccountTitle;

  /// No description provided for @profileAccountSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Información del usuario conectado'**
  String get profileAccountSubtitle;

  /// No description provided for @profileAccountEmailLabel.
  ///
  /// In es, this message translates to:
  /// **'Correo electrónico'**
  String get profileAccountEmailLabel;

  /// No description provided for @profileAccountNameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get profileAccountNameLabel;

  /// No description provided for @profileAccountTypeLabel.
  ///
  /// In es, this message translates to:
  /// **'Tipo de cuenta'**
  String get profileAccountTypeLabel;

  /// No description provided for @profileAccountTypeGoogle.
  ///
  /// In es, this message translates to:
  /// **'Google'**
  String get profileAccountTypeGoogle;

  /// No description provided for @profileAccountTypePassword.
  ///
  /// In es, this message translates to:
  /// **'Correo y contraseña'**
  String get profileAccountTypePassword;

  /// No description provided for @profilePrefsTitle.
  ///
  /// In es, this message translates to:
  /// **'Preferencias'**
  String get profilePrefsTitle;

  /// No description provided for @profilePrefsSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Personaliza la app a tu gusto'**
  String get profilePrefsSubtitle;

  /// No description provided for @profilePrefsNotifications.
  ///
  /// In es, this message translates to:
  /// **'Alertas y notificaciones'**
  String get profilePrefsNotifications;

  /// No description provided for @profilePrefsLanguage.
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get profilePrefsLanguage;

  /// No description provided for @profileAboutTitle.
  ///
  /// In es, this message translates to:
  /// **'Acerca de'**
  String get profileAboutTitle;

  /// No description provided for @profileAboutSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Información de la aplicación'**
  String get profileAboutSubtitle;

  /// No description provided for @profileAboutVersion.
  ///
  /// In es, this message translates to:
  /// **'Versión'**
  String get profileAboutVersion;

  /// No description provided for @profileAboutTerms.
  ///
  /// In es, this message translates to:
  /// **'Términos y condiciones'**
  String get profileAboutTerms;

  /// No description provided for @profileAboutPrivacy.
  ///
  /// In es, this message translates to:
  /// **'Política de privacidad'**
  String get profileAboutPrivacy;

  /// No description provided for @profileLogout.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get profileLogout;

  /// No description provided for @profileLogoutConfirmTitle.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get profileLogoutConfirmTitle;

  /// No description provided for @profileLogoutConfirmBody.
  ///
  /// In es, this message translates to:
  /// **'¿Seguro que quieres cerrar tu sesión? Tendrás que iniciar sesión de nuevo.'**
  String get profileLogoutConfirmBody;

  /// No description provided for @languageSheetTitle.
  ///
  /// In es, this message translates to:
  /// **'Elegir idioma'**
  String get languageSheetTitle;

  /// No description provided for @languageSheetSubtitle.
  ///
  /// In es, this message translates to:
  /// **'El cambio se aplica al instante'**
  String get languageSheetSubtitle;

  /// No description provided for @languageSpanish.
  ///
  /// In es, this message translates to:
  /// **'Español'**
  String get languageSpanish;

  /// No description provided for @languageEnglish.
  ///
  /// In es, this message translates to:
  /// **'Inglés'**
  String get languageEnglish;

  /// No description provided for @languageSavedSnack.
  ///
  /// In es, this message translates to:
  /// **'Idioma actualizado'**
  String get languageSavedSnack;

  /// No description provided for @legalTermsTitle.
  ///
  /// In es, this message translates to:
  /// **'Términos y condiciones'**
  String get legalTermsTitle;

  /// No description provided for @legalTermsBody.
  ///
  /// In es, this message translates to:
  /// **'Bienvenido a PantryScanner. Al usar esta aplicación aceptas los siguientes términos: la app se ofrece tal cual, sin garantías de exactitud absoluta en fechas de vencimiento o inventario. El usuario es responsable de verificar la información antes de tomar decisiones de consumo o compra. PantryScanner no almacena datos sensibles fuera de tu dispositivo y tu cuenta Firebase. El equipo se reserva el derecho de modificar funcionalidades en futuras versiones.'**
  String get legalTermsBody;

  /// No description provided for @legalPrivacyTitle.
  ///
  /// In es, this message translates to:
  /// **'Política de privacidad'**
  String get legalPrivacyTitle;

  /// No description provided for @legalPrivacyBody.
  ///
  /// In es, this message translates to:
  /// **'PantryScanner respeta tu privacidad. Recopilamos solo: tu correo electrónico (para autenticación), los productos que registras (almacenados localmente en tu dispositivo y sincronizados con Firebase asociados a tu cuenta), y configuraciones de la app (idioma, preferencias). No compartimos tu información con terceros con fines publicitarios. Puedes eliminar tu cuenta y todos los datos asociados contactando al equipo. Las imágenes de productos se almacenan localmente en tu dispositivo.'**
  String get legalPrivacyBody;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
