import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_theme_tokens.dart';
import '../../models/tournament_list_item.dart';
import '../news/news_network_image.dart';

class TournamentCard extends StatelessWidget {
  const TournamentCard({super.key, required this.tournament});

  final TournamentListItem tournament;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 288,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 160,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  NewsNetworkImage(imageUrl: tournament.imageUrl),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Text(
                          tournament.homeStatusBadge,
                          style: AppTypography.labelCaps(Colors.white)
                              .copyWith(fontSize: 10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tournament.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodyMd(AppColors.onSurface)
                        .copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _MetaRow(
                    icon: Icons.calendar_today_outlined,
                    label: tournament.homeDateLabel,
                  ),
                  const SizedBox(height: 4),
                  _MetaRow(
                    icon: Icons.location_on_outlined,
                    label: tournament.location,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Divider(
                    height: 1,
                    color: AppColors.outlineVariant.withValues(alpha: 0.6),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Đăng ký:',
                        style: AppTypography.labelCaps(
                          AppColors.onSurfaceVariant,
                        ).copyWith(fontSize: 11, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        tournament.registrationLabel,
                        style: AppTypography.bodyMd(AppColors.primary)
                            .copyWith(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.onSurfaceVariant),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            style: AppTypography.labelCaps(AppColors.onSurfaceVariant)
                .copyWith(fontSize: 11, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
