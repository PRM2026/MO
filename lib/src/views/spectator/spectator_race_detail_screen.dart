import 'package:flutter/material.dart';

import '../../constants/app_spacing.dart';
import '../../constants/referee_colors.dart';
import '../../models/spectator_models.dart';
import '../../viewmodels/spectator_race_detail_viewmodel.dart';
import '../../widgets/spectator/spectator_app_bar.dart';
import '../../widgets/spectator/spectator_glass_card.dart';

class SpectatorRaceDetailScreen extends StatefulWidget {
  const SpectatorRaceDetailScreen({
    super.key,
    required this.raceId,
    this.tournamentId,
    this.viewModel,
  });

  final String raceId;
  final String? tournamentId;
  final SpectatorRaceDetailViewModel? viewModel;

  @override
  State<SpectatorRaceDetailScreen> createState() =>
      _SpectatorRaceDetailScreenState();
}

class _SpectatorRaceDetailScreenState extends State<SpectatorRaceDetailScreen> {
  late final SpectatorRaceDetailViewModel _viewModel;
  late final bool _ownsViewModel;

  @override
  void initState() {
    super.initState();
    _ownsViewModel = widget.viewModel == null;
    _viewModel =
        widget.viewModel ??
        SpectatorRaceDetailViewModel(
          raceId: widget.raceId,
          tournamentId: widget.tournamentId,
        );
    _viewModel.load();
  }

  @override
  void dispose() {
    if (_ownsViewModel) {
      _viewModel.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _viewModel,
      builder: (context, _) {
        final detail = _viewModel.data;

        return Scaffold(
          backgroundColor: RefereeColors.background,
          appBar: const SpectatorAppBar(
            titleOverride: 'Chi tiet cuoc dua',
            showProfileAvatar: false,
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenPadding,
              AppSpacing.lg,
              AppSpacing.screenPadding,
              120,
            ),
            children: [
              if (_viewModel.isLoading)
                const _DetailLoadingState()
              else if (_viewModel.errorMessage != null)
                _DetailErrorState(
                  message: _viewModel.errorMessage!,
                  onRetry: _viewModel.retry,
                )
              else if (detail != null)
                _RaceDetailContent(detail: detail)
              else
                const _DetailEmptyState(),
            ],
          ),
        );
      },
    );
  }
}

class _RaceDetailContent extends StatelessWidget {
  const _RaceDetailContent({required this.detail});

  final SpectatorRaceDetail detail;

  @override
  Widget build(BuildContext context) {
    final race = detail.race;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SpectatorGlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                race.statusLabel.toUpperCase(),
                style: const TextStyle(
                  color: RefereeColors.championshipGold,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                race.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                race.tournamentName,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.65)),
              ),
              const SizedBox(height: 20),
              _DetailInfoRow(
                icon: Icons.schedule,
                label: 'Gio',
                value: race.time,
              ),
              _DetailInfoRow(
                icon: Icons.location_on_outlined,
                label: 'Dia diem',
                value: race.venue,
              ),
              _DetailInfoRow(
                icon: Icons.straighten,
                label: 'Cu ly',
                value: race.distance,
              ),
              _DetailInfoRow(
                icon: Icons.groups_outlined,
                label: 'So nguoi tham gia',
                value: race.participantLabel,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.section),
        _PrizeSection(prizes: detail.prizes),
        const SizedBox(height: AppSpacing.section),
        FilledButton.icon(
          onPressed: detail.hasResults ? () {} : null,
          style: FilledButton.styleFrom(
            backgroundColor: RefereeColors.championshipGold,
            foregroundColor: RefereeColors.background,
            disabledBackgroundColor: Colors.white.withValues(alpha: 0.08),
            disabledForegroundColor: Colors.white.withValues(alpha: 0.35),
            minimumSize: const Size.fromHeight(48),
          ),
          icon: const Icon(Icons.emoji_events_outlined),
          label: Text(detail.hasResults ? 'Xem ket qua' : 'Chua co ket qua'),
        ),
        if (!detail.hasResults) ...[
          const SizedBox(height: 12),
          Text(
            'Chua co ket qua.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.55)),
          ),
        ],
      ],
    );
  }
}

class _PrizeSection extends StatelessWidget {
  const _PrizeSection({required this.prizes});

  final List<SpectatorRacePrize> prizes;

  @override
  Widget build(BuildContext context) {
    return SpectatorGlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Giai thuong',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          if (prizes.isEmpty)
            Text(
              'Chua cong bo giai thuong.',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
            )
          else
            for (final prize in prizes)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  '${prize.rank == null ? '--' : 'Hang ${prize.rank}'}: ${prize.itemName.isEmpty ? prize.amount : prize.itemName}',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.75)),
                ),
              ),
        ],
      ),
    );
  }
}

class _DetailInfoRow extends StatelessWidget {
  const _DetailInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: RefereeColors.championshipGold, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.55)),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailLoadingState extends StatelessWidget {
  const _DetailLoadingState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 64),
      child: Center(
        child: CircularProgressIndicator(color: RefereeColors.championshipGold),
      ),
    );
  }
}

class _DetailErrorState extends StatelessWidget {
  const _DetailErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return SpectatorGlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
          ),
          const SizedBox(height: 16),
          OutlinedButton(onPressed: onRetry, child: const Text('Thu lai')),
        ],
      ),
    );
  }
}

class _DetailEmptyState extends StatelessWidget {
  const _DetailEmptyState();

  @override
  Widget build(BuildContext context) {
    return SpectatorGlassCard(
      padding: const EdgeInsets.all(20),
      child: Text(
        'Khong tim thay cuoc dua.',
        style: TextStyle(color: Colors.white.withValues(alpha: 0.75)),
      ),
    );
  }
}
