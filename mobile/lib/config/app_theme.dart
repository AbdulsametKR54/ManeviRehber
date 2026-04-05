import 'package:flutter/material.dart';

class AppTheme {
  // Light Theme Colors
  static const Color lPrimary = Color(0xFF1E5F4F);
  static const Color lPrimaryVariant = Color(0xFF2F7F68);
  static const Color lSecondary = Color(0xFFC9A66B);
  static const Color lAccent = Color(0xFFE8DCC2);
  static const Color lBackground = Color(0xFFF7F7F5);
  static const Color lSurface = Color(0xFFFFFFFF);
  static const Color lSurfaceVariant = Color(0xFFF0F0EC);
  static const Color lOnPrimary = Colors.white;
  static const Color lOnSecondary = Color(0xFF1A1A1A);
  static const Color lTextPrimary = Color(0xFF1A1A1A);
  static const Color lTextSecondary = Color(0xFF4A4A4A);
  static const Color lMuted = Color(0xFF7A7A7A);

  // Dark Theme Colors
  static const Color dPrimary = Color(0xFF4CC9A6);
  static const Color dPrimaryVariant = Color(0xFF3BA88A);
  static const Color dSecondary = Color(0xFFD4B98A);
  static const Color dAccent = Color(0xFF2A2F2E);
  static const Color dBackground = Color(0xFF0F1514);
  static const Color dSurface = Color(0xFF1A1F1E);
  static const Color dSurfaceVariant = Color(0xFF232927);
  static const Color dOnPrimary = Color(0xFF0F1514);
  static const Color dOnSecondary = Colors.white;
  static const Color dTextPrimary = Color(0xFFFFFFFF);
  static const Color dTextSecondary = Color(0xFFC7C7C7);
  static const Color dMuted = Color(0xFF8A8A8A);

  static ThemeData lightTheme(Color seedColor) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.light,
        surface: lSurface,
      ),
      scaffoldBackgroundColor: lBackground,
      fontFamily: 'Manrope',
      appBarTheme: const AppBarTheme(
        backgroundColor: lSurface,
        foregroundColor: lTextPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontFamily: 'Noto Serif', color: lTextPrimary),
        headlineMedium: TextStyle(fontFamily: 'Noto Serif', color: lTextPrimary),
        titleLarge: TextStyle(fontFamily: 'Noto Serif', color: lTextPrimary),
        bodyLarge: TextStyle(color: lTextPrimary),
        bodyMedium: TextStyle(color: lTextSecondary),
        bodySmall: TextStyle(color: lMuted),
      ),
    );
  }

  static ThemeData darkTheme(Color seedColor) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.dark,
        surface: dSurface,
      ),
      scaffoldBackgroundColor: dBackground,
      fontFamily: 'Manrope',
      appBarTheme: const AppBarTheme(
        backgroundColor: dSurface,
        foregroundColor: dTextPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontFamily: 'Noto Serif', color: dTextPrimary),
        headlineMedium: TextStyle(fontFamily: 'Noto Serif', color: dTextPrimary),
        titleLarge: TextStyle(fontFamily: 'Noto Serif', color: dTextPrimary),
        bodyLarge: TextStyle(color: dTextPrimary),
        bodyMedium: TextStyle(color: dTextSecondary),
        bodySmall: TextStyle(color: dMuted),
      ),
    );
  }

}
