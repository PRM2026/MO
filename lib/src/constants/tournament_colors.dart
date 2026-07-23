import 'package:flutter/material.dart';

/// Design tokens for Giải đấu screen (Grand Championship M3).
abstract final class TournamentColors {
  static const Color primary = Color(0xFF0D2542);
  static const Color secondary = Color(0xFF795900);
  static const Color secondaryContainer = Color(0xFFFFC641);
  static const Color onSurfaceVariant = Color(0xFF44474D);
  static const Color outline = Color(0xFF74777E);
  static const Color outlineVariant = Color(0xFFC4C6CE);
  static const Color surface = Color(0xFFFCF9F8);
  static const Color liveRed = Color(0xFFEF4444);

  static const LinearGradient imageOverlay = LinearGradient(
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    colors: [Color(0xE60D2542), Color(0x660D2542), Colors.transparent],
    stops: [0.0, 0.5, 1.0],
  );
}
