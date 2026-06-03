import 'package:flutter/widgets.dart';

import '../../features/inventory/domain/entities/sort_preference.dart';
import '../../l10n/generated/app_localizations.dart';

extension SortCriteriaL10n on SortCriteria {
  String label(BuildContext context) {
    final AppLocalizations t = AppLocalizations.of(context);
    switch (this) {
      case SortCriteria.expiryDate:
        return t.sortExpiryDate;
      case SortCriteria.name:
        return t.sortName;
      case SortCriteria.quantity:
        return t.sortQuantity;
      case SortCriteria.category:
        return t.sortCategory;
    }
  }
}
