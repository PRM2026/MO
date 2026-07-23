import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../constants/app_spacing.dart';
import '../../constants/app_theme_tokens.dart';
import '../../constants/referee_colors.dart';
import '../../models/betting_models.dart';
import '../../utils/app_toast.dart';
import '../../utils/currency_format.dart';
import '../../utils/date_format.dart';
import '../../viewmodels/spectator_betting_viewmodel.dart';
import '../../widgets/spectator/spectator_app_bar.dart';
import '../../widgets/spectator/spectator_glass_card.dart';

class SpectatorBettingScreen extends StatefulWidget {
  const SpectatorBettingScreen({super.key, this.viewModel});

  final SpectatorBettingViewModel? viewModel;

  @override
  State<SpectatorBettingScreen> createState() => _SpectatorBettingScreenState();
}

class _SpectatorBettingScreenState extends State<SpectatorBettingScreen> {
  late final SpectatorBettingViewModel _viewModel;
  late final bool _ownsViewModel;
  final _stake = TextEditingController();
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    _ownsViewModel = widget.viewModel == null;
    _viewModel = widget.viewModel ?? SpectatorBettingViewModel();
    _viewModel.addListener(_onChanged);
    _viewModel.load();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  void _selectMarket(BetMarket market) {
    _viewModel.selectMarket(market.id);
    _stake.text = market.minStake > 0 ? market.minStake.toStringAsFixed(0) : '';
  }

