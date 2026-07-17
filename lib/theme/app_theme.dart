import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF6E8EFB);
  static const Color secondary = Color(0xFFA777E3);
  static const Color background = Color(0xFFF5F7FA);
  static const Color inputBackground = Color(0xFFF9FAFC);
  static const Color line = Color(0xFFE1E5EB);
  static const Color softLine = Color(0xFFF0F2F5);
  static const Color textDark = Color(0xFF333333);
  static const Color textMedium = Color(0xFF666666);
  static const Color textLight = Color(0xFF8A94A6);
  static const Color danger = Color(0xFFE74C3C);
  static const Color success = Color(0xFF52C41A);

  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, secondary],
  );

  static const List<String> _fontFallback = [
    'PingFang SC',
    'Microsoft YaHei',
    'Helvetica Neue',
    'Arial',
  ];

  static ThemeData light() {
    return _build(
      brightness: Brightness.light,
      scaffoldBackground: background,
      surface: background,
      inputFill: inputBackground,
      borderColor: line,
      textPrimary: textDark,
      textSecondary: textMedium,
    );
  }

  static ThemeData dark() {
    const darkScaffold = Color(0xFF12141A);
    const darkSurface = Color(0xFF1B1F2A);
    const darkInput = Color(0xFF242836);
    const darkLine = Color(0xFF343A4A);
    const darkText = Color(0xFFE8EAF0);
    const darkMuted = Color(0xFFA7AEBE);
    return _build(
      brightness: Brightness.dark,
      scaffoldBackground: darkScaffold,
      surface: darkSurface,
      inputFill: darkInput,
      borderColor: darkLine,
      textPrimary: darkText,
      textSecondary: darkMuted,
    );
  }

  static ThemeData _build({
    required Brightness brightness,
    required Color scaffoldBackground,
    required Color surface,
    required Color inputFill,
    required Color borderColor,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: scaffoldBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: brightness,
        primary: primary,
        secondary: secondary,
        surface: surface,
      ),
      fontFamilyFallback: _fontFallback,
      textTheme: TextTheme(
        headlineMedium: TextStyle(
          color: textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(color: textSecondary, fontSize: 16),
        bodyMedium: TextStyle(color: textSecondary, fontSize: 14),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputFill,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: secondary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF4D4F)),
        ),
      ),
    );
  }
}
