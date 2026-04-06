import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color surface = Color(0xFFF7FAFC);
  static const Color surfaceContainerLow = Color(0xFFF1F4F6);
  static const Color surfaceContainerHighest = Color(0xFFE0E3E5);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);

  static const Color primary = Color(0xFF074469);
  static const Color primaryContainer = Color(0xFF2A5C82);

  static const Color onSurface = Color(0xFF181C1E);
  static const Color onSurfaceVariant = Color(0xFF5A6472);
  static const Color onPrimary = Color(0xFFFFFFFF);

  static const Color outlineVariant = Color(0xFFCACED2);

  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color warning = Color(0xFF5A3B00);
  static const Color warningContainer = Color(0xFFFFF0D4);

  static const Color stableGreen = Color(0xFF1B6B3A);
  static const Color stableGreenContainer = Color(0xFFD4F0E0);
  static const Color observationBlue = Color(0xFF1565C0);
  static const Color observationBlueContainer = Color(0xFFD6E4FF);

  static const Gradient signatureGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryContainer],
  );
}
