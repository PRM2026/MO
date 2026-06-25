import 'package:flutter/material.dart';

import '../../constants/app_spacing.dart';
import '../../constants/referee_colors.dart';
import '../../models/spectator_models.dart';
import '../../routes/app_routes.dart';
import '../../viewmodels/spectator_tournament_detail_viewmodel.dart';
import '../../widgets/news/news_network_image.dart';
import '../../widgets/spectator/spectator_app_bar.dart';
import '../../widgets/spectator/spectator_glass_card.dart';

class SpectatorTournamentDetailScreen extends StatefulWidget {
  const SpectatorTournamentDetailScreen({
    super.key,
    required this.tournamentId,
    this.onRaceTap,
    this.viewModel,
  });

  final String tournamentId;
  final ValueChanged<SpectatorRaceItem>? onRaceTap;
  final SpectatorTournamentDetailViewModel? viewModel;

  @override
  State<SpectatorTournamentDetailScreen> createState() =>
      _SpectatorTournamentDetailScreenState();
}

class _SpectatorTournamentDetailScreenState
    extends State<SpectatorTournamentDetailScreen> {
  late final SpectatorTournamentDetailViewModel _viewModel;
  late final bool _ownsViewModel;

  @override
  void initState() {
    super.initState();
    _ownsViewModel = widget.viewModel == null;
    _viewModel =
        widget.viewModel ??
        SpectatorTournamentDetailViewModel(tournamentId: widget.tournamentId);
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
            titleOverride: 'Chi tiet giai dau',
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
                const _TournamentLoadingState()
              else if (_viewModel.errorMessage != null)
                _TournamentErrorState(
                  message: _viewModel.errorMessage!,
                  onRetry: _viewModel.retry,
                )
              else if (detail != null)
                _TournamentContent(
                  detail: detail,
                  onRaceTap: widget.onRaceTap ?? _openRaceDetail,
                )
              else
                const _TournamentEmptyState(),
            ],
          ),
        );
      },
    );
  }

  void _openRaceDetail(SpectatorRaceItem race) {
    AppRoutes.openSpectatorRaceDetail(
      context,
      raceId: race.id,
      tournamentId: race.tournamentId,
    );
  }
}

class _TournamentContent extends StatelessWidget {
  const _TournamentContent({required this.detail, required this.onRaceTap});

  final SpectatorTournamentDetail detail;
  final ValueChanged<SpectatorRaceItem> onRaceTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TournamentHero(detail: detail),
        const SizedBox(height: AppSpacing.section),
        _InfoSection(detail: detail),
        const SizedBox(height: AppSpacing.section),
        _TextSection(
          title: 'Mo ta',
          emptyText: 'Chua co mo ta giai dau.',
          value: detail.description,
        ),
        const SizedBox(height: AppSpacing.section),
        _TextSection(
          title: 'The le',
          emptyText: 'Chua cong bo the le.',
          value: detail.rules,
        ),
        const SizedBox(height: AppSpacing.section),
        const Text(
          'Danh sach cuoc dua',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        if (detail.races.isEmpty)
          const _TournamentRacesEmptyState()
        else
          for (final raceDetail in detail.races) ...[
            _TournamentRaceCard(
              detail: raceDetail,
              onTap: () => onRaceTap(raceDetail.race),
            ),
            const SizedBox(height: 12),
          ],
      ],
    );
  }
}

class _TournamentHero extends StatelessWidget {
  const _TournamentHero({required this.detail});

  final SpectatorTournamentDetail detail;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 240,
        child: Stack(
          fit: StackFit.expand,
          children: [
            NewsNetworkImage(imageUrl: detail.bannerUrl),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    RefereeColors.portalSurface,
                    RefereeColors.portalSurface.withValues(alpha: 0.45),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: RefereeColors.championshipGold.withValues(
                        alpha: 0.18,
                      ),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: RefereeColors.championshipGold.withValues(
                          alpha: 0.3,
                        ),
                      ),
                    ),
                    child: Text(
                      detail.statusLabel.toUpperCase(),
                      style: const TextStyle(
                        color: RefereeColors.championshipGold,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    detail.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 18,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          detail.location,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
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

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.detail});

  final SpectatorTournamentDetail detail;

  @override
  Widget build(BuildContext context) {
    return SpectatorGlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.app_registration_outlined,
            label: 'Dang ky',
            value: _fallback(detail.registrationWindowLabel),
          ),
          _InfoRow(
            icon: Icons.event_outlined,
            label: 'Thoi gian',
            value: _fallback(detail.scheduleWindowLabel),
          ),
          _InfoRow(
            icon: Icons.flag_outlined,
            label: 'Trang thai',
            value: detail.statusLabel,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
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

class _TextSection extends StatelessWidget {
  const _TextSection({
    required this.title,
    required this.emptyText,
    required this.value,
  });

  final String title;
  final String emptyText;
  final String value;

  @override
  Widget build(BuildContext context) {
    final text = value.trim().isEmpty ? emptyText : value.trim();

    return SpectatorGlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            text,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.72)),
          ),
        ],
      ),
    );
  }
}

class _TournamentRaceCard extends StatelessWidget {
  const _TournamentRaceCard({required this.detail, required this.onTap});

  final SpectatorRaceDetail detail;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final race = detail.race;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SpectatorGlassCard(
          padding: const EdgeInsets.all(16),
          accentBorder: true,
          accentColor: RefereeColors.championshipGold,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      race.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Text(
                    race.statusLabel,
                    style: const TextStyle(
                      color: RefereeColors.championshipGold,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _fallback(race.trackInfo),
                style: TextStyle(color: Colors.white.withValues(alpha: 0.62)),
              ),
              const SizedBox(height: 8),
              Text(
                race.participantLabel,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.62)),
              ),
              if (detail.prizes.isNotEmpty) ...[
                const SizedBox(height: 12),
                for (final prize in detail.prizes.take(3))
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '${prize.rank == null ? '--' : 'Hang ${prize.rank}'}: ${prize.itemName.isEmpty ? prize.amount : prize.itemName}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TournamentLoadingState extends StatelessWidget {
  const _TournamentLoadingState();

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

class _TournamentErrorState extends StatelessWidget {
  const _TournamentErrorState({required this.message, required this.onRetry});

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

class _TournamentEmptyState extends StatelessWidget {
  const _TournamentEmptyState();

  @override
  Widget build(BuildContext context) {
    return SpectatorGlassCard(
      padding: const EdgeInsets.all(20),
      child: Text(
        'Khong tim thay giai dau.',
        style: TextStyle(color: Colors.white.withValues(alpha: 0.75)),
      ),
    );
  }
}

class _TournamentRacesEmptyState extends StatelessWidget {
  const _TournamentRacesEmptyState();

  @override
  Widget build(BuildContext context) {
    return SpectatorGlassCard(
      padding: const EdgeInsets.all(16),
      child: Text(
        'Chua co cuoc dua trong giai dau nay.',
        style: TextStyle(color: Colors.white.withValues(alpha: 0.75)),
      ),
    );
  }
}

String _fallback(String value) {
  final text = value.trim();
  return text.isEmpty ? spectatorPlaceholder : text;
}
