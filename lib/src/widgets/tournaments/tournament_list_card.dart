import 'package:flutter/material.dart';

import '../../constants/app_spacing.dart';
import '../../constants/app_theme_tokens.dart';
import '../../constants/tournament_colors.dart';
import '../../models/tournament_list_item.dart';
import '../news/news_network_image.dart';

class TournamentListCard extends StatelessWidget {
  const TournamentListCard({
    super.key,
    required this.tournament,
    this.onTap,
  });

  final TournamentListItem tournament;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 0,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: TournamentColors.primary.withValues(alpha: 0.05),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 192,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    NewsNetworkImage(imageUrl: tournament.imageUrl),
                    DecoratedBox(
                      decoration: const BoxDecoration(
                        gradient: TournamentColors.imageOverlay,
                      ),
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (tournament.isLive) ...[
                                Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: TournamentColors.liveRed,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'ĐANG DIỄN RA',
                                      style: AppTypography.labelCaps(
                                        Colors.white,
                                      ).copyWith(fontSize: 10),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                              ],
                              Text(
                                tournament.title,
                                style: AppTypography.headlineSm(Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (tournament.badgeLabel != null)
                      Positioned(
                        top: 16,
                        right: 16,
                        child: _Badge(
                          label: tournament.badgeLabel!,
                          style: tournament.badgeStyle,
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Wrap(
                      spacing: AppSpacing.lg,
                      runSpacing: AppSpacing.md,
                      children: [
                        _MetaItem(
                          icon: Icons.location_on_outlined,
                          label: tournament.location,
                          width: (constraints.maxWidth - AppSpacing.lg) / 2,
                        ),
                        _MetaItem(
                          icon: Icons.calendar_month_outlined,
                          label: tournament.startLabel,
                          width: (constraints.maxWidth - AppSpacing.lg) / 2,
                        ),
                        _MetaItem(
                          icon: Icons.assignment_ind_outlined,
                          label: tournament.registrationLabel,
                          width: (constraints.maxWidth - AppSpacing.lg) / 2,
                        ),
                        _MetaItem(
                          icon: Icons.sports_score_outlined,
                          label: tournament.racesLabel,
                          width: (constraints.maxWidth - AppSpacing.lg) / 2,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.style});

  final String label;
  final TournamentBadgeStyle style;

  @override
  Widget build(BuildContext context) {
    final bg = switch (style) {
      TournamentBadgeStyle.gold => TournamentColors.secondaryContainer,
      TournamentBadgeStyle.navy => TournamentColors.primary,
      TournamentBadgeStyle.none => Colors.transparent,
    };
    final fg = switch (style) {
      TournamentBadgeStyle.gold => TournamentColors.primary,
      TournamentBadgeStyle.navy => Colors.white,
      TournamentBadgeStyle.none => Colors.white,
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: fg,
          ),
        ),
      ),
    );
  }
}

class _MetaItem extends StatelessWidget {
  const _MetaItem({
    required this.icon,
    required this.label,
    required this.width,
  });

  final IconData icon;
  final String label;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Row(
        children: [
          Icon(icon, size: 18, color: TournamentColors.secondary),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodySm(TournamentColors.onSurfaceVariant)
                  .copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
