import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ⚡ Brand Color Accents - Perfectly matched to your high-performance FITTER logo look
  static const Color primaryNeon = Color(0xFFC0FF00);
  static const Color primaryOrange = primaryNeon; // Fallback alias so older widgets don't throw compiler errors
  static const Color secondaryNavy = Color(0xFF1E293B);

  // Light Mode Color System
  static const Color lightBg = Color(0xFFF8FAFC);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textLight = Color(0xFF64748B);

  // Dark Mode Color System - Updated to Pitch Black to seamlessly match your logo backdrop
  static const Color darkBg = Color(0xFF000000);
  static const Color darkCard = Color(0xFF121212); // Deep premium charcoal grey for visual card contrast
  static const Color textWhite = Color(0xFFFFFFFF);

  // Status Colors
  static const Color success = Color(0xFF22C55E);
  static const Color danger = Color(0xFFEF4444);

  static TextStyle _baseTextStyle(Color color, double size, FontWeight weight) {
    return GoogleFonts.poppins(
      color: color,
      fontSize: size,
      fontWeight: weight,
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBg,
      cardColor: lightCard,
      primaryColor: primaryNeon,
      colorScheme: const ColorScheme.light(
        primary: primaryNeon,
        secondary: secondaryNavy,
        surface: lightCard,
        error: danger,
      ),
      textTheme: TextTheme(
        headlineLarge: _baseTextStyle(textDark, 24, FontWeight.bold),
        titleLarge: _baseTextStyle(textDark, 18, FontWeight.w600),
        bodyMedium: _baseTextStyle(textDark, 14, FontWeight.normal),
        bodySmall: _baseTextStyle(textLight, 12, FontWeight.normal),
        labelLarge: _baseTextStyle(textDark, 28, FontWeight.bold),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBg,
      cardColor: darkCard,
      primaryColor: primaryNeon,
      colorScheme: const ColorScheme.dark(
        primary: primaryNeon,
        secondary: darkCard,
        surface: darkCard,
        error: danger,
      ),
      textTheme: TextTheme(
        headlineLarge: _baseTextStyle(textWhite, 24, FontWeight.bold),
        titleLarge: _baseTextStyle(textWhite, 18, FontWeight.w600),
        bodyMedium: _baseTextStyle(textWhite, 14, FontWeight.normal),
        bodySmall: _baseTextStyle(textLight, 12, FontWeight.normal),
        labelLarge: _baseTextStyle(textWhite, 28, FontWeight.bold),
      ),
    );
  }
}