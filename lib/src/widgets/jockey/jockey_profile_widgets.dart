import 'package:flutter/material.dart';

import '../../constants/app_theme_tokens.dart';
import '../../constants/referee_colors.dart';
import '../../models/jockey_profile_response.dart';
import '../news/news_network_image.dart';
import '../referee/referee_glass_card.dart';

class JockeyProfileHeaderCard extends StatelessWidget {
  const JockeyProfileHeaderCard({super.key, required this.profile});

  final JockeyProfileResponse profile;

  @override
  Widget build(BuildContext context) {
    return RefereeGlassCard(
      padding: const EdgeInsets.all(24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 720;
          final avatar = _JockeyAvatar(imageUrl: profile.avatarUrl);

          final info = Column(
            crossAxisAlignment: isWide
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            children: [
              Text(
                profile.displayName,
                textAlign: isWide ? TextAlign.start : TextAlign.center,
                style: AppTypography.displayLg(
                  RefereeColors.onSurface,
                ).copyWith(fontSize: isWide ? 32 : 28),
              ),
              const SizedBox(height: 6),
              Text(
                profile.usernameLabel,
                style: AppTypography.bodyMd(RefereeColors.onSurfaceVariant),
              ),
              const SizedBox(height: 14),
              Wrap(
                alignment: isWide ? WrapAlignment.start : WrapAlignment.center,
                spacing: 10,
                runSpacing: 10,
                children: [
                  _StatusBadge(status: profile.statusCode),
                  _InfoPill(
                    icon: Icons.badge_outlined,
                    label: profile.licenseLabel,
                  ),
                  _InfoPill(
                    icon: Icons.history_edu_outlined,
                    label: '${profile.experienceYears} nam kinh nghiem',
                  ),
                ],
              ),
            ],
          );

          if (isWide) {
            return Row(
              children: [
                avatar,
                const SizedBox(width: 24),
                Expanded(child: info),
              ],
            );
          }

          return Column(children: [avatar, const SizedBox(height: 20), info]);
        },
      ),
    );
  }
}

class JockeyProfileReviewCard extends StatelessWidget {
  const JockeyProfileReviewCard({super.key, required this.profile});

  final JockeyProfileResponse profile;

  @override
  Widget build(BuildContext context) {
    if (!profile.shouldShowReviewReason) return const SizedBox.shrink();

    return RefereeGlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.report_problem_outlined,
            color: RefereeColors.statusRed,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ly do xet duyet',
                  style: AppTypography.labelCaps(RefereeColors.statusRed),
                ),
                const SizedBox(height: 6),
                Text(
                  profile.reviewReason!.trim(),
                  style: AppTypography.bodyMd(RefereeColors.onSurface),
                ),
                if (profile.reviewedAt != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    profile.reviewedAtLabel,
                    style: AppTypography.bodySm(RefereeColors.onSurfaceVariant),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class JockeyProfilePerformanceGrid extends StatelessWidget {
  const JockeyProfilePerformanceGrid({super.key, required this.profile});

  final JockeyProfileResponse profile;

  @override
  Widget build(BuildContext context) {
    final performance = profile.performance;
    final rankOne = performance.rankCounts['1'] ?? 0;
    final rankTwo = performance.rankCounts['2'] ?? 0;
    final rankThree = performance.rankCounts['3'] ?? 0;
    final stats = [
      _ProfileMetric(
        'Tong cuoc dua',
        '${performance.totalRaces}',
        Icons.flag_outlined,
      ),
      _ProfileMetric(
        'So lan thang',
        '${performance.wins}',
        Icons.emoji_events_outlined,
      ),
      _ProfileMetric('Ti le thang', performance.winRateLabel, Icons.show_chart),
      _ProfileMetric(
        'Hang 1/2/3',
        '$rankOne/$rankTwo/$rankThree',
        Icons.military_tech_outlined,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 720 ? 4 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: stats.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: constraints.maxWidth >= 720 ? 1.25 : 1.35,
          ),
          itemBuilder: (context, index) => _MetricCard(metric: stats[index]),
        );
      },
    );
  }
}

class JockeyProfileInfoSection extends StatelessWidget {
  const JockeyProfileInfoSection({super.key, required this.profile});

  final JockeyProfileResponse profile;

  @override
  Widget build(BuildContext context) {
    return RefereeGlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionTitle(title: 'Thong tin jockey'),
          const SizedBox(height: 16),
          _InfoRow(
            label: 'Chieu cao',
            value: _physicalValue(profile.heightCm, 'cm'),
          ),
          _InfoRow(
            label: 'Can nang',
            value: _physicalValue(profile.weightKg, 'kg'),
          ),
          _InfoRow(label: 'Bio', value: _fallback(profile.bio)),
          _InfoRow(label: 'Giai thuong', value: _fallback(profile.awards)),
          _InfoRow(label: 'Chuyen mon', value: _fallback(profile.specialties)),
          _InfoRow(label: 'Thanh tich', value: _fallback(profile.achievements)),
          _InfoRow(
            label: 'Tai lieu license',
            value: profile.licenseDocumentUrl?.trim().isNotEmpty == true
                ? 'Da tai len'
                : 'Chua tai len',
          ),
        ],
      ),
    );
  }
}

