import 'package:flutter/material.dart';

class AppTheme {
  // Cinematic Forest color palette
  static const Color background = Color(0xFF0F1713); // Deep forest dark
  static const Color surface = Color(0xFF1B261E);    // Dark moss surface
  static const Color textPrimary = Color(0xFFEBEDED); // White/ice primary text
  static const Color textSecondary = Color(0xFFAAB2AC); // Soft leaf grey text
  static const Color primary = Color(0xFF62A87C);    // Pine green accent
  static const Color accent = Color(0xFF7CB9E8);    // Mist blue accent
  static const Color divider = Color(0x33EBEDED);   // Subtle light divider

  // Liquid glass colors (Optimized for dark background)
  static const Color glassWhite = Color(0x1AFFFFFF);         // ~10% opacity white
  static const Color glassBorder = Color(0x66FFFFFF);        // ~40% white for sharp edge
  static const Color glassShadow = Color(0x44000000);        // Deeper shadow for depth
  static const Color glassHighlight = Color(0xCCFFFFFF);      // ~80% white for spectral edge

  static const String fontFamily = 'Calibri';

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primary,
      scaffoldBackgroundColor: background,
      fontFamily: fontFamily,
      colorScheme: ColorScheme.dark(
        primary: primary,
        secondary: accent,
        surface: surface,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: textPrimary,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          fontSize: 32,
        ),
        displayMedium: TextStyle(
          color: textPrimary,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
          fontSize: 24,
        ),
        bodyLarge: TextStyle(
          color: textPrimary,
          fontWeight: FontWeight.w400,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: textSecondary,
          fontWeight: FontWeight.w400,
          fontSize: 14,
        ),
        labelLarge: TextStyle(
          color: textPrimary,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
          fontSize: 14,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
        ),
      ),
      useMaterial3: true,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
    );
  }
}
