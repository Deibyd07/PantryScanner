import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Escala tipográfica semántica.
///
/// **Familias**:
/// - **Plus Jakarta Sans** — UI por defecto (body, labels, inputs).
/// - **Epilogue** — display & headings (más expresiva, geometric).
///
/// **Pesos**:
/// - 400 (regular) — body
/// - 500 (medium) — UI helpers
/// - 600 (semibold) — labels destacados
/// - 700 (bold) — botones, énfasis
/// - 800 (extrabold) — titles
/// - 900 (black) — display hero
///
/// **Uso**:
/// ```dart
/// Text('Hola', style: AppTypography.title.copyWith(color: ...))
/// ```
///
/// Para escalas dependientes del usuario (Dynamic Type / fontScaleFactor),
/// el sistema respeta automáticamente MediaQuery.textScaler — no override.
class AppTypography {
  AppTypography._();

  // ──────────────────────────────────────────────────────────────────────────
  // DISPLAY — Epilogue, peso 900, letter-spacing negativo
  // ──────────────────────────────────────────────────────────────────────────

  /// 52pt — Hero principal ("Mi despensa").
  static TextStyle get displayHero => GoogleFonts.epilogue(
        fontSize: 52,
        fontWeight: FontWeight.w900,
        letterSpacing: -2.8,
        height: 0.92,
      );

  /// 32pt — Display alternativo ("Alertas inteligentes").
  static TextStyle get displayLg => GoogleFonts.epilogue(
        fontSize: 32,
        fontWeight: FontWeight.w900,
        height: 1.05,
        letterSpacing: -0.8,
      );

  /// 26pt — Display medium ("Bienvenido de nuevo").
  static TextStyle get displayMd => GoogleFonts.epilogue(
        fontSize: 26,
        fontWeight: FontWeight.w900,
        height: 1.1,
        letterSpacing: -0.5,
      );

  /// 24pt — Display compacto ("¡Correo enviado!", "Recuperar contraseña").
  static TextStyle get displaySm => GoogleFonts.epilogue(
        fontSize: 24,
        fontWeight: FontWeight.w900,
        height: 1.05,
        letterSpacing: -0.4,
      );

  // ──────────────────────────────────────────────────────────────────────────
  // HEADINGS — Epilogue, peso 800
  // ──────────────────────────────────────────────────────────────────────────

  /// 22pt — Heading large (valores destacados, métricas grandes).
  static TextStyle get headingLg => GoogleFonts.epilogue(
        fontSize: 22,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.5,
      );

  /// 18pt — Heading regular (app bar titles, section headers grandes).
  static TextStyle get headingMd => GoogleFonts.epilogue(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.3,
      );

  /// 16pt — Heading pequeño (card titles, section titles).
  static TextStyle get headingSm => GoogleFonts.epilogue(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.3,
      );

  /// 15pt — Heading micro (product name in card).
  static TextStyle get headingXs => GoogleFonts.epilogue(
        fontSize: 15,
        fontWeight: FontWeight.w800,
        height: 1.2,
        letterSpacing: -0.3,
      );

  // ──────────────────────────────────────────────────────────────────────────
  // BODY — Plus Jakarta Sans
  // ──────────────────────────────────────────────────────────────────────────

  /// 16pt — Body large (texto principal extenso).
  static TextStyle get bodyLg => GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.5,
      );

  /// 14pt — Body regular (texto principal, paragraphs).
  static TextStyle get bodyMd => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.4,
      );

  /// 13pt — Body small (descriptions, subtitles).
  static TextStyle get bodySm => GoogleFonts.plusJakartaSans(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        height: 1.4,
      );

  /// 12pt — Body extra small (helpers, hints).
  static TextStyle get bodyXs => GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.4,
      );

  // ──────────────────────────────────────────────────────────────────────────
  // LABEL — Plus Jakarta Sans, semibold / bold
  // ──────────────────────────────────────────────────────────────────────────

  /// 16pt bold — Botón primario.
  static TextStyle get buttonLg => GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.3,
      );

  /// 14pt bold — Botón estándar / link prominente.
  static TextStyle get buttonMd => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
      );

  /// 13pt semibold — Label de input destacado.
  static TextStyle get labelMd => GoogleFonts.plusJakartaSans(
        fontSize: 13,
        fontWeight: FontWeight.w600,
      );

  /// 12pt semibold — Label / chip text.
  static TextStyle get labelSm => GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      );

  /// 11pt semibold — Status / metric labels.
  static TextStyle get labelXs => GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w600,
      );

  /// 10pt black uppercase — Tab bar labels, micro-tags.
  static TextStyle get labelTab => GoogleFonts.plusJakartaSans(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.4,
      );

  /// 9pt extrabold uppercase — Status badges (CATEGORY, VENCIDO).
  static TextStyle get caption => GoogleFonts.plusJakartaSans(
        fontSize: 9,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.4,
      );

  // ──────────────────────────────────────────────────────────────────────────
  // TextTheme builder — para inyectar en ThemeData.
  // ──────────────────────────────────────────────────────────────────────────

  /// Construye un TextTheme aplicando Plus Jakarta Sans a la jerarquía
  /// de Material. Override semántico para los slots de display con Epilogue.
  static TextTheme buildTextTheme({required Brightness brightness}) {
    final Color body = brightness == Brightness.light
        ? AppColors.light.textBody
        : AppColors.dark.textBody;

    final TextTheme base = brightness == Brightness.light
        ? ThemeData.light().textTheme
        : ThemeData.dark().textTheme;

    return GoogleFonts.plusJakartaSansTextTheme(base)
        .apply(bodyColor: body, displayColor: body)
        .copyWith(
          // Display slots → Epilogue
          displayLarge: displayHero.copyWith(color: body),
          displayMedium: displayLg.copyWith(color: body),
          displaySmall: displayMd.copyWith(color: body),
          headlineLarge: displaySm.copyWith(color: body),
          headlineMedium: headingLg.copyWith(color: body),
          headlineSmall: headingMd.copyWith(color: body),
          titleLarge: headingMd.copyWith(color: body),
          titleMedium: headingSm.copyWith(color: body),
          titleSmall: headingXs.copyWith(color: body),
        );
  }
}
