import 'package:flutter/material.dart';

import '../../constants/referee_colors.dart';

class RefereeGlassCard extends StatelessWidget {
  const RefereeGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.highlighted = false,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool highlighted;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = DecoratedBox(
      decoration: BoxDecoration(
        color: RefereeColors.glassFill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: highlighted
              ? RefereeColors.tertiary.withValues(alpha: 0.4)
              : RefereeColors.glassBorder,
        ),
        boxShadow: highlighted
            ? [
                BoxShadow(
                  color: RefereeColors.tertiary.withValues(alpha: 0.12),
                  blurRadius: 12,
                ),
              ]
            : null,
      ),
      child: Padding(padding: padding, child: child),
    );

    if (onTap == null) return card;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: card,
      ),
    );
  }
}

class RefereeSpeedLine extends StatelessWidget {
  const RefereeSpeedLine({super.key, this.opacity = 1});

  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Container(
        height: 2,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          gradient: LinearGradient(
            colors: [
              RefereeColors.tertiary,
              RefereeColors.tertiary.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
  }
}
