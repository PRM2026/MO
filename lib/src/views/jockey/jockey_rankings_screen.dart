import 'package:flutter/material.dart';

import '../../constants/app_spacing.dart';
import '../../constants/app_theme_tokens.dart';
import '../../constants/referee_colors.dart';
import '../../services/api_client.dart';
import '../../widgets/jockey/jockey_app_bar.dart';
import '../../widgets/referee/referee_glass_card.dart';

class JockeyRankingsScreen extends StatefulWidget {
  const JockeyRankingsScreen({super.key, this.apiClient});

  final ApiClient? apiClient;

  @override
  State<JockeyRankingsScreen> createState() => _JockeyRankingsScreenState();
}

class _JockeyRankingsScreenState extends State<JockeyRankingsScreen> {
  late final ApiClient _apiClient;
  List<Map<String, dynamic>> _rankings = const [];
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _apiClient = widget.apiClient ?? ApiClient();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _apiClient.getObject(
        '/rankings',
        (json) => json,
        authenticated: false,
      );
      final jockeys = data['jockeys'];
      if (mounted) {
        setState(() {
          _rankings = jockeys is List
              ? jockeys.whereType<Map<String, dynamic>>().toList()
              : const [];
        });
      }
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RefereeColors.background,
      appBar: const JockeyAppBar(
        showBack: true,
        titleOverride: 'Bảng xếp hạng',
        showNotificationAction: false,
      ),
      body: _loading
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
                  AppSpacing.lg,
                  AppSpacing.md,
                  80,
                ),
                children: [
                  Text(
                    'JOCKEY XUẤT SẮC',
                    style: AppTypography.labelCaps(
                      RefereeColors.championshipGold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Xếp hạng theo thành tích thi đấu',
                    style: AppTypography.headlineSm(Colors.white),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  if (_error != null)
                    _StateCard(message: _error!, onRetry: _load)
                  else if (_rankings.isEmpty)
                    const _StateCard(message: 'Chưa có dữ liệu xếp hạng.')
                  else
                    for (var index = 0; index < _rankings.length; index++) ...[
                      _RankingCard(
                        rank: _int(_rankings[index]['rank'], index + 1),
                        data: _rankings[index],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                ],
              ),
            ),
    );
  }
}

class _RankingCard extends StatelessWidget {
  const _RankingCard({required this.rank, required this.data});

  final int rank;
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final medal = switch (rank) {
      1 => const Color(0xFFFFC928),
      2 => const Color(0xFFCBD5E1),
      3 => const Color(0xFFCD7F32),
      _ => RefereeColors.onSurfaceVariant,
    };
    return RefereeGlassCard(
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: medal.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: medal.withValues(alpha: 0.5)),
            ),
            child: Text(
              '#$rank',
              style: AppTypography.bodyMd(
                medal,
              ).copyWith(fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _text(
                    data['jockeyFullName'] ?? data['name'],
                    fallback: 'Jockey',
                  ),
                  style: AppTypography.bodyMd(
                    Colors.white,
                  ).copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  '${_int(data['wins'], 0)} thắng • '
                  '${_int(data['races'] ?? data['raceCount'], 0)} cuộc đua',
                  style: AppTypography.bodySm(RefereeColors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${_number(data['winRate'])}%',
                style: AppTypography.bodyMd(
                  const Color(0xFF6EE7B7),
                ).copyWith(fontWeight: FontWeight.w800),
              ),
              Text(
                'Tỷ lệ thắng',
                style: AppTypography.bodySm(RefereeColors.onSurfaceVariant),
              ),
            ],
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

int _int(Object? value, int fallback) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('$value') ?? fallback;
}

num _number(Object? value) {
  if (value is num) return value;
  return num.tryParse('$value') ?? 0;
}

String _text(Object? value, {required String fallback}) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? fallback : text;
}
