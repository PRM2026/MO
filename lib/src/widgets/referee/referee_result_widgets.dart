import 'package:flutter/material.dart';

import '../../constants/app_theme_tokens.dart';
import '../../constants/referee_colors.dart';
import '../../models/race_result_confirmation.dart';
import '../news/news_network_image.dart';
import 'referee_glass_card.dart';

class RefereeBreadcrumb extends StatelessWidget {
  const RefereeBreadcrumb({
    super.key,
    required this.raceCode,
  });

  final String raceCode;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4,
      runSpacing: 4,
      children: [
        _crumb('Quản lý', RefereeColors.onSurfaceVariant),
        const Icon(Icons.chevron_right, size: 14, color: RefereeColors.onSurfaceVariant),
        _crumb('Cuộc đua $raceCode', RefereeColors.onSurfaceVariant),
        const Icon(Icons.chevron_right, size: 14, color: RefereeColors.onSurfaceVariant),
        _crumb('Xác nhận Kết quả', RefereeColors.tertiary),
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

class RefereeResultsTable extends StatelessWidget {
  const RefereeResultsTable({super.key, required this.rows});

  final List<RaceFinisherRow> rows;

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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: RefereeColors.successEmerald.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: RefereeColors.successEmerald.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    'DỮ LIỆU TỰ ĐỘNG',
                    style: AppTypography.labelCaps(RefereeColors.successEmerald)
                        .copyWith(fontSize: 10),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.white.withValues(alpha: 0.1)),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: MediaQuery.sizeOf(context).width - 32,
              ),
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(
                  const Color(0x802C2A25),
                ),
                dataRowMinHeight: 72,
                dataRowMaxHeight: 88,
                columnSpacing: 24,
                horizontalMargin: 24,
                headingTextStyle: AppTypography.labelCaps(
                  RefereeColors.onSurfaceVariant,
                ).copyWith(fontSize: 11, letterSpacing: 0.8),
                columns: const [
                  DataColumn(label: Text('Hạng')),
                  DataColumn(label: Text('Vận động viên / Ngựa')),
                  DataColumn(label: Text('Thời gian')),
                  DataColumn(label: Text('Chênh lệch')),
                  DataColumn(label: Text('Thao tác')),
                ],
                rows: rows.map(_buildRow).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  DataRow _buildRow(RaceFinisherRow row) {
    return DataRow(
      cells: [
        DataCell(
          row.highlightRank
              ? Container(
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
                    '${row.rank}',
                    style: AppTypography.labelCaps(RefereeColors.tertiary)
                        .copyWith(fontWeight: FontWeight.w700),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Text(
                    '${row.rank}',
                    style: AppTypography.bodyMd(RefereeColors.onSurfaceVariant),
                  ),
                ),
        ),
        DataCell(
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: row.horseImageUrl != null
                      ? NewsNetworkImage(imageUrl: row.horseImageUrl!)
                      : ColoredBox(
                          color: const Color(0xFF37342F),
                          child: Icon(
                            Icons.pets,
                            color: RefereeColors.onSurfaceVariant,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    row.horseName,
                    style: AppTypography.labelCaps(RefereeColors.onSurface)
                        .copyWith(fontSize: 14, letterSpacing: 0.2),
                  ),
                  Text(
                    'Jockey: ${row.jockeyName}',
                    style: AppTypography.labelCaps(
                      RefereeColors.onSurfaceVariant,
                    ).copyWith(fontSize: 11, fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ],
          ),
        ),
        DataCell(
          Text(
            row.finishTime,
            style: AppTypography.bodyMd(
              row.highlightRank
                  ? RefereeColors.championshipGold
                  : RefereeColors.onSurface,
            ).copyWith(fontWeight: FontWeight.w500),
          ),
        ),
        DataCell(
          Text(
            row.gapLabel,
            style: AppTypography.bodyMd(
              row.gapIsPositive
                  ? RefereeColors.statusRed
                  : RefereeColors.onSurfaceVariant,
            ),
          ),
        ),
        DataCell(
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.edit_outlined,
              color: RefereeColors.onSurfaceVariant,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }
}

class RefereeAppliedViolationsCard extends StatelessWidget {
  const RefereeAppliedViolationsCard({
    super.key,
    required this.violations,
  });

  final List<AppliedViolationSummary> violations;

  @override
  Widget build(BuildContext context) {
    return RefereeGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: RefereeColors.statusRed),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'VI PHẠM & HÌNH PHẠT ĐÃ ÁP DỤNG',
                  style: AppTypography.labelCaps(RefereeColors.onSurface)
                      .copyWith(fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          for (final item in violations) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: RefereeColors.statusRed.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: RefereeColors.statusRed.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: RefereeColors.statusRed.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(Icons.block, color: RefereeColors.statusRed),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: AppTypography.labelCaps(RefereeColors.onSurface)
                              .copyWith(fontSize: 14, letterSpacing: 0.2),
                        ),
                        Text(
                          item.penaltyDescription,
                          style: AppTypography.labelCaps(
                            RefereeColors.onSurfaceVariant,
                          ).copyWith(fontSize: 11, fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.close,
                      color: RefereeColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                  style: BorderStyle.solid,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_circle_outline,
                    color: RefereeColors.onSurfaceVariant,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Thêm vi phạm thủ công',
                    style: AppTypography.labelCaps(
                      RefereeColors.onSurfaceVariant,
                    ).copyWith(fontWeight: FontWeight.w500),
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
                'ƯỚC TÍNH THƯỞNG GIẢI',
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
                  RichText(
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
                ],
              ),
              const SizedBox(height: 16),
              Divider(color: Colors.white.withValues(alpha: 0.1)),
              const SizedBox(height: 12),
              for (final row in breakdown) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      row.label,
                      style: AppTypography.bodySm(
                        RefereeColors.onSurfaceVariant,
                      ),
                    ),
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
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: RefereeColors.tertiary,
                  side: BorderSide(
                    color: RefereeColors.tertiary.withValues(alpha: 0.3),
                  ),
                  minimumSize: const Size.fromHeight(40),
                ),
                child: Text(
                  'Điều chỉnh tỷ lệ thưởng',
                  style: AppTypography.labelCaps(RefereeColors.tertiary)
                      .copyWith(fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class RefereeActivityTimeline extends StatelessWidget {
  const RefereeActivityTimeline({super.key, required this.entries});

  final List<ActivityLogEntry> entries;

  @override
  Widget build(BuildContext context) {
    return RefereeGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.history, color: RefereeColors.secondary),
              const SizedBox(width: 8),
              Text(
                'NHẬT KÝ ĐIỀU HÀNH',
                style: AppTypography.labelCaps(RefereeColors.onSurface)
                    .copyWith(fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...entries.map((entry) => _TimelineItem(entry: entry)),
        ],
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({required this.entry});

  final ActivityLogEntry entry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 24,
              child: Column(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: RefereeColors.portalSurface,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: entry.isActive
                            ? RefereeColors.tertiary
                            : Colors.white.withValues(alpha: 0.2),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: entry.isActive
                              ? RefereeColors.tertiary
                              : Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.timeLabel,
                    style: AppTypography.labelCaps(
                      RefereeColors.onSurfaceVariant,
                    ).copyWith(fontSize: 11),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    entry.message,
                    style: AppTypography.bodySm(RefereeColors.onSurface)
                        .copyWith(fontWeight: FontWeight.w500),
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
