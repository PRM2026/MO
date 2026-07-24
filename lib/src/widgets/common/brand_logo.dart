import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';

/// Logo đại diện: vòng tròn vàng + sao trắng.
class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.size = 32, this.elevated = false});

  final double size;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    final iconSize = size * 0.55;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
        boxShadow: elevated
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: SizedBox(
        width: size,
        height: size,
        child: Icon(Icons.star_rounded, color: Colors.white, size: iconSize),
      ),
    );
  }
}
