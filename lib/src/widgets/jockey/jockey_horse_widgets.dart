import 'package:flutter/material.dart';

import '../../constants/app_theme_tokens.dart';
import '../../constants/referee_colors.dart';
import '../../models/jockey_horse_data.dart';
import '../news/news_network_image.dart';
import '../referee/referee_glass_card.dart';

class JockeyHorseGridCard extends StatelessWidget {
  const JockeyHorseGridCard({
    super.key,
    required this.horse,
    required this.onTap,
  });

  final JockeyHorseItem horse;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return RefereeGlassCard(
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: SizedBox(
              height: 192,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  NewsNetworkImage(imageUrl: horse.imageUrl),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          RefereeColors.portalSurface,
                        ],
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
                            color: horse.badgeColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            horse.badgeLabel,
                            style: AppTypography.labelCaps(horse.badgeColor)
                                .copyWith(fontSize: 11),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          horse.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.headlineSm(Colors.white)
                              .copyWith(fontSize: 22),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CHỦ SỞ HỮU',
                        style: AppTypography.labelCaps(
                          RefereeColors.onSurfaceVariant.withValues(alpha: 0.7),
                        ).copyWith(fontSize: 10, letterSpacing: 0.8),
                      ),
                      Text(
                        horse.ownerName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodyMd(
                          RefereeColors.championshipGold,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'TUỔI',
                      style: AppTypography.labelCaps(
                        RefereeColors.onSurfaceVariant.withValues(alpha: 0.7),
                      ).copyWith(fontSize: 10, letterSpacing: 0.8),
                    ),
                    Text(
                      horse.ageLabel,
                      style: AppTypography.bodyMd(RefereeColors.onSurface),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> showJockeyHorseDetailSheet(
  BuildContext context,
  JockeyHorseItem horse,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.6),
    builder: (context) => _JockeyHorseDetailSheet(horse: horse),
  );
}

class _JockeyHorseDetailSheet extends StatefulWidget {
  const _JockeyHorseDetailSheet({required this.horse});

  final JockeyHorseItem horse;

  @override
  State<_JockeyHorseDetailSheet> createState() =>
      _JockeyHorseDetailSheetState();
}

class _JockeyHorseDetailSheetState extends State<_JockeyHorseDetailSheet> {
  bool _animateBars = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _animateBars = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final horse = widget.horse;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 512,
            maxHeight: MediaQuery.sizeOf(context).height * 0.88,
          ),
          child: Material(
            color: RefereeColors.portalSurface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              horse.name,
                              style: AppTypography.displayLg(
                                RefereeColors.championshipGold,
                              ).copyWith(fontSize: 28),
                            ),
                            Text(
                              horse.breed,
                              style: AppTypography.bodyMd(
                                RefereeColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'CHỦ SỞ HỮU',
                            style: AppTypography.labelCaps(
                              RefereeColors.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            horse.ownerName,
                            style: AppTypography.bodyMd(Colors.white)
                                .copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'CHỈ SỐ HIỆN TẠI',
                    style: AppTypography.labelCaps(RefereeColors.onSurface)
                        .copyWith(letterSpacing: 1.2),
                  ),
                  const SizedBox(height: 16),
                  _StatBar(
                    label: 'Tốc độ (Speed)',
                    value: horse.speed,
                    color: RefereeColors.championshipGold,
                    animate: _animateBars,
                  ),
                  const SizedBox(height: 16),
                  _StatBar(
                    label: 'Sức bền (Stamina)',
                    value: horse.stamina,
                    color: RefereeColors.championshipGold,
                    animate: _animateBars,
                  ),
                  const SizedBox(height: 16),
                  _StatBar(
                    label: 'Thể trạng (Health)',
                    value: horse.health,
                    color: RefereeColors.successEmerald,
                    animate: _animateBars,
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.history_edu_outlined,
                              size: 18,
                              color: RefereeColors.championshipGold,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Ghi chú từ huấn luyện viên',
                              style: AppTypography.labelCaps(
                                RefereeColors.onSurface,
                              ).copyWith(fontSize: 14, letterSpacing: 0.2),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          horse.trainerNotes,
                          style: AppTypography.bodyMd(
                            RefereeColors.onSurfaceVariant,
                          ).copyWith(fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () => Navigator.pop(context),
                    style: FilledButton.styleFrom(
                      backgroundColor: RefereeColors.championshipGold,
                      foregroundColor: RefereeColors.portalSurface,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Đóng',
                      style: AppTypography.labelCaps(
                        RefereeColors.portalSurface,
                      ).copyWith(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatBar extends StatelessWidget {
  const _StatBar({
    required this.label,
    required this.value,
    required this.color,
    required this.animate,
  });

  final String label;
  final int value;
  final Color color;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTypography.labelCaps(RefereeColors.onSurfaceVariant)
                  .copyWith(fontWeight: FontWeight.w500),
            ),
            Text(
              '$value%',
              style: AppTypography.labelCaps(color),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: SizedBox(
            height: 8,
            child: ColoredBox(
              color: Colors.white.withValues(alpha: 0.05),
              child: Align(
                alignment: Alignment.centerLeft,
                child: AnimatedFractionallySizedBox(
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOut,
                  widthFactor: animate ? value / 100 : 0,
                  child: ColoredBox(color: color),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
