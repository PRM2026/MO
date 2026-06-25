import 'package:flutter/material.dart';

import '../../constants/app_spacing.dart';
import '../../constants/app_theme_tokens.dart';
import '../../constants/referee_colors.dart';
import '../../models/spectator_models.dart';
import '../news/news_network_image.dart';
import 'spectator_glass_card.dart';

class SpectatorHeroBanner extends StatelessWidget {
  const SpectatorHeroBanner({
    super.key,
    required this.event,
    this.onViewDetails,
  });

  final SpectatorFeaturedEvent event;
  final VoidCallback? onViewDetails;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            NewsNetworkImage(imageUrl: event.imageUrl),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    RefereeColors.portalSurface,
                    RefereeColors.portalSurface.withValues(alpha: 0.4),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: RefereeColors.championshipGold.withValues(
                            alpha: 0.2,
                          ),
                          border: Border.all(
                            color: RefereeColors.championshipGold.withValues(
                              alpha: 0.3,
                            ),
                          ),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'SẮP DIỄN RA',
                          style: AppTypography.labelCaps(
                            RefereeColors.championshipGold,
                          ).copyWith(fontSize: 10),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        event.dateLabel,
                        style: AppTypography.bodySm(
                          Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event.title,
                    style: AppTypography.displayLg(Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 18,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.location,
                          style: AppTypography.bodySm(
                            Colors.white.withValues(alpha: 0.8),
                          ).copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: onViewDetails,
                      style: FilledButton.styleFrom(
                        backgroundColor: RefereeColors.championshipGold,
                        foregroundColor: RefereeColors.portalSurface,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Xem chi tiết',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
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

class SpectatorQuickActions extends StatelessWidget {
  const SpectatorQuickActions({
    super.key,
    this.onScheduleTap,
    this.onHorsesTap,
    this.onResultsTap,
  });

  final VoidCallback? onScheduleTap;
  final VoidCallback? onHorsesTap;
  final VoidCallback? onResultsTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickActionTile(
            icon: Icons.calendar_month_outlined,
            label: 'Lịch đua',
            onTap: onScheduleTap,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickActionTile(
            icon: Icons.pets_outlined,
            label: 'Danh sách ngựa',
            onTap: onHorsesTap,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickActionTile(
            icon: Icons.emoji_events_outlined,
            label: 'Kết quả',
            onTap: onResultsTap,
          ),
        ),
      ],
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({required this.icon, required this.label, this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SpectatorGlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: RefereeColors.championshipGold.withValues(alpha: 0.1),
                  border: Border.all(
                    color: RefereeColors.championshipGold.withValues(
                      alpha: 0.2,
                    ),
                  ),
                ),
                child: Icon(icon, color: RefereeColors.championshipGold),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: AppTypography.bodySm(
                  Colors.white.withValues(alpha: 0.8),
                ).copyWith(fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SpectatorSectionHeader extends StatelessWidget {
  const SpectatorSectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onActionTap,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTypography.displayLg(Colors.white).copyWith(
              fontSize: 24,
              height: 32 / 24,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (actionLabel != null)
          GestureDetector(
            onTap: onActionTap,
            child: Text(
              actionLabel!,
              style: AppTypography.bodySm(
                RefereeColors.championshipGold,
              ).copyWith(fontWeight: FontWeight.w600),
            ),
          ),
      ],
    );
  }
}

class SpectatorRaceListTile extends StatelessWidget {
  const SpectatorRaceListTile({super.key, required this.race, this.onTap});

  final SpectatorRaceItem race;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isOpen = race.status == SpectatorRaceStatus.open;
    final accentColor = isOpen
        ? RefereeColors.championshipGold
        : RefereeColors.championshipGold.withValues(alpha: 0.4);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SpectatorGlassCard(
          accentBorder: true,
          accentColor: accentColor,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      race.name,
                      style: AppTypography.bodyMd(
                        Colors.white,
                      ).copyWith(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _MetaChip(icon: Icons.schedule, label: race.time),
                        const SizedBox(width: 12),
                        _MetaChip(icon: Icons.straighten, label: race.distance),
                      ],
                    ),
                  ],
                ),
              ),
              _StatusBadge(isOpen: isOpen),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.white.withValues(alpha: 0.5)),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTypography.bodySm(
            Colors.white.withValues(alpha: 0.5),
          ).copyWith(fontSize: 12),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.isOpen});

  final bool isOpen;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isOpen
            ? RefereeColors.successEmerald.withValues(alpha: 0.1)
            : Colors.white.withValues(alpha: 0.05),
        border: Border.all(
          color: isOpen
              ? RefereeColors.successEmerald.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.1),
        ),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        isOpen ? 'OPEN' : 'PENDING',
        style: AppTypography.labelCaps(
          isOpen
              ? RefereeColors.successEmerald
              : Colors.white.withValues(alpha: 0.4),
        ).copyWith(fontSize: 10),
      ),
    );
  }
}

