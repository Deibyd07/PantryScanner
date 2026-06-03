// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'PantryScanner';

  @override
  String get appTagline => 'Tu despensa, bajo control';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonSave => 'Guardar';

  @override
  String get commonDelete => 'Eliminar';

  @override
  String get commonClose => 'Cerrar';

  @override
  String get commonBack => 'Atrás';

  @override
  String get commonContinue => 'Continuar';

  @override
  String get commonOk => 'OK';

  @override
  String get commonError => 'Error';

  @override
  String get commonRetry => 'Reintentar';

  @override
  String get commonLoading => 'Cargando…';

  @override
  String get commonUndo => 'Deshacer';

  @override
  String get commonSee => 'Ver';

  @override
  String get commonEdit => 'Editar';

  @override
  String get commonAdd => 'Añadir';

  @override
  String get commonSearch => 'Buscar';

  @override
  String get navPantry => 'Despensa';

  @override
  String get navRecipes => 'Recetas';

  @override
  String get navAlerts => 'Alertas';

  @override
  String get navProfile => 'Perfil';

  @override
  String get cartTooltip => 'Lista de compras';

  @override
  String get popupLogoutTitle => 'Cerrar sesión';

  @override
  String get popupLogoutBody => '¿Estás seguro de que deseas cerrar tu sesión?';

  @override
  String get inventoryTitle => 'Mi despensa';

  @override
  String get inventoryTagline => 'Organiza · Controla · Ahorra';

  @override
  String get inventorySearchHint => 'Busca en tu despensa...';

  @override
  String get inventoryClearSearch => 'Limpiar búsqueda';

  @override
  String get inventoryEmptyTitle => 'Tu despensa está vacía';

  @override
  String get inventoryEmptyHint =>
      'Toca el botón central para escanear tu primer producto';

  @override
  String inventorySearchNoResults(String query) {
    return 'Sin resultados para \"$query\"';
  }

  @override
  String get inventorySearchTryOther =>
      'Intenta con otro nombre, marca o categoría';

  @override
  String get inventoryLoadError => 'No se pudo cargar el inventario';

  @override
  String get inventoryDeleteTitle => 'Eliminar producto';

  @override
  String inventoryDeleteBody(String name) {
    return '¿Seguro que quieres eliminar \"$name\" de tu despensa?';
  }

  @override
  String inventoryDeletedSnack(String name) {
    return '\"$name\" eliminado';
  }

  @override
  String get inventoryConfirmDeleteTitle => '¿Eliminar producto?';

  @override
  String inventoryConfirmDeleteBody(String name) {
    return 'La cantidad de \"$name\" llegará a 0. ¿Quieres eliminarlo del inventario?';
  }

  @override
  String get categoryAll => 'Todos';

  @override
  String get categoryDairy => 'Lácteos';

  @override
  String get categoryMeat => 'Carnes';

  @override
  String get categoryFruitsVeg => 'Frutas y verduras';

  @override
  String get categoryCanned => 'Enlatados';

  @override
  String get categoryDrinks => 'Bebidas';

  @override
  String get categorySnacks => 'Snacks';

  @override
  String get categoryCereals => 'Cereales';

  @override
  String get categoryCondiments => 'Condimentos';

  @override
  String get categoryUncategorized => 'Sin categoría';

  @override
  String get unitOne => 'unidad';

  @override
  String get unitMany => 'unidades';

  @override
  String get insightsTitle => 'Resumen inteligente';

  @override
  String get insightsMetricExpired => 'Vencidos';

  @override
  String get insightsMetricProducts => 'Productos';

  @override
  String get insightsMetricExpiring => 'Por vencer';

  @override
  String get insightsEmpty => 'Aún no tienes productos en tu despensa';

  @override
  String get insightsAllGood => 'Todo en orden: nada por vencer pronto';

  @override
  String insightsMixed(int expired, int expiring) {
    return '$expired vencidos · $expiring por vencer pronto';
  }

  @override
  String insightsExpired(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count productos vencidos',
      one: '1 producto vencido',
    );
    return '$_temp0';
  }

  @override
  String insightsExpiring(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count productos vencen pronto',
      one: '1 producto vence pronto',
    );
    return '$_temp0';
  }

  @override
  String get sortTitle => 'Ordenar por';

  @override
  String get sortExpiryDate => 'Fecha de vencimiento';

  @override
  String get sortName => 'Nombre A-Z';

  @override
  String get sortQuantity => 'Cantidad';

  @override
  String get sortCategory => 'Categoría';

  @override
  String get sortAscending => 'Ascendente';

  @override
  String get sortDescending => 'Descendente';

  @override
  String get sortApply => 'Aplicar';

  @override
  String get cartTitle => 'Lista de compras';

  @override
  String get cartEmpty => 'Aún no has añadido nada';

  @override
  String get cartAllDone => '¡Todo conseguido!';

  @override
  String cartPendingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ítems por comprar',
      one: '1 ítem por comprar',
    );
    return '$_temp0';
  }

  @override
  String get cartStatTotal => 'Total';

  @override
  String get cartStatPending => 'Pendientes';

  @override
  String get cartStatDone => 'Conseguidos';

  @override
  String get cartSectionToBuy => 'Por comprar';

  @override
  String get cartSectionManual => 'Agregados manualmente';

  @override
  String get cartSectionRecipe => 'Faltan para preparar esta receta';

  @override
  String get cartSectionDone => 'Ya tienes';

  @override
  String get cartSectionDoneSubtitle => 'Marcados como conseguidos';

  @override
  String get cartClearDoneTooltip => 'Borrar conseguidos';

  @override
  String get cartClearDoneTitle => 'Quitar conseguidos';

  @override
  String get cartClearDoneBody =>
      '¿Quieres borrar todos los ítems que ya marcaste como conseguidos?';

  @override
  String get cartQuickAddHint => 'Añadir ítem (ej. Leche 2 L, 3 huevos)';

  @override
  String cartDeletedSnack(String name) {
    return 'Eliminaste \"$name\"';
  }

  @override
  String cartClearedSnack(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Borraste $count conseguidos',
      one: 'Borraste 1 conseguido',
    );
    return '$_temp0';
  }

  @override
  String get cartEmptyTitle => 'Tu lista está vacía';

  @override
  String get cartEmptyHint =>
      'Añade ítems con el campo de arriba o desde una receta usando \"Añadir faltantes a la lista\".';

  @override
  String get cartMarkAll => 'Todos';

  @override
  String get cartEditItemTitle => 'Editar ítem';

  @override
  String get cartEditNameLabel => 'Nombre';

  @override
  String get cartEditQtyLabel => 'Cantidad (opcional)';

  @override
  String get cartEditQtyHint => 'Ej. 2 L, 500 g, 3 unidades';

  @override
  String get cartDeleteItemTooltip => 'Eliminar de la lista';

  @override
  String get cartEditTooltip => 'Editar';

  @override
  String get recipeDifficultyEasy => 'Fácil';

  @override
  String get recipeDifficultyMedium => 'Medio';

  @override
  String get recipeDifficultyAdvanced => 'Avanzado';

  @override
  String get recipeMealBreakfast => 'Desayuno';

  @override
  String get recipeMealLunch => 'Almuerzo';

  @override
  String get recipeMealDinner => 'Cena';

  @override
  String get recipeMealSnack => 'Snack';

  @override
  String get recipeMealDessert => 'Postre';

  @override
  String get recipesLoadError => 'No se pudieron cargar las recetas';

  @override
  String get recipesHeroTitle => 'Cocina con lo que tienes';

  @override
  String get recipesHeroEmpty => 'Aún no hay recetas en el catálogo';

  @override
  String get recipesHeroNoneCookable =>
      'Te faltan algunos ingredientes para cocinar completo';

  @override
  String recipesHeroCookable(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recetas listas para cocinar ahora',
      one: '1 receta lista para cocinar ahora',
    );
    return '$_temp0';
  }

  @override
  String get recipesStatCatalog => 'En catálogo';

  @override
  String get recipesStatCookable => 'Puedes cocinar';

  @override
  String get recipesStatExpiring => 'Por vencer';

  @override
  String get recipesViewPantry => 'Ver despensa';

  @override
  String get recipesFilterAll => 'Todas';

  @override
  String get recipesFilterCookable => 'Puedo cocinar';

  @override
  String get recipesFilterExpiring => 'Aprovecha por vencer';

  @override
  String get recipesEmptyTitleAll => 'Sin recetas';

  @override
  String get recipesEmptyBodyAll =>
      'Pronto añadiremos más recetas al catálogo.';

  @override
  String get recipesEmptyTitleCookable => 'Te faltan ingredientes';

  @override
  String get recipesEmptyBodyCookable =>
      'Aún no tienes en despensa todos los ingredientes para cocinar una receta completa. Mira el resto y compra lo que te falte.';

  @override
  String get recipesEmptyTitleExpiring => 'Nada por vencer';

  @override
  String get recipesEmptyBodyExpiring =>
      'Ninguna receta del catálogo usa productos que estés por perder. ¡Buena gestión!';

  @override
  String recipeMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get recipeReady => 'Listo';

  @override
  String recipeCoveragePercent(int percent) {
    return '$percent%';
  }

  @override
  String get recipeUseExpiringOne => 'Aprovecha 1 producto por vencer';

  @override
  String recipeUseExpiringMany(int count) {
    return 'Aprovecha $count productos por vencer';
  }

  @override
  String get recipeMissingOne => 'Te falta 1 ingrediente';

  @override
  String recipeMissingMany(int count) {
    return 'Te faltan $count ingredientes';
  }

  @override
  String get recipeDetailNotFound => 'Receta no encontrada';

  @override
  String get recipeDetailCanCookNow => 'Puedes cocinarla ahora';

  @override
  String get recipeDetailServingsOne => 'porción';

  @override
  String get recipeDetailServingsMany => 'porciones';

  @override
  String get recipeDetailDifficultyLabel => 'dificultad';

  @override
  String get recipeIngredientsTitle => 'Ingredientes';

  @override
  String recipeIngredientsCountTotal(int count) {
    return '$count en total';
  }

  @override
  String recipeIngredientsCountDetail(int inPantry, int missing) {
    return '$inPantry en tu despensa · $missing por conseguir';
  }

  @override
  String get recipeIngredientInPantry => 'En tu despensa';

  @override
  String get recipeIngredientExpiring => 'Por vencer · aprovéchalo';

  @override
  String get recipeIngredientMissing => 'Comprar';

  @override
  String get recipeIngredientOptional => 'Opcional';

  @override
  String get recipeStepsTitle => 'Preparación';

  @override
  String recipeStepsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pasos',
      one: '1 paso',
    );
    return '$_temp0';
  }

  @override
  String get recipeAddMissingOne => 'Añadir el faltante a la lista';

  @override
  String recipeAddMissingMany(int count) {
    return 'Añadir $count faltantes a la lista';
  }

  @override
  String get recipeAddedAllExisted => 'Ya tenías esos ítems en la lista';

  @override
  String get recipeAddedOne => '1 ítem añadido a la lista';

  @override
  String recipeAddedMany(int count) {
    return '$count ítems añadidos a la lista';
  }

  @override
  String recipeAddedMixed(int added, int skipped) {
    return '$added añadidos · $skipped ya estaban';
  }

  @override
  String get recipeViewList => 'Ver lista';

  @override
  String get statusExpired => 'Vencido';

  @override
  String get statusExpiringSoon => 'Vence pronto';

  @override
  String get statusOutOfStock => 'Agotado';

  @override
  String get statusFresh => 'Fresco';

  @override
  String get statusOutOfStockShort => 'SIN STOCK';

  @override
  String get statusExpiredShort => 'VENCIDO';

  @override
  String statusDaysLeft(int days) {
    return '${days}d restantes';
  }

  @override
  String get profileTitle => 'Mi perfil';

  @override
  String get profileUserFallback => 'Usuario';

  @override
  String get profileAccountGoogle => 'Cuenta Google';

  @override
  String get profileAccountEmail => 'Cuenta con correo';

  @override
  String get profileStatsProducts => 'Productos';

  @override
  String get profileStatsCategories => 'Categorías';

  @override
  String get profileStatsWithPhoto => 'Con foto';

  @override
  String get profileAccountTitle => 'Tu cuenta';

  @override
  String get profileAccountSubtitle => 'Información del usuario conectado';

  @override
  String get profileAccountEmailLabel => 'Correo electrónico';

  @override
  String get profileAccountNameLabel => 'Nombre';

  @override
  String get profileAccountTypeLabel => 'Tipo de cuenta';

  @override
  String get profileAccountTypeGoogle => 'Google';

  @override
  String get profileAccountTypePassword => 'Correo y contraseña';

  @override
  String get profilePrefsTitle => 'Preferencias';

  @override
  String get profilePrefsSubtitle => 'Personaliza la app a tu gusto';

  @override
  String get profilePrefsNotifications => 'Alertas y notificaciones';

  @override
  String get profilePrefsLanguage => 'Idioma';

  @override
  String get profileAboutTitle => 'Acerca de';

  @override
  String get profileAboutSubtitle => 'Información de la aplicación';

  @override
  String get profileAboutVersion => 'Versión';

  @override
  String get profileAboutTerms => 'Términos y condiciones';

  @override
  String get profileAboutPrivacy => 'Política de privacidad';

  @override
  String get profileLogout => 'Cerrar sesión';

  @override
  String get profileLogoutConfirmTitle => 'Cerrar sesión';

  @override
  String get profileLogoutConfirmBody =>
      '¿Seguro que quieres cerrar tu sesión? Tendrás que iniciar sesión de nuevo.';

  @override
  String get languageSheetTitle => 'Elegir idioma';

  @override
  String get languageSheetSubtitle => 'El cambio se aplica al instante';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageEnglish => 'Inglés';

  @override
  String get languageSavedSnack => 'Idioma actualizado';

  @override
  String get legalTermsTitle => 'Términos y condiciones';

  @override
  String get legalTermsBody =>
      'Bienvenido a PantryScanner. Al usar esta aplicación aceptas los siguientes términos: la app se ofrece tal cual, sin garantías de exactitud absoluta en fechas de vencimiento o inventario. El usuario es responsable de verificar la información antes de tomar decisiones de consumo o compra. PantryScanner no almacena datos sensibles fuera de tu dispositivo y tu cuenta Firebase. El equipo se reserva el derecho de modificar funcionalidades en futuras versiones.';

  @override
  String get legalPrivacyTitle => 'Política de privacidad';

  @override
  String get legalPrivacyBody =>
      'PantryScanner respeta tu privacidad. Recopilamos solo: tu correo electrónico (para autenticación), los productos que registras (almacenados localmente en tu dispositivo y sincronizados con Firebase asociados a tu cuenta), y configuraciones de la app (idioma, preferencias). No compartimos tu información con terceros con fines publicitarios. Puedes eliminar tu cuenta y todos los datos asociados contactando al equipo. Las imágenes de productos se almacenan localmente en tu dispositivo.';
}