class JockeyRaceHistorySection extends StatelessWidget {
  const JockeyRaceHistorySection({super.key, required this.items});

  final List<JockeyRaceHistoryItem> items;

  @override
  Widget build(BuildContext context) {
    return RefereeGlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionTitle(title: 'Lich su dua'),
          const SizedBox(height: 16),
          if (items.isEmpty)
            Text(
              'Chua co lich su dua.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMd(RefereeColors.onSurfaceVariant),
            )
          else
            for (var i = 0; i < items.length; i++) ...[
              _RaceHistoryTile(item: items[i]),
              if (i < items.length - 1)
                Divider(color: Colors.white.withValues(alpha: 0.08)),
            ],
        ],
      ),
    );
  }
}

class JockeyProfileActionsCard extends StatelessWidget {
  const JockeyProfileActionsCard({
    super.key,
    required this.isLoggingOut,
    this.onEdit,
    required this.onChangePassword,
    required this.onLogout,
  });

  final bool isLoggingOut;
  final VoidCallback? onEdit;
  final VoidCallback onChangePassword;
  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context) {
    return RefereeGlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (onEdit != null) ...[
            FilledButton.icon(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Chinh sua ho so'),
            ),
            const SizedBox(height: 12),
          ],
          OutlinedButton.icon(
            onPressed: onChangePassword,
            icon: const Icon(Icons.security_outlined),
            label: const Text('Bao mat & Mat khau'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: isLoggingOut ? null : onLogout,
            icon: isLoggingOut
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.logout),
            label: const Text('Dang xuat'),
            style: OutlinedButton.styleFrom(
              foregroundColor: RefereeColors.statusRed,
              side: BorderSide(
                color: RefereeColors.statusRed.withValues(alpha: 0.35),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _JockeyAvatar extends StatelessWidget {
  const _JockeyAvatar({this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 112,
      height: 112,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: RefereeColors.championshipGold, width: 4),
      ),
      child: imageUrl?.trim().isNotEmpty == true
          ? NewsNetworkImage(imageUrl: imageUrl!.trim())
          : const ColoredBox(
              color: RefereeColors.secondaryContainer,
              child: Icon(
                Icons.person_outline,
                color: RefereeColors.onSecondaryContainer,
                size: 48,
              ),
            ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'APPROVED' => RefereeColors.successEmerald,
      'REJECTED' || 'SUSPENDED' => RefereeColors.statusRed,
      'PENDING' => RefereeColors.championshipGold,
      _ => RefereeColors.onSurfaceVariant,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(status, style: AppTypography.labelCaps(color)),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: RefereeColors.onSurfaceVariant, size: 16),
          const SizedBox(width: 6),
          Text(label, style: AppTypography.bodySm(RefereeColors.onSurface)),
        ],
      ),
    );
  }
}

class _ProfileMetric {
  const _ProfileMetric(this.label, this.value, this.icon);

  final String label;
  final String value;
  final IconData icon;
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.metric});

  final _ProfileMetric metric;

  @override
  Widget build(BuildContext context) {
    return RefereeGlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(metric.icon, color: RefereeColors.championshipGold),
          Text(
            metric.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.labelCaps(RefereeColors.onSurfaceVariant),
          ),
          Text(
            metric.value,
            style: AppTypography.headlineSm(
              RefereeColors.onSurface,
            ).copyWith(fontSize: 22),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTypography.headlineSm(
        RefereeColors.onSurface,
      ).copyWith(fontSize: 20),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: AppTypography.labelCaps(RefereeColors.onSurfaceVariant),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTypography.bodyMd(RefereeColors.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}

class _RaceHistoryTile extends StatelessWidget {
  const _RaceHistoryTile({required this.item});

  final JockeyRaceHistoryItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          const Icon(
            Icons.flag_outlined,
            color: RefereeColors.championshipGold,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: AppTypography.bodyMd(
                    RefereeColors.onSurface,
                  ).copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  item.subtitle,
                  style: AppTypography.bodySm(RefereeColors.onSurfaceVariant),
                ),
                const SizedBox(height: 4),
                Text(
                  item.finishTimeLabel,
                  style: AppTypography.bodySm(RefereeColors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _StatusBadge(status: item.rankLabel.toUpperCase()),
        ],
      ),
    );
  }
}

String _fallback(String? value) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? 'Chua cap nhat' : trimmed;
}

String _physicalValue(num value, String unit) {
  if (value <= 0) return 'Chua cap nhat';
  final label = value % 1 == 0 ? value.toInt().toString() : value.toString();
  return '$label $unit';
}
