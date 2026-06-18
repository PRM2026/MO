import 'package:flutter/material.dart';

import '../../constants/app_theme_tokens.dart';
import '../../constants/referee_colors.dart';
import '../../models/race_result_confirmation.dart';
import 'referee_glass_card.dart';

class RefereeBreadcrumb extends StatelessWidget {
  const RefereeBreadcrumb({
    super.key,
    required this.raceCode,
    required this.raceName,
  });

  final String raceCode;
  final String raceName;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4,
      runSpacing: 4,
      children: [
        _crumb('Quản lý', RefereeColors.onSurfaceVariant),
        const Icon(
          Icons.chevron_right,
          size: 14,
          color: RefereeColors.onSurfaceVariant,
        ),
        _crumb('Cuộc đua $raceCode', RefereeColors.onSurfaceVariant),
        const Icon(
          Icons.chevron_right,
          size: 14,
          color: RefereeColors.onSurfaceVariant,
        ),
        _crumb(raceName, RefereeColors.tertiary),
      ],
    );
  }

  Widget _crumb(String text, Color color) {
    return Text(
      text,
      style: AppTypography.labelCaps(color).copyWith(
        fontWeight: FontWeight.w500,
        fontSize: 12,
      ),
    );
  }
}

class RefereeRaceSelector extends StatelessWidget {
  const RefereeRaceSelector({
    super.key,
    required this.races,
    required this.selectedRaceId,
    required this.onChanged,
  });

  final List<RefereeRaceOption> races;
  final int? selectedRaceId;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    if (races.isEmpty) return const SizedBox.shrink();

    return RefereeGlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          isExpanded: true,
          value: selectedRaceId,
          dropdownColor: RefereeColors.portalSurface,
          icon: const Icon(Icons.expand_more, color: RefereeColors.tertiary),
          items: races
              .map(
                (race) => DropdownMenuItem<int>(
                  value: race.id,
                  child: Text(
                    race.label,
                    style: AppTypography.bodyMd(RefereeColors.onSurface),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(growable: false),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class RefereeResultsTable extends StatelessWidget {
  const RefereeResultsTable({
    super.key,
    required this.rows,
    required this.isFinalized,
  });

  final List<RaceFinisherRow> rows;
  final bool isFinalized;

  @override
  Widget build(BuildContext context) {
    return RefereeGlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Icon(Icons.timer_outlined, color: RefereeColors.tertiary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'BẢNG KẾT QUẢ VỀ ĐÍCH',
                    style: AppTypography.labelCaps(RefereeColors.onSurface)
                        .copyWith(fontSize: 14),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (isFinalized
                            ? RefereeColors.successEmerald
                            : RefereeColors.tertiary)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: (isFinalized
                              ? RefereeColors.successEmerald
                              : RefereeColors.tertiary)
                          .withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    isFinalized ? 'ĐÃ CHỐT' : 'CHƯA CHỐT',
                    style: AppTypography.labelCaps(
                      isFinalized
                          ? RefereeColors.successEmerald
                          : RefereeColors.tertiary,
                    ).copyWith(fontSize: 10),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.white.withValues(alpha: 0.1)),
          if (rows.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
              child: Center(
                child: Text(
                  'Chưa có dữ liệu kết quả',
                  style: AppTypography.labelCaps(
                    RefereeColors.onSurfaceVariant,
                  ).copyWith(fontWeight: FontWeight.w400),
                ),
              ),
            )
          else
            ...rows.map(
              (row) => _ResultListTile(row: row, showDivider: row != rows.last),
            ),
        ],
      ),
    );
  }
}

class _ResultListTile extends StatelessWidget {
  const _ResultListTile({required this.row, required this.showDivider});

  final RaceFinisherRow row;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final typeColor = row.highlightRank
        ? RefereeColors.championshipGold
        : RefereeColors.onSurface;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _RankBadge(rank: row.rank, highlight: row.highlightRank),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      row.horseName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.labelCaps(RefereeColors.onSurface)
                          .copyWith(fontSize: 14, letterSpacing: 0.2),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      row.jockeyName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.labelCaps(
                        RefereeColors.onSurfaceVariant,
                      ).copyWith(fontSize: 11, fontWeight: FontWeight.w400),
                    ),
                    if (row.statusLabel != null &&
                        row.statusLabel != 'Về đích') ...[
                      const SizedBox(height: 4),
                      Text(
                        row.statusLabel!,
                        style: AppTypography.labelCaps(RefereeColors.statusRed)
                            .copyWith(fontSize: 10),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    row.finishTime,
                    style: AppTypography.bodyMd(typeColor).copyWith(
                      fontWeight: FontWeight.w600,
                      fontFeatures: const [],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    row.gapLabel,
                    style: AppTypography.labelCaps(
                      row.gapIsPositive
                          ? RefereeColors.statusRed
                          : RefereeColors.onSurfaceVariant,
                    ).copyWith(fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(height: 1, color: Colors.white.withValues(alpha: 0.05)),
      ],
    );
  }
}

class _RankBadge extends StatelessWidget {
  const _RankBadge({required this.rank, required this.highlight});

