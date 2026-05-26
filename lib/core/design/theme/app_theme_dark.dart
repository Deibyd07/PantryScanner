import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';

/// Tema oscuro de PantryScanner — DISEÑADO A MANO (no auto-derivado).
///
/// **Decisiones clave:**
/// - Fondo `#000000` (OLED max savings).
/// - Superficies `#121212` / `#1E1E1E` (elevación tonal, no shadows).
/// - Primary desaturado `#EF5350` para WCAG AA contra #121212 (5.1:1).
/// - Texto warm-white `#E8E8E8` (no pure white — eye strain).
/// - Misma identidad visual (rojo cereza), distinta luminancia.
class AppThemeDark {
  AppThemeDark._();

  static ThemeData get theme {
    const _DarkP p = _DarkP();

    final ColorScheme scheme = ColorScheme.dark(
      primary: p.brandPrimary,
      onPrimary: p.onBrand,
      primaryContainer: p.brandTintMedium,
      onPrimaryContainer: const Color(0xFFFFD4D0),
      secondary: const Color(0xFFFF7B70),
      onSecondary: const Color(0xFF1A0808),
      secondaryContainer: p.brandTintSoft,
      onSecondaryContainer: const Color(0xFFFFD4D0),
      tertiary: const Color(0xFFFF8A80),
      onTertiary: const Color(0xFF1A0808),
      surface: p.surface,
      onSurface: p.textBody,
      surfaceContainerHighest: p.surfaceHigh,
      surfaceContainerLow: p.bgMuted,
      surfaceContainer: p.surfaceContainer,
      error: const Color(0xFFFF6B6B),
      onError: const Color(0xFF1A0808),
      outline: p.outline,
      outlineVariant: p.outlineSoft,
    );

    final TextTheme textTheme =
        AppTypography.buildTextTheme(brightness: Brightness.dark);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: p.scaffold,

      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
        titleTextStyle: AppTypography.headingMd.copyWith(color: p.textBody),
        iconTheme: IconThemeData(color: p.textBody),
      ),

      cardTheme: CardThemeData(
        color: p.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.brXl,
          side: BorderSide(color: p.outline),
        ),
        margin: EdgeInsets.zero,
      ),

      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.brMdPlus),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.surfaceMuted,
        border: OutlineInputBorder(
          borderRadius: AppRadius.brMdPlus,
          borderSide: BorderSide(color: p.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.brMdPlus,
          borderSide: BorderSide(color: p.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.brMdPlus,
          borderSide: BorderSide(color: p.brandPrimary, width: 1.5),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: AppRadius.brMdPlus,
          borderSide: BorderSide(color: Color(0xFFFF6B6B)),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: AppRadius.brMdPlus,
          borderSide: BorderSide(color: Color(0xFFFF6B6B), width: 1.5),
        ),
        labelStyle: AppTypography.labelMd.copyWith(color: p.textMuted),
        floatingLabelStyle:
            AppTypography.labelSm.copyWith(color: p.brandPrimary),
        hintStyle: AppTypography.bodyMd.copyWith(color: p.textPlaceholder),
        prefixIconColor: p.textMuted,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 17,
        ),
      ),

      chipTheme: ChipThemeData(
        selectedColor: p.brandPrimary,
        backgroundColor: p.surfaceContainer,
        checkmarkColor: p.onBrand,
        labelStyle: AppTypography.labelSm.copyWith(color: p.textBody),
        shape: const StadiumBorder(),
        side: BorderSide(color: p.outline),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.ms,
          vertical: AppSpacing.sm,
        ),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: p.brandPrimary,
        foregroundColor: p.onBrand,
        elevation: 4,
        shape: const CircleBorder(),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: p.brandPrimary,
          foregroundColor: p.onBrand,
          minimumSize: const Size(double.infinity, 52),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.brMdPlus),
          textStyle: AppTypography.buttonLg,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: p.brandPrimary,
          side: BorderSide(color: p.brandPrimary),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.brMdPlus),
        ),
      ),

      dividerTheme: DividerThemeData(
        color: p.divider,
        thickness: 1,
        space: 0,
      ),
    );
  }
}

class _DarkP {
  const _DarkP();
  Color get scaffold => AppColors.dark.scaffold;
  Color get surface => AppColors.dark.surface;
  Color get surfaceMuted => AppColors.dark.surfaceMuted;
  Color get surfaceContainer => AppColors.dark.surfaceContainer;
  Color get surfaceHigh => AppColors.dark.surfaceHigh;
  Color get bgMuted => AppColors.dark.bgMuted;
  Color get textBody => AppColors.dark.textBody;
  Color get textMuted => AppColors.dark.textMuted;
  Color get textPlaceholder => AppColors.dark.textPlaceholder;
  Color get outline => AppColors.dark.outline;
  Color get outlineSoft => AppColors.dark.outlineSoft;
  Color get divider => AppColors.dark.divider;
  Color get brandPrimary => AppColors.dark.brandPrimary;
  Color get brandTintMedium => AppColors.dark.brandTintMedium;
  Color get brandTintSoft => AppColors.dark.brandTintSoft;
  Color get onBrand => AppColors.dark.onBrand;
}
