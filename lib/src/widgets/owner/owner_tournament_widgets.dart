import 'package:flutter/material.dart';

import '../../constants/app_theme_tokens.dart';
import '../../constants/referee_colors.dart';
import '../../models/tournament_list_item.dart';
import '../../viewmodels/owner_tournaments_viewmodel.dart';
import '../news/news_network_image.dart';
import '../referee/referee_glass_card.dart';

class OwnerTournamentFilterChips extends StatelessWidget {
  const OwnerTournamentFilterChips({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final OwnerTournamentFilter selected;
  final ValueChanged<OwnerTournamentFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: OwnerTournamentFilter.values.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final filter = OwnerTournamentFilter.values[index];
          final isSelected = filter == selected;

          return FilterChip(
            label: Text(
              filter.label,
              style: AppTypography.labelCaps(
                isSelected
                    ? RefereeColors.championshipGold
                    : RefereeColors.onSurfaceVariant,
              ).copyWith(fontSize: 13, letterSpacing: 0.2),
            ),
            selected: isSelected,
            showCheckmark: false,
            onSelected: (_) => onSelected(filter),
            backgroundColor: RefereeColors.surfaceContainer.withValues(
              alpha: 0.5,
            ),
            selectedColor: RefereeColors.championshipGold.withValues(
              alpha: 0.12,
            ),
            side: BorderSide(
              color: isSelected
                  ? RefereeColors.championshipGold
                  : Colors.white.withValues(alpha: 0.1),
              width: isSelected ? 1.5 : 1,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          );
        },
      ),
    );
  }
}

class OwnerTournamentGridCard extends StatelessWidget {
  const OwnerTournamentGridCard({
    super.key,
    required this.tournament,
    this.onPrimaryAction,
  });

  final TournamentListItem tournament;
  final VoidCallback? onPrimaryAction;

  @override
  Widget build(BuildContext context) {
    return RefereeGlassCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: onPrimaryAction,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _BannerSection(tournament: tournament),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    tournament.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.headlineSm(
                      RefereeColors.onSurface,
                    ).copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(
                    icon: Icons.calendar_today_outlined,
                    label: tournament.ownerDateLabel,
                  ),
                  const SizedBox(height: 8),
                  _InfoRow(
                    icon: Icons.location_on_outlined,
                    label: tournament.location,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _InfoRow(
                          icon: Icons.groups_outlined,
                          label: tournament.ownerCapacityLabel,
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton(
                        onPressed: onPrimaryAction,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: RefereeColors.championshipGold,
                          side: const BorderSide(
                            color: RefereeColors.championshipGold,
                            width: 1.5,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          'Chi Tiết',
                          style: AppTypography.labelCaps(
                            RefereeColors.championshipGold,
                          ).copyWith(fontSize: 11),
                        ),
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

class _BannerSection extends StatelessWidget {
  const _BannerSection({required this.tournament});

  final TournamentListItem tournament;

  @override
  Widget build(BuildContext context) {
    final isOngoing = tournament.isOwnerOngoing;
    final isCompleted = tournament.isOwnerCompleted;
    final badgeColor = isOngoing
        ? RefereeColors.successEmerald
        : isCompleted
        ? RefereeColors.onSurfaceVariant
        : RefereeColors.championshipGold;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      child: SizedBox(
        height: 180,
        child: Stack(
          fit: StackFit.expand,
          children: [
            tournament.imageUrl.isNotEmpty
                ? NewsNetworkImage(imageUrl: tournament.imageUrl)
                : ColoredBox(
                  color: RefereeColors.surfaceContainer,
                  child: Icon(
                    Icons.emoji_events_outlined,
                    size: 64,
                    color: RefereeColors.onSurfaceVariant.withValues(
                      alpha: 0.4,
                    ),
                  ),
                ),
            if (!isOngoing)
              ColoredBox(color: Colors.black.withValues(alpha: 0.15)),
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  tournament.ownerPortalBadge,
                  style: AppTypography.labelCaps(
                    badgeColor,
                  ).copyWith(fontSize: 11),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: RefereeColors.onSurfaceVariant),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodyMd(RefereeColors.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}
