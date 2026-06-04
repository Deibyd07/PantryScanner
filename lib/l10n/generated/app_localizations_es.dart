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
  String get offlineBanner => 'Sin conexión a internet';

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
  String get commonConfirm => 'Confirmar';

  @override
  String get commonCreate => 'Crear';

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
  String get profileEditNameTitle => 'Editar nombre';

  @override
  String get profileNameUpdated => 'Nombre actualizado';

  @override
  String profileNameUpdateError(String error) {
    return 'No se pudo actualizar el nombre: $error';
  }

  @override
  String get profileSecurityTitle => 'Seguridad';

  @override
  String get profileSecuritySubtitle => 'Contraseña y datos de acceso';

  @override
  String get profileChangePassword => 'Cambiar contraseña';

  @override
  String get profileChangePasswordTitle => 'Cambiar contraseña';

  @override
  String get profileCurrentPasswordLabel => 'Contraseña actual';

  @override
  String get profileNewPasswordLabel => 'Nueva contraseña';

  @override
  String get profileConfirmNewPasswordLabel => 'Confirmar nueva contraseña';

  @override
  String get profilePasswordUpdated => 'Contraseña actualizada';

  @override
  String profilePasswordUpdateError(String error) {
    return 'Error al cambiar contraseña: $error';
  }

  @override
  String get profileDeleteAccount => 'Eliminar cuenta';

  @override
  String get profileDeleteAccountTitle => '¿Eliminar tu cuenta?';

  @override
  String get profileDeleteAccountBody =>
      'Todos tus datos de PantryScanner se eliminarán permanentemente. Esta acción no se puede deshacer.';

  @override
  String get profileDeleteAccountConfirmBtn => 'Sí, eliminar mi cuenta';

  @override
  String get profileDeletePasswordHint =>
      'Ingresa tu contraseña para confirmar';

  @override
  String get profileDeleteReauthGoogle =>
      'Se verificará tu identidad con Google antes de eliminar la cuenta.';

  @override
  String get profileDeleteSuccess => 'Cuenta eliminada';

  @override
  String profileDeleteError(String error) {
    return 'No se pudo eliminar la cuenta: $error';
  }

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

  @override
  String get productFormHeroTitleAdd => 'Agregar producto';

  @override
  String get productFormHeroTitleEdit => 'Editar producto';

  @override
  String get productFormHeroSubtitle =>
      'Llena los datos y guarda en tu despensa';

  @override
  String get productFormSectionPhoto => 'Foto del producto';

  @override
  String get productFormSectionBasic => 'Información básica';

  @override
  String get productFormSectionCategory => 'Categoría';

  @override
  String get productFormSectionQuantity => 'Cantidad';

  @override
  String get productFormSectionMinStock => 'Stock mínimo';

  @override
  String get productFormSectionExpiry => 'Fecha de vencimiento';

  @override
  String get productFormSectionNotes => 'Notas opcionales';

  @override
  String get productFormMinStockHint =>
      'Recibirás una alerta cuando la cantidad llegue a este valor.';

  @override
  String get productFormUnitsLabel => 'Unidades en inventario';

  @override
  String get productFormMinStockLabel => 'Cantidad mínima de alerta';

  @override
  String get productFormNoExpiry => 'Sin fecha de vencimiento';

  @override
  String get productFormNotesLabel => 'Notas (opcional)';

  @override
  String get productFormNotesHint =>
      'Ej: Comprado en oferta, revisar antes de usar…';

  @override
  String get productFormSave => 'Guardar en inventario';

  @override
  String productFormSaveError(String error) {
    return 'Error al guardar: $error';
  }

  @override
  String productFormSavedSnack(String name) {
    return '¡$name agregado al inventario!';
  }

  @override
  String productFormUpdatedSnack(String name) {
    return '¡$name actualizado!';
  }

  @override
  String get productFormDatePickerHelp => 'Selecciona la fecha de vencimiento';

  @override
  String get productFormNameLabel => 'Nombre del producto';

  @override
  String get productFormNameHint => 'Ej: Leche entera, Arroz integral…';

  @override
  String get productFormNameRequired => 'El nombre es obligatorio';

  @override
  String get productFormNameMin => 'El nombre debe tener al menos 2 caracteres';

  @override
  String get productFormBarcodeLabel => 'Código de barras';

  @override
  String get productFormBarcodeScanned => 'Código escaneado';

  @override
  String get productFormCreateNewCategory => 'Crear nueva';

  @override
  String get productFormNewCategoryTitle => 'Nueva categoría';

  @override
  String get productFormNewCategoryHint => 'Nombre de la categoría';

  @override
  String get productFormImagePickerTitle => 'Agregar foto del producto';

  @override
  String get productFormTakePhoto => 'Tomar foto';

  @override
  String get productFormTakePhotoSubtitle => 'Abre la cámara del dispositivo';

  @override
  String get productFormUploadImage => 'Subir imagen';

  @override
  String get productFormUploadFromGallery => 'Subir desde galería';

  @override
  String get productFormUploadFromComputerSubtitle =>
      'Elige una imagen de tu computador';

  @override
  String get productFormUploadFromGallerySubtitle =>
      'Elige una imagen guardada';

  @override
  String get productFormCameraWebNotice =>
      'La cámara solo está disponible en la app móvil.';

  @override
  String get productFormRemovePhoto => 'Quitar foto';

  @override
  String get productFormRemovePhotoSubtitle => 'Elimina la imagen seleccionada';

  @override
  String get productFormChangePhoto => 'Cambiar foto';

  @override
  String get productFormPhotoOptionsHint => 'Cámara · Galería · Opcional';

  @override
  String productFormImagePickerError(String error) {
    return 'Error al abrir cámara/galería: $error';
  }

  @override
  String get productLookupLoadingTitle => 'Buscando producto…';

  @override
  String get productLookupLoadingSubtitle =>
      'Consultando base de datos global de alimentos.';

  @override
  String get productLookupFoundTitle => 'Producto encontrado';

  @override
  String get productLookupFoundCacheSubtitle =>
      'Cargado desde la caché local. Revisa los datos antes de guardar.';

  @override
  String get productLookupFoundApiSubtitle =>
      'Datos auto-completados desde OpenFoodFacts. Revisa antes de guardar.';

  @override
  String get productLookupNotFoundTitle => 'Producto no reconocido';

  @override
  String get productLookupNotFoundSubtitle =>
      'Completa los campos manualmente para agregarlo a tu despensa.';

  @override
  String get productLookupFoundSnack => 'Producto encontrado y autocompletado.';

  @override
  String get productLookupNotFoundSnack =>
      'Producto no reconocido. Ingrésalo manualmente.';

  @override
  String get productDetailLoadError => 'No se pudo cargar el producto';

  @override
  String get productDetailNotInPantry =>
      'Este producto ya no está en tu despensa';

  @override
  String get productDetailUnitOne => 'unidad';

  @override
  String get productDetailUnitMany => 'unidades';

  @override
  String get productDetailNoExpiryShort => 'sin vencimiento';

  @override
  String get productDetailDaysExpiredMany => 'días vencido';

  @override
  String get productDetailExpiresToday => 'vence hoy';

  @override
  String get productDetailDayLeft => 'día restante';

  @override
  String get productDetailDaysLeftMany => 'días restantes';

  @override
  String get productDetailMinStockShort => 'stock mín.';

  @override
  String get productDetailQtyCardTitle => 'Cantidad';

  @override
  String get productDetailQtyCardCaption => 'Ajusta cuántas unidades tienes';

  @override
  String get productDetailDetailsCardTitle => 'Detalles';

  @override
  String get productDetailDetailsCardCaption => 'Información del producto';

  @override
  String get productDetailNotesCardTitle => 'Notas';

  @override
  String get productDetailNotesCardCaption => 'Tus apuntes sobre este producto';

  @override
  String get productDetailRowBarcode => 'Código de barras';

  @override
  String get productDetailRowBarcodeMissing => 'Sin código';

  @override
  String get productDetailRowCategory => 'Categoría';

  @override
  String get productDetailRowExpiry => 'Vencimiento';

  @override
  String get productDetailRowExpiryMissing => 'No registrado';

  @override
  String get productDetailRowAdded => 'Agregado';

  @override
  String get productDetailRowUpdated => 'Última edición';

  @override
  String get productDetailActionReplenish => 'Reponer · añadir al carrito';

  @override
  String get productDetailActionEdit => 'Editar producto';

  @override
  String get productDetailActionAddToCart => 'Añadir al carrito';

  @override
  String get productDetailActionDelete => 'Eliminar producto';

  @override
  String productDetailCartAlreadyHad(String name) {
    return 'Ya tenías \"$name\" en tu carrito';
  }

  @override
  String productDetailCartAdded(String name) {
    return 'Añadiste \"$name\" al carrito';
  }

  @override
  String get commonChange => 'Cambiar';

  @override
  String get notifHeroTitle => 'Alertas';

  @override
  String get notifHeroEnabledSubtitle =>
      'Configura cuándo y cómo recibir avisos de tu despensa.';

  @override
  String get notifHeroDisabledSubtitle =>
      'Las alertas están pausadas. Actívalas para no perder ningún producto.';

  @override
  String get notifViewInboxTooltip => 'Ver notificaciones recibidas';

  @override
  String get notifConfigTooltip => 'Configurar alertas';

  @override
  String notifSaveError(String error) {
    return 'No se pudo guardar la configuración: $error';
  }

  @override
  String get notifLoadError => 'No se pudo cargar la configuración.';

  @override
  String get notifPermissionDenied =>
      'Permiso denegado. Actívalo en la configuración del sistema.';

  @override
  String get notifMasterEnabled => 'Alertas activas';

  @override
  String get notifMasterDisabled => 'Alertas pausadas';

  @override
  String get notifMasterEnabledSub =>
      'Te avisaremos antes de que algo se venza.';

  @override
  String get notifMasterDisabledSub =>
      'Actívalas para recibir avisos de vencimiento.';

  @override
  String get notifThresholdTitle => 'Umbral global';

  @override
  String get notifThresholdSubtitle =>
      'Avisar X días antes de que algo se venza.';

  @override
  String notifDaysCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count días',
      one: '1 día',
    );
    return '$_temp0';
  }

  @override
  String get notifTimeCardTitle => 'Hora preferida';

  @override
  String get notifTimeCardSubtitle => 'Las alertas se enviarán a esta hora.';

  @override
  String get notifTimePickerHelp => 'Hora preferida para alertas';

  @override
  String get notifCategoryRulesTitle => 'Reglas por categoría';

  @override
  String get notifCategoryRulesSubtitle =>
      'Sobrescribe el umbral global para una categoría puntual.';

  @override
  String get notifChangeThresholdTooltip => 'Cambiar umbral';

  @override
  String get notifUseGlobal => 'Usar global';

  @override
  String get notifLabelGlobal => 'Global';

  @override
  String get notifInstantBanner =>
      'Los cambios se aplican al instante en tus alertas.';

  @override
  String get notifInboxTitle => 'Notificaciones';

  @override
  String get notifInboxLoadError => 'No se pudieron cargar las notificaciones';

  @override
  String get notifInboxAllGood => 'Todo en orden por ahora';

  @override
  String notifInboxAttentionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count productos requieren tu atención',
      one: '1 producto requiere tu atención',
    );
    return '$_temp0';
  }

  @override
  String get notifInboxChipExpired => 'Vencidos';

  @override
  String get notifInboxChipExpiring => 'Por vencer';

  @override
  String get notifInboxChipLowStock => 'Stock bajo';

  @override
  String get notifInboxSectionExpiredTitle => 'Vencidos';

  @override
  String get notifInboxSectionExpiredCaption => 'Retíralos de tu despensa';

  @override
  String get notifInboxSectionExpiringTitle => 'Por vencer pronto';

  @override
  String get notifInboxSectionExpiringCaption =>
      'Consúmelos en los próximos días';

  @override
  String get notifInboxSectionLowStockTitle => 'Stock bajo';

  @override
  String get notifInboxSectionLowStockCaption =>
      'Pronto necesitarás reponerlos';

  @override
  String get notifExpiredToday => 'Venció hoy';

  @override
  String get notifExpiredOneDay => 'Venció hace 1 día';

  @override
  String notifExpiredManyDays(int days) {
    return 'Venció hace $days días';
  }

  @override
  String get notifExpiresToday => 'Vence hoy';

  @override
  String get notifExpiresTomorrow => 'Vence mañana';

  @override
  String notifExpiresInDays(int days, String date) {
    return 'Vence en $days días · $date';
  }

  @override
  String notifLowStockRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Quedan $count unidades',
      one: 'Queda 1 unidad',
    );
    return '$_temp0';
  }

  @override
  String get notifInboxEmptyTitle => 'Sin notificaciones';

  @override
  String get notifInboxEmptyBody =>
      'Tu despensa está en orden. Cuando un producto esté por vencer o quede con poco stock, los avisos aparecerán aquí.';

  @override
  String get scannerTitle => 'Escáner de productos';

  @override
  String get scannerManualBtn => 'Manual';

  @override
  String get scannerCameraError =>
      'No se pudo iniciar la cámara. Verifica permisos e intenta de nuevo.';

  @override
  String scannerDetectedCode(String code) {
    return 'Código detectado: $code';
  }

  @override
  String get scannerInvalidCode =>
      'Código no reconocido. Usa un EAN-13 o UPC-A válido.';

  @override
  String get scannerAddProduct => 'Agregar producto';

  @override
  String get scannerPermDisabledTitle => 'Permiso de cámara desactivado';

  @override
  String get scannerPermRequestTitle => 'Necesitamos acceso a la cámara';

  @override
  String get scannerPermDisabledBody =>
      'Activa el permiso de cámara en la configuración del sistema para volver a escanear códigos de barras.';

  @override
  String get scannerPermRequestBody =>
      'Usamos la cámara solo para leer códigos EAN-13 y UPC-A de tus productos. Puedes continuar con ingreso manual si prefieres.';

  @override
  String get scannerPermRequesting => 'Solicitando permiso…';

  @override
  String get scannerPermAllow => 'Permitir cámara';

  @override
  String get scannerPermOpenSettings => 'Abrir configuración';

  @override
  String get scannerManualEntry => 'Ingresar código manualmente';

  @override
  String get scannerGuideHint => 'Alinea el código dentro del marco';

  @override
  String get scannerFlashOn => 'Encender linterna';

  @override
  String get scannerFlashOff => 'Apagar linterna';

  @override
  String get authEmailLabel => 'Correo electrónico';

  @override
  String get authPasswordLabel => 'Contraseña';

  @override
  String get authEmailRequired => 'Ingresa tu correo electrónico';

  @override
  String get authEmailInvalid => 'Formato de correo inválido';

  @override
  String get authPasswordRequired => 'Ingresa tu contraseña';

  @override
  String get authUnexpectedError => 'Error inesperado. Intenta de nuevo.';

  @override
  String get authWelcomeBack => 'Bienvenido de nuevo';

  @override
  String get authWelcomeBackSub => 'Ingresa tus datos para continuar';

  @override
  String get authSignInBtn => 'Iniciar sesión';

  @override
  String get authForgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get authOrContinueWith => 'o continúa con';

  @override
  String get authNoAccount => '¿No tienes cuenta? ';

  @override
  String get authCreateAccount => 'Crear cuenta';

  @override
  String get authCreateAccountSub => 'Completa tus datos para registrarte';

  @override
  String get authFullNameLabel => 'Nombre completo';

  @override
  String get authNameRequired => 'Ingresa tu nombre';

  @override
  String get authConfirmPasswordLabel => 'Confirmar contraseña';

  @override
  String get authPasswordMin => 'Mínimo 8 caracteres';

  @override
  String get authPasswordUppercase => 'Debe incluir al menos 1 mayúscula';

  @override
  String get authPasswordNumber => 'Debe incluir al menos 1 número';

  @override
  String get authConfirmPasswordRequired => 'Confirma tu contraseña';

  @override
  String get authPasswordMismatch => 'Las contraseñas no coinciden';

  @override
  String get authRegisterHeroSub => 'Únete y organiza tu despensa';

  @override
  String get authAlreadyHaveAccount => '¿Ya tienes cuenta? ';

  @override
  String get authRecoverTitle => 'Recuperar contraseña';

  @override
  String get authRecoverSub =>
      'Ingresa tu correo y te enviaremos un enlace para restablecerla.';

  @override
  String get authSendResetLink => 'Enviar enlace';

  @override
  String get authRememberedPassword => '¿Recordaste tu contraseña? ';

  @override
  String get authEmailSentTitle => '¡Correo enviado!';

  @override
  String authEmailSentBody(String email) {
    return 'Revisa tu bandeja de entrada en\n$email\ny sigue el enlace para restablecer tu contraseña.';
  }

  @override
  String get authBackToLogin => 'Volver al inicio de sesión';

  @override
  String get authRecoverHeroSub => 'Recupera el acceso a tu cuenta.';
}
