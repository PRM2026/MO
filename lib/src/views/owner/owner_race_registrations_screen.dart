import 'package:flutter/material.dart';

import '../../constants/app_spacing.dart';
import '../../constants/app_theme_tokens.dart';
import '../../constants/referee_colors.dart';
import '../../models/owner_race_registration.dart';
import '../../repositories/owner_race_registration_repository.dart';
import '../../utils/app_toast.dart';
import '../../utils/currency_format.dart';
import '../../utils/date_format.dart';
import '../../widgets/owner/owner_app_bar.dart';
import '../../widgets/owner/owner_dashboard_widgets.dart';
import '../../widgets/referee/referee_glass_card.dart';

class OwnerRaceRegistrationsScreen extends StatefulWidget {
  const OwnerRaceRegistrationsScreen({super.key});

  @override
  State<OwnerRaceRegistrationsScreen> createState() =>
      _OwnerRaceRegistrationsScreenState();
}

class _OwnerRaceRegistrationsScreenState
    extends State<OwnerRaceRegistrationsScreen> {
  final _repository = OwnerRaceRegistrationRepository();
  List<OwnerRaceRegistration> _items = const [];
  bool _loading = true;
  String? _error;
  String _filter = 'ALL';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await _repository.fetchRegistrations();
      items.sort((a, b) => _compareDate(b.createdAt, a.createdAt));
      if (mounted) setState(() => _items = items);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<OwnerRaceRegistration> get _filtered => _filter == 'ALL'
      ? _items
      : _items.where((item) => item.statusCode == _filter).toList();

  Future<void> _withdraw(OwnerRaceRegistration item) async {
    final note = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rút đăng ký'),
        content: TextField(
          controller: note,
          maxLength: 1000,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Lý do (không bắt buộc)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Giữ đăng ký'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Xác nhận rút'),
          ),
        ],
      ),
    );
    final value = note.text;
    note.dispose();
    if (confirmed != true) return;
    try {
      await _repository.withdrawRegistration(
        item.id,
        OwnerRaceRegistrationWithdrawData(note: value),
      );
      if (!mounted) return;
      AppToast.showSuccess(context, 'Đã rút đăng ký.');
      await _load();
    } catch (error) {
      if (mounted) AppToast.showError(context, error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RefereeColors.background,
      appBar: const OwnerAppBar(
        showBack: true,
        titleOverride: 'Đăng ký cuộc đua',
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
                  padding: const EdgeInsets.all(AppSpacing.md),
                  children: [
                    Wrap(
                      spacing: AppSpacing.sm,
                      children: [
                        for (final entry in const {
                          'ALL': 'Tất cả',
                          'PENDING': 'Chờ duyệt',
                          'APPROVED': 'Đã duyệt',
                          'REJECTED': 'Từ chối',
                          'WITHDRAWN': 'Đã rút',
                        }.entries)
                          ChoiceChip(
                            label: Text(entry.value),
                            selected: _filter == entry.key,
                            onSelected: (_) =>
                                setState(() => _filter = entry.key),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    if (_error != null)
                      _StateCard(message: _error!, onRetry: _load)
                    else if (_filtered.isEmpty)
                      const _StateCard(message: 'Chưa có đăng ký cuộc đua.')
                    else
                      for (final item in _filtered) ...[
                        _RegistrationCard(
                          item: item,
                          onWithdraw: item.isPending
                              ? () => _withdraw(item)
                              : null,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                      ],
                  ],
                ),
              ),
      ),
    );
  }
}

class _RegistrationCard extends StatelessWidget {
  const _RegistrationCard({required this.item, this.onWithdraw});

  final OwnerRaceRegistration item;
  final VoidCallback? onWithdraw;

  @override
  Widget build(BuildContext context) {
    return RefereeGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.raceName ?? 'Cuộc đua #${item.raceId}',
                  style: AppTypography.headlineSm(RefereeColors.onSurface),
                ),
              ),
              Text(
                item.statusLabel,
                style: AppTypography.labelCaps(RefereeColors.championshipGold),
              ),
            ],
          ),
          Text(
            item.tournamentName ?? 'Giải đấu',
            style: AppTypography.bodySm(RefereeColors.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Ngựa: ${item.horseName ?? '#${item.horseId}'}'),
          Text('Jockey: ${item.jockeyUsername ?? '#${item.jockeyId}'}'),
          Text('Phí tham gia: ${formatVnd(item.entryFeeAmount ?? 0)}'),
          Text(
            'Ngày gửi: ${formatDisplayDateTime(item.createdAt?.toIso8601String())}',
          ),
          if (item.reviewNote?.isNotEmpty == true)
            Text('Phản hồi: ${item.reviewNote}'),
          if (onWithdraw != null) ...[
            const SizedBox(height: AppSpacing.md),
            OutlinedButton.icon(
              onPressed: onWithdraw,
              icon: const Icon(Icons.undo),
              label: const Text('Rút đăng ký'),
            ),
          ],
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

int _compareDate(DateTime? left, DateTime? right) {
  if (left == null && right == null) return 0;
  if (left == null) return -1;
  if (right == null) return 1;
  return left.compareTo(right);
}
