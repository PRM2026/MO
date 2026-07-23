import 'package:flutter/material.dart';

import '../../constants/app_spacing.dart';
import '../../constants/app_theme_tokens.dart';
import '../../constants/referee_colors.dart';
import '../../services/owner_dashboard_service.dart';
import '../../utils/currency_format.dart';
import '../../utils/date_format.dart';
import '../../widgets/owner/owner_app_bar.dart';
import '../../widgets/owner/owner_dashboard_widgets.dart';
import '../../widgets/referee/referee_glass_card.dart';

class OwnerResultsScreen extends StatefulWidget {
  const OwnerResultsScreen({super.key, this.service});

  final OwnerDashboardService? service;

  @override
  State<OwnerResultsScreen> createState() => _OwnerResultsScreenState();
}

class _OwnerResultsScreenState extends State<OwnerResultsScreen> {
  late final OwnerDashboardService _service;
  Map<String, dynamic>? _payload;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? OwnerDashboardService();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final payload = await _service.getOwnerResults();
      if (mounted) setState(() => _payload = payload);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final summary = _map(_payload?['summary']);
    final results = _list(_payload?['results']);
    return Scaffold(
      backgroundColor: RefereeColors.background,
      appBar: const OwnerAppBar(
        showBack: true,
        titleOverride: 'Kết quả thi đấu',
      ),
      body: OwnerPortalBackground(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(
                  color: RefereeColors.championshipGold,
                ),
              )
            : RefreshIndicator(
                color: RefereeColors.championshipGold,
                onRefresh: _load,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.md,
                    80,
                  ),
                  children: [
                    if (_error != null)
                      _StateCard(message: _error!, onRetry: _load)
                    else ...[
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: AppSpacing.sm,
                        crossAxisSpacing: AppSpacing.sm,
                        childAspectRatio: 1.35,
                        children: [
                          _Metric(
                            icon: Icons.emoji_events_outlined,
                            label: 'Tổng lần thắng',
                            value: '${_number(summary['totalWins'])}',
                          ),
                          _Metric(
                            icon: Icons.flag_outlined,
                            label: 'Race tham gia',
                            value: '${_number(summary['totalRaces'])}',
                          ),
                          _Metric(
                            icon: Icons.payments_outlined,
                            label: 'Tổng tiền thưởng',
                            value: formatVnd(_number(summary['totalPrize'])),
                          ),
                          _Metric(
                            icon: Icons.pets_outlined,
                            label: 'Ngựa tốt nhất',
                            value: _text(
                              summary['bestHorseName'],
                              fallback: '—',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Text(
                        'LỊCH SỬ KẾT QUẢ',
                        style: AppTypography.labelCaps(
                          RefereeColors.championshipGold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      if (results.isEmpty)
                        const _StateCard(
                          message: 'Chưa có kết quả thi đấu đã chốt.',
                        )
                      else
                        for (final result in results) ...[
                          _ResultCard(data: result),
                          const SizedBox(height: AppSpacing.sm),
                        ],
                    ],
                  ],
                ),
              ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return RefereeGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: RefereeColors.championshipGold),
          const Spacer(),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.headlineSm(Colors.white),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodySm(RefereeColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.data});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final position = _number(data['position']);
    final prize = _number(data['prize'] ?? data['prizeAmount']);
    return RefereeGlassCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: position == 1
                  ? RefereeColors.championshipGold.withValues(alpha: 0.18)
                  : Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: position == 1
                    ? RefereeColors.championshipGold
                    : Colors.white12,
              ),
            ),
            child: Text(
              '#${position == 0 ? '—' : position}',
              style: AppTypography.bodyMd(
                position == 1 ? RefereeColors.championshipGold : Colors.white,
              ).copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _text(data['horse'] ?? data['horseName'], fallback: 'Ngựa'),
                  style: AppTypography.bodyMd(
                    Colors.white,
                  ).copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  _text(data['race'] ?? data['raceName'], fallback: 'Cuộc đua'),
                  style: AppTypography.bodySm(RefereeColors.onSurfaceVariant),
                ),
                Text(
                  _text(data['tournament'] ?? data['tournamentName']),
                  style: AppTypography.bodySm(RefereeColors.onSurfaceVariant),
                ),
                if (data['date'] != null || data['finalizedAt'] != null)
                  Text(
                    formatDisplayDate('${data['date'] ?? data['finalizedAt']}'),
                    style: AppTypography.bodySm(RefereeColors.onSurfaceVariant),
                  ),
              ],
            ),
          ),
          Text(
            prize > 0 ? '+${formatVnd(prize)}' : '—',
            style: AppTypography.bodySm(
              const Color(0xFF6EE7B7),
            ).copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _StateCard extends StatelessWidget {
  const _StateCard({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return RefereeGlassCard(
      child: Column(
        children: [
          Text(message, textAlign: TextAlign.center),
          if (onRetry != null)
            TextButton(onPressed: onRetry, child: const Text('Thử lại')),
        ],
      ),
    );
  }
}

Map<String, dynamic> _map(Object? value) {
  return value is Map<String, dynamic> ? value : const {};
}

List<Map<String, dynamic>> _list(Object? value) {
  return value is List
      ? value.whereType<Map<String, dynamic>>().toList()
      : const [];
}

num _number(Object? value) {
  if (value is num) return value;
  return num.tryParse('$value') ?? 0;
}

String _text(Object? value, {String fallback = ''}) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? fallback : text;
}
