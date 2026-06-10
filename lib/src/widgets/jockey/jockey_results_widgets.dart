import 'package:flutter/material.dart';

import '../../constants/app_theme_tokens.dart';
import '../../constants/referee_colors.dart';
import '../../models/jockey_results_data.dart';
import '../news/news_network_image.dart';
import '../referee/referee_glass_card.dart';

class JockeyResultsHeaderActions extends StatelessWidget {
  const JockeyResultsHeaderActions({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 640;

        final filterButton = OutlinedButton.icon(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            foregroundColor: RefereeColors.onSurface,
            backgroundColor: RefereeColors.surfaceContainer,
            side: BorderSide.none,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          icon: const Icon(Icons.calendar_today_outlined, size: 20),
          label: const Text('30 ngày qua'),
        );

        final exportButton = FilledButton.icon(
          onPressed: () {},
          style: FilledButton.styleFrom(
            backgroundColor: RefereeColors.championshipGold,
            foregroundColor: RefereeColors.onTertiary,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          icon: const Icon(Icons.download_outlined, size: 20),
          label: const Text('Xuất PDF'),
        );

        if (isWide) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              filterButton,
              const SizedBox(width: 8),
              exportButton,
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            filterButton,
            const SizedBox(height: 8),
            exportButton,
          ],
        );
      },
    );
  }
}

class JockeyResultsStatsGrid extends StatelessWidget {
  const JockeyResultsStatsGrid({super.key, required this.stats});

  final List<JockeyResultsStatItem> stats;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 640 ? 4 : 2;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: crossAxisCount == 4 ? 1.1 : 0.95,
          ),
          itemCount: stats.length,
          itemBuilder: (context, index) =>
              _StatTile(stat: stats[index]),
        );
      },
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.stat});

  final JockeyResultsStatItem stat;

  @override
  Widget build(BuildContext context) {
    return RefereeGlassCard(
      padding: const EdgeInsets.all(20),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: stat.accentColor, width: 4),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(stat.icon, color: stat.accentColor.withValues(alpha: 0.5)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stat.label.toUpperCase(),
                    style: AppTypography.labelCaps(
                      RefereeColors.onSurfaceVariant,
                    ).copyWith(fontSize: 11),
                  ),
                  Text(
                    stat.value,
                    style: AppTypography.headlineSm(
                      stat.highlightValue
                          ? RefereeColors.championshipGold
                          : RefereeColors.onSurface,
                    ).copyWith(fontSize: 22),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class JockeyPerformanceChartCard extends StatelessWidget {
  const JockeyPerformanceChartCard({
    super.key,
    required this.heights,
    required this.trendLabel,
  });

  final List<double> heights;
  final String trendLabel;

  @override
  Widget build(BuildContext context) {
    return RefereeGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: RefereeColors.tertiary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Vận tốc thi đua',
                        style: AppTypography.labelCaps(RefereeColors.onSurface)
                            .copyWith(fontSize: 14, letterSpacing: 0.2),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                trendLabel,
                style: AppTypography.labelCaps(RefereeColors.onSurfaceVariant)
                    .copyWith(fontWeight: FontWeight.w400),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 128,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < heights.length; i++) ...[
                  if (i > 0) const SizedBox(width: 4),
                  Expanded(
                    child: _ChartBar(
                      heightFactor: heights[i],
                      highlighted: i == 3,
                    ),
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

class _ChartBar extends StatelessWidget {
  const _ChartBar({
    required this.heightFactor,
    this.highlighted = false,
  });

  final double heightFactor;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxHeight = constraints.maxHeight;
        return Align(
          alignment: Alignment.bottomCenter,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            height: maxHeight * heightFactor,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: highlighted
                    ? [
                        RefereeColors.tertiary.withValues(alpha: 0.2),
                        RefereeColors.tertiary,
                      ]
                    : [
                        RefereeColors.secondary.withValues(alpha: 0.2),
                        RefereeColors.secondary.withValues(alpha: 0.6),
                      ],
              ),
              boxShadow: highlighted
                  ? [
                      BoxShadow(
                        color: RefereeColors.tertiary.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, -4),
                      ),
                    ]
                  : null,
            ),
          ),
        );
      },
    );
  }
}

class JockeyFeaturedHorsePanel extends StatelessWidget {
  const JockeyFeaturedHorsePanel({super.key, required this.horse});

  final JockeyFeaturedHorseCard horse;

