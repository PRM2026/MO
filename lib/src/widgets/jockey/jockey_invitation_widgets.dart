import 'package:flutter/material.dart';

import '../../constants/app_theme_tokens.dart';
import '../../constants/referee_colors.dart';
import '../../models/jockey_invitation_data.dart';
import '../news/news_network_image.dart';
import '../referee/referee_glass_card.dart';

class JockeyInvitationListTile extends StatelessWidget {
  const JockeyInvitationListTile({
    super.key,
    required this.item,
    required this.onTap,
  });

  final JockeyInvitationListItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return RefereeGlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 72,
              height: 72,
              child: item.horseImageUrl != null
                  ? NewsNetworkImage(imageUrl: item.horseImageUrl!)
                  : ColoredBox(
                      color: RefereeColors.surfaceContainer,
                      child: Icon(
                        Icons.pets,
                        color: RefereeColors.onSurfaceVariant,
                      ),
                    ),
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
                        item.horseName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.labelCaps(RefereeColors.onSurface)
                            .copyWith(fontSize: 15),
                      ),
                    ),
                    if (item.isNew)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: RefereeColors.championshipGold
                              .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'MỚI',
                          style: AppTypography.labelCaps(
                            RefereeColors.championshipGold,
                          ).copyWith(fontSize: 9),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.tournamentName,
                  style: AppTypography.bodySm(RefereeColors.championshipGold),
                ),
                Text(
                  '${item.ownerName} • ${item.raceDate}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelCaps(
                    RefereeColors.onSurfaceVariant,
                  ).copyWith(fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                item.baseFee,
                style: AppTypography.labelCaps(RefereeColors.onSurface)
                    .copyWith(fontSize: 11),
              ),
              Icon(
                Icons.chevron_right,
                color: RefereeColors.onSurfaceVariant,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class JockeyInvitationHeroCard extends StatelessWidget {
  const JockeyInvitationHeroCard({super.key, required this.detail});

  final JockeyInvitationDetail detail;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          SizedBox(
            height: 256,
            width: double.infinity,
            child: NewsNetworkImage(imageUrl: detail.horseImageUrl),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    RefereeColors.portalSurface.withValues(alpha: 0.4),
                    RefereeColors.portalSurface,
                  ],
                  stops: const [0.35, 0.7, 1],
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: RefereeGlassCard(
              padding: const EdgeInsets.all(24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TÊN NGỰA ĐUA',
                          style: AppTypography.labelCaps(
                            RefereeColors.championshipGold,
                          ).copyWith(letterSpacing: 1),
                        ),
                        Text(
                          detail.horseName,
                          style: AppTypography.displayLg(Colors.white)
                              .copyWith(fontSize: 32),
                        ),
                        Text(
                          detail.horseBreed,
                          style: AppTypography.bodyMd(
                            RefereeColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: RefereeColors.championshipGold
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: RefereeColors.championshipGold
                            .withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      detail.tournamentBadge,
                      style: AppTypography.labelCaps(
                        RefereeColors.championshipGold,
                      ).copyWith(fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class JockeyInvitationOwnerCard extends StatelessWidget {
  const JockeyInvitationOwnerCard({super.key, required this.detail});

  final JockeyInvitationDetail detail;

  @override
  Widget build(BuildContext context) {
    return RefereeGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  color: RefereeColors.championshipGold,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      detail.ownerName,
                      style: AppTypography.headlineSm(Colors.white)
                          .copyWith(fontSize: 20),
                    ),
                    Text(
                      detail.ownerSubtitle,
                      style: AppTypography.labelCaps(
                        RefereeColors.onSurfaceVariant,
                      ).copyWith(fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  RefereeColors.championshipGold.withValues(alpha: 0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '"${detail.ownerMessage}"',
                  style: AppTypography.bodyMd(RefereeColors.onSurface)
                      .copyWith(fontStyle: FontStyle.italic),
                ),
              ),
              const Positioned(
                top: -8,
                left: -4,
                child: Icon(
                  Icons.format_quote,
                  color: RefereeColors.championshipGold,
                  size: 28,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class JockeyInvitationScheduleWarning extends StatelessWidget {
  const JockeyInvitationScheduleWarning({super.key, required this.detail});

  final JockeyInvitationDetail detail;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: RefereeColors.statusRed.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: RefereeColors.statusRed.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded, color: RefereeColors.statusRed),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cảnh báo trùng lịch',
                  style: AppTypography.labelCaps(RefereeColors.statusRed)
                      .copyWith(fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text.rich(
                  TextSpan(
                    style: AppTypography.bodyMd(
                      RefereeColors.onSurfaceVariant,
                    ),
                    children: [
                      const TextSpan(
                        text: 'Lưu ý: Trùng lịch với giải đấu ',
                      ),
                      TextSpan(
                        text: detail.conflictEventName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const TextSpan(
                        text:
                            ' (cách nhau 2 giờ). Vui lòng kiểm tra lộ trình di chuyển.',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class JockeyInvitationRemunerationCard extends StatelessWidget {
  const JockeyInvitationRemunerationCard({super.key, required this.detail});

  final JockeyInvitationDetail detail;

  @override
  Widget build(BuildContext context) {
    return RefereeGlassCard(
      child: Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            child: Icon(
              Icons.payments_outlined,
              size: 96,
              color: RefereeColors.championshipGold.withValues(alpha: 0.1),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'THÙ LAO & QUYỀN LỢI',
                style: AppTypography.labelCaps(RefereeColors.championshipGold)
                    .copyWith(letterSpacing: 1.2),
              ),
              const SizedBox(height: 24),
              Text(
                'Phí nài ngựa (Base)',
                style: AppTypography.labelCaps(
                  RefereeColors.onSurfaceVariant,
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    detail.baseFee,
                    style: AppTypography.displayLg(Colors.white)
                        .copyWith(fontSize: 32),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'VND',
                    style: AppTypography.labelCaps(
                      RefereeColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: RefereeColors.championshipGold,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.military_tech_outlined,
                        color: RefereeColors.portalSurface,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            detail.prizeShareLabel,
                            style: AppTypography.labelCaps(Colors.white)
                                .copyWith(fontSize: 14, letterSpacing: 0.2),
                          ),
                          Text(
                            detail.prizeShareDescription,
                            style: AppTypography.labelCaps(
                              RefereeColors.onSurfaceVariant,
                            ).copyWith(fontWeight: FontWeight.w400),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class JockeyInvitationRaceDetailsCard extends StatelessWidget {
  const JockeyInvitationRaceDetailsCard({super.key, required this.detail});

  final JockeyInvitationDetail detail;

  static const _rows = [
    (Icons.calendar_month_outlined, 'Ngày thi đấu'),
    (Icons.schedule_outlined, 'Giờ xuất phát'),
    (Icons.location_on_outlined, 'Trường đua'),
  ];

  @override
  Widget build(BuildContext context) {
    final values = [detail.raceDate, detail.startTime, detail.venue];

    return RefereeGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'THÔNG TIN TRẬN ĐẤU',
            style: AppTypography.labelCaps(RefereeColors.onSurfaceVariant)
                .copyWith(letterSpacing: 1.2),
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < _rows.length; i++) ...[
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        _rows[i].$1,
                        size: 20,
                        color: RefereeColors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          _rows[i].$2,
                          style: AppTypography.bodyMd(
                            RefereeColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    values[i],
                    textAlign: TextAlign.end,
                    style: AppTypography.bodyMd(Colors.white),
                  ),
                ),
              ],
            ),
            if (i < _rows.length - 1) const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}

class JockeyInvitationActionBar extends StatelessWidget {
  const JockeyInvitationActionBar({
    super.key,
    required this.onDecline,
    required this.onAccept,
    required this.isProcessing,
  });

  final VoidCallback? onDecline;
  final VoidCallback? onAccept;
  final bool isProcessing;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: RefereeColors.portalSurface.withValues(alpha: 0.9),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: isProcessing ? null : onDecline,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: RefereeColors.championshipGold,
                    side: const BorderSide(
                      color: RefereeColors.championshipGold,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'TỪ CHỐI',
                    style: AppTypography.labelCaps(
                      RefereeColors.championshipGold,
                    ).copyWith(letterSpacing: 0.8),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: FilledButton(
                  onPressed: isProcessing ? null : onAccept,
                  style: FilledButton.styleFrom(
                    backgroundColor: RefereeColors.championshipGold,
                    foregroundColor: RefereeColors.portalSurface,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isProcessing
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: RefereeColors.portalSurface,
                          ),
                        )
                      : Text(
                          'CHẤP NHẬN LỜI MỜI',
                          style: AppTypography.labelCaps(
                            RefereeColors.portalSurface,
                          ).copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
