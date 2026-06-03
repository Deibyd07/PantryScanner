import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/sort_preference.dart';
import '../../domain/usecases/sort_inventory_items_usecase.dart';

class SortPreferenceNotifier extends StateNotifier<SortPreference> {
  SortPreferenceNotifier() : super(const SortPreference()) {
    _load();
  }

  static const String _keyCriteria = 'sort_criteria';
  static const String _keyAscending = 'sort_ascending';

  Future<void> _load() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? criteriaName = prefs.getString(_keyCriteria);
    final SortCriteria criteria = criteriaName != null
        ? SortCriteria.values.firstWhere(
            (SortCriteria e) => e.name == criteriaName,
            orElse: () => SortCriteria.expiryDate,
          )
        : SortCriteria.expiryDate;
    final bool ascending = prefs.getBool(_keyAscending) ?? true;
    state = SortPreference(criteria: criteria, ascending: ascending);
  }

  Future<void> update(SortPreference pref) async {
    state = pref;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCriteria, pref.criteria.name);
    await prefs.setBool(_keyAscending, pref.ascending);
  }
}

final StateNotifierProvider<SortPreferenceNotifier, SortPreference>
    sortPreferenceProvider =
    StateNotifierProvider<SortPreferenceNotifier, SortPreference>(
  (Ref ref) => SortPreferenceNotifier(),
);

final Provider<SortInventoryItemsUseCase> sortInventoryItemsUseCaseProvider =
    Provider<SortInventoryItemsUseCase>(
  (Ref ref) => const SortInventoryItemsUseCase(),
);
