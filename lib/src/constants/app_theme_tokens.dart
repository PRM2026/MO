import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppTypography {
  static TextStyle displayLg(Color color) => GoogleFonts.beVietnamPro(
    fontSize: 32,
    height: 40 / 32,
    letterSpacing: -0.32,
    fontWeight: FontWeight.w700,
    color: color,
  );

  static TextStyle displayMd(Color color) => GoogleFonts.beVietnamPro(
    fontSize: 28,
    height: 36 / 28,
    letterSpacing: -0.28,
    fontWeight: FontWeight.w700,
    color: color,
  );

  static TextStyle headlineSm(Color color) => GoogleFonts.beVietnamPro(
    fontSize: 20,
    height: 28 / 20,
    fontWeight: FontWeight.w600,
    color: color,
  );

  static TextStyle bodyMd(Color color) => GoogleFonts.beVietnamPro(
    fontSize: 15,
    height: 22 / 15,
    fontWeight: FontWeight.w400,
    color: color,
  );

  static TextStyle bodySm(Color color) => GoogleFonts.beVietnamPro(
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w400,
    color: color,
  );

  static TextStyle labelCaps(Color color) => GoogleFonts.beVietnamPro(
    fontSize: 12,
    height: 16 / 12,
    letterSpacing: 0.6,
    fontWeight: FontWeight.w700,
    color: color,
  );
}
