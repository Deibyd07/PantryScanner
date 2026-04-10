class ScanBarcodeUseCase {
  const ScanBarcodeUseCase();

  String? call(String? rawCode) {
    if (rawCode == null) {
      return null;
    }

    final String normalized = rawCode.replaceAll(RegExp(r'\\s+'), '');
    final bool isEan13 = RegExp(r'^\d{13}$').hasMatch(normalized);
    final bool isUpcA = RegExp(r'^\d{12}$').hasMatch(normalized);

    if (!isEan13 && !isUpcA) {
      return null;
    }

    return normalized;
  }
}
