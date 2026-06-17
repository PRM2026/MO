import 'package:flutter/material.dart';

import '../../constants/app_theme_tokens.dart';
import '../../constants/referee_colors.dart';
import '../../models/jockey_dashboard_data.dart';
import '../news/news_network_image.dart';
import '../referee/referee_glass_card.dart';

class JockeySpeedlineBackground extends StatelessWidget {
  const JockeySpeedlineBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: CustomPaint(painter: _SpeedlinePainter())),
        child,
      ],
    );
  }
}

class _SpeedlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = RefereeColors.championshipGold.withValues(alpha: 0.05)
      ..strokeWidth = 1;

    for (var x = 0.0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class JockeyWelcomeHeader extends StatelessWidget {
  const JockeyWelcomeHeader({
    super.key,
    required this.greeting,
    required this.jockeyName,
  });

  final String greeting;
  final String jockeyName;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: AppTypography.labelCaps(
            RefereeColors.championshipGold,
          ).copyWith(letterSpacing: 0.8),
        ),
        Text(
          jockeyName,
          style: AppTypography.displayLg(
            RefereeColors.onSurface,
          ).copyWith(fontSize: 28),
        ),
      ],
    );
  }
}

class JockeyStatsGrid extends StatelessWidget {
  const JockeyStatsGrid({super.key, required this.stats});

  final List<JockeyDashboardStat> stats;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 960;
        final crossAxisCount = isWide ? 4 : 2;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: isWide ? 1.35 : 1.15,
          ),
          itemCount: stats.length,
          itemBuilder: (context, index) => _StatCard(stat: stats[index]),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.stat});

  final JockeyDashboardStat stat;

  @override
  Widget build(BuildContext context) {
    return RefereeGlassCard(
      padding: const EdgeInsets.all(16),
      child: stat.accentBorder
          ? DecoratedBox(
              decoration: const BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: RefereeColors.championshipGold,
                    width: 4,
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 12),
                child: _StatContent(stat: stat),
              ),
            )
          : _StatContent(stat: stat),
    );
  }
}

class _StatContent extends StatelessWidget {
  const _StatContent({required this.stat});

  final JockeyDashboardStat stat;

  @override
  Widget build(BuildContext context) {
    final valueColor = stat.highlight
        ? RefereeColors.championshipGold
        : RefereeColors.onSurface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          stat.label.toUpperCase(),
          style: AppTypography.labelCaps(
            RefereeColors.onSurfaceVariant,
          ).copyWith(fontSize: 11),
        ),
        if (stat.trend != null)
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                stat.value,
                style: AppTypography.displayLg(
                  valueColor,
                ).copyWith(fontSize: 28),
              ),
              const SizedBox(width: 4),
              Text(
                stat.trend!,
                style: AppTypography.bodySm(RefereeColors.successEmerald),
              ),
            ],
          )
        else if (stat.subLabel != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                stat.value,
                style: AppTypography.displayLg(
                  valueColor,
                ).copyWith(fontSize: 28),
              ),
              Text(
                stat.subLabel!,
                style: AppTypography.labelCaps(RefereeColors.onSurfaceVariant),
              ),
            ],
          )
        else
          Text(
            stat.value,
            style: AppTypography.displayLg(valueColor).copyWith(fontSize: 28),
          ),
      ],
    );
  }
}

class JockeyRecentResultsSection extends StatelessWidget {
  const JockeyRecentResultsSection({super.key, required this.results});

  final List<JockeyRecentResult> results;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Kết quả gần đây',
          style: AppTypography.headlineSm(
            RefereeColors.onSurface,
          ).copyWith(fontSize: 22),
        ),
        const SizedBox(height: 16),
        if (results.isEmpty)
          const _EmptyDashboardMessage(message: 'Chua co cuoc dua gan day.')
        else
          for (final result in results) ...[
            _ResultTile(result: result),
            const SizedBox(height: 12),
          ],
      ],
    );
  }
}

class JockeyUpcomingRacesSection extends StatelessWidget {
  const JockeyUpcomingRacesSection({super.key, required this.races});

  final List<JockeyDashboardUpcomingRace> races;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Cuoc dua sap toi',
          style: AppTypography.headlineSm(
            RefereeColors.onSurface,
          ).copyWith(fontSize: 22),
        ),
        const SizedBox(height: 16),
        if (races.isEmpty)
          const _EmptyDashboardMessage(message: 'Chua co cuoc dua sap toi.')
        else
          for (final race in races) ...[
            RefereeGlassCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(
                    Icons.flag_outlined,
                    color: RefereeColors.championshipGold,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          race.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.labelCaps(
                            RefereeColors.onSurface,
                          ).copyWith(fontSize: 14, letterSpacing: 0.2),
                        ),
                        Text(
                          race.timeLabel,
                          style: AppTypography.bodySm(
                            RefereeColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (race.status.isNotEmpty) _StatusPill(label: race.status),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
      ],
    );
  }
}

