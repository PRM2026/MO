import 'package:flutter/material.dart';

import '../../constants/app_spacing.dart';
import '../../constants/referee_colors.dart';
import '../../data/spectator_home_mock.dart';
import '../../repositories/auth_repository.dart';
import '../../widgets/spectator/spectator_app_bar.dart';
import '../../widgets/spectator/spectator_home_widgets.dart';

class SpectatorHomeScreen extends StatefulWidget {
  const SpectatorHomeScreen({
    super.key,
    this.onProfileTap,
    this.onRacesTap,
    this.onResultsTap,
    this.onViewAllRaces,
  });

  final VoidCallback? onProfileTap;
  final VoidCallback? onRacesTap;
  final VoidCallback? onResultsTap;
  final VoidCallback? onViewAllRaces;

  @override
  State<SpectatorHomeScreen> createState() => _SpectatorHomeScreenState();
}

class _SpectatorHomeScreenState extends State<SpectatorHomeScreen> {
  final AuthRepository _authRepository = AuthRepository();
  String? _profileImageUrl;
  String _displayName = 'Khán giả';

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
        final name = user.fullName?.trim();
        if (name != null && name.isNotEmpty) {
          _displayName = name;
        }
      });
    } catch (_) {
      try {
        final profile = await _authRepository.loadProfile();
        if (!mounted) return;
        setState(() {
          final name = profile.fullName?.trim();
          if (name != null && name.isNotEmpty) {
            _displayName = name;
          }
        });
      } catch (_) {
        if (!mounted) return;
        setState(() {
          _profileImageUrl = SpectatorHomeMock.defaultProfileImageUrl;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RefereeColors.background,
      appBar: SpectatorAppBar(
        profileImageUrl:
            _profileImageUrl ?? SpectatorHomeMock.defaultProfileImageUrl,
        displayName: _displayName,
        onProfileTap: widget.onProfileTap,
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenPadding,
              AppSpacing.lg,
              AppSpacing.screenPadding,
              120,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                SpectatorHeroBanner(
                  event: SpectatorHomeMock.featuredEvent,
                  onViewDetails: widget.onViewAllRaces,
                ),
                const SizedBox(height: AppSpacing.section),
                SpectatorQuickActions(
                  onScheduleTap: widget.onRacesTap,
                  onHorsesTap: widget.onRacesTap,
                  onResultsTap: widget.onResultsTap,
                ),
                const SizedBox(height: AppSpacing.section),
                SpectatorSectionHeader(
                  title: 'Cuộc Đua Sắp Tới',
                  actionLabel: 'Xem tất cả',
                  onActionTap: widget.onViewAllRaces,
                ),
                const SizedBox(height: AppSpacing.lg),
                for (final race in SpectatorHomeMock.upcomingRaces) ...[
                  SpectatorRaceListTile(race: race),
                  const SizedBox(height: 12),
                ],
                const SizedBox(height: AppSpacing.section),
                const SpectatorSectionHeader(title: 'Chiến Mã Nổi Bật'),
                const SizedBox(height: AppSpacing.lg),
                SpectatorHorizontalList(
                  itemCount: SpectatorHomeMock.featuredHorses.length,
                  itemBuilder: (context, index) => SpectatorFeaturedHorseCard(
                    horse: SpectatorHomeMock.featuredHorses[index],
                  ),
                ),
                const SizedBox(height: AppSpacing.section),
                const SpectatorSectionHeader(title: 'Kết Quả Gần Đây'),
                const SizedBox(height: AppSpacing.lg),
                SpectatorRecentResultsPanel(
                  results: SpectatorHomeMock.recentResults,
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
