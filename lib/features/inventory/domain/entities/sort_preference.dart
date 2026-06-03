enum SortCriteria { expiryDate, name, quantity, category }

extension SortCriteriaLabel on SortCriteria {
  String get label {
    switch (this) {
      case SortCriteria.expiryDate:
        return 'Fecha de vencimiento';
      case SortCriteria.name:
        return 'Nombre A-Z';
      case SortCriteria.quantity:
        return 'Cantidad';
      case SortCriteria.category:
        return 'Categoría';
    }
  }
}

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
