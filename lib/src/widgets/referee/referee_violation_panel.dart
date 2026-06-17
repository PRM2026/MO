import 'package:flutter/material.dart';

import '../../constants/app_theme_tokens.dart';
import '../../constants/referee_colors.dart';
import '../../models/violation_record.dart';
import 'referee_glass_card.dart';

class RefereeViolationSummaryCard extends StatelessWidget {
  const RefereeViolationSummaryCard({
    super.key,
    required this.totalViolations,
    required this.pendingCount,
  });

  final int totalViolations;
  final int pendingCount;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: RefereeColors.glassFill,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(color: RefereeColors.statusRed, width: 4),
          top: BorderSide(color: RefereeColors.glassBorder),
          right: BorderSide(color: RefereeColors.glassBorder),
          bottom: BorderSide(color: RefereeColors.glassBorder),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TÓM TẮT CHẶNG ĐUA',
              style: AppTypography.labelCaps(RefereeColors.onSurfaceVariant)
                  .copyWith(letterSpacing: 1.2),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatBox(
                    label: 'Tổng vi phạm',
                    value: '$totalViolations',
                    valueColor: RefereeColors.statusRed,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatBox(
                    label: 'Đang chờ xử lý',
                    value: '$pendingCount',
                    valueColor: RefereeColors.tertiary,
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

class _StatBox extends StatelessWidget {
  const _StatBox({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.labelCaps(RefereeColors.onSurfaceVariant)
                .copyWith(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTypography.displayMd(valueColor)
                .copyWith(fontSize: 28, height: 1.1),
          ),
        ],
      ),
    );
  }
}

class RefereeViolationListPanel extends StatelessWidget {
  const RefereeViolationListPanel({
    super.key,
    required this.records,
    this.onViewAll,
  });

  final List<ViolationRecordItem> records;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    return RefereeGlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Danh sách đã ghi nhận',
                    style: AppTypography.bodyMd(RefereeColors.onSurface)
                        .copyWith(fontWeight: FontWeight.w700, fontSize: 18),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: RefereeColors.statusRed.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'THỬ NGHIỆM',
                    style: AppTypography.labelCaps(RefereeColors.statusRed)
                        .copyWith(fontSize: 10),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.white.withValues(alpha: 0.1)),
          if (records.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              child: Center(
                child: Text(
                  'Chưa có vi phạm nào được ghi nhận',
                  style: AppTypography.labelCaps(
                    RefereeColors.onSurfaceVariant,
                  ).copyWith(fontWeight: FontWeight.w400),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            for (var i = 0; i < records.length; i++) ...[
              RefereeViolationListTile(record: records[i]),
              if (i < records.length - 1)
                Divider(
                  height: 1,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
            ],
          Container(
            color: Colors.white.withValues(alpha: 0.05),
            padding: const EdgeInsets.all(16),
            child: Center(
              child: TextButton(
                onPressed: onViewAll,
                child: Text(
                  'XEM TẤT CẢ LỊCH SỬ',
                  style: AppTypography.labelCaps(RefereeColors.tertiary)
                      .copyWith(fontSize: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RefereeViolationListTile extends StatelessWidget {
  const RefereeViolationListTile({super.key, required this.record});

  final ViolationRecordItem record;

  @override
  Widget build(BuildContext context) {
    final typeColor =
        record.severityHigh ? RefereeColors.statusRed : RefereeColors.tertiary;
    final statusBg = record.status == ViolationReviewStatus.confirmed
        ? Colors.white.withValues(alpha: 0.1)
        : RefereeColors.tertiary.withValues(alpha: 0.2);
    final statusFg = record.status == ViolationReviewStatus.confirmed
        ? RefereeColors.onSurfaceVariant
        : RefereeColors.tertiary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: typeColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      record.severityHigh
                          ? Icons.warning_rounded
                          : Icons.report_outlined,
                      color: typeColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          record.horseLabel,
                          style: AppTypography.labelCaps(
                            RefereeColors.onSurface,
                          ).copyWith(fontSize: 14, letterSpacing: 0.2),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: typeColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                record.violationType,
                                style: AppTypography.bodyMd(typeColor).copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.visibility_outlined,
                    color: RefereeColors.onSurfaceVariant,
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                '"${record.note}"',
                style: AppTypography.labelCaps(
                  RefereeColors.onSurfaceVariant,
                ).copyWith(
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    record.timeLabel,
                    style: AppTypography.labelCaps(
                      Colors.white.withValues(alpha: 0.4),
                    ).copyWith(fontFeatures: const []),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      record.statusLabel.toUpperCase(),
                      style: AppTypography.labelCaps(statusFg)
                          .copyWith(fontSize: 10),
                    ),
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
