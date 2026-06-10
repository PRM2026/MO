import 'package:flutter/material.dart';

import '../../constants/app_theme_tokens.dart';
import '../../constants/auth_colors.dart';

class AuthSectionDivider extends StatelessWidget {
  const AuthSectionDivider({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AuthColors.slate100, height: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            label.toUpperCase(),
            style: AppTypography.labelCaps(AuthColors.slate400),
          ),
        ),
        const Expanded(child: Divider(color: AuthColors.slate100, height: 1)),
      ],
    );
  }
}
