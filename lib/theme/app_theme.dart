import 'package:flutter/material.dart';

class AppTheme {
  // Off-white minimal color palette
  static const Color background = Color(0xFFF4F3EF);
  static const Color surface = Color(0xFFFAF9F6);
  static const Color textPrimary = Color(0xFF1C1C1E);
  static const Color textSecondary = Color(0xFF8A8A8E);
  static const Color primary = Color(0xFF3A3A5C); // Deep slate accent
  static const Color accent = Color(0xFF5E6AD2);   // Soft indigo
  static const Color divider = Color(0xFFE5E5EA);

  // Liquid glass colors
  static const Color glassWhite = Color(0xCCFFFFFF);         // white with ~80% opacity
  static const Color glassBorder = Color(0xAAFFFFFF);        // border highlight
  static const Color glassShadow = Color(0x22000000);        // subtle shadow

  static const String fontFamily = 'Calibri';

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: accent,
      scaffoldBackgroundColor: background,
      fontFamily: fontFamily,
      colorScheme: ColorScheme.light(
        primary: accent,
        secondary: primary,
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
