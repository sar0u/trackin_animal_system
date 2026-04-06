import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Titres
  static const TextStyle titleLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.lightOnSurface,
  );
  static const TextStyle titleMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.lightOnSurface,
  );
  static const TextStyle titleSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.lightOnSurface,
  );

  // Texte Principal
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    color: AppColors.lightOnSurface,
  );
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    color: AppColors.lightOnSurface,
  );
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    color: AppColors.lightOnSurface,
  );

  // Boutons
  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  // Labels
  static const TextStyle labelMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.lightOnSurface,
  );
  static const TextStyle labelSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.lightOnSurface,
  );

  // Headers (h1, h2, h3, h4)
  static const TextStyle h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.lightOnSurface,
  );
  static const TextStyle h2 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.lightOnSurface,
  );
  static const TextStyle h3 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.lightOnSurface,
  );
  static const TextStyle h4 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.lightOnSurface,
  );

  // Thème Sombre
  static const TextStyle darkTitleLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.darkOnSurface,
  );
  static const TextStyle darkBodyLarge = TextStyle(
    fontSize: 16,
    color: AppColors.darkOnSurface,
  );
  static const TextStyle darkLabelMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.darkOnSurface,
  );
}