import 'package:flutter/material.dart';

import '../../constants/app_theme_tokens.dart';
import '../../constants/referee_colors.dart';
import '../../models/violation_record.dart';
import 'referee_glass_card.dart';

class RefereeViolationSummaryCard extends StatelessWidget {
  const RefereeViolationSummaryCard({super.key, required this.totalViolations});

  final int totalViolations;

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
              style: AppTypography.labelCaps(
                RefereeColors.onSurfaceVariant,
              ).copyWith(letterSpacing: 1.2),
            ),
            const SizedBox(height: 16),
            _StatBox(
              label: 'Tổng vi phạm đã ghi',
              value: '$totalViolations',
              valueColor: RefereeColors.statusRed,
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
            style: AppTypography.labelCaps(
              RefereeColors.onSurfaceVariant,
            ).copyWith(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTypography.displayMd(
              valueColor,
            ).copyWith(fontSize: 28, height: 1.1),
          ),
        ],
      ),
    );
  }
}

class RefereeViolationListPanel extends StatelessWidget {
  const RefereeViolationListPanel({super.key, required this.records});

  final List<ViolationRecordItem> records;

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
                    'Danh sách vi phạm',
                    style: AppTypography.bodyMd(
                      RefereeColors.onSurface,
                    ).copyWith(fontWeight: FontWeight.w700, fontSize: 18),
                  ),
                ),
                Text(
                  '${records.length}',
                  style: AppTypography.labelCaps(RefereeColors.tertiary),
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
                Divider(height: 1, color: Colors.white.withValues(alpha: 0.05)),
            ],
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
    final typeColor = record.severityHigh
        ? RefereeColors.statusRed
        : RefereeColors.tertiary;

    return Material(
      color: Colors.transparent,
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
                      Text(
                        record.raceLabel,
                        style: AppTypography.bodyMd(
                          RefereeColors.onSurfaceVariant,
                        ).copyWith(fontSize: 11),
                      ),
                      const SizedBox(height: 4),
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
              ],
            ),
            const SizedBox(height: 10),
            Text(
              record.note,
              style: AppTypography.labelCaps(RefereeColors.onSurfaceVariant)
                  .copyWith(
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w400,
                    height: 1.4,
                  ),
            ),
            if (record.penaltyText != null) ...[
              const SizedBox(height: 8),
              Text(
                'Xử phạt: ${record.penaltyText}',
                style: AppTypography.bodyMd(
                  RefereeColors.tertiary,
                ).copyWith(fontSize: 12),
              ),
            ],
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
                    color: typeColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    record.severityLabel.toUpperCase(),
                    style: AppTypography.labelCaps(
                      typeColor,
                    ).copyWith(fontSize: 10),
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