class SpectatorFeaturedHorseCard extends StatelessWidget {
  const SpectatorFeaturedHorseCard({super.key, required this.horse});

  final SpectatorFeaturedHorse horse;

  @override
  Widget build(BuildContext context) {
    final isTopRank = horse.rank == 1;

    return SizedBox(
      width: 256,
      child: SpectatorGlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 160,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: NewsNetworkImage(imageUrl: horse.imageUrl),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isTopRank
                            ? RefereeColors.championshipGold
                            : Colors.white.withValues(alpha: 0.2),
                        border: isTopRank
                            ? null
                            : Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                              ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'RANK #${horse.rank}',
                        style: AppTypography.labelCaps(
                          isTopRank
                              ? RefereeColors.portalSurface
                              : Colors.white,
                        ).copyWith(fontSize: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    horse.name,
                    style: AppTypography.headlineSm(Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 16,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Rider: ${horse.rider}',
                        style: AppTypography.bodySm(
                          Colors.white.withValues(alpha: 0.6),
                        ).copyWith(fontSize: 12),
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

class SpectatorRecentResultsPanel extends StatelessWidget {
  const SpectatorRecentResultsPanel({super.key, required this.results});

  final List<SpectatorRecentResult> results;

  @override
  Widget build(BuildContext context) {
    return SpectatorGlassCard(
      child: Column(
        children: [
          for (var i = 0; i < results.length; i++) ...[
            if (i > 0)
              Divider(height: 1, color: Colors.white.withValues(alpha: 0.05)),
            SpectatorRecentResultTile(result: results[i]),
          ],
        ],
      ),
    );
  }
}

class SpectatorRecentResultTile extends StatelessWidget {
  const SpectatorRecentResultTile({super.key, required this.result});

  final SpectatorRecentResult result;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: result.highlight
                  ? RefereeColors.championshipGold.withValues(alpha: 0.2)
                  : Colors.white.withValues(alpha: 0.1),
            ),
            alignment: Alignment.center,
            child: Text(
              '1',
              style: AppTypography.bodyMd(
                result.highlight
                    ? RefereeColors.championshipGold
                    : Colors.white.withValues(alpha: 0.4),
              ).copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        result.horseName,
                        style: AppTypography.bodyMd(
                          Colors.white,
                        ).copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    Text(
                      result.time,
                      style:
                          AppTypography.bodySm(
                            RefereeColors.championshipGold,
                          ).copyWith(
                            fontWeight: FontWeight.w500,
                            letterSpacing: -0.14,
                          ),
                    ),
                  ],
                ),
                Text(
                  result.eventName,
                  style: AppTypography.bodySm(
                    Colors.white.withValues(alpha: 0.4),
                  ).copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SpectatorHorizontalList extends StatelessWidget {
  const SpectatorHorizontalList({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
  });

  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPadding,
        ),
        itemCount: itemCount,
        separatorBuilder: (_, index) => const SizedBox(width: 16),
        itemBuilder: itemBuilder,
      ),
    );
  }
}
