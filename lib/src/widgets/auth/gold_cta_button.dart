import 'package:flutter/material.dart';

import '../../constants/auth_colors.dart';
import '../../constants/app_theme_tokens.dart';

class GoldCtaButton extends StatelessWidget {
  const GoldCtaButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AuthColors.goldGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AuthColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(label, style: AppTypography.headlineSm(Colors.white)),
            ),
          ),
        ),
      ),
    );
  }
}