  Future<void> _placeBet() async {
    final success = await _viewModel.placeBet(_stake.text);
    if (!mounted) return;
    if (success) {
      AppToast.showSuccess(context, 'Đặt cược thành công.');
      setState(() => _tab = 1);
      return;
    }
    AppToast.showError(
      context,
      _viewModel.mutationError ?? 'Đặt cược thất bại.',
    );
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onChanged);
    if (_ownsViewModel) _viewModel.dispose();
    _stake.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RefereeColors.background,
      appBar: const SpectatorAppBar(
        titleOverride: 'Đặt cược',
        showProfileAvatar: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: SegmentedButton<int>(
              segments: const [
                ButtonSegment(
                  value: 0,
                  icon: Icon(Icons.sports_score_outlined),
                  label: Text('Kèo cược'),
                ),
                ButtonSegment(
                  value: 1,
                  icon: Icon(Icons.history),
                  label: Text('Lịch sử'),
                ),
              ],
              selected: {_tab},
              onSelectionChanged: (value) => setState(() => _tab = value.first),
            ),
          ),
          Expanded(
            child: _viewModel.isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: RefereeColors.championshipGold,
                    ),
                  )
                : RefreshIndicator(
                    color: RefereeColors.championshipGold,
                    onRefresh: _viewModel.load,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.screenPadding,
                        AppSpacing.md,
                        AppSpacing.screenPadding,
                        80,
                      ),
                      children: [
                        if (_viewModel.errorMessage != null)
                          _EmptyCard(
                            message: _viewModel.errorMessage!,
                            onRetry: _viewModel.load,
                          )
                        else if (_tab == 0)
                          _buildMarketTab()
                        else
                          _BetHistory(bets: _viewModel.bets),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketTab() {
    if (_viewModel.markets.isEmpty) {
      return const _EmptyCard(
        message: 'Hiện chưa có cuộc đua nào đang mở cược.',
      );
    }
    final selected = _viewModel.selectedMarket;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'KÈO ĐANG MỞ',
          style: AppTypography.labelCaps(RefereeColors.championshipGold),
        ),
        const SizedBox(height: AppSpacing.sm),
        for (final market in _viewModel.markets) ...[
          _MarketTile(
            market: market,
            selected: selected?.id == market.id,
            onTap: () => _selectMarket(market),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        if (selected != null) ...[
          const SizedBox(height: AppSpacing.md),
          SpectatorGlassCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  selected.raceName,
                  style: AppTypography.headlineSm(Colors.white),
                ),
                Text(
                  selected.tournamentName,
                  style: AppTypography.bodySm(
                    Colors.white.withValues(alpha: 0.55),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'CHỌN NGỰA',
                  style: AppTypography.labelCaps(
                    RefereeColors.championshipGold,
                  ),
                ),
                for (final option in selected.options)
                  ListTile(
                    onTap: () =>
                        _viewModel.selectParticipant(option.participantId),
                    leading: Icon(
                      _viewModel.selectedParticipantId == option.participantId
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color:
                          _viewModel.selectedParticipantId ==
                              option.participantId
                          ? RefereeColors.championshipGold
                          : RefereeColors.onSurfaceVariant,
                    ),
                    title: Text(option.horseName),
                    subtitle: Text(
                      'Ô ${option.gateNumber ?? '—'} • '
                      '${option.jockeyUsername ?? 'Chưa có jockey'}',
                    ),
                  ),
                if (selected.options.isEmpty)
                  const Text('Kèo này chưa có ngựa hợp lệ.'),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  key: const Key('spectator-bet-stake'),
                  controller: _stake,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Số tiền cược (VND)',
                    helperText:
                        '${formatVnd(selected.minStake)} – '
                        '${formatVnd(selected.maxStake)}',
                    border: const OutlineInputBorder(),
                  ),
                ),
                if (_viewModel.mutationError != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    _viewModel.mutationError!,
                    style: const TextStyle(color: RefereeColors.statusRed),
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                FilledButton.icon(
                  key: const Key('spectator-place-bet'),
                  onPressed:
                      _viewModel.isSubmitting ||
                          !selected.isOpen ||
                          selected.options.isEmpty
                      ? null
                      : _placeBet,
                  icon: const Icon(Icons.paid_outlined),
                  label: Text(
                    _viewModel.isSubmitting
                        ? 'Đang đặt cược...'
                        : 'Xác nhận đặt cược',
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _MarketTile extends StatelessWidget {
  const _MarketTile({
    required this.market,
    required this.selected,
    required this.onTap,
  });

  final BetMarket market;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SpectatorGlassCard(
      accentBorder: selected,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        onTap: onTap,
        leading: const Icon(
          Icons.emoji_events_outlined,
          color: RefereeColors.championshipGold,
        ),
        title: Text(market.raceName),
        subtitle: Text(market.tournamentName),
        trailing: Text('${market.options.length} ngựa'),
      ),
    );
  }
}

class _BetHistory extends StatelessWidget {
  const _BetHistory({required this.bets});

  final List<BetRecord> bets;

  @override
  Widget build(BuildContext context) {
    if (bets.isEmpty) {
      return const _EmptyCard(message: 'Bạn chưa có lệnh đặt cược nào.');
    }
    return Column(
      children: [
        for (final bet in bets) ...[
          SpectatorGlassCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        bet.raceName,
                        style: AppTypography.bodyMd(Colors.white),
                      ),
                    ),
                    Text(
                      _statusLabel(bet.status),
                      style: AppTypography.labelCaps(
                        bet.status == 'WON'
                            ? RefereeColors.successEmerald
                            : RefereeColors.championshipGold,
                      ),
                    ),
                  ],
                ),
                Text(
                  bet.horseName,
                  style: AppTypography.bodySm(
                    Colors.white.withValues(alpha: 0.55),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Tiền cược: ${formatVnd(bet.stakeAmount)}',
                  style: AppTypography.bodyMd(Colors.white),
                ),
                Text(
                  'Có thể nhận: ${formatVnd(bet.potentialPayoutAmount)}',
                  style: AppTypography.bodyMd(RefereeColors.championshipGold),
                ),
                Text(
                  formatDisplayDateTime(bet.placedAt?.toIso8601String()),
                  style: AppTypography.bodySm(
                    Colors.white.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return SpectatorGlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTypography.bodyMd(Colors.white),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: AppSpacing.md),
            OutlinedButton(onPressed: onRetry, child: const Text('Thử lại')),
          ],
        ],
      ),
    );
  }
}

String _statusLabel(String status) {
  return switch (status) {
    'PENDING' => 'Đang chờ',
    'WON' => 'Thắng cược',
    'LOST' => 'Thua cược',
    'CANCELLED' => 'Đã hủy',
    'REFUNDED' => 'Đã hoàn tiền',
    'SETTLED' => 'Đã chốt',
    _ => status,
  };
}
