import 'package:flutter/material.dart';

import '../../constants/auth_colors.dart';
import '../../constants/auth_constants.dart';

class AuthBackground extends StatelessWidget {
  const AuthBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 353,
          child: DecoratedBox(
            decoration: BoxDecoration(gradient: AuthColors.headerGradient),
          ),
        ),
        if (MediaQuery.sizeOf(context).width >= 768)
          Positioned(
            top: 0,
            right: 0,
            child: Opacity(
              opacity: 0.2,
              child: Image.network(
                AuthConstants.decorationImageUrl,
                width: 600,
                height: 600,
                fit: BoxFit.contain,
              ),
            ),
          ),
      ],
    );
  }
}
