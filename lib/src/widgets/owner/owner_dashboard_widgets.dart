import 'package:flutter/material.dart';

import '../../constants/app_theme_tokens.dart';
import '../../constants/referee_colors.dart';
import '../../models/owner_dashboard_data.dart';
import '../jockey/jockey_dashboard_widgets.dart';
import '../news/news_network_image.dart';
import '../referee/referee_glass_card.dart';

class OwnerHeroBanner extends StatelessWidget {
  const OwnerHeroBanner({super.key, required this.hero, this.onViewTournament});

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
                padding: const EdgeInsets.all(20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: RefereeColors.championshipGold.withValues(
                                alpha: 0.15,
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
                              ).copyWith(fontSize: 10),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            hero.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.headlineSm(
                              Colors.white,
                            ).copyWith(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            hero.subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.bodySm(
                              RefereeColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    OutlinedButton(
                      onPressed: onViewTournament,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: RefereeColors.championshipGold,
                        side: const BorderSide(
                          color: RefereeColors.championshipGold,
                          width: 1.5,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Xem giải',
                            style: AppTypography.labelCaps(
                              RefereeColors.championshipGold,
                            ).copyWith(fontSize: 12),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_forward, size: 14),
                        ],
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

class OwnerDashboardEmptyHero extends StatelessWidget {
  const OwnerDashboardEmptyHero({super.key});

  @override
  Widget build(BuildContext context) {
    return RefereeGlassCard(
      padding: EdgeInsets.zero,
      child: AspectRatio(
        aspectRatio: 16 / 10,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.emoji_events_outlined,
                  size: 44,
                  color: RefereeColors.championshipGold.withValues(alpha: 0.8),
                ),
                const SizedBox(height: 12),
                Text(
                  'Chưa có giải đấu nổi bật.',
                  textAlign: TextAlign.center,
                  style: AppTypography.headlineSm(
                    RefereeColors.onSurface,
                  ).copyWith(fontSize: 20),
                ),
                const SizedBox(height: 6),
                Text(
                  'Dữ liệu sẽ hiển thị khi máy chủ trả về giải đấu phù hợp.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMd(RefereeColors.onSurfaceVariant),
                ),
              ],
            ),
          ),
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
                style: AppTypography.headlineSm(
                  RefereeColors.onSurface,
                ).copyWith(fontSize: 22),
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
        if (horses.isEmpty)
          const _DashboardEmptyMessage(message: 'Chưa có ngựa nổi bật.')
        else
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

class OwnerDashboardQuickActionsSection extends StatelessWidget {
  const OwnerDashboardQuickActionsSection({
    super.key,
    this.onViewInvitations,
    this.onViewAcceptedJockeys,
  });

  final VoidCallback? onViewInvitations;
  final VoidCallback? onViewAcceptedJockeys;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickActionButton(
            icon: Icons.mail_outline,
            label: 'Lời mời jockey',
            onTap: onViewInvitations,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickActionButton(
            icon: Icons.groups_outlined,
            label: 'Jockey đã nhận',
            onTap: onViewAcceptedJockeys,
          ),
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return RefereeGlassCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: RefereeColors.championshipGold.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: RefereeColors.championshipGold.withValues(alpha: 0.2),
              ),
            ),
            child: Icon(
              icon,
              color: RefereeColors.championshipGold,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.labelCaps(
                RefereeColors.onSurface,
              ).copyWith(
                fontSize: 13,
                letterSpacing: 0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: RefereeColors.onSurfaceVariant,
            size: 18,
          ),
        ],
      ),
    );
  }
}

class _FeaturedHorseCard extends StatelessWidget {
  const _FeaturedHorseCard({required this.horse});

  final OwnerFeaturedHorse horse;

  @override
  Widget build(BuildContext context) {
    return RefereeGlassCard(
      padding: const EdgeInsets.all(10),
      child: SizedBox(
        width: 180,
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
                            horizontal: 10,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: RefereeColors.portalSurface.withValues(
                              alpha: 0.85,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: RefereeColors.championshipGold.withValues(
                                alpha: 0.3,
                              ),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            horse.rankLabel!,
                            style: AppTypography.labelCaps(
                              RefereeColors.championshipGold,
                            ).copyWith(fontSize: 9),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              horse.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.headlineSm(
                RefereeColors.onSurface,
              ).copyWith(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              horse.subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodySm(
                RefereeColors.onSurfaceVariant,
              ).copyWith(fontSize: 12),
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
          style: AppTypography.headlineSm(
            RefereeColors.onSurface,
          ).copyWith(fontSize: 22),
        ),
        const SizedBox(height: 16),
        if (races.isEmpty)
          const _DashboardEmptyMessage(message: 'Chưa có lịch đua sắp tới.')
        else
          for (final race in races) ...[
            _UpcomingRaceTile(race: race),
            const SizedBox(height: 12),
          ],
      ],
    );
  }
}

class _DashboardEmptyMessage extends StatelessWidget {
  const _DashboardEmptyMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return RefereeGlassCard(
      padding: const EdgeInsets.all(20),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: AppTypography.bodyMd(RefereeColors.onSurfaceVariant),
      ),
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
      OwnerRaceStatusTone.emerald => RefereeColors.successEmerald.withValues(
        alpha: 0.1,
      ),
      OwnerRaceStatusTone.gold => RefereeColors.championshipGold.withValues(
        alpha: 0.1,
      ),
      OwnerRaceStatusTone.muted => Colors.white.withValues(alpha: 0.05),
    };
  }

  Color get _badgeBorder {
    return switch (race.tone) {
      OwnerRaceStatusTone.emerald => RefereeColors.successEmerald.withValues(
        alpha: 0.2,
      ),
      OwnerRaceStatusTone.gold => RefereeColors.championshipGold.withValues(
        alpha: 0.2,
      ),
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
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 52,
            decoration: BoxDecoration(
              color: _accentColor,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: RefereeColors.portalSurface.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: RefereeColors.championshipGold.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${race.day}',
                  style: AppTypography.displayMd(
                    RefereeColors.championshipGold,
                  ).copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                  ),
                ),
                Text(
                  race.monthLabel,
                  style: AppTypography.labelCaps(
                    RefereeColors.onSurfaceVariant,
                  ).copyWith(fontSize: 9, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  race.title,
                  style: AppTypography.headlineSm(
                    RefereeColors.onSurface,
                  ).copyWith(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 3),
                Text(
                  race.detail,
                  style: AppTypography.bodySm(
                    RefereeColors.onSurfaceVariant,
                  ).copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _badgeBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _badgeBorder),
            ),
            child: Text(
              race.statusLabel,
              style: AppTypography.labelCaps(_badgeText).copyWith(
                fontSize: 9,
                letterSpacing: 0.2,
              ),
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
