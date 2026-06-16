import 'package:flutter/material.dart';

import '../../constants/app_spacing.dart';
import '../../constants/referee_colors.dart';
import '../../data/spectator_results_mock.dart';
import '../../repositories/auth_repository.dart';
import '../../utils/app_toast.dart';
import '../../widgets/spectator/spectator_app_bar.dart';
import '../../widgets/spectator/spectator_results_widgets.dart';

class SpectatorResultsScreen extends StatefulWidget {
  const SpectatorResultsScreen({super.key, this.onProfileTap});

  final VoidCallback? onProfileTap;

  @override
  State<SpectatorResultsScreen> createState() => _SpectatorResultsScreenState();
}

class _SpectatorResultsScreenState extends State<SpectatorResultsScreen> {
  final AuthRepository _authRepository = AuthRepository();
  SpectatorResultsFilter _filter = SpectatorResultsFilter.all;
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
          _profileImageUrl = SpectatorResultsMock.profileImageUrl;
        });
      } catch (_) {
        if (!mounted) return;
        setState(() {
          _profileImageUrl = SpectatorResultsMock.profileImageUrl;
        });
      }
    }
  }

  List<SpectatorRaceResultGroup> get _visibleResults {
    if (_filter == SpectatorResultsFilter.all) {
      return SpectatorResultsMock.raceResults;
    }
    return SpectatorResultsMock.raceResults
        .where((item) => item.category == _filter)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RefereeColors.background,
      appBar: SpectatorAppBar(
        displayName: _displayName,
        profileImageUrl:
            _profileImageUrl ?? SpectatorResultsMock.profileImageUrl,
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
          const SpectatorResultsHero(),
          const SizedBox(height: AppSpacing.section),
          SpectatorResultsFilterBar(
            selected: _filter,
            onSelected: (filter) => setState(() => _filter = filter),
          ),
          const SizedBox(height: AppSpacing.section),
          for (final group in _visibleResults) ...[
            SpectatorRaceResultCard(
              group: group,
              onLeaderboardTap: () {
                AppToast.showSuccess(
                  context,
                  'Đang mở bảng xếp hạng ${group.title}',
                );
              },
            ),
            const SizedBox(height: 16),
          ],
          SpectatorResultsPromoBanner(
            onBuyTicket: () {
              AppToast.showSuccess(context, 'Đang mở trang mua vé VIP');
            },
          ),
        ],
      ),
    );
  }
}
