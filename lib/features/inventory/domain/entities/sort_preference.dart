enum SortCriteria { expiryDate, name, quantity, category }

class SortPreference {
  const SortPreference({
    this.criteria = SortCriteria.expiryDate,
    this.ascending = true,
  });

  final SortCriteria criteria;
  final bool ascending;

  SortPreference copyWith({SortCriteria? criteria, bool? ascending}) {
    return SortPreference(
      criteria: criteria ?? this.criteria,
      ascending: ascending ?? this.ascending,
    );
  }
}
