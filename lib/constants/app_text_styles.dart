import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Headings
  static const TextStyle heading1 = TextStyle(
    fontSize: 28.0,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
    fontFamily: 'Roboto',
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 24.0,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
    fontFamily: 'Roboto',
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
    fontFamily: 'Roboto',
  );

  // Body text
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.normal,
    color: AppColors.textDark,
    fontFamily: 'Roboto',
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.normal,
    color: AppColors.textDark,
    fontFamily: 'Roboto',
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.normal,
    color: AppColors.textMedium,
    fontFamily: 'Roboto',
  );

  // Button text
  static const TextStyle buttonText = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    fontFamily: 'Roboto',
  );

  // Input text
  static const TextStyle inputText = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.normal,
    color: AppColors.textDark,
    fontFamily: 'Roboto',
  );

  static const TextStyle inputLabel = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.w500,
    color: AppColors.textMedium,
    fontFamily: 'Roboto',
  );

  // Link text
  static const TextStyle linkText = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    color: AppColors.primaryGreen,
    fontFamily: 'Roboto',
    decoration: TextDecoration.underline,
  );
}
