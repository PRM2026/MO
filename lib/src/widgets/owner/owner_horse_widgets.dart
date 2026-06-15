import 'package:flutter/material.dart';

import '../../constants/app_theme_tokens.dart';
import '../../constants/referee_colors.dart';
import '../../models/owner_horse_item.dart';
import '../news/news_network_image.dart';
import '../referee/referee_glass_card.dart';

class OwnerHorseFilterChips extends StatelessWidget {
  const OwnerHorseFilterChips({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final OwnerHorseFilter selected;
  final ValueChanged<OwnerHorseFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: OwnerHorseFilter.values.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final filter = OwnerHorseFilter.values[index];
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
            backgroundColor: RefereeColors.portalSurface.withValues(alpha: 0.7),
            selectedColor: RefereeColors.portalSurface.withValues(alpha: 0.7),
            side: BorderSide(
              color: isSelected
                  ? RefereeColors.championshipGold
                  : Colors.white.withValues(alpha: 0.1),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          );
        },
      ),
    );
  }
}

class OwnerHorseGridCard extends StatelessWidget {
  const OwnerHorseGridCard({super.key, required this.horse, this.onTap});

  final OwnerHorseItem horse;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final winRateColor = horse.performance.totalRaces > 0
        ? RefereeColors.successEmerald
        : RefereeColors.onSurface;

    return RefereeGlassCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _HorseImageHeader(horse: horse),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              horse.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.headlineSm(
                                RefereeColors.onSurface,
                              ).copyWith(fontSize: 22),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              horse.breed,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.bodyMd(
                                RefereeColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'WIN RATE',
                            style: AppTypography.labelCaps(
                              RefereeColors.onSurfaceVariant,
                            ).copyWith(fontSize: 10),
                          ),
                          Text(
                            horse.performance.winRateLabel,
                            style: AppTypography.headlineSm(
                              winRateColor,
                            ).copyWith(fontSize: 22),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Divider(color: Colors.white.withValues(alpha: 0.05)),
                  const SizedBox(height: 12),
                  _HorseDetailRow(
                    icon: Icons.badge_outlined,
                    label: 'Trạng thái',
                    value: horse.statusLabel,
                    valueColor: _statusColor(horse.statusCode),
                  ),
                  const SizedBox(height: 8),
                  _HorseDetailRow(
                    icon: Icons.pets_outlined,
                    label: 'Thông tin',
                    value:
                        '${horse.ageLabel} • ${horse.genderLabel} • ${horse.colorLabel}',
                  ),
                  const SizedBox(height: 8),
                  _HorseDetailRow(
                    icon: Icons.monitor_weight_outlined,
                    label: 'Thể trạng',
                    value: horse.bodyMetricsLabel,
                  ),
                  if (horse.reviewReason?.trim().isNotEmpty == true) ...[
                    const SizedBox(height: 8),
                    _HorseDetailRow(
                      icon: Icons.info_outline,
                      label: 'Phản hồi',
                      value: horse.reviewReason!.trim(),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Divider(color: Colors.white.withValues(alpha: 0.05)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _StatColumn(
                        label: 'Cuộc đua',
                        value: '${horse.performance.totalRaces}',
                      ),
                      const SizedBox(width: 16),
                      _StatColumn(
                        label: 'Tỷ lệ thắng',
                        value: horse.performance.winRateLabel,
                      ),
                      const SizedBox(width: 16),
                      _StatColumn(
                        label: 'Thắng',
                        value: '${horse.performance.wins}',
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

class _HorseDetailRow extends StatelessWidget {
  const _HorseDetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: RefereeColors.onSurfaceVariant),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: AppTypography.bodySm(RefereeColors.onSurfaceVariant),
        ),
        Expanded(
          child: Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodySm(
              valueColor ?? RefereeColors.onSurface,
            ).copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

Color _statusColor(String status) {
  return switch (status) {
    'APPROVED' => RefereeColors.successEmerald,
    'REJECTED' => RefereeColors.statusRed,
    'SUSPENDED' => RefereeColors.statusRed,
    _ => RefereeColors.championshipGold,
  };
}

class _HorseImageHeader extends StatelessWidget {
  const _HorseImageHeader({required this.horse});

  final OwnerHorseItem horse;

  @override
  Widget build(BuildContext context) {
    final isTopRank = horse.rankLabel?.startsWith('#1') == true;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      child: SizedBox(
        height: 256,
        child: Stack(
          fit: StackFit.expand,
          children: [
            horse.imageUrl.isNotEmpty
                ? NewsNetworkImage(imageUrl: horse.imageUrl)
                : ColoredBox(
                    color: RefereeColors.surfaceContainer,
                    child: Icon(
                      Icons.art_track_outlined,
                      size: 64,
                      color: RefereeColors.onSurfaceVariant.withValues(
                        alpha: 0.4,
                      ),
                    ),
                  ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    RefereeColors.portalSurface.withValues(alpha: 0.6),
                  ],
                  stops: const [0.45, 1],
                ),
              ),
            ),
            if (horse.rankLabel != null)
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isTopRank
                        ? RefereeColors.championshipGold
                        : RefereeColors.onSurfaceVariant.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(999),
                    border: isTopRank
                        ? null
                        : Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                  ),
                  child: Text(
                    horse.rankLabel!,
                    style: AppTypography.labelCaps(
                      isTopRank
                          ? RefereeColors.onTertiary
                          : RefereeColors.onSurface,
                    ).copyWith(fontSize: 10),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.labelCaps(
              RefereeColors.onSurfaceVariant,
            ).copyWith(fontSize: 11),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.labelCaps(
              RefereeColors.championshipGold,
            ).copyWith(fontSize: 14, letterSpacing: 0),
          ),
        ],
      ),
    );
  }
}

class OwnerAddHorseCard extends StatelessWidget {
  const OwnerAddHorseCard({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 2,
              strokeAlign: BorderSide.strokeAlignInside,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_circle_outline,
                size: 48,
                color: RefereeColors.championshipGold.withValues(alpha: 0.4),
              ),
              const SizedBox(height: 16),
              Text(
                'Thêm ngựa mới',
                style: AppTypography.labelCaps(
                  RefereeColors.onSurfaceVariant,
                ).copyWith(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OwnerHorseSearchBar extends StatelessWidget {
  const OwnerHorseSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    this.onClose,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        autofocus: true,
        style: AppTypography.bodyMd(RefereeColors.onSurface),
        decoration: InputDecoration(
          hintText: 'Tìm theo tên hoặc giống ngựa...',
          hintStyle: AppTypography.bodyMd(RefereeColors.onSurfaceVariant),
          prefixIcon: const Icon(
            Icons.search,
            color: RefereeColors.championshipGold,
          ),
          suffixIcon: IconButton(
            onPressed: onClose,
            icon: const Icon(
              Icons.close,
              color: RefereeColors.onSurfaceVariant,
            ),
          ),
          filled: true,
          fillColor: RefereeColors.portalSurface.withValues(alpha: 0.7),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: RefereeColors.championshipGold),
          ),
        ),
      ),
    );
  }
}
