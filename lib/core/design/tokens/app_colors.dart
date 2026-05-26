import 'package:flutter/material.dart';

/// Paleta de colores de PantryScanner — single source of truth.
///
/// Light y dark mode son intencionales (no auto-derivados de un seed).
/// La identidad de marca (rojo cereza) se preserva en ambos modos pero
/// con luminancias distintas para cumplir WCAG AA y respetar OLED.
class AppColors {
  AppColors._();

  // ──────────────────────────────────────────────────────────────────────────
  // BRAND — comunes a light y dark (gradientes hero, marca)
  // ──────────────────────────────────────────────────────────────────────────

  /// Rojo cereza principal. Identidad de marca.
  static const Color brandPrimary = Color(0xFFC0392B);

  /// Rojo claro vivo (uso: extremo claro del gradiente hero).
  static const Color brandPrimaryLight = Color(0xFFEF4444);

  /// Rojo oscuro intenso (uso: extremo oscuro del gradiente hero, fondos auth).
  static const Color brandPrimaryDark = Color(0xFF7F1D1D);

  /// Rojo coral, intermedio entre primary y light.
  static const Color brandSecondary = Color(0xFFE74C3C);

  /// Rojo coral suave (uso: shimmer, hover, gradientes).
  static const Color brandTertiary = Color(0xFFFF6B6B);

  /// Tinte rojo muy claro (uso: pills, badges con fondo).
  static const Color brandTintSoft = Color(0xFFFEF2F2);

  /// Tinte rojo claro (uso: contenedores, surface tintada).
  static const Color brandTintMedium = Color(0xFFFEE2E2);

  /// Rojo profundo (uso: onPrimaryContainer).
  static const Color brandTintDeep = Color(0xFF7F1D1D);

  /// Gradiente hero canónico — usado en pantallas con "Split Hero" pattern.
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[brandPrimaryLight, brandPrimaryDark],
  );

  /// Gradiente vivo (FAB, botón scan elevado del bottom nav).
  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[brandPrimaryLight, brandPrimary],
  );

  /// Stops del gradiente shimmer del CTA primario (animado).
  static const List<Color> shimmerStops = <Color>[
    brandPrimary,
    brandSecondary,
    brandTertiary,
    brandSecondary,
    brandPrimary,
  ];

  // ──────────────────────────────────────────────────────────────────────────
  // LIGHT MODE
  // ──────────────────────────────────────────────────────────────────────────

  static const LightPalette light = LightPalette();

  // ──────────────────────────────────────────────────────────────────────────
  // DARK MODE (intencional — NO derivado de fromSeed)
  // ──────────────────────────────────────────────────────────────────────────

  static const DarkPalette dark = DarkPalette();

  // ──────────────────────────────────────────────────────────────────────────
  // SEMÁNTICOS — independientes del tema (mismo significado en ambos)
  // ──────────────────────────────────────────────────────────────────────────

  /// Verde fresco — producto en buen estado, éxito.
  static const Color successStrong = Color(0xFF16A34A);
  static const Color successSoft = Color(0xFF22C55E);
  static const Color successBg = Color(0xFFF0FDF4);

  /// Ámbar — vence pronto, advertencia.
  static const Color warningStrong = Color(0xFFD97706);
  static const Color warningSoft = Color(0xFFF59E0B);
  static const Color warningBg = Color(0xFFFFFBEB);

  /// Rojo — vencido, error destructivo.
  static const Color dangerStrong = Color(0xFFDC2626);
  static const Color dangerSoft = Color(0xFFEF4444);
  static const Color dangerBg = Color(0xFFFEF2F2);

  /// Gris azulado — agotado, neutro inactivo.
  static const Color neutralStrong = Color(0xFF94A3B8);
  static const Color neutralSoft = Color(0xFFCBD5E1);
  static const Color neutralBg = Color(0xFFF8FAFC);
}

// ────────────────────────────────────────────────────────────────────────────
// Context extension — acceso al palette adaptado al brightness actual.
// ────────────────────────────────────────────────────────────────────────────

/// Acceso al palette de colores adaptado al brightness del tema actual.
///
/// Uso:
/// ```dart
/// final Color bg = context.palette.bg;
/// ```
///
/// Para tokens que NO cambian entre light/dark (gradiente hero, semánticos,
/// brand fijo) usa `AppColors.X` directamente.
extension AppPaletteContext on BuildContext {
  /// Palette de colores adaptado a light/dark.
  PaletteSpec get palette {
    return Theme.of(this).brightness == Brightness.dark
        ? const _DarkAdapter()
        : const _LightAdapter();
  }
}

/// Contrato compartido de la paleta — implementado por _LightAdapter y _DarkAdapter.
/// Las pantallas dependen de esta interfaz para no acoplarse a un brightness.
abstract interface class PaletteSpec {
  Color get bg;
  Color get bgMuted;
  Color get surface;
  Color get surfaceMuted;
  Color get surfaceContainer;
  Color get surfaceHigh;
  Color get scaffold;
  Color get textBody;
  Color get textMuted;
  Color get textPlaceholder;
  Color get textInverse;
  Color get outline;
  Color get outlineSoft;
  Color get divider;
  Color get brandPrimary;
  Color get brandPrimaryLight;
  Color get brandPrimaryDark;
  Color get brandTintSoft;
  Color get brandTintMedium;
  Color get onBrand;
}

