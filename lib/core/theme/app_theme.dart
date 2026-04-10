import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData get lightTheme {
    const ColorScheme lightScheme = ColorScheme.light(
      primary: Color(0xFF002B02),
      onPrimary: Colors.white,
      secondary: Color(0xFF4A6549),
      onSecondary: Colors.white,
      surface: Color(0xFFFBFAEE),
      onSurface: Color(0xFF1B1C15),
      error: Color(0xFFBA1A1A),
      onError: Colors.white,
    );

    final TextTheme textTheme = GoogleFonts.plusJakartaSansTextTheme();

    return ThemeData(
      useMaterial3: true,
      colorScheme: lightScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: const Color(0xFFFBFAEE),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: const Color(0xFFFBFAEE),
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.epilogue(
          color: const Color(0xFF1B1C15),
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

  static ThemeData get darkTheme {
    final ColorScheme darkScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF1F7A5A),
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: darkScheme,
      textTheme: GoogleFonts.plusJakartaSansTextTheme(ThemeData.dark().textTheme),
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
