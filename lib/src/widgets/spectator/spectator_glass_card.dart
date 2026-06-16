import 'dart:ui';

import 'package:flutter/material.dart';

import '../../constants/referee_colors.dart';

class SpectatorGlassCard extends StatelessWidget {
  const SpectatorGlassCard({
    super.key,
    required this.child,
    this.borderRadius = 12,
    this.padding,
    this.accentBorder = false,
    this.accentColor,
  });

  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final bool accentBorder;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final borderSide = accentBorder
        ? Border(
            left: BorderSide(
              color: accentColor ?? RefereeColors.championshipGold,
              width: 4,
            ),
          )
        : null;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: RefereeColors.glassFill,
            border: Border.all(color: RefereeColors.glassBorder),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: Container(
            decoration: BoxDecoration(
              border: borderSide,
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}
