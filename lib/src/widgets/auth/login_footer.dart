import 'package:flutter/material.dart';

import '../../constants/app_spacing.dart';
import '../../constants/app_theme_tokens.dart';
import '../../constants/auth_colors.dart';

class LoginFooter extends StatelessWidget {
  const LoginFooter({
    super.key,
    this.promptText = 'Chưa có tài khoản? ',
    this.actionLabel = 'Đăng ký ngay',
    this.onActionTap,
    this.showTopDivider = true,
  });

  final String promptText;
  final String actionLabel;
  final VoidCallback? onActionTap;
  final bool showTopDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showTopDivider)
          const Divider(color: AuthColors.slate100, height: 1),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
            vertical: showTopDivider ? AppSpacing.xl : AppSpacing.lg,
          ),
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                promptText,
                style: AppTypography.bodyMd(AuthColors.slate500),
              ),
              GestureDetector(
                onTap: onActionTap,
                child: Text(
                  actionLabel,
                  style: AppTypography.bodyMd(AuthColors.primaryDark)
                      .copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
