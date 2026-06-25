import 'package:flutter/material.dart';

import '../../constants/app_theme_tokens.dart';
import '../../constants/referee_colors.dart';
import '../../models/spectator_models.dart';
import '../../viewmodels/spectator_races_viewmodel.dart';
import '../news/news_network_image.dart';
import 'spectator_glass_card.dart';

class SpectatorScheduleHero extends StatelessWidget {
  const SpectatorScheduleHero({super.key, required this.featured});

  final SpectatorScheduleFeatured featured;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 192,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            NewsNetworkImage(imageUrl: featured.imageUrl),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [RefereeColors.background, Colors.transparent],
                ),
              ),
            ),
            Positioned(
              left: 16,
              bottom: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      featured.badge.toUpperCase(),
                      style: AppTypography.labelCaps(
                        RefereeColors.championshipGold,
                      ).copyWith(fontSize: 12, letterSpacing: 2),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    featured.title,
                    style: AppTypography.headlineSm(
                      Colors.white,
                    ).copyWith(fontSize: 24, height: 32 / 24),
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

class SpectatorRaceFilterBar extends StatelessWidget {
  const SpectatorRaceFilterBar({
    super.key,
    required this.selected,
    required this.onSelected,
    this.onDateTap,
  });

  final SpectatorRaceListFilter selected;
  final ValueChanged<SpectatorRaceListFilter> onSelected;
  final VoidCallback? onDateTap;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FilterChip(
            label: 'Sap toi',
            selected: selected == SpectatorRaceListFilter.upcoming,
            onTap: () => onSelected(SpectatorRaceListFilter.upcoming),
          ),
          const SizedBox(width: 12),
          _FilterChip(
            label: 'Da ket thuc',
            selected: selected == SpectatorRaceListFilter.finished,
            onTap: () => onSelected(SpectatorRaceListFilter.finished),
          ),
          const SizedBox(width: 12),
          _FilterChip(
            label: 'Ngay',
            icon: Icons.calendar_today_outlined,
            selected: selected == SpectatorRaceListFilter.date,
            onTap: onDateTap ?? () => onSelected(SpectatorRaceListFilter.date),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            horizontal: icon != null ? 16 : 24,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: selected
                ? RefereeColors.championshipGold
                : Colors.white.withValues(alpha: 0.05),
            border: selected
                ? null
                : Border.all(color: Colors.white.withValues(alpha: 0.1)),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 18,
                  color: selected
                      ? RefereeColors.background
                      : RefereeColors.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: AppTypography.bodySm(
                  selected
                      ? RefereeColors.background
                      : RefereeColors.onSurfaceVariant,
                ).copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SpectatorScheduleRaceCard extends StatelessWidget {
  const SpectatorScheduleRaceCard({
    super.key,
    required this.race,
    this.onViewDetails,
  });

  final SpectatorRaceItem race;
  final VoidCallback? onViewDetails;

  @override
  Widget build(BuildContext context) {
    final accentColor = race.featured
        ? RefereeColors.championshipGold
        : RefereeColors.outlineVariant;

    return Stack(
      children: [
        SpectatorGlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              race.statusLabel.toUpperCase(),
                              style: AppTypography.labelCaps(
                                race.featured
                                    ? RefereeColors.championshipGold.withValues(
                                        alpha: 0.8,
                                      )
                                    : RefereeColors.onSurfaceVariant,
                              ).copyWith(fontSize: 12),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: Container(
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: RefereeColors.outlineVariant,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                race.trackInfo,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.bodySm(
                                  RefereeColors.onSurfaceVariant,
                                ).copyWith(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          race.name,
                          style: AppTypography.headlineSm(
                            RefereeColors.onSurface,
                          ).copyWith(fontSize: 24, height: 32 / 24),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _TimeBadge(label: race.timeBadge, featured: race.featured),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _InfoTile(
                      icon: Icons.schedule_outlined,
                      label: 'Gio',
                      value: race.time,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _InfoTile(
                      icon: Icons.location_on_outlined,
                      label: 'Dia diem',
                      value: race.venue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Divider(color: Colors.white.withValues(alpha: 0.05), height: 1),
              const SizedBox(height: 12),
              Row(
                children: [
                  _ParticipantStack(
                    avatars: race.participantAvatars,
                    extraCount: race.extraParticipants,
                  ),
                  const Spacer(),
                  _ViewDetailsButton(
                    featured: race.featured,
                    onTap: onViewDetails,
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          child: Container(
            width: 4,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TimeBadge extends StatelessWidget {
  const _TimeBadge({required this.label, required this.featured});

  final String label;
  final bool featured;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: featured
            ? RefereeColors.championshipGold.withValues(alpha: 0.1)
            : Colors.white.withValues(alpha: 0.05),
        border: Border.all(
          color: featured
              ? RefereeColors.championshipGold.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.1),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: AppTypography.bodySm(
          featured
              ? RefereeColors.championshipGold
              : RefereeColors.onSurfaceVariant,
        ).copyWith(fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: RefereeColors.championshipGold, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.bodySm(
                  RefereeColors.onSurfaceVariant,
                ).copyWith(fontSize: 12),
              ),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodySm(
                  RefereeColors.onSurface,
                ).copyWith(fontWeight: FontWeight.w500, letterSpacing: -0.14),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ParticipantStack extends StatelessWidget {
  const _ParticipantStack({required this.avatars, required this.extraCount});

  final List<String> avatars;
  final int extraCount;

  @override
  Widget build(BuildContext context) {
    if (avatars.isEmpty && extraCount <= 0) {
      return const SizedBox.shrink();
    }

    final chips = <Widget>[
      for (final url in avatars.take(2)) _AvatarChip(imageUrl: url),
      if (extraCount > 0) _ExtraChip(count: extraCount),
    ];

    return SizedBox(
      height: 28,
      width: chips.length * 22.0 + 6,
      child: Stack(
        children: [
          for (var i = 0; i < chips.length; i++)
            Positioned(left: i * 22.0, child: chips[i]),
        ],
      ),
    );
  }
}

class _AvatarChip extends StatelessWidget {
  const _AvatarChip({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: RefereeColors.background, width: 1),
        color: RefereeColors.surfaceContainer,
      ),
      clipBehavior: Clip.antiAlias,
      child: NewsNetworkImage(imageUrl: imageUrl),
    );
  }
}

class _ExtraChip extends StatelessWidget {
  const _ExtraChip({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: RefereeColors.background, width: 1),
        color: RefereeColors.surfaceContainer,
      ),
      child: Text(
        '+$count',
        style: AppTypography.labelCaps(
          RefereeColors.onSurfaceVariant,
        ).copyWith(fontSize: 10),
      ),
    );
  }
}

class _ViewDetailsButton extends StatelessWidget {
  const _ViewDetailsButton({required this.featured, this.onTap});

  final bool featured;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (featured) {
      return FilledButton.icon(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          backgroundColor: RefereeColors.championshipGold,
          foregroundColor: RefereeColors.background,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        icon: const Icon(Icons.arrow_forward, size: 18),
        iconAlignment: IconAlignment.end,
        label: const Text(
          'Xem chi tiet',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      );
    }

    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: RefereeColors.onSurface,
        side: BorderSide(color: RefereeColors.outlineVariant),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: const Text(
        'Xem chi tiet',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}
