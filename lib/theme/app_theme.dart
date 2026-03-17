import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.skyBlue,
        secondary: AppColors.iceBlue,
        surface: AppColors.surface,
        error: AppColors.magenta,
        onPrimary: Colors.white,
        onSecondary: AppColors.navy,
        onSurface: AppColors.navy,
        onError: Colors.white,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFFDF6E3), // Solarized base3 (cream)
        foregroundColor: Color(0xFF073642), // Solarized base02 (dark blue-gray)
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.skyBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.navy,
          side: const BorderSide(color: AppColors.border, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: AppColors.skyBlue,
        inactiveTrackColor: AppColors.border,
        thumbColor: AppColors.skyBlue,
        overlayColor: Color(0x2957C7FF),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 96,
          fontWeight: FontWeight.bold,
          color: AppColors.navy,
        ),
        displayMedium: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.bold,
          color: AppColors.navy,
        ),
        displaySmall: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.navy,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.navy,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: AppColors.navy,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: AppColors.navy,
        ),
      ),
    );
  }

  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.skyBlue,
        secondary: AppColors.iceBlue,
        surface: AppColors.darkSurface,
        error: AppColors.magenta,
        onPrimary: Colors.white,
        onSecondary: AppColors.darkText,
        onSurface: AppColors.darkText,
        onError: Colors.white,
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.darkBorder, width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.darkText,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.skyBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.darkText,
          side: const BorderSide(color: AppColors.darkBorder, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: AppColors.skyBlue,
        inactiveTrackColor: AppColors.darkBorder,
        thumbColor: AppColors.skyBlue,
        overlayColor: Color(0x2957C7FF),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 96,
          fontWeight: FontWeight.bold,
          color: AppColors.darkText,
        ),
        displayMedium: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.bold,
          color: AppColors.darkText,
        ),
        displaySmall: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.darkText,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.darkText,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: AppColors.darkText,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: AppColors.darkTextSecondary,
        ),
      ),
    );
  }
}