class JockeyDashboardAlertsSection extends StatelessWidget {
  const JockeyDashboardAlertsSection({super.key, required this.alerts});

  final List<JockeyDashboardAlert> alerts;

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Can chu y',
          style: AppTypography.headlineSm(
            RefereeColors.onSurface,
          ).copyWith(fontSize: 22),
        ),
        const SizedBox(height: 16),
        for (final alert in alerts) ...[
          RefereeGlassCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(
                  Icons.notifications_active_outlined,
                  color: RefereeColors.championshipGold,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    alert.title,
                    style: AppTypography.bodyMd(RefereeColors.onSurface),
                  ),
                ),
                if (alert.status.isNotEmpty) _StatusPill(label: alert.status),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class JockeyQuickLinksSection extends StatelessWidget {
  const JockeyQuickLinksSection({
    super.key,
    required this.links,
    required this.onLinkTap,
  });

  final List<JockeyDashboardQuickLink> links;
  final ValueChanged<JockeyDashboardQuickLink> onLinkTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Truy cap nhanh',
          style: AppTypography.headlineSm(
            RefereeColors.onSurface,
          ).copyWith(fontSize: 22),
        ),
        const SizedBox(height: 16),
        if (links.isEmpty)
          const _EmptyDashboardMessage(message: 'Chua co lien ket nhanh.')
        else
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final link in links)
                OutlinedButton.icon(
                  onPressed: () => onLinkTap(link),
                  icon: Icon(_quickLinkIcon(link.label), size: 18),
                  label: Text(link.label),
                ),
            ],
          ),
      ],
    );
  }
}

class _EmptyDashboardMessage extends StatelessWidget {
  const _EmptyDashboardMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return RefereeGlassCard(
      padding: const EdgeInsets.all(16),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: AppTypography.bodyMd(RefereeColors.onSurfaceVariant),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: RefereeColors.championshipGold.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: RefereeColors.championshipGold.withValues(alpha: 0.35),
        ),
      ),
      child: Text(
        label,
        style: AppTypography.labelCaps(
          RefereeColors.championshipGold,
        ).copyWith(fontSize: 10),
      ),
    );
  }
}

IconData _quickLinkIcon(String label) {
  return switch (label.trim().toLowerCase()) {
    'profile' => Icons.person_outline,
    'invitations' => Icons.mail_outline,
    'my races' => Icons.calendar_today_outlined,
    'performance' => Icons.military_tech_outlined,
    'wallet' => Icons.account_balance_wallet_outlined,
    'notifications' => Icons.notifications_none,
    _ => Icons.open_in_new,
  };
}

class _ResultTile extends StatelessWidget {
  const _ResultTile({required this.result});

  final JockeyRecentResult result;

  @override
  Widget build(BuildContext context) {
    return RefereeGlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: result.isWinner
                  ? RefereeColors.championshipGold.withValues(alpha: 0.1)
                  : Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: result.rank > 0
                ? Text(
                    '${result.rank}',
                    style: AppTypography.headlineSm(
                      result.isWinner
                          ? RefereeColors.championshipGold
                          : RefereeColors.onSurfaceVariant,
                    ),
                  )
                : Icon(
                    Icons.flag_outlined,
                    color: result.isWinner
                        ? RefereeColors.championshipGold
                        : RefereeColors.onSurfaceVariant,
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.eventName,
                  style: AppTypography.labelCaps(
                    RefereeColors.onSurface,
                  ).copyWith(fontSize: 14, letterSpacing: 0.2),
                ),
                Text(
                  result.detail,
                  style: AppTypography.labelCaps(
                    RefereeColors.onSurfaceVariant,
                  ).copyWith(fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ),
          Icon(
            result.isWinner
                ? Icons.military_tech_outlined
                : Icons.chevron_right,
            color: result.isWinner
                ? RefereeColors.championshipGold
                : RefereeColors.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}

class JockeyMotivationCard extends StatelessWidget {
  const JockeyMotivationCard({
    super.key,
    required this.quote,
    required this.imageUrl,
  });

  final String quote;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 160,
        child: Stack(
          fit: StackFit.expand,
          children: [
            NewsNetworkImage(imageUrl: imageUrl),
            ColoredBox(
              color: RefereeColors.portalSurface.withValues(alpha: 0.6),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  quote,
                  style:
                      AppTypography.bodyMd(
                        Colors.white.withValues(alpha: 0.8),
                      ).copyWith(
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
