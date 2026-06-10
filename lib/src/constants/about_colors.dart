import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Design tokens for the About / Giới thiệu screen (Grand Championship M3).
abstract final class AboutColors {
  static const Color surface = AppColors.surface;
  static const Color surfaceLow = AppColors.surfaceContainer;
  static const Color surfaceHighest = Color(0xFFEAE7E7);
  static const Color primary = Color(0xFF0D2542);
  static const Color secondary = Color(0xFF795900);
  static const Color secondaryContainer = Color(0xFFFFC641);
  static const Color onSecondary = Colors.white;
  static const Color outline = Color(0xFF74777E);
  static const Color outlineVariant = AppColors.outlineVariant;

  static const LinearGradient ctaGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFC641), Color(0xFF795900)],
  );
}
