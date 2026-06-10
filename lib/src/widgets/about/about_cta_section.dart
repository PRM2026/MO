import 'package:flutter/material.dart';

import '../../constants/about_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_theme_tokens.dart';

class AboutCtaSection extends StatelessWidget {
  const AboutCtaSection({
    super.key,
    this.onRegister,
    this.onViewTournaments,
  });

  final VoidCallback? onRegister;
  final VoidCallback? onViewTournaments;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: const BoxDecoration(
              gradient: AboutColors.ctaGradient,
            ),
            child: Column(
              children: [
                Icon(
                  Icons.emoji_events_outlined,
                  size: 48,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Bắt đầu ngay hôm nay',
                  textAlign: TextAlign.center,
                  style: AppTypography.displayMd(Colors.white),
                ),
                const SizedBox(height: AppSpacing.sm),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 280),
                  child: Text(
                    'Tham gia cùng chúng tôi để trải nghiệm hệ thống quản lý giải đua chuyên nghiệp nhất.',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMd(
                      Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                FilledButton(
                  onPressed: onRegister,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AboutColors.secondary,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  child: const Text(
                    'Đăng ký miễn phí',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                OutlinedButton(
                  onPressed: onViewTournaments,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                    side: BorderSide(
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Xem giải đấu',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: -32,
            right: -32,
            child: _GlowOrb(size: 128),
          ),
          Positioned(
            bottom: -32,
            left: -32,
            child: _GlowOrb(size: 128),
          ),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.1),
      ),
    );
  }
}
