import 'package:flutter/material.dart';

/// **DEPRECATED** — usa `AppColors` desde
/// `package:pantry_scanner/core/design/design_system.dart`.
///
/// Alias de compatibilidad para código existente; mantiene los valores
/// `const Color` originales para que callers que usen `const` constructors
/// sigan compilando. Las pantallas se migran progresivamente.
@Deprecated('Use AppColors from core/design/design_system.dart')
class InventoryTokens {
  // Fondos
  static const Color bg = Color(0xFFF7F8FA);
  static const Color bgMuted = Color(0xFFF1F5F9);

  // Marca
  static const Color primary = Color(0xFFC0392B);
  static const Color secondary = Color(0xFFE74C3C);
  static const Color tertiary = Color(0xFFFF6B6B);

  // FAB / accent
  static const Color accentContainer = Color(0xFFC0392B);
  static const Color accentOnContainer = Color(0xFFFFFFFF);

  // Tintes rojos
  static const Color redTint = Color(0xFFFEF2F2);
  static const Color redTintMedium = Color(0xFFFEE2E2);

  // Borders
  static const Color outline = Color(0xFFE2E8F0);

  // Texto
  static const Color textMuted = Color(0xFF64748B);
  static const Color textBody = Color(0xFF0F172A);
}
