import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Seed & scheme colours ────────────────────────────────────────────────
  static const Color _primary   = Color(0xFFC0392B); // rojo cereza
  static const Color _secondary = Color(0xFFE74C3C); // rojo vibrante
  static const Color _surface   = Color(0xFFFFF8F7); // blanco cálido rosado
  static const Color _onSurface = Color(0xFF3B0A0A); // granate oscuro

  static ThemeData get lightTheme {
    const ColorScheme lightScheme = ColorScheme.light(
      primary:               _primary,
      onPrimary:             Colors.white,
      primaryContainer:      Color(0xFFFFDAD7), // rosa suave
      onPrimaryContainer:    Color(0xFF410002),
      secondary:             _secondary,
      onSecondary:           Colors.white,
      secondaryContainer:    Color(0xFFFFEDEB),
      onSecondaryContainer:  Color(0xFF5C0006),
      tertiary:              Color(0xFFFF6B6B), // coral
      onTertiary:            Colors.white,
      surface:               _surface,
      onSurface:             _onSurface,
      surfaceContainerHighest: Color(0xFFFFEDEB),
      error:                 Color(0xFFBA1A1A),
      onError:               Colors.white,
      outline:               Color(0xFFFFBDBA),
      outlineVariant:        Color(0xFFFFD9D7),
    );

    final TextTheme textTheme = GoogleFonts.plusJakartaSansTextTheme(ThemeData.light().textTheme).apply(
      bodyColor: _onSurface,
      displayColor: _onSurface,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: lightScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: _surface,

      // ── AppBar ──────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: _surface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.epilogue(
          color: _onSurface,
          fontWeight: FontWeight.w900,
          fontSize: 18,
        ),
        iconTheme: const IconThemeData(color: _primary),
      ),

      // ── Snackbar ─────────────────────────────────────────────────────────
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),

      // ── Input fields ─────────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(24)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(24)),
          borderSide: BorderSide(color: _primary, width: 2),
        ),
        labelStyle: const TextStyle(color: _primary),
        prefixIconColor: _primary,
      ),

      // ── Chips ─────────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        selectedColor: _primary,
        checkmarkColor: Colors.white,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
        shape: const StadiumBorder(),
        side: const BorderSide(color: Color(0xFFFFBDBA)),
      ),

      // ── Floating Action Button ─────────────────────────────────────────
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFFC0392B),
        foregroundColor: Colors.white,
        elevation: 6,
      ),
    );
  }

  // ── Dark theme ───────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    final ColorScheme darkScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFFC0392B),
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: darkScheme,
      textTheme:
          GoogleFonts.plusJakartaSansTextTheme(ThemeData.dark().textTheme),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: darkScheme.surface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.epilogue(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 18,
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(24)),
        ),
      ),
    );
  }
}
