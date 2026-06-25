import 'package:flutter/material.dart';

import '../../constants/app_spacing.dart';
import '../../constants/referee_colors.dart';
import '../../models/spectator_models.dart';
import '../../viewmodels/spectator_races_viewmodel.dart';
import '../../widgets/spectator/spectator_app_bar.dart';
import '../../widgets/spectator/spectator_glass_card.dart';
import '../../widgets/spectator/spectator_races_widgets.dart';

class SpectatorRacesScreen extends StatefulWidget {
  const SpectatorRacesScreen({
    super.key,
    this.onProfileTap,
    this.onRaceTap,
    this.viewModel,
  });

  final VoidCallback? onProfileTap;
  final ValueChanged<SpectatorRaceItem>? onRaceTap;
  final SpectatorRacesViewModel? viewModel;

  @override
  State<SpectatorRacesScreen> createState() => _SpectatorRacesScreenState();
}

class _SpectatorRacesScreenState extends State<SpectatorRacesScreen> {
  late final SpectatorRacesViewModel _viewModel;
  late final bool _ownsViewModel;

  @override
  void initState() {
    super.initState();
    _ownsViewModel = widget.viewModel == null;
    _viewModel = widget.viewModel ?? SpectatorRacesViewModel();
    _viewModel.load();
  }

  @override
  void dispose() {
    if (_ownsViewModel) {
      _viewModel.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final dates = _viewModel.allRaces
        .map((race) => race.scheduledStartAt)
        .whereType<DateTime>()
        .toList(growable: false);
    final firstDate = dates.isEmpty
        ? DateTime(now.year - 1)
        : dates.reduce((a, b) => a.isBefore(b) ? a : b);
    final lastDate = dates.isEmpty
        ? DateTime(now.year + 3)
        : dates.reduce((a, b) => a.isAfter(b) ? a : b);
    final initialDate = _viewModel.selectedDate ?? now;
    final safeInitial = initialDate.isBefore(firstDate)
        ? firstDate
        : initialDate.isAfter(lastDate)
        ? lastDate
        : initialDate;

    final picked = await showDatePicker(
      context: context,
      initialDate: safeInitial,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: RefereeColors.championshipGold,
              surface: RefereeColors.background,
            ),
          ),
          child: child!,
        );
      },
    );

    if (!mounted || picked == null) return;
    _viewModel.selectDate(picked);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _viewModel,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: RefereeColors.background,
          appBar: SpectatorAppBar(
            titleOverride: 'Cuoc dua',
            onProfileTap: widget.onProfileTap,
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenPadding,
              AppSpacing.lg,
              AppSpacing.screenPadding,
              120,
            ),
            children: [
              if (_viewModel.scheduleHero != null) ...[
                SpectatorScheduleHero(featured: _viewModel.scheduleHero!),
                const SizedBox(height: AppSpacing.section),
              ],
              SpectatorRaceFilterBar(
                selected: _viewModel.selectedFilter,
                onSelected: _viewModel.selectFilter,
                onDateTap: _pickDate,
              ),
              const SizedBox(height: AppSpacing.section),
              if (_viewModel.isLoading)
                const _RacesLoadingState()
              else if (_viewModel.errorMessage != null)
                _RacesErrorState(
                  message: _viewModel.errorMessage!,
                  onRetry: _viewModel.retry,
                )
              else if (_viewModel.races.isEmpty)
                _RacesEmptyState(filter: _viewModel.selectedFilter)
              else
                for (final race in _viewModel.races) ...[
                  SpectatorScheduleRaceCard(
                    race: race,
                    onViewDetails: widget.onRaceTap == null
                        ? null
                        : () => widget.onRaceTap!(race),
                  ),
                  const SizedBox(height: 16),
                ],
            ],
          ),
        );
      },
    );
  }
}

class _RacesLoadingState extends StatelessWidget {
  const _RacesLoadingState();

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

class _RacesErrorState extends StatelessWidget {
  const _RacesErrorState({required this.message, required this.onRetry});

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

class _RacesEmptyState extends StatelessWidget {
  const _RacesEmptyState({required this.filter});

  final SpectatorRaceListFilter filter;

  @override
  Widget build(BuildContext context) {
    final message = switch (filter) {
      SpectatorRaceListFilter.date => 'Khong co cuoc dua trong ngay da chon.',
      _ => 'Chua co cuoc dua nao.',
    };

    return SpectatorGlassCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Icon(
            Icons.calendar_month_outlined,
            color: RefereeColors.championshipGold.withValues(alpha: 0.8),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.75)),
            ),
          ),
        ],
      ),
    );
  }
}
