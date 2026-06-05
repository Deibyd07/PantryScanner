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
  /// **'Foodly'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In es, this message translates to:
  /// **'Tu despensa, bajo control'**
  String get appTagline;

  /// No description provided for @offlineBanner.
  ///
  /// In es, this message translates to:
  /// **'Sin conexión a internet'**
  String get offlineBanner;

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

  /// No description provided for @commonConfirm.
  ///
  /// In es, this message translates to:
  /// **'Confirmar'**
  String get commonConfirm;

  /// No description provided for @commonCreate.
  ///
  /// In es, this message translates to:
  /// **'Crear'**
  String get commonCreate;

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

  /// No description provided for @inventoryBelowMinStockSnack.
  ///
  /// In es, this message translates to:
  /// **'\"{name}\" está en su stock mínimo'**
  String inventoryBelowMinStockSnack(String name);

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

  /// No description provided for @profileEditNameTitle.
  ///
  /// In es, this message translates to:
  /// **'Editar nombre'**
  String get profileEditNameTitle;

  /// No description provided for @profileNameUpdated.
  ///
  /// In es, this message translates to:
  /// **'Nombre actualizado'**
  String get profileNameUpdated;

  /// No description provided for @profileNameUpdateError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo actualizar el nombre: {error}'**
  String profileNameUpdateError(String error);

  /// No description provided for @profileSecurityTitle.
  ///
  /// In es, this message translates to:
  /// **'Seguridad'**
  String get profileSecurityTitle;

  /// No description provided for @profileSecuritySubtitle.
  ///
  /// In es, this message translates to:
  /// **'Contraseña y datos de acceso'**
  String get profileSecuritySubtitle;

  /// No description provided for @profileChangePassword.
  ///
  /// In es, this message translates to:
  /// **'Cambiar contraseña'**
  String get profileChangePassword;

  /// No description provided for @profileChangePasswordTitle.
  ///
  /// In es, this message translates to:
  /// **'Cambiar contraseña'**
  String get profileChangePasswordTitle;

  /// No description provided for @profileCurrentPasswordLabel.
  ///
  /// In es, this message translates to:
  /// **'Contraseña actual'**
  String get profileCurrentPasswordLabel;

  /// No description provided for @profileNewPasswordLabel.
  ///
  /// In es, this message translates to:
  /// **'Nueva contraseña'**
  String get profileNewPasswordLabel;

  /// No description provided for @profileConfirmNewPasswordLabel.
  ///
  /// In es, this message translates to:
  /// **'Confirmar nueva contraseña'**
  String get profileConfirmNewPasswordLabel;

  /// No description provided for @profilePasswordUpdated.
  ///
  /// In es, this message translates to:
  /// **'Contraseña actualizada'**
  String get profilePasswordUpdated;

  /// No description provided for @profilePasswordUpdateError.
  ///
  /// In es, this message translates to:
  /// **'Error al cambiar contraseña: {error}'**
  String profilePasswordUpdateError(String error);

  /// No description provided for @profileDeleteAccount.
  ///
  /// In es, this message translates to:
  /// **'Eliminar cuenta'**
  String get profileDeleteAccount;

  /// No description provided for @profileDeleteAccountTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar tu cuenta?'**
  String get profileDeleteAccountTitle;

  /// No description provided for @profileDeleteAccountBody.
  ///
  /// In es, this message translates to:
  /// **'Todos tus datos de Foodly se eliminarán permanentemente. Esta acción no se puede deshacer.'**
  String get profileDeleteAccountBody;

  /// No description provided for @profileDeleteAccountConfirmBtn.
  ///
  /// In es, this message translates to:
  /// **'Sí, eliminar mi cuenta'**
  String get profileDeleteAccountConfirmBtn;

  /// No description provided for @profileDeletePasswordHint.
  ///
  /// In es, this message translates to:
  /// **'Ingresa tu contraseña para confirmar'**
  String get profileDeletePasswordHint;

  /// No description provided for @profileDeleteReauthGoogle.
  ///
  /// In es, this message translates to:
  /// **'Se verificará tu identidad con Google antes de eliminar la cuenta.'**
  String get profileDeleteReauthGoogle;

  /// No description provided for @profileDeleteSuccess.
  ///
  /// In es, this message translates to:
  /// **'Cuenta eliminada'**
  String get profileDeleteSuccess;

  /// No description provided for @profileDeleteError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo eliminar la cuenta: {error}'**
  String profileDeleteError(String error);

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
  /// **'Bienvenido a Foodly. Al usar esta aplicación aceptas los siguientes términos: la app se ofrece tal cual, sin garantías de exactitud absoluta en fechas de vencimiento o inventario. El usuario es responsable de verificar la información antes de tomar decisiones de consumo o compra. Foodly no almacena datos sensibles fuera de tu dispositivo y tu cuenta Firebase. El equipo se reserva el derecho de modificar funcionalidades en futuras versiones.'**
  String get legalTermsBody;

  /// No description provided for @legalPrivacyTitle.
  ///
  /// In es, this message translates to:
  /// **'Política de privacidad'**
  String get legalPrivacyTitle;

  /// No description provided for @legalPrivacyBody.
  ///
  /// In es, this message translates to:
  /// **'Foodly respeta tu privacidad. Recopilamos solo: tu correo electrónico (para autenticación), los productos que registras (almacenados localmente en tu dispositivo y sincronizados con Firebase asociados a tu cuenta), y configuraciones de la app (idioma, preferencias). No compartimos tu información con terceros con fines publicitarios. Puedes eliminar tu cuenta y todos los datos asociados contactando al equipo. Las imágenes de productos se almacenan localmente en tu dispositivo.'**
  String get legalPrivacyBody;

  /// No description provided for @productFormHeroTitleAdd.
  ///
  /// In es, this message translates to:
  /// **'Agregar producto'**
  String get productFormHeroTitleAdd;

  /// No description provided for @productFormHeroTitleEdit.
  ///
  /// In es, this message translates to:
  /// **'Editar producto'**
  String get productFormHeroTitleEdit;

  /// No description provided for @productFormHeroSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Llena los datos y guarda en tu despensa'**
  String get productFormHeroSubtitle;

  /// No description provided for @productFormSectionPhoto.
  ///
  /// In es, this message translates to:
  /// **'Foto del producto'**
  String get productFormSectionPhoto;

  /// No description provided for @productFormSectionBasic.
  ///
  /// In es, this message translates to:
  /// **'Información básica'**
  String get productFormSectionBasic;

  /// No description provided for @productFormSectionCategory.
  ///
  /// In es, this message translates to:
  /// **'Categoría'**
  String get productFormSectionCategory;

  /// No description provided for @productFormSectionQuantity.
  ///
  /// In es, this message translates to:
  /// **'Cantidad'**
  String get productFormSectionQuantity;

  /// No description provided for @productFormSectionMinStock.
  ///
  /// In es, this message translates to:
  /// **'Stock mínimo'**
  String get productFormSectionMinStock;

  /// No description provided for @productFormSectionExpiry.
  ///
  /// In es, this message translates to:
  /// **'Fecha de vencimiento'**
  String get productFormSectionExpiry;

  /// No description provided for @productFormSectionNotes.
  ///
  /// In es, this message translates to:
  /// **'Notas opcionales'**
  String get productFormSectionNotes;

  /// No description provided for @productFormMinStockHint.
  ///
  /// In es, this message translates to:
  /// **'Recibirás una alerta cuando la cantidad llegue a este valor.'**
  String get productFormMinStockHint;

  /// No description provided for @productFormUnitsLabel.
  ///
  /// In es, this message translates to:
  /// **'Unidades en inventario'**
  String get productFormUnitsLabel;

  /// No description provided for @productFormMinStockLabel.
  ///
  /// In es, this message translates to:
  /// **'Cantidad mínima de alerta'**
  String get productFormMinStockLabel;

  /// No description provided for @productFormNoExpiry.
  ///
  /// In es, this message translates to:
  /// **'Sin fecha de vencimiento'**
  String get productFormNoExpiry;

  /// No description provided for @productFormNotesLabel.
  ///
  /// In es, this message translates to:
  /// **'Notas (opcional)'**
  String get productFormNotesLabel;

  /// No description provided for @productFormNotesHint.
  ///
  /// In es, this message translates to:
  /// **'Ej: Comprado en oferta, revisar antes de usar…'**
  String get productFormNotesHint;

  /// No description provided for @productFormSave.
  ///
  /// In es, this message translates to:
  /// **'Guardar en inventario'**
  String get productFormSave;

  /// No description provided for @productFormSaveError.
  ///
  /// In es, this message translates to:
  /// **'Error al guardar: {error}'**
  String productFormSaveError(String error);

  /// No description provided for @productFormSavedSnack.
  ///
  /// In es, this message translates to:
  /// **'¡{name} agregado al inventario!'**
  String productFormSavedSnack(String name);

  /// No description provided for @productFormUpdatedSnack.
  ///
  /// In es, this message translates to:
  /// **'¡{name} actualizado!'**
  String productFormUpdatedSnack(String name);

  /// No description provided for @productFormDatePickerHelp.
  ///
  /// In es, this message translates to:
  /// **'Selecciona la fecha de vencimiento'**
  String get productFormDatePickerHelp;

  /// No description provided for @productFormNameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre del producto'**
  String get productFormNameLabel;

  /// No description provided for @productFormNameHint.
  ///
  /// In es, this message translates to:
  /// **'Ej: Leche entera, Arroz integral…'**
  String get productFormNameHint;

  /// No description provided for @productFormNameRequired.
  ///
  /// In es, this message translates to:
  /// **'El nombre es obligatorio'**
  String get productFormNameRequired;

  /// No description provided for @productFormNameMin.
  ///
  /// In es, this message translates to:
  /// **'El nombre debe tener al menos 2 caracteres'**
  String get productFormNameMin;

  /// No description provided for @productFormBarcodeLabel.
  ///
  /// In es, this message translates to:
  /// **'Código de barras'**
  String get productFormBarcodeLabel;

  /// No description provided for @productFormBarcodeScanned.
  ///
  /// In es, this message translates to:
  /// **'Código escaneado'**
  String get productFormBarcodeScanned;

  /// No description provided for @productFormCreateNewCategory.
  ///
  /// In es, this message translates to:
  /// **'Crear nueva'**
  String get productFormCreateNewCategory;

  /// No description provided for @productFormNewCategoryTitle.
  ///
  /// In es, this message translates to:
  /// **'Nueva categoría'**
  String get productFormNewCategoryTitle;

  /// No description provided for @productFormNewCategoryHint.
  ///
  /// In es, this message translates to:
  /// **'Nombre de la categoría'**
  String get productFormNewCategoryHint;

  /// No description provided for @productFormImagePickerTitle.
  ///
  /// In es, this message translates to:
  /// **'Agregar foto del producto'**
  String get productFormImagePickerTitle;

  /// No description provided for @productFormTakePhoto.
  ///
  /// In es, this message translates to:
  /// **'Tomar foto'**
  String get productFormTakePhoto;

  /// No description provided for @productFormTakePhotoSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Abre la cámara del dispositivo'**
  String get productFormTakePhotoSubtitle;

  /// No description provided for @productFormUploadImage.
  ///
  /// In es, this message translates to:
  /// **'Subir imagen'**
  String get productFormUploadImage;

  /// No description provided for @productFormUploadFromGallery.
  ///
  /// In es, this message translates to:
  /// **'Subir desde galería'**
  String get productFormUploadFromGallery;

  /// No description provided for @productFormUploadFromComputerSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Elige una imagen de tu computador'**
  String get productFormUploadFromComputerSubtitle;

  /// No description provided for @productFormUploadFromGallerySubtitle.
  ///
  /// In es, this message translates to:
  /// **'Elige una imagen guardada'**
  String get productFormUploadFromGallerySubtitle;

  /// No description provided for @productFormCameraWebNotice.
  ///
  /// In es, this message translates to:
  /// **'La cámara solo está disponible en la app móvil.'**
  String get productFormCameraWebNotice;

  /// No description provided for @productFormRemovePhoto.
  ///
  /// In es, this message translates to:
  /// **'Quitar foto'**
  String get productFormRemovePhoto;

  /// No description provided for @productFormRemovePhotoSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Elimina la imagen seleccionada'**
  String get productFormRemovePhotoSubtitle;

  /// No description provided for @productFormChangePhoto.
  ///
  /// In es, this message translates to:
  /// **'Cambiar foto'**
  String get productFormChangePhoto;

  /// No description provided for @productFormPhotoOptionsHint.
  ///
  /// In es, this message translates to:
  /// **'Cámara · Galería · Opcional'**
  String get productFormPhotoOptionsHint;

  /// No description provided for @productFormImagePickerError.
  ///
  /// In es, this message translates to:
  /// **'Error al abrir cámara/galería: {error}'**
  String productFormImagePickerError(String error);

  /// No description provided for @productFormImageUploading.
  ///
  /// In es, this message translates to:
  /// **'Subiendo imagen…'**
  String get productFormImageUploading;

  /// No description provided for @productFormImageUploadError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo subir la imagen. Intenta de nuevo.'**
  String get productFormImageUploadError;

  /// No description provided for @productLookupLoadingTitle.
  ///
  /// In es, this message translates to:
  /// **'Buscando producto…'**
  String get productLookupLoadingTitle;

  /// No description provided for @productLookupLoadingSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Consultando base de datos global de alimentos.'**
  String get productLookupLoadingSubtitle;

  /// No description provided for @productLookupFoundTitle.
  ///
  /// In es, this message translates to:
  /// **'Producto encontrado'**
  String get productLookupFoundTitle;

  /// No description provided for @productLookupFoundCacheSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Cargado desde la caché local. Revisa los datos antes de guardar.'**
  String get productLookupFoundCacheSubtitle;

  /// No description provided for @productLookupFoundApiSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Datos auto-completados desde OpenFoodFacts. Revisa antes de guardar.'**
  String get productLookupFoundApiSubtitle;

  /// No description provided for @productLookupNotFoundTitle.
  ///
  /// In es, this message translates to:
  /// **'Producto no reconocido'**
  String get productLookupNotFoundTitle;

  /// No description provided for @productLookupNotFoundSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Completa los campos manualmente para agregarlo a tu despensa.'**
  String get productLookupNotFoundSubtitle;

  /// No description provided for @productLookupFoundSnack.
  ///
  /// In es, this message translates to:
  /// **'Producto encontrado y autocompletado.'**
  String get productLookupFoundSnack;

  /// No description provided for @productLookupNotFoundSnack.
  ///
  /// In es, this message translates to:
  /// **'Producto no reconocido. Ingrésalo manualmente.'**
  String get productLookupNotFoundSnack;

  /// No description provided for @productDetailLoadError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo cargar el producto'**
  String get productDetailLoadError;

  /// No description provided for @productDetailNotInPantry.
  ///
  /// In es, this message translates to:
  /// **'Este producto ya no está en tu despensa'**
  String get productDetailNotInPantry;

  /// No description provided for @productDetailUnitOne.
  ///
  /// In es, this message translates to:
  /// **'unidad'**
  String get productDetailUnitOne;

  /// No description provided for @productDetailUnitMany.
  ///
  /// In es, this message translates to:
  /// **'unidades'**
  String get productDetailUnitMany;

  /// No description provided for @productDetailNoExpiryShort.
  ///
  /// In es, this message translates to:
  /// **'sin vencimiento'**
  String get productDetailNoExpiryShort;

  /// No description provided for @productDetailDaysExpiredMany.
  ///
  /// In es, this message translates to:
  /// **'días vencido'**
  String get productDetailDaysExpiredMany;

  /// No description provided for @productDetailExpiresToday.
  ///
  /// In es, this message translates to:
  /// **'vence hoy'**
  String get productDetailExpiresToday;

  /// No description provided for @productDetailDayLeft.
  ///
  /// In es, this message translates to:
  /// **'día restante'**
  String get productDetailDayLeft;

  /// No description provided for @productDetailDaysLeftMany.
  ///
  /// In es, this message translates to:
  /// **'días restantes'**
  String get productDetailDaysLeftMany;

  /// No description provided for @productDetailMinStockShort.
  ///
  /// In es, this message translates to:
  /// **'stock mín.'**
  String get productDetailMinStockShort;

  /// No description provided for @productDetailQtyCardTitle.
  ///
  /// In es, this message translates to:
  /// **'Cantidad'**
  String get productDetailQtyCardTitle;

  /// No description provided for @productDetailQtyCardCaption.
  ///
  /// In es, this message translates to:
  /// **'Ajusta cuántas unidades tienes'**
  String get productDetailQtyCardCaption;

  /// No description provided for @productDetailDetailsCardTitle.
  ///
  /// In es, this message translates to:
  /// **'Detalles'**
  String get productDetailDetailsCardTitle;

  /// No description provided for @productDetailDetailsCardCaption.
  ///
  /// In es, this message translates to:
  /// **'Información del producto'**
  String get productDetailDetailsCardCaption;

  /// No description provided for @productDetailNotesCardTitle.
  ///
  /// In es, this message translates to:
  /// **'Notas'**
  String get productDetailNotesCardTitle;

  /// No description provided for @productDetailNotesCardCaption.
  ///
  /// In es, this message translates to:
  /// **'Tus apuntes sobre este producto'**
  String get productDetailNotesCardCaption;

  /// No description provided for @productDetailRowBarcode.
  ///
  /// In es, this message translates to:
  /// **'Código de barras'**
  String get productDetailRowBarcode;

  /// No description provided for @productDetailRowBarcodeMissing.
  ///
  /// In es, this message translates to:
  /// **'Sin código'**
  String get productDetailRowBarcodeMissing;

  /// No description provided for @productDetailRowCategory.
  ///
  /// In es, this message translates to:
  /// **'Categoría'**
  String get productDetailRowCategory;

  /// No description provided for @productDetailRowExpiry.
  ///
  /// In es, this message translates to:
  /// **'Vencimiento'**
  String get productDetailRowExpiry;

  /// No description provided for @productDetailRowExpiryMissing.
  ///
  /// In es, this message translates to:
  /// **'No registrado'**
  String get productDetailRowExpiryMissing;

  /// No description provided for @productDetailRowAdded.
  ///
  /// In es, this message translates to:
  /// **'Agregado'**
  String get productDetailRowAdded;

  /// No description provided for @productDetailRowUpdated.
  ///
  /// In es, this message translates to:
  /// **'Última edición'**
  String get productDetailRowUpdated;

  /// No description provided for @productDetailActionReplenish.
  ///
  /// In es, this message translates to:
  /// **'Reponer · añadir al carrito'**
  String get productDetailActionReplenish;

  /// No description provided for @productDetailActionEdit.
  ///
  /// In es, this message translates to:
  /// **'Editar producto'**
  String get productDetailActionEdit;

  /// No description provided for @productDetailActionAddToCart.
  ///
  /// In es, this message translates to:
  /// **'Añadir al carrito'**
  String get productDetailActionAddToCart;

  /// No description provided for @productDetailActionDelete.
  ///
  /// In es, this message translates to:
  /// **'Eliminar producto'**
  String get productDetailActionDelete;

  /// No description provided for @productDetailCartAlreadyHad.
  ///
  /// In es, this message translates to:
  /// **'Ya tenías \"{name}\" en tu carrito'**
  String productDetailCartAlreadyHad(String name);

  /// No description provided for @productDetailCartAdded.
  ///
  /// In es, this message translates to:
  /// **'Añadiste \"{name}\" al carrito'**
  String productDetailCartAdded(String name);

  /// No description provided for @commonChange.
  ///
  /// In es, this message translates to:
  /// **'Cambiar'**
  String get commonChange;

  /// No description provided for @notifHeroTitle.
  ///
  /// In es, this message translates to:
  /// **'Alertas'**
  String get notifHeroTitle;

  /// No description provided for @notifHeroEnabledSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Configura cuándo y cómo recibir avisos de tu despensa.'**
  String get notifHeroEnabledSubtitle;

  /// No description provided for @notifHeroDisabledSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Las alertas están pausadas. Actívalas para no perder ningún producto.'**
  String get notifHeroDisabledSubtitle;

  /// No description provided for @notifViewInboxTooltip.
  ///
  /// In es, this message translates to:
  /// **'Ver notificaciones recibidas'**
  String get notifViewInboxTooltip;

  /// No description provided for @notifConfigTooltip.
  ///
  /// In es, this message translates to:
  /// **'Configurar alertas'**
  String get notifConfigTooltip;

  /// No description provided for @notifSaveError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo guardar la configuración: {error}'**
  String notifSaveError(String error);

  /// No description provided for @notifLoadError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo cargar la configuración.'**
  String get notifLoadError;

  /// No description provided for @notifPermissionDenied.
  ///
  /// In es, this message translates to:
  /// **'Permiso denegado. Actívalo en la configuración del sistema.'**
  String get notifPermissionDenied;

  /// No description provided for @notifMasterEnabled.
  ///
  /// In es, this message translates to:
  /// **'Alertas activas'**
  String get notifMasterEnabled;

  /// No description provided for @notifMasterDisabled.
  ///
  /// In es, this message translates to:
  /// **'Alertas pausadas'**
  String get notifMasterDisabled;

  /// No description provided for @notifMasterEnabledSub.
  ///
  /// In es, this message translates to:
  /// **'Te avisaremos antes de que algo se venza.'**
  String get notifMasterEnabledSub;

  /// No description provided for @notifMasterDisabledSub.
  ///
  /// In es, this message translates to:
  /// **'Actívalas para recibir avisos de vencimiento.'**
  String get notifMasterDisabledSub;

  /// No description provided for @notifThresholdTitle.
  ///
  /// In es, this message translates to:
  /// **'Umbral global'**
  String get notifThresholdTitle;

  /// No description provided for @notifThresholdSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Avisar X días antes de que algo se venza.'**
  String get notifThresholdSubtitle;

  /// No description provided for @notifDaysCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 día} other{{count} días}}'**
  String notifDaysCount(int count);

  /// No description provided for @notifTimeCardTitle.
  ///
  /// In es, this message translates to:
  /// **'Hora preferida'**
  String get notifTimeCardTitle;

  /// No description provided for @notifTimeCardSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Las alertas se enviarán a esta hora.'**
  String get notifTimeCardSubtitle;

  /// No description provided for @notifTimePickerHelp.
  ///
  /// In es, this message translates to:
  /// **'Hora preferida para alertas'**
  String get notifTimePickerHelp;

  /// No description provided for @notifCategoryRulesTitle.
  ///
  /// In es, this message translates to:
  /// **'Reglas por categoría'**
  String get notifCategoryRulesTitle;

  /// No description provided for @notifCategoryRulesSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Sobrescribe el umbral global para una categoría puntual.'**
  String get notifCategoryRulesSubtitle;

  /// No description provided for @notifChangeThresholdTooltip.
  ///
  /// In es, this message translates to:
  /// **'Cambiar umbral'**
  String get notifChangeThresholdTooltip;

  /// No description provided for @notifUseGlobal.
  ///
  /// In es, this message translates to:
  /// **'Usar global'**
  String get notifUseGlobal;

  /// No description provided for @notifLabelGlobal.
  ///
  /// In es, this message translates to:
  /// **'Global'**
  String get notifLabelGlobal;

  /// No description provided for @notifInstantBanner.
  ///
  /// In es, this message translates to:
  /// **'Los cambios se aplican al instante en tus alertas.'**
  String get notifInstantBanner;

  /// No description provided for @notifInboxTitle.
  ///
  /// In es, this message translates to:
  /// **'Notificaciones'**
  String get notifInboxTitle;

  /// No description provided for @notifInboxLoadError.
  ///
  /// In es, this message translates to:
  /// **'No se pudieron cargar las notificaciones'**
  String get notifInboxLoadError;

  /// No description provided for @notifInboxAllGood.
  ///
  /// In es, this message translates to:
  /// **'Todo en orden por ahora'**
  String get notifInboxAllGood;

  /// No description provided for @notifInboxAttentionCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 producto requiere tu atención} other{{count} productos requieren tu atención}}'**
  String notifInboxAttentionCount(int count);

  /// No description provided for @notifInboxChipExpired.
  ///
  /// In es, this message translates to:
  /// **'Vencidos'**
  String get notifInboxChipExpired;

  /// No description provided for @notifInboxChipExpiring.
  ///
  /// In es, this message translates to:
  /// **'Por vencer'**
  String get notifInboxChipExpiring;

  /// No description provided for @notifInboxChipLowStock.
  ///
  /// In es, this message translates to:
  /// **'Stock bajo'**
  String get notifInboxChipLowStock;

  /// No description provided for @notifInboxSectionExpiredTitle.
  ///
  /// In es, this message translates to:
  /// **'Vencidos'**
  String get notifInboxSectionExpiredTitle;

  /// No description provided for @notifInboxSectionExpiredCaption.
  ///
  /// In es, this message translates to:
  /// **'Retíralos de tu despensa'**
  String get notifInboxSectionExpiredCaption;

  /// No description provided for @notifInboxSectionExpiringTitle.
  ///
  /// In es, this message translates to:
  /// **'Por vencer pronto'**
  String get notifInboxSectionExpiringTitle;

  /// No description provided for @notifInboxSectionExpiringCaption.
  ///
  /// In es, this message translates to:
  /// **'Consúmelos en los próximos días'**
  String get notifInboxSectionExpiringCaption;

  /// No description provided for @notifInboxSectionLowStockTitle.
  ///
  /// In es, this message translates to:
  /// **'Stock bajo'**
  String get notifInboxSectionLowStockTitle;

  /// No description provided for @notifInboxSectionLowStockCaption.
  ///
  /// In es, this message translates to:
  /// **'Pronto necesitarás reponerlos'**
  String get notifInboxSectionLowStockCaption;

  /// No description provided for @notifExpiredToday.
  ///
  /// In es, this message translates to:
  /// **'Venció hoy'**
  String get notifExpiredToday;

  /// No description provided for @notifExpiredOneDay.
  ///
  /// In es, this message translates to:
  /// **'Venció hace 1 día'**
  String get notifExpiredOneDay;

  /// No description provided for @notifExpiredManyDays.
  ///
  /// In es, this message translates to:
  /// **'Venció hace {days} días'**
  String notifExpiredManyDays(int days);

  /// No description provided for @notifExpiresToday.
  ///
  /// In es, this message translates to:
  /// **'Vence hoy'**
  String get notifExpiresToday;

  /// No description provided for @notifExpiresTomorrow.
  ///
  /// In es, this message translates to:
  /// **'Vence mañana'**
  String get notifExpiresTomorrow;

  /// No description provided for @notifExpiresInDays.
  ///
  /// In es, this message translates to:
  /// **'Vence en {days} días · {date}'**
  String notifExpiresInDays(int days, String date);

  /// No description provided for @notifLowStockRemaining.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{Queda 1 unidad} other{Quedan {count} unidades}}'**
  String notifLowStockRemaining(int count);

  /// No description provided for @notifInboxEmptyTitle.
  ///
  /// In es, this message translates to:
  /// **'Sin notificaciones'**
  String get notifInboxEmptyTitle;

  /// No description provided for @notifInboxEmptyBody.
  ///
  /// In es, this message translates to:
  /// **'Tu despensa está en orden. Cuando un producto esté por vencer o quede con poco stock, los avisos aparecerán aquí.'**
  String get notifInboxEmptyBody;

  /// No description provided for @scannerTitle.
  ///
  /// In es, this message translates to:
  /// **'Escáner de productos'**
  String get scannerTitle;

  /// No description provided for @scannerManualBtn.
  ///
  /// In es, this message translates to:
  /// **'Manual'**
  String get scannerManualBtn;

  /// No description provided for @scannerCameraError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo iniciar la cámara. Verifica permisos e intenta de nuevo.'**
  String get scannerCameraError;

  /// No description provided for @scannerDetectedCode.
  ///
  /// In es, this message translates to:
  /// **'Código detectado: {code}'**
  String scannerDetectedCode(String code);

  /// No description provided for @scannerInvalidCode.
  ///
  /// In es, this message translates to:
  /// **'Código no reconocido. Usa un EAN-13 o UPC-A válido.'**
  String get scannerInvalidCode;

  /// No description provided for @scannerAddProduct.
  ///
  /// In es, this message translates to:
  /// **'Agregar producto'**
  String get scannerAddProduct;

  /// No description provided for @scannerPermDisabledTitle.
  ///
  /// In es, this message translates to:
  /// **'Permiso de cámara desactivado'**
  String get scannerPermDisabledTitle;

  /// No description provided for @scannerPermRequestTitle.
  ///
  /// In es, this message translates to:
  /// **'Necesitamos acceso a la cámara'**
  String get scannerPermRequestTitle;

  /// No description provided for @scannerPermDisabledBody.
  ///
  /// In es, this message translates to:
  /// **'Activa el permiso de cámara en la configuración del sistema para volver a escanear códigos de barras.'**
  String get scannerPermDisabledBody;

  /// No description provided for @scannerPermRequestBody.
  ///
  /// In es, this message translates to:
  /// **'Usamos la cámara solo para leer códigos EAN-13 y UPC-A de tus productos. Puedes continuar con ingreso manual si prefieres.'**
  String get scannerPermRequestBody;

  /// No description provided for @scannerPermRequesting.
  ///
  /// In es, this message translates to:
  /// **'Solicitando permiso…'**
  String get scannerPermRequesting;

  /// No description provided for @scannerPermAllow.
  ///
  /// In es, this message translates to:
  /// **'Permitir cámara'**
  String get scannerPermAllow;

  /// No description provided for @scannerPermOpenSettings.
  ///
  /// In es, this message translates to:
  /// **'Abrir configuración'**
  String get scannerPermOpenSettings;

  /// No description provided for @scannerManualEntry.
  ///
  /// In es, this message translates to:
  /// **'Ingresar código manualmente'**
  String get scannerManualEntry;

  /// No description provided for @scannerGuideHint.
  ///
  /// In es, this message translates to:
  /// **'Alinea el código dentro del marco'**
  String get scannerGuideHint;

  /// No description provided for @scannerFlashOn.
  ///
  /// In es, this message translates to:
  /// **'Encender linterna'**
  String get scannerFlashOn;

  /// No description provided for @scannerFlashOff.
  ///
  /// In es, this message translates to:
  /// **'Apagar linterna'**
  String get scannerFlashOff;

  /// No description provided for @authEmailLabel.
  ///
  /// In es, this message translates to:
  /// **'Correo electrónico'**
  String get authEmailLabel;

  /// No description provided for @authPasswordLabel.
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get authPasswordLabel;

  /// No description provided for @authEmailRequired.
  ///
  /// In es, this message translates to:
  /// **'Ingresa tu correo electrónico'**
  String get authEmailRequired;

  /// No description provided for @authEmailInvalid.
  ///
  /// In es, this message translates to:
  /// **'Formato de correo inválido'**
  String get authEmailInvalid;

  /// No description provided for @authPasswordRequired.
  ///
  /// In es, this message translates to:
  /// **'Ingresa tu contraseña'**
  String get authPasswordRequired;

  /// No description provided for @authUnexpectedError.
  ///
  /// In es, this message translates to:
  /// **'Error inesperado. Intenta de nuevo.'**
  String get authUnexpectedError;

  /// No description provided for @authWelcomeBack.
  ///
  /// In es, this message translates to:
  /// **'Bienvenido de nuevo'**
  String get authWelcomeBack;

  /// No description provided for @authWelcomeBackSub.
  ///
  /// In es, this message translates to:
  /// **'Ingresa tus datos para continuar'**
  String get authWelcomeBackSub;

  /// No description provided for @authSignInBtn.
  ///
  /// In es, this message translates to:
  /// **'Iniciar sesión'**
  String get authSignInBtn;

  /// No description provided for @authForgotPassword.
  ///
  /// In es, this message translates to:
  /// **'¿Olvidaste tu contraseña?'**
  String get authForgotPassword;

  /// No description provided for @authOrContinueWith.
  ///
  /// In es, this message translates to:
  /// **'o continúa con'**
  String get authOrContinueWith;

  /// No description provided for @authNoAccount.
  ///
  /// In es, this message translates to:
  /// **'¿No tienes cuenta? '**
  String get authNoAccount;

  /// No description provided for @authCreateAccount.
  ///
  /// In es, this message translates to:
  /// **'Crear cuenta'**
  String get authCreateAccount;

  /// No description provided for @authCreateAccountSub.
  ///
  /// In es, this message translates to:
  /// **'Completa tus datos para registrarte'**
  String get authCreateAccountSub;

  /// No description provided for @authFullNameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre completo'**
  String get authFullNameLabel;

  /// No description provided for @authNameRequired.
  ///
  /// In es, this message translates to:
  /// **'Ingresa tu nombre'**
  String get authNameRequired;

  /// No description provided for @authConfirmPasswordLabel.
  ///
  /// In es, this message translates to:
  /// **'Confirmar contraseña'**
  String get authConfirmPasswordLabel;

  /// No description provided for @authPasswordMin.
  ///
  /// In es, this message translates to:
  /// **'Mínimo 8 caracteres'**
  String get authPasswordMin;

  /// No description provided for @authPasswordUppercase.
  ///
  /// In es, this message translates to:
  /// **'Debe incluir al menos 1 mayúscula'**
  String get authPasswordUppercase;

  /// No description provided for @authPasswordNumber.
  ///
  /// In es, this message translates to:
  /// **'Debe incluir al menos 1 número'**
  String get authPasswordNumber;

  /// No description provided for @authConfirmPasswordRequired.
  ///
  /// In es, this message translates to:
  /// **'Confirma tu contraseña'**
  String get authConfirmPasswordRequired;

  /// No description provided for @authPasswordMismatch.
  ///
  /// In es, this message translates to:
  /// **'Las contraseñas no coinciden'**
  String get authPasswordMismatch;

  /// No description provided for @authRegisterHeroSub.
  ///
  /// In es, this message translates to:
  /// **'Únete y organiza tu despensa'**
  String get authRegisterHeroSub;

  /// No description provided for @authAlreadyHaveAccount.
  ///
  /// In es, this message translates to:
  /// **'¿Ya tienes cuenta? '**
  String get authAlreadyHaveAccount;

  /// No description provided for @authRecoverTitle.
  ///
  /// In es, this message translates to:
  /// **'Recuperar contraseña'**
  String get authRecoverTitle;

  /// No description provided for @authRecoverSub.
  ///
  /// In es, this message translates to:
  /// **'Ingresa tu correo y te enviaremos un enlace para restablecerla.'**
  String get authRecoverSub;

  /// No description provided for @authSendResetLink.
  ///
  /// In es, this message translates to:
  /// **'Enviar enlace'**
  String get authSendResetLink;

  /// No description provided for @authRememberedPassword.
  ///
  /// In es, this message translates to:
  /// **'¿Recordaste tu contraseña? '**
  String get authRememberedPassword;

  /// No description provided for @authEmailSentTitle.
  ///
  /// In es, this message translates to:
  /// **'¡Correo enviado!'**
  String get authEmailSentTitle;

  /// No description provided for @authEmailSentBody.
  ///
  /// In es, this message translates to:
  /// **'Revisa tu bandeja de entrada en\n{email}\ny sigue el enlace para restablecer tu contraseña.'**
  String authEmailSentBody(String email);

  /// No description provided for @authBackToLogin.
  ///
  /// In es, this message translates to:
  /// **'Volver al inicio de sesión'**
  String get authBackToLogin;

  /// No description provided for @authRecoverHeroSub.
  ///
  /// In es, this message translates to:
  /// **'Recupera el acceso a tu cuenta.'**
  String get authRecoverHeroSub;
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
