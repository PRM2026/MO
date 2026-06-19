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

class OwnerHorseGridCard extends StatelessWidget {
  const OwnerHorseGridCard({super.key, required this.horse, this.onTap});

  final OwnerHorseItem horse;
  final VoidCallback? onTap;

  Widget _buildTag(String label, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: RefereeColors.onSurfaceVariant),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppTypography.bodySm(
              RefereeColors.onSurfaceVariant,
            ).copyWith(fontSize: 11, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: AppTypography.labelCaps(
            RefereeColors.onSurfaceVariant,
          ).copyWith(
            fontSize: 9,
            letterSpacing: 0.5,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTypography.displayMd(
            valueColor ?? RefereeColors.onSurface,
          ).copyWith(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      width: 1,
      height: 24,
      color: Colors.white.withValues(alpha: 0.08),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          horse.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.headlineSm(
                            RefereeColors.onSurface,
                          ).copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: _statusColor(
                            horse.statusCode,
                          ).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: _statusColor(
                              horse.statusCode,
                            ).withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          horse.statusLabel.toUpperCase(),
                          style: AppTypography.labelCaps(
                            _statusColor(horse.statusCode),
                          ).copyWith(fontSize: 9, letterSpacing: 0.2),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _buildTag(horse.breed, icon: Icons.pets_outlined),
                      if (horse.age != null)
                        _buildTag(
                          horse.ageLabel,
                          icon: Icons.calendar_today_outlined,
                        ),
                      _buildTag(
                        horse.genderLabel,
                        icon: Icons.transgender_outlined,
                      ),
                      _buildTag(
                        horse.colorLabel,
                        icon: Icons.color_lens_outlined,
                      ),
                      if (horse.heightCm != null || horse.weightKg != null)
                        _buildTag(
                          horse.bodyMetricsLabel,
                          icon: Icons.monitor_weight_outlined,
                        ),
                    ],
                  ),
                  if (horse.reviewReason?.trim().isNotEmpty == true) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: RefereeColors.statusRed.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: RefereeColors.statusRed.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            size: 16,
                            color: RefereeColors.statusRed,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              horse.reviewReason!.trim(),
                              style: AppTypography.bodySm(
                                RefereeColors.statusRed,
                              ).copyWith(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: RefereeColors.portalSurface.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.05),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          label: 'CUỘC ĐUA',
                          value: '${horse.performance.totalRaces}',
                        ),
                        _buildVerticalDivider(),
                        _buildStatItem(
                          label: 'THẮNG',
                          value: '${horse.performance.wins}',
                          valueColor: RefereeColors.championshipGold,
                        ),
                        _buildVerticalDivider(),
                        _buildStatItem(
                          label: 'TỶ LỆ THẮNG',
                          value: horse.performance.winRateLabel,
                          valueColor: RefereeColors.successEmerald,
                        ),
                      ],
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
        height: 200,
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

class OwnerAddHorseCard extends StatelessWidget {
  const OwnerAddHorseCard({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return RefereeGlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: RefereeColors.championshipGold.withValues(alpha: 0.05),
              shape: BoxShape.circle,
              border: Border.all(
                color: RefereeColors.championshipGold.withValues(alpha: 0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: RefereeColors.championshipGold.withValues(alpha: 0.04),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.add_rounded,
              size: 32,
              color: RefereeColors.championshipGold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Thêm ngựa mới',
            style: AppTypography.labelCaps(
              RefereeColors.championshipGold,
            ).copyWith(
              fontSize: 13,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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
