import 'package:flutter/material.dart';

/// Palette for auth screens (light editorial theme).
abstract final class AuthColors {
  static const Color navy = Color(0xFF1E3A5F);
  static const Color background = Colors.white;
  static const Color headerGlowStart = Color(0xFFFFF8F0);
  static const Color headerGlowEnd = Colors.white;
  static const Color primary = Color(0xFFF6BE39);
  static const Color primaryDark = Color(0xFFD4A017);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate50 = Color(0xFFF8FAFC);
  static const Color facebookBlue = Color(0xFF1877F2);

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [headerGlowStart, headerGlowEnd],
  );
}
