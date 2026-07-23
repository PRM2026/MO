import 'package:flutter/material.dart';

import '../../constants/auth_colors.dart';

class AuthBackButton extends StatelessWidget {
  const AuthBackButton({
    super.key,
    required this.onPressed,
    this.tooltip = 'Quay lại',
  });

  final VoidCallback onPressed;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.92),
      shape: CircleBorder(
        side: BorderSide(color: AuthColors.slate200.withValues(alpha: 0.9)),
      ),
      elevation: 1,
      shadowColor: AuthColors.navy.withValues(alpha: 0.12),
      child: IconButton(
        key: const ValueKey('auth-back-button'),
        onPressed: onPressed,
        tooltip: tooltip,
        icon: const Icon(Icons.arrow_back_rounded),
        color: AuthColors.navy,
        iconSize: 22,
        constraints: const BoxConstraints.tightFor(width: 44, height: 44),
        padding: EdgeInsets.zero,
      ),
    );
  }
}
