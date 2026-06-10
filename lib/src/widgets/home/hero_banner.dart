import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_theme_tokens.dart';

class HeroBanner extends StatelessWidget {
  const HeroBanner({
    super.key,
    required this.imageUrl,
    this.onViewTournaments,
    this.onRegister,
  });

  final String imageUrl;
  final VoidCallback? onViewTournaments;
  final VoidCallback? onRegister;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final aspectRatio = width < 400 ? 4 / 3 : 16 / 10;

    return AspectRatio(
      aspectRatio: aspectRatio,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(imageUrl, fit: BoxFit.cover),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    AppColors.onSurface.withValues(alpha: 0.6),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxHeight < 240;
                final padding = compact ? AppSpacing.lg : AppSpacing.xl;

                return Padding(
                  padding: EdgeInsets.all(padding),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: constraints.maxWidth - padding * 2,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _Badge(
                              child: Text(
                                '🏆 NỀN TẢNG CHUYÊN NGHIỆP',
                                style: AppTypography.labelCaps(Colors.white),
                              ),
                            ),
                            SizedBox(height: compact ? AppSpacing.sm : AppSpacing.lg),
                            Text(
                              'Trải nghiệm giải đua ngựa chuyên nghiệp',
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: (compact
                                      ? AppTypography.headlineSm
                                      : AppTypography.displayLg)(Colors.white),
                            ),
                            SizedBox(height: compact ? AppSpacing.sm : AppSpacing.lg),
                            Wrap(
                              spacing: AppSpacing.md,
                              runSpacing: AppSpacing.sm,
                              children: [
                                _GoldButton(
                                  label: 'XEM GIẢI ĐẤU',
                                  onPressed: onViewTournaments,
                                  compact: compact,
                                ),
                                _GlassButton(
                                  label: 'ĐĂNG KÝ',
                                  onPressed: onRegister,
                                  compact: compact,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 6,
        ),
        child: child,
      ),
    );
  }
}

class _GoldButton extends StatelessWidget {
  const _GoldButton({
    required this.label,
    this.onPressed,
    this.compact = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppColors.goldGradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 16 : 24,
              vertical: compact ? 10 : 12,
            ),
            child: Text(
              label,
              style: AppTypography.labelCaps(AppColors.onPrimary),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassButton extends StatelessWidget {
  const _GlassButton({
    required this.label,
    this.onPressed,
    this.compact = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: BorderSide(color: Colors.white.withValues(alpha: 0.4)),
        backgroundColor: Colors.white.withValues(alpha: 0.1),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 16 : 24,
          vertical: compact ? 10 : 12,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(label, style: AppTypography.labelCaps(Colors.white)),
    );
  }
}