  @override
  Widget build(BuildContext context) {
    return RefereeGlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: SizedBox(
              height: 256,
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
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: RefereeColors.tertiary,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        horse.badgeLabel,
                        style: AppTypography.labelCaps(RefereeColors.onTertiary)
                            .copyWith(fontSize: 11, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  horse.name,
                  style: AppTypography.headlineSm(RefereeColors.onSurface)
                      .copyWith(fontSize: 22),
                ),
                Text(
                  horse.subtitle,
                  style: AppTypography.bodyMd(
                    RefereeColors.onSurfaceVariant,
                  ).copyWith(fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _MiniStat(
                        label: 'Tỉ lệ thắng',
                        value: horse.winRate,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _MiniStat(
                        label: 'Tốc độ tối đa',
                        value: horse.topSpeed,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: RefereeColors.tertiary,
                    side: BorderSide(
                      color: RefereeColors.tertiary.withValues(alpha: 0.3),
                    ),
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: const Text('Xem phân tích chi tiết'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: AppTypography.labelCaps(RefereeColors.onSurfaceVariant)
                .copyWith(fontSize: 10),
          ),
          Text(
            value,
            style: AppTypography.labelCaps(RefereeColors.tertiary)
                .copyWith(fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class JockeyResultsHistorySection extends StatelessWidget {
  const JockeyResultsHistorySection({
    super.key,
    required this.results,
    required this.totalResults,
  });

  final List<JockeyRaceResultItem> results;
  final int totalResults;

  @override
  Widget build(BuildContext context) {
    return RefereeGlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              border: Border(
                bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Lịch sử kết quả',
                    style: AppTypography.headlineSm(RefereeColors.onSurface)
                        .copyWith(fontSize: 22),
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.filter_list,
                    color: RefereeColors.onSurfaceVariant,
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.refresh,
                    color: RefereeColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth >= 768) {
                return _ResultsTable(results: results);
              }
              return _ResultsMobileList(results: results);
            },
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.02),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Hiển thị ${results.length} / $totalResults cuộc đua',
                    style: AppTypography.labelCaps(RefereeColors.onSurfaceVariant)
                        .copyWith(fontWeight: FontWeight.w400),
                  ),
                ),
                IconButton(
                  onPressed: null,
                  icon: Icon(
                    Icons.navigate_before,
                    color: RefereeColors.onSurfaceVariant.withValues(alpha: 0.3),
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.navigate_next,
                    color: RefereeColors.onSurfaceVariant,
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

class _ResultsTable extends StatelessWidget {
  const _ResultsTable({required this.results});

  final List<JockeyRaceResultItem> results;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: MediaQuery.sizeOf(context).width - 32,
        ),
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(Colors.transparent),
          columnSpacing: 24,
          horizontalMargin: 24,
          headingTextStyle: AppTypography.labelCaps(RefereeColors.onSurfaceVariant)
              .copyWith(fontSize: 11, letterSpacing: 0.8),
          columns: const [
            DataColumn(label: Text('Giải đấu / Cuộc đua')),
            DataColumn(label: Text('Chiến mã & Jockey')),
            DataColumn(label: Text('Thứ hạng')),
            DataColumn(label: Text('Thời gian')),
            DataColumn(label: Text('Tiền thưởng')),
            DataColumn(label: Text('')),
          ],
          rows: results.map((item) {
            return DataRow(
              cells: [
                DataCell(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item.eventName,
                        style: AppTypography.labelCaps(RefereeColors.onSurface)
                            .copyWith(fontSize: 14, letterSpacing: 0.2),
                      ),
                      Text(
                        item.trackInfo,
                        style: AppTypography.labelCaps(RefereeColors.onSurfaceVariant)
                            .copyWith(fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                ),
                DataCell(
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: item.rankColor.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.pets,
                          size: 18,
                          color: item.rankColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(item.horseName),
                          Text(
                            'Jockey: ${item.jockeyName}',
                            style: AppTypography.labelCaps(RefereeColors.onSurfaceVariant)
                                .copyWith(fontWeight: FontWeight.w400),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                DataCell(_RankBadge(item: item)),
                DataCell(Text(item.finishTime)),
                DataCell(
                  Text(
                    item.prizeAmount,
                    style: AppTypography.bodySm(RefereeColors.tertiary),
                  ),
                ),
                DataCell(
                  Icon(Icons.chevron_right, color: RefereeColors.onSurfaceVariant),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _ResultsMobileList extends StatelessWidget {
  const _ResultsMobileList({required this.results});

  final List<JockeyRaceResultItem> results;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < results.length; i++) ...[
          Padding(
            padding: const EdgeInsets.all(24),
            child: _MobileResultTile(item: results[i]),
          ),
          if (i < results.length - 1)
            Divider(height: 1, color: Colors.white.withValues(alpha: 0.05)),
        ],
      ],
    );
  }
}

class _MobileResultTile extends StatelessWidget {
  const _MobileResultTile({required this.item});

  final JockeyRaceResultItem item;

  @override
  Widget build(BuildContext context) {
    return Column(
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
                    item.eventName,
                    style: AppTypography.labelCaps(RefereeColors.onSurface)
                        .copyWith(fontSize: 14, letterSpacing: 0.2),
                  ),
                  Text(
                    item.trackInfo,
                    style: AppTypography.labelCaps(RefereeColors.onSurfaceVariant)
                        .copyWith(fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ),
            _RankBadge(item: item),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Icon(Icons.pets_outlined, size: 18, color: RefereeColors.onSurfaceVariant),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                item.horseName,
                style: AppTypography.bodyMd(RefereeColors.onSurface),
              ),
            ),
            Text(
              item.prizeAmount,
              style: AppTypography.bodySm(RefereeColors.tertiary),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Thời gian: ${item.finishTime} | Jockey: ${item.jockeyName}',
          style: AppTypography.labelCaps(RefereeColors.onSurfaceVariant)
              .copyWith(fontWeight: FontWeight.w400),
        ),
      ],
    );
  }
}

class _RankBadge extends StatelessWidget {
  const _RankBadge({required this.item});

  final JockeyRaceResultItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: item.rankColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: item.rankColor.withValues(alpha: 0.2)),
      ),
      child: Text(
        item.rankLabel,
        style: AppTypography.labelCaps(item.rankColor)
            .copyWith(fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }
}
