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
        Positioned.fill(
          child: CustomPaint(
            painter: _SpeedlinePainter(),
          ),
        ),
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
          style: AppTypography.labelCaps(RefereeColors.championshipGold)
              .copyWith(letterSpacing: 0.8),
        ),
        Text(
          jockeyName,
          style: AppTypography.displayLg(RefereeColors.onSurface)
              .copyWith(fontSize: 28),
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
                style: AppTypography.displayLg(valueColor)
                    .copyWith(fontSize: 28),
              ),
              const SizedBox(width: 4),
              Text(
                stat.trend!,
                style: AppTypography.bodySm(
                  RefereeColors.successEmerald,
                ),
              ),
            ],
          )
        else if (stat.subLabel != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                stat.value,
                style: AppTypography.displayLg(valueColor)
                    .copyWith(fontSize: 28),
              ),
              Text(
                stat.subLabel!,
                style: AppTypography.labelCaps(
                  RefereeColors.onSurfaceVariant,
                ),
              ),
            ],
          )
        else
          Text(
            stat.value,
            style: AppTypography.displayLg(valueColor)
                .copyWith(fontSize: 28),
          ),
      ],
    );
  }
}

class JockeyAlertBanner extends StatelessWidget {
  const JockeyAlertBanner({
    super.key,
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: RefereeColors.statusRed.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: RefereeColors.statusRed.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: RefereeColors.statusRed.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.medical_services_outlined,
              color: RefereeColors.statusRed,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.labelCaps(RefereeColors.statusRed)
                      .copyWith(fontSize: 14),
                ),
                Text(
                  message,
                  style: AppTypography.bodyMd(RefereeColors.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class JockeyHorseCarousel extends StatelessWidget {
  const JockeyHorseCarousel({
    super.key,
    required this.horses,
  });

  final List<JockeyAssignedHorse> horses;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Chiến mã được phân công',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.headlineSm(RefereeColors.onSurface)
                    .copyWith(fontSize: 22),
              ),
            ),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Xem tất cả',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.labelCaps(RefereeColors.championshipGold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 384,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: horses.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) =>
                _HorseCard(horse: horses[index]),
          ),
        ),
      ],
    );
  }
}

class _HorseCard extends StatelessWidget {
  const _HorseCard({required this.horse});

  final JockeyAssignedHorse horse;

  @override
  Widget build(BuildContext context) {
    final statusColor = JockeyDashboardData.statusColor(horse.status);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: 288,
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
                    RefereeColors.portalSurface.withValues(alpha: 0.95),
                  ],
                  stops: const [0.45, 1],
                ),
              ),
            ),
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  JockeyDashboardData.statusLabel(horse.status),
                  style: AppTypography.labelCaps(statusColor)
                      .copyWith(fontSize: 10, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      horse.name,
                      style: AppTypography.headlineSm(RefereeColors.onSurface)
                          .copyWith(fontSize: 22),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tốc độ: ${horse.speed}  •  Bền bỉ: ${horse.stamina}',
                      style: AppTypography.labelCaps(
                        RefereeColors.onSurfaceVariant,
                      ).copyWith(fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class JockeyQuickActions extends StatelessWidget {
  const JockeyQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 640;

        final confirmButton = FilledButton.icon(
          onPressed: () {},
          style: FilledButton.styleFrom(
            backgroundColor: RefereeColors.championshipGold,
            foregroundColor: RefereeColors.portalSurface,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(Icons.check_circle_outline),
          label: Text(
            'Xác nhận lịch',
            style: AppTypography.labelCaps(RefereeColors.portalSurface),
          ),
        );

        final leaderboardButton = OutlinedButton.icon(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            foregroundColor: RefereeColors.championshipGold,
            side: const BorderSide(color: RefereeColors.championshipGold),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(Icons.leaderboard_outlined),
          label: Text(
            'Xem bảng xếp hạng',
            style: AppTypography.labelCaps(RefereeColors.championshipGold),
          ),
        );

        if (isWide) {
          return Row(
            children: [
              Expanded(child: confirmButton),
              const SizedBox(width: 16),
              Expanded(child: leaderboardButton),
            ],
          );
        }

        return Column(
          children: [
            SizedBox(width: double.infinity, child: confirmButton),
            const SizedBox(height: 12),
            SizedBox(width: double.infinity, child: leaderboardButton),
          ],
        );
      },
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
          style: AppTypography.headlineSm(RefereeColors.onSurface)
              .copyWith(fontSize: 22),
        ),
        const SizedBox(height: 16),
        for (final result in results) ...[
          _ResultTile(result: result),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
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
            child: Text(
              '${result.rank}',
              style: AppTypography.headlineSm(
                result.isWinner
                    ? RefereeColors.championshipGold
                    : RefereeColors.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.eventName,
                  style: AppTypography.labelCaps(RefereeColors.onSurface)
                      .copyWith(fontSize: 14, letterSpacing: 0.2),
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
                  style: AppTypography.bodyMd(Colors.white.withValues(alpha: 0.8))
                      .copyWith(
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
