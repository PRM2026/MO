import 'package:flutter/material.dart';

import '../../constants/app_theme_tokens.dart';
import '../../constants/referee_colors.dart';
import '../../models/jockey_invitation_data.dart';
import '../referee/referee_glass_card.dart';

class JockeyInvitationFilterChips extends StatelessWidget {
  const JockeyInvitationFilterChips({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final JockeyInvitationFilter selected;
  final ValueChanged<JockeyInvitationFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: JockeyInvitationFilter.values.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final filter = JockeyInvitationFilter.values[index];
          final isSelected = filter == selected;
          return FilterChip(
            label: Text(filter.label),
            selected: isSelected,
            showCheckmark: false,
            onSelected: (_) => onSelected(filter),
            labelStyle: AppTypography.labelCaps(
              isSelected
                  ? RefereeColors.championshipGold
                  : RefereeColors.onSurfaceVariant,
            ).copyWith(fontSize: 12, letterSpacing: 0.2),
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
          );
        },
      ),
    );
  }
}

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: RefereeColors.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.mail_outline,
              color: RefereeColors.championshipGold,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.horseName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.headlineSm(
                          RefereeColors.onSurface,
                        ).copyWith(fontSize: 18),
                      ),
                    ),
                    const SizedBox(width: 8),
                    JockeyInvitationStatusBadge(
                      statusCode: item.statusCode,
                      label: item.statusLabel,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${item.raceName} • ${item.tournamentName}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySm(RefereeColors.onSurfaceVariant),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 14,
                  runSpacing: 6,
                  children: [
                    _InlineInfo(
                      icon: Icons.person_outline,
                      value: item.ownerName,
                    ),
                    _InlineInfo(
                      icon: Icons.payments_outlined,
                      value: item.remunerationLabel,
                    ),
                    _InlineInfo(
                      icon: Icons.schedule_outlined,
                      value: item.createdAtLabel,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          const Padding(
            padding: EdgeInsets.only(top: 18),
            child: Icon(
              Icons.chevron_right,
              color: RefereeColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class JockeyInvitationDetailHeader extends StatelessWidget {
  const JockeyInvitationDetailHeader({super.key, required this.detail});

  final JockeyInvitationDetail detail;

  @override
  Widget build(BuildContext context) {
    return RefereeGlassCard(
      padding: const EdgeInsets.all(22),
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
                    Text(
                      'LỜI MỜI #${detail.id}',
                      style: AppTypography.labelCaps(
                        RefereeColors.championshipGold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      detail.horseName,
                      style: AppTypography.displayLg(
                        RefereeColors.onSurface,
                      ).copyWith(fontSize: 30),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      detail.horseReference,
                      style: AppTypography.bodySm(
                        RefereeColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              JockeyInvitationStatusBadge(
                statusCode: detail.statusCode,
                label: detail.statusLabel,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Divider(color: Colors.white.withValues(alpha: 0.08)),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(
                Icons.payments_outlined,
                color: RefereeColors.championshipGold,
              ),
              const SizedBox(width: 10),
              Text(
                detail.remunerationLabel,
                style: AppTypography.headlineSm(
                  RefereeColors.onSurface,
                ).copyWith(fontSize: 24),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class JockeyInvitationPartyCard extends StatelessWidget {
  const JockeyInvitationPartyCard({super.key, required this.detail});

  final JockeyInvitationDetail detail;

  @override
  Widget build(BuildContext context) {
    return _DetailCard(
      title: 'Các bên liên quan',
      children: [
        _DetailRow(
          icon: Icons.person_outline,
          label: 'Chủ ngựa',
          value: detail.ownerName,
          subtitle: detail.ownerReference,
        ),
        _DetailRow(
          icon: Icons.sports_outlined,
          label: 'Jockey',
          value: detail.jockeyReference,
        ),
      ],
    );
  }
}

class JockeyInvitationRaceCard extends StatelessWidget {
  const JockeyInvitationRaceCard({super.key, required this.detail});

  final JockeyInvitationDetail detail;

  @override
  Widget build(BuildContext context) {
    return _DetailCard(
      title: 'Cuộc đua và giải đấu',
      children: [
        _DetailRow(
          icon: Icons.flag_outlined,
          label: 'Cuộc đua',
          value: detail.raceName,
          subtitle: detail.raceReference,
        ),
        _DetailRow(
          icon: Icons.emoji_events_outlined,
          label: 'Giải đấu',
          value: detail.tournamentName,
          subtitle: detail.tournamentReference,
        ),
      ],
    );
  }
}

class JockeyInvitationMessageCard extends StatelessWidget {
  const JockeyInvitationMessageCard({super.key, required this.detail});

  final JockeyInvitationDetail detail;

  @override
  Widget build(BuildContext context) {
    return _DetailCard(
      title: 'Nội dung lời mời',
      children: [
        _MessageBlock(label: 'Lời nhắn từ chủ ngựa', value: detail.message),
        if (detail.hasResponseNote)
          _MessageBlock(
            label: 'Phản hồi của jockey',
            value: detail.responseNote,
          ),
      ],
    );
  }
}

class JockeyInvitationTimelineCard extends StatelessWidget {
  const JockeyInvitationTimelineCard({super.key, required this.detail});

  final JockeyInvitationDetail detail;

  @override
  Widget build(BuildContext context) {
    return _DetailCard(
      title: 'Mốc thời gian',
      children: [
        _DetailRow(
          icon: Icons.send_outlined,
          label: 'Đã gửi',
          value: detail.createdAtLabel,
        ),
        _DetailRow(
          icon: Icons.update_outlined,
          label: 'Cập nhật gần nhất',
          value: detail.updatedAtLabel,
        ),
        if (detail.hasRespondedAt)
          _DetailRow(
            icon: Icons.task_alt_outlined,
            label: 'Đã phản hồi',
            value: detail.respondedAtLabel,
          ),
        if (detail.hasCancelledAt)
          _DetailRow(
            icon: Icons.cancel_outlined,
            label: 'Đã hủy',
            value: detail.cancelledAtLabel,
          ),
      ],
    );
  }
}

class JockeyInvitationStatusBadge extends StatelessWidget {
  const JockeyInvitationStatusBadge({
    super.key,
    required this.statusCode,
    required this.label,
  });

  final String statusCode;
  final String label;

  @override
  Widget build(BuildContext context) {
    final color = switch (statusCode) {
      'ACCEPTED' => RefereeColors.successEmerald,
      'REJECTED' || 'CANCELLED' => RefereeColors.statusRed,
      'PENDING' => RefereeColors.championshipGold,
      _ => RefereeColors.onSurfaceVariant,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: AppTypography.labelCaps(color).copyWith(fontSize: 10),
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return RefereeGlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: AppTypography.headlineSm(
              RefereeColors.onSurface,
            ).copyWith(fontSize: 19),
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1) ...[
              const SizedBox(height: 14),
              Divider(color: Colors.white.withValues(alpha: 0.06)),
              const SizedBox(height: 14),
            ],
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.subtitle,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: RefereeColors.championshipGold, size: 21),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.labelCaps(RefereeColors.onSurfaceVariant),
              ),
              const SizedBox(height: 3),
              Text(value, style: AppTypography.bodyMd(RefereeColors.onSurface)),
              if (subtitle?.isNotEmpty == true) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: AppTypography.bodySm(RefereeColors.onSurfaceVariant),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _MessageBlock extends StatelessWidget {
  const _MessageBlock({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelCaps(RefereeColors.onSurfaceVariant),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            value,
            style: AppTypography.bodyMd(RefereeColors.onSurface),
          ),
        ),
      ],
    );
  }
}

class _InlineInfo extends StatelessWidget {
  const _InlineInfo({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: RefereeColors.onSurfaceVariant),
        const SizedBox(width: 5),
        Text(
          value,
          style: AppTypography.bodySm(RefereeColors.onSurfaceVariant),
        ),
      ],
    );
  }
}