  final int? rank;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final label = rank?.toString() ?? '—';

    if (highlight) {
      return Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: RefereeColors.tertiary.withValues(alpha: 0.2),
          shape: BoxShape.circle,
          border: Border.all(
            color: RefereeColors.tertiary.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: AppTypography.labelCaps(RefereeColors.tertiary)
              .copyWith(fontWeight: FontWeight.w700),
        ),
      );
    }

    return SizedBox(
      width: 32,
      height: 32,
      child: Center(
        child: Text(
          label,
          style: AppTypography.bodyMd(RefereeColors.onSurfaceVariant),
        ),
      ),
    );
  }
}

class RefereePrizePreviewCard extends StatelessWidget {
  const RefereePrizePreviewCard({
    super.key,
    required this.totalPrizePool,
    required this.breakdown,
  });

  final String totalPrizePool;
  final List<PrizeBreakdownRow> breakdown;

  @override
  Widget build(BuildContext context) {
    return RefereeGlassCard(
      child: Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            child: Icon(
              Icons.stars,
              size: 96,
              color: RefereeColors.tertiary.withValues(alpha: 0.1),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CƠ CẤU GIẢI THƯỞNG',
                style: AppTypography.labelCaps(RefereeColors.tertiary)
                    .copyWith(letterSpacing: 1.2),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Tổng quỹ thưởng:',
                    style: AppTypography.labelCaps(
                      RefereeColors.onSurfaceVariant,
                    ).copyWith(fontWeight: FontWeight.w500),
                  ),
                  Flexible(
                    child: RichText(
                      textAlign: TextAlign.end,
                      text: TextSpan(
                        style: AppTypography.headlineSm(RefereeColors.onSurface)
                            .copyWith(fontWeight: FontWeight.w700),
                        children: [
                          TextSpan(text: totalPrizePool),
                          TextSpan(
                            text: ' VND',
                            style: AppTypography.bodyMd(
                              RefereeColors.onSurfaceVariant,
                            ).copyWith(fontWeight: FontWeight.w400),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (breakdown.isNotEmpty) ...[
                const SizedBox(height: 16),
                Divider(color: Colors.white.withValues(alpha: 0.1)),
                const SizedBox(height: 12),
                for (final row in breakdown) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          row.label,
                          style: AppTypography.bodySm(
                            RefereeColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        row.amount,
                        style: AppTypography.bodySm(
                          row.highlight
                              ? RefereeColors.championshipGold
                              : RefereeColors.onSurface,
                        ).copyWith(
                          fontWeight:
                              row.highlight ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ] else ...[
                const SizedBox(height: 12),
                Text(
                  'Chưa có thông tin giải thưởng',
                  style: AppTypography.bodySm(RefereeColors.onSurfaceVariant),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class RefereeInfoBanner extends StatelessWidget {
  const RefereeInfoBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: RefereeColors.tertiary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: RefereeColors.tertiary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: RefereeColors.tertiary,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: AppTypography.labelCaps(RefereeColors.tertiary).copyWith(
                fontWeight: FontWeight.w400,
                height: 1.5,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<bool?> showRefereeConfirmResultDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.6),
    builder: (context) => const _ConfirmResultDialog(),
  );
}

class _ConfirmResultDialog extends StatelessWidget {
  const _ConfirmResultDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: RefereeGlassCard(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: RefereeColors.tertiary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.verified,
                color: RefereeColors.tertiary,
                size: 36,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Xác nhận chốt kết quả?',
              textAlign: TextAlign.center,
              style: AppTypography.headlineSm(RefereeColors.onSurface)
                  .copyWith(fontSize: 22),
            ),
            const SizedBox(height: 8),
            Text(
              'Hành động này sẽ chính thức ghi nhận kết quả vào hệ thống và kích hoạt quy trình giải ngân tiền thưởng. Bạn không thể hoàn tác sau khi xác nhận.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMd(RefereeColors.onSurfaceVariant),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: RefereeColors.onSurface,
                      side: const BorderSide(color: RefereeColors.outlineVariant),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Hủy bỏ'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: FilledButton.styleFrom(
                      backgroundColor: RefereeColors.championshipGold,
                      foregroundColor: RefereeColors.portalSurface,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'Đồng ý Chốt',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
