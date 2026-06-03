import 'package:flutter/widgets.dart';

import '../../features/inventory/domain/entities/inventory_item.dart';
import '../../l10n/generated/app_localizations.dart';

/// Etiquetas localizadas para [ProductStatus].
extension ProductStatusL10n on ProductStatus {
  String label(BuildContext context) {
    final AppLocalizations t = AppLocalizations.of(context);
    switch (this) {
      case ProductStatus.expired:
        return t.statusExpired;
      case ProductStatus.expiringSoon:
        return t.statusExpiringSoon;
      case ProductStatus.outOfStock:
        return t.statusOutOfStock;
      case ProductStatus.normal:
        return t.statusFresh;
    }
  }
}
