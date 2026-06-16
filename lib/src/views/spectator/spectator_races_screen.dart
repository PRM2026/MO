import 'package:flutter/material.dart';

import '../../constants/app_spacing.dart';
import '../../constants/referee_colors.dart';
import '../../data/spectator_races_mock.dart';
import '../../repositories/auth_repository.dart';
import '../../utils/app_toast.dart';
import '../../widgets/spectator/spectator_app_bar.dart';
import '../../widgets/spectator/spectator_races_widgets.dart';

class SpectatorRacesScreen extends StatefulWidget {
  const SpectatorRacesScreen({super.key, this.onProfileTap});

  final VoidCallback? onProfileTap;

  @override
  State<SpectatorRacesScreen> createState() => _SpectatorRacesScreenState();
}

class _SpectatorRacesScreenState extends State<SpectatorRacesScreen> {
  final AuthRepository _authRepository = AuthRepository();
  SpectatorRaceFilter _filter = SpectatorRaceFilter.upcoming;
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final user = await _authRepository.refreshCurrentUser();
      if (!mounted) return;
      setState(() {
        _profileImageUrl = user.avatarUrl;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _profileImageUrl = SpectatorRacesMock.profileImageUrl;
      });
    }
  }

  List<SpectatorScheduleRace> get _visibleRaces {
    return switch (_filter) {
      SpectatorRaceFilter.upcoming => SpectatorRacesMock.upcomingScheduleRaces,
      SpectatorRaceFilter.finished => SpectatorRacesMock.finishedScheduleRaces,
      SpectatorRaceFilter.date => SpectatorRacesMock.upcomingScheduleRaces,
    };
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2026),
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
    setState(() => _filter = SpectatorRaceFilter.date);
    AppToast.showSuccess(
      context,
      'Lọc theo ngày ${picked.day}/${picked.month}/${picked.year}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RefereeColors.background,
      appBar: SpectatorAppBar(
        titleOverride: 'Cuộc đua',
        profileImageUrl:
            _profileImageUrl ?? SpectatorRacesMock.profileImageUrl,
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
          SpectatorScheduleHero(featured: SpectatorRacesMock.scheduleHero),
          const SizedBox(height: AppSpacing.section),
          SpectatorRaceFilterBar(
            selected: _filter,
            onSelected: (filter) => setState(() => _filter = filter),
            onDateTap: _pickDate,
          ),
          const SizedBox(height: AppSpacing.section),
          for (final race in _visibleRaces) ...[
            SpectatorScheduleRaceCard(
              race: race,
              onViewDetails: () {
                AppToast.showSuccess(context, 'Đang mở ${race.title}');
              },
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}
