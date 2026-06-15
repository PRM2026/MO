import 'package:flutter/material.dart';

import '../../constants/app_theme_tokens.dart';
import '../../constants/referee_colors.dart';
import '../../models/owner_dashboard_data.dart';
import '../jockey/jockey_dashboard_widgets.dart';
import '../news/news_network_image.dart';
import '../referee/referee_glass_card.dart';

class OwnerHeroBanner extends StatelessWidget {
  const OwnerHeroBanner({
    super.key,
    required this.hero,
    this.onViewTournament,
  });

  final OwnerHeroTournament hero;
  final VoidCallback? onViewTournament;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: 16 / 10,
        child: Stack(
          fit: StackFit.expand,
          children: [
            NewsNetworkImage(imageUrl: hero.imageUrl),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    RefereeColors.portalSurface.withValues(alpha: 0.95),
                  ],
                  stops: const [0.35, 1],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: RefereeColors.championshipGold.withValues(
                          alpha: 0.2,
                        ),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: RefereeColors.championshipGold.withValues(
                            alpha: 0.3,
                          ),
                        ),
                      ),
                      child: Text(
                        hero.badgeLabel,
                        style: AppTypography.labelCaps(
                          RefereeColors.championshipGold,
                        ).copyWith(fontSize: 11),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      hero.title,
                      style: AppTypography.headlineSm(Colors.white)
                          .copyWith(fontSize: 28),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hero.subtitle,
                      style: AppTypography.bodyMd(
                        RefereeColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: onViewTournament,
                        style: FilledButton.styleFrom(
                          backgroundColor: RefereeColors.championshipGold,
                          foregroundColor: RefereeColors.background,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Xem giải đấu',
                          style: AppTypography.labelCaps(
                            RefereeColors.background,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OwnerFeaturedHorsesSection extends StatelessWidget {
  const OwnerFeaturedHorsesSection({
    super.key,
    required this.horses,
    this.onViewAll,
  });

  final List<OwnerFeaturedHorse> horses;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Ngựa nổi bật',
                style: AppTypography.headlineSm(RefereeColors.onSurface)
                    .copyWith(fontSize: 22),
              ),
            ),
            TextButton(
              onPressed: onViewAll,
              child: Text(
                'Xem tất cả',
                style: AppTypography.labelCaps(RefereeColors.championshipGold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 220,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: horses.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) =>
                _FeaturedHorseCard(horse: horses[index]),
          ),
        ),
      ],
    );
  }
}

class _FeaturedHorseCard extends StatelessWidget {
  const _FeaturedHorseCard({required this.horse});

  final OwnerFeaturedHorse horse;

  @override
  Widget build(BuildContext context) {
    return RefereeGlassCard(
      padding: const EdgeInsets.all(12),
      child: SizedBox(
        width: 192,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    NewsNetworkImage(imageUrl: horse.imageUrl),
                    if (horse.rankLabel != null)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: RefereeColors.portalSurface.withValues(
                              alpha: 0.8,
                            ),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.1),
                            ),
                          ),
                          child: Text(
                            horse.rankLabel!,
                            style: AppTypography.labelCaps(
                              RefereeColors.championshipGold,
                            ).copyWith(fontSize: 10),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              horse.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.labelCaps(RefereeColors.onSurface)
                  .copyWith(fontSize: 14, letterSpacing: 0.2),
            ),
            Text(
              horse.subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.labelCaps(
                RefereeColors.onSurfaceVariant,
              ).copyWith(fontWeight: FontWeight.w400, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class OwnerUpcomingRacesSection extends StatelessWidget {
  const OwnerUpcomingRacesSection({super.key, required this.races});

  final List<OwnerUpcomingRace> races;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Lịch đua sắp tới',
          style: AppTypography.headlineSm(RefereeColors.onSurface)
              .copyWith(fontSize: 22),
        ),
        const SizedBox(height: 16),
        for (final race in races) ...[
          _UpcomingRaceTile(race: race),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _UpcomingRaceTile extends StatelessWidget {
  const _UpcomingRaceTile({required this.race});

  final OwnerUpcomingRace race;

  Color get _accentColor {
    return switch (race.tone) {
      OwnerRaceStatusTone.emerald => RefereeColors.successEmerald,
      OwnerRaceStatusTone.gold => RefereeColors.championshipGold,
      OwnerRaceStatusTone.muted => RefereeColors.outlineVariant,
    };
  }

  Color get _badgeBackground {
    return switch (race.tone) {
      OwnerRaceStatusTone.emerald =>
        RefereeColors.successEmerald.withValues(alpha: 0.1),
      OwnerRaceStatusTone.gold =>
        RefereeColors.championshipGold.withValues(alpha: 0.1),
      OwnerRaceStatusTone.muted => Colors.white.withValues(alpha: 0.05),
    };
  }

  Color get _badgeBorder {
    return switch (race.tone) {
      OwnerRaceStatusTone.emerald =>
        RefereeColors.successEmerald.withValues(alpha: 0.2),
      OwnerRaceStatusTone.gold =>
        RefereeColors.championshipGold.withValues(alpha: 0.2),
      OwnerRaceStatusTone.muted => Colors.white.withValues(alpha: 0.1),
    };
  }

  Color get _badgeText {
    return switch (race.tone) {
      OwnerRaceStatusTone.emerald => RefereeColors.successEmerald,
      OwnerRaceStatusTone.gold => RefereeColors.championshipGold,
      OwnerRaceStatusTone.muted => RefereeColors.onSurfaceVariant,
    };
  }

  @override
  Widget build(BuildContext context) {
    return RefereeGlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 56,
            decoration: BoxDecoration(
              color: _accentColor,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: RefereeColors.surfaceContainer,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${race.day}',
                  style: AppTypography.labelCaps(
                    RefereeColors.championshipGold,
                  ).copyWith(fontSize: 14),
                ),
                Text(
                  race.monthLabel,
                  style: AppTypography.labelCaps(
                    RefereeColors.onSurfaceVariant,
                  ).copyWith(fontSize: 9),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  race.title,
                  style: AppTypography.labelCaps(RefereeColors.onSurface)
                      .copyWith(fontSize: 14, letterSpacing: 0.2),
                ),
                Text(
                  race.detail,
                  style: AppTypography.labelCaps(
                    RefereeColors.onSurfaceVariant,
                  ).copyWith(fontWeight: FontWeight.w400, fontSize: 11),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _badgeBackground,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: _badgeBorder),
            ),
            child: Text(
              race.statusLabel.toUpperCase(),
              style: AppTypography.labelCaps(_badgeText).copyWith(fontSize: 9),
            ),
          ),
        ],
      ),
    );
  }
}

class OwnerPortalBackground extends StatelessWidget {
  const OwnerPortalBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return JockeySpeedlineBackground(child: child);
  }
}
