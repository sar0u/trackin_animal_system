import 'package:flutter/material.dart';

class AppColors {
  // Thème Vert Principal
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color primaryGreenLight = Color(0xFF4CAF50);
  static const Color primaryGreenDark = Color(0xFF1B5E20);
  static const Color primaryGreenAccent = Color(0xFF66BB6A);

  // Palette Secondaire
  static const Color secondaryOlive = Color(0xFF8D6E63);
  static const Color successGreen = Color(0xFF66BB6A);
  static const Color warningOrange = Color(0xFFFF9800);
  static const Color dangerRed = Color(0xFFF44336);
  static const Color infoBlue = Color(0xFF2196F3);

  // Thème Clair
  static const Color lightBackground = Color(0xFFF5F5F5);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightOnSurface = Color(0xFF212121);
  static const Color lightBorder = Color(0xFFE0E0E0);

  // Thème Sombre
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkOnSurface = Color(0xFFE0E0E0);
  static const Color darkBorder = Color(0xFF333333);

  // Getters pour compatibilité avec le code existant
  static Color get primary => primaryGreen;
  static Color get surface => lightSurface;
  static Color get error => dangerRed;
  static Color get textSecondary => Colors.grey;
  static Color get textPrimary => lightOnSurface;
  static Color get border => lightBorder;
}