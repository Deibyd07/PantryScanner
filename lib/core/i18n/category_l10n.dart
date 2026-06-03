import 'package:flutter/widgets.dart';

import '../../l10n/generated/app_localizations.dart';

/// Las categorías se almacenan en BD en español (canónico) para preservar la
/// integridad histórica y la sincronización. Este helper traduce el nombre
/// canónico a su versión localizada para la UI.
///
/// El primer elemento de [pantryCategoryKeys] es el sentinel "Todos" usado
/// como filtro "sin categoría seleccionada".
const List<String> pantryCategoryKeys = <String>[
  'Todos',
  'Lácteos',
  'Carnes',
  'Frutas y verduras',
  'Enlatados',
  'Bebidas',
  'Snacks',
  'Cereales',
  'Condimentos',
];

String categoryLabel(BuildContext context, String canonical) {
  final AppLocalizations t = AppLocalizations.of(context);
  switch (canonical) {
    case 'Todos':
      return t.categoryAll;
    case 'Lácteos':
      return t.categoryDairy;
    case 'Carnes':
      return t.categoryMeat;
    case 'Frutas y verduras':
      return t.categoryFruitsVeg;
    case 'Enlatados':
      return t.categoryCanned;
    case 'Bebidas':
      return t.categoryDrinks;
    case 'Snacks':
      return t.categorySnacks;
    case 'Cereales':
      return t.categoryCereals;
    case 'Condimentos':
      return t.categoryCondiments;
    default:
      return canonical;
  }
}
