import 'package:flutter/material.dart';

import '../../constants/app_spacing.dart';
import '../../constants/app_theme_tokens.dart';
import '../../constants/auth_colors.dart';

enum SocialProvider { google, facebook }

class SocialAuthButton extends StatelessWidget {
  const SocialAuthButton({super.key, required this.provider, this.onPressed});

  final SocialProvider provider;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        side: const BorderSide(color: AuthColors.slate200),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (provider == SocialProvider.google)
            const Icon(
              Icons.g_mobiledata_rounded,
              color: Color(0xFF4285F4),
              size: 26,
            )
          else
            const Icon(
              Icons.facebook,
              color: AuthColors.facebookBlue,
              size: 20,
            ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            provider == SocialProvider.google ? 'Google' : 'Facebook',
            style: AppTypography.bodyMd(
              AuthColors.slate700,
            ).copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
