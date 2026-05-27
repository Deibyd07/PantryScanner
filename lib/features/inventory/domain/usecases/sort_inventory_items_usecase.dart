import '../entities/inventory_item.dart';
import '../entities/sort_preference.dart';

class SortInventoryItemsUseCase {
  const SortInventoryItemsUseCase();

  List<InventoryItem> call(List<InventoryItem> items, SortPreference pref) {
    final List<InventoryItem> sorted = List<InventoryItem>.from(items);
    sorted.sort((InventoryItem a, InventoryItem b) {
      final int cmp;
      switch (pref.criteria) {
        case SortCriteria.expiryDate:
          final DateTime aDate = a.expiryDate ?? DateTime(9999);
          final DateTime bDate = b.expiryDate ?? DateTime(9999);
          cmp = aDate.compareTo(bDate);
        case SortCriteria.name:
          cmp = a.name.toLowerCase().compareTo(b.name.toLowerCase());
        case SortCriteria.quantity:
          cmp = a.quantity.compareTo(b.quantity);
        case SortCriteria.category:
          cmp = (a.category ?? '').toLowerCase()
              .compareTo((b.category ?? '').toLowerCase());
      }
      return pref.ascending ? cmp : -cmp;
    });
    return sorted;
  }
}
