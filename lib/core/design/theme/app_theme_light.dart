import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';

/// Tema claro de PantryScanner.
///
/// Material 3, basado en tokens. Cualquier cambio visual sistémico debe
/// hacerse aquí — NO en pantallas individuales.
class AppThemeLight {
  AppThemeLight._();

  static ThemeData get theme {
    const _LightP p = _LightP();

    final ColorScheme scheme = ColorScheme.light(
      primary: AppColors.brandPrimary,
      onPrimary: p.onBrand,
      primaryContainer: AppColors.brandTintMedium,
      onPrimaryContainer: AppColors.brandTintDeep,
      secondary: AppColors.brandSecondary,
      onSecondary: p.onBrand,
      secondaryContainer: AppColors.brandTintSoft,
      onSecondaryContainer: AppColors.brandTintDeep,
      tertiary: AppColors.brandTertiary,
      onTertiary: p.onBrand,
      surface: p.surface,
      onSurface: p.textBody,
      surfaceContainerHighest: p.surfaceContainer,
      surfaceContainerLow: p.surfaceMuted,
      surfaceContainer: p.surfaceContainer,
      error: AppColors.dangerStrong,
      onError: p.onBrand,
      outline: p.outline,
      outlineVariant: p.outline,
    );

    final TextTheme textTheme =
        AppTypography.buildTextTheme(brightness: Brightness.light);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
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
        fillColor: p.surface,
        border: OutlineInputBorder(
          borderRadius: AppRadius.brMdPlus,
          borderSide: BorderSide(color: p.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.brMdPlus,
          borderSide: BorderSide(color: p.outline),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: AppRadius.brMdPlus,
          borderSide:
              BorderSide(color: AppColors.brandPrimary, width: 1.5),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: AppRadius.brMdPlus,
          borderSide: BorderSide(color: AppColors.dangerStrong),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: AppRadius.brMdPlus,
          borderSide: BorderSide(color: AppColors.dangerStrong, width: 1.5),
        ),
        labelStyle: AppTypography.labelMd.copyWith(color: p.textMuted),
        floatingLabelStyle:
            AppTypography.labelSm.copyWith(color: AppColors.brandPrimary),
        hintStyle: AppTypography.bodyMd.copyWith(color: p.textPlaceholder),
        prefixIconColor: p.textMuted,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 17,
        ),
      ),

      chipTheme: ChipThemeData(
        selectedColor: AppColors.brandPrimary,
        backgroundColor: p.surfaceContainer,
        checkmarkColor: p.onBrand,
        labelStyle: AppTypography.labelSm,
        shape: const StadiumBorder(),
        side: BorderSide(color: p.outline),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.ms,
          vertical: AppSpacing.sm,
        ),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.brandPrimary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.brandPrimary,
          foregroundColor: p.onBrand,
          minimumSize: const Size(double.infinity, 52),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.brMdPlus),
          textStyle: AppTypography.buttonLg,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.brandPrimary,
          side: const BorderSide(color: AppColors.brandPrimary),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.brMdPlus),
        ),
      ),

      dividerTheme: DividerThemeData(
        color: p.divider,
        thickness: 1,
        space: 0,
      ),

      segmentedButtonTheme: const SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor:
              WidgetStatePropertyAll<Color>(Color(0xFFFFFFFF)),
        ),
      ),
    );
  }
}

// Cache local del shape de la paleta (evita lookups repetidos al construir
// el theme — el getter `AppColors.light` ya da una const instance).
class _LightP {
  const _LightP();
  Color get scaffold => AppColors.light.scaffold;
  Color get surface => AppColors.light.surface;
  Color get surfaceMuted => AppColors.light.surfaceMuted;
  Color get surfaceContainer => AppColors.light.surfaceContainer;
  Color get textBody => AppColors.light.textBody;
  Color get textMuted => AppColors.light.textMuted;
  Color get textPlaceholder => AppColors.light.textPlaceholder;
  Color get outline => AppColors.light.outline;
  Color get divider => AppColors.light.divider;
  Color get onBrand => AppColors.light.onBrand;
}
