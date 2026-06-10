import 'package:flutter/material.dart';

abstract final class AppColors {
  static const Color primary = Color(0xFFD4A017);
  static const Color primaryBright = Color(0xFFF6BE39);
  static const Color onPrimary = Color(0xFF402D00);
  static const Color secondary = Color(0xFF2F4A70);
  static const Color onSurface = Color(0xFF071325);
  static const Color onSurfaceVariant = Color(0xFF4F4634);
  static const Color surface = Color(0xFFF8FAFC);
  static const Color surfaceContainer = Color(0xFFF1F5F9);
  static const Color outlineVariant = Color(0xFFE2E8F0);
  static const Color primaryContainer = Color(0xFFF6BE39);
  static const Color onPrimaryContainer = Color(0xFFFFFFFF);

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF6BE39), Color(0xFFD4A017)],
  );
}
