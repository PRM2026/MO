import 'package:flutter/material.dart';

import '../../constants/app_theme_tokens.dart';
import '../../constants/referee_colors.dart';

class RefereeAlertBanner extends StatelessWidget {
  const RefereeAlertBanner({
    super.key,
    required this.title,
    required this.message,
    this.onAction,
  });

  final String title;
  final String message;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: RefereeColors.tertiaryContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: RefereeColors.tertiary.withValues(alpha: 0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: RefereeColors.tertiary.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.priority_high,
                color: RefereeColors.tertiary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.labelCaps(RefereeColors.tertiary)
                        .copyWith(fontSize: 14, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: AppTypography.bodyMd(RefereeColors.onSurface),
                  ),
                ],
              ),
            ),
            if (onAction != null) ...[
              const SizedBox(width: 8),
              FilledButton(
                onPressed: onAction,
                style: FilledButton.styleFrom(
                  backgroundColor: RefereeColors.tertiary,
                  foregroundColor: RefereeColors.onTertiary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Xử lý ngay',
                  style: AppTypography.labelCaps(RefereeColors.onTertiary)
                      .copyWith(fontSize: 13, letterSpacing: 0.3),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
