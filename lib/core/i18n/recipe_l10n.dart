import 'package:flutter/widgets.dart';

import '../../features/recipes/domain/entities/recipe.dart';
import '../../l10n/generated/app_localizations.dart';

extension RecipeDifficultyL10n on RecipeDifficulty {
  String label(BuildContext context) {
    final AppLocalizations t = AppLocalizations.of(context);
    switch (this) {
      case RecipeDifficulty.facil:
        return t.recipeDifficultyEasy;
      case RecipeDifficulty.medio:
        return t.recipeDifficultyMedium;
      case RecipeDifficulty.avanzado:
        return t.recipeDifficultyAdvanced;
    }
  }
}

extension RecipeMealL10n on RecipeMeal {
  String label(BuildContext context) {
    final AppLocalizations t = AppLocalizations.of(context);
    switch (this) {
      case RecipeMeal.desayuno:
        return t.recipeMealBreakfast;
      case RecipeMeal.almuerzo:
        return t.recipeMealLunch;
      case RecipeMeal.cena:
        return t.recipeMealDinner;
      case RecipeMeal.snack:
        return t.recipeMealSnack;
      case RecipeMeal.postre:
        return t.recipeMealDessert;
    }
  }
}