class _LightAdapter implements PaletteSpec {
  const _LightAdapter();
  @override Color get bg => AppColors.light.bg;
  @override Color get bgMuted => AppColors.light.bgMuted;
  @override Color get surface => AppColors.light.surface;
  @override Color get surfaceMuted => AppColors.light.surfaceMuted;
  @override Color get surfaceContainer => AppColors.light.surfaceContainer;
  @override Color get surfaceHigh => AppColors.light.surfaceHigh;
  @override Color get scaffold => AppColors.light.scaffold;
  @override Color get textBody => AppColors.light.textBody;
  @override Color get textMuted => AppColors.light.textMuted;
  @override Color get textPlaceholder => AppColors.light.textPlaceholder;
  @override Color get textInverse => AppColors.light.textInverse;
  @override Color get outline => AppColors.light.outline;
  @override Color get outlineSoft => AppColors.light.outlineSoft;
  @override Color get divider => AppColors.light.divider;
  @override Color get brandPrimary => AppColors.brandPrimary;
  @override Color get brandPrimaryLight => AppColors.brandPrimaryLight;
  @override Color get brandPrimaryDark => AppColors.brandPrimaryDark;
  @override Color get brandTintSoft => AppColors.brandTintSoft;
  @override Color get brandTintMedium => AppColors.brandTintMedium;
  @override Color get onBrand => AppColors.light.onBrand;
}

class _DarkAdapter implements PaletteSpec {
  const _DarkAdapter();
  @override Color get bg => AppColors.dark.bg;
  @override Color get bgMuted => AppColors.dark.bgMuted;
  @override Color get surface => AppColors.dark.surface;
  @override Color get surfaceMuted => AppColors.dark.surfaceMuted;
  @override Color get surfaceContainer => AppColors.dark.surfaceContainer;
  @override Color get surfaceHigh => AppColors.dark.surfaceHigh;
  @override Color get scaffold => AppColors.dark.scaffold;
  @override Color get textBody => AppColors.dark.textBody;
  @override Color get textMuted => AppColors.dark.textMuted;
  @override Color get textPlaceholder => AppColors.dark.textPlaceholder;
  @override Color get textInverse => AppColors.dark.textInverse;
  @override Color get outline => AppColors.dark.outline;
  @override Color get outlineSoft => AppColors.dark.outlineSoft;
  @override Color get divider => AppColors.dark.divider;
  @override Color get brandPrimary => AppColors.dark.brandPrimary;
  @override Color get brandPrimaryLight => AppColors.dark.brandPrimaryLight;
  @override Color get brandPrimaryDark => AppColors.dark.brandPrimaryDark;
  @override Color get brandTintSoft => AppColors.dark.brandTintSoft;
  @override Color get brandTintMedium => AppColors.dark.brandTintMedium;
  @override Color get onBrand => AppColors.dark.onBrand;
}

// ────────────────────────────────────────────────────────────────────────────
// LIGHT PALETTE
// ────────────────────────────────────────────────────────────────────────────
class LightPalette {
  const LightPalette();

  // Backgrounds & surfaces
  Color get bg => const Color(0xFFF7F8FA);
  Color get bgMuted => const Color(0xFFF1F5F9);
  Color get surface => const Color(0xFFFFFFFF);
  Color get surfaceMuted => const Color(0xFFF8FAFC);
  Color get surfaceContainer => const Color(0xFFF1F5F9);
  Color get surfaceHigh => const Color(0xFFFFFFFF);
  Color get scaffold => const Color(0xFFF7F8FA);

  // Text
  Color get textBody => const Color(0xFF0F172A);
  Color get textMuted => const Color(0xFF64748B);
  Color get textPlaceholder => const Color(0xFFB0BAC9);
  Color get textInverse => const Color(0xFFFFFFFF);

  // Borders / dividers
  Color get outline => const Color(0xFFE2E8F0);
  Color get outlineSoft => const Color(0xFFEEF0F4);
  Color get divider => const Color(0xFFF0F2F5);

  // On-brand text
  Color get onBrand => const Color(0xFFFFFFFF);
}

// ────────────────────────────────────────────────────────────────────────────
// DARK PALETTE — diseñado a mano, no auto-derivado
// Estrategia: OLED-friendly (#000 bg), elevación con superficies gradadas,
// brand desaturado para WCAG AA contra fondos oscuros.
// ────────────────────────────────────────────────────────────────────────────
class DarkPalette {
  const DarkPalette();

  // Backgrounds & surfaces
  Color get bg => const Color(0xFF000000); // True black para OLED
  Color get bgMuted => const Color(0xFF0D0D0D);
  Color get surface => const Color(0xFF121212); // Material recommended near-black
  Color get surfaceMuted => const Color(0xFF1A1A1A);
  Color get surfaceContainer => const Color(0xFF1E1E1E);
  Color get surfaceHigh => const Color(0xFF2A2A2A);
  Color get scaffold => const Color(0xFF000000);

  // Text — nunca pure white (eye strain)
  Color get textBody => const Color(0xFFE8E8E8);
  Color get textMuted => const Color(0xFF9AA3B0);
  Color get textPlaceholder => const Color(0xFF555F6E);
  Color get textInverse => const Color(0xFF0F172A);

  // Borders / dividers
  Color get outline => const Color(0xFF2A2F38);
  Color get outlineSoft => const Color(0xFF1E232B);
  Color get divider => const Color(0xFF1A1E25);

  // Brand desaturado para contraste sobre #121212 (4.5:1 mín)
  Color get brandPrimary => const Color(0xFFEF5350);
  Color get brandPrimaryLight => const Color(0xFFFF7B70);
  Color get brandPrimaryDark => const Color(0xFFB91C1C);
  Color get brandTintSoft => const Color(0xFF2A1414);
  Color get brandTintMedium => const Color(0xFF3D1C1C);

  // On-brand text
  Color get onBrand => const Color(0xFFFFFFFF);
}
