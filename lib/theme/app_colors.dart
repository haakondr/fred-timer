import 'package:flutter/material.dart';

class AppColors {
  // Light Mode Colors
  static const Color background = Color(0xFFF5F7FA); // Cool gray
  static const Color surface = Color(0xFFFFFFFF); // White
  static const Color magenta = Color(0xFFFF0080); // Danger/Primary
  static const Color violet = Color(0xFF6C71C4); // Solarized violet - Primary
  static const Color iceBlue = Color(0xFF64FFDA); // Success/Accent
  static const Color poisonGreen = Color(0xFF00FF00); // Warning
  static const Color navy = Color(0xFF0a192f); // Text/Dark actions
  static const Color border = Color(0xFFE0E0E0); // Dividers

  // Dark Mode Colors
  static const Color darkBackground = Color(0xFF0a192f); // Navy
  static const Color darkSurface = Color(0xFF112240); // Lighter navy
  static const Color darkText = Color(0xFFE6F1FF); // Light blue-white
  static const Color darkTextSecondary = Color(0x99E6F1FF); // 60% opacity
  static const Color darkBorder = Color(0xFF233554); // Muted navy

  // Semantic Colors (shared across themes)
  static const Color danger = magenta;
  static const Color success = iceBlue;
  static const Color warning = poisonGreen;
  static const Color primary = violet;
}
