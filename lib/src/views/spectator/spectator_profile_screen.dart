import 'package:flutter/material.dart';

import '../../constants/app_spacing.dart';
import '../../constants/app_theme_tokens.dart';
import '../../constants/referee_colors.dart';
import '../../data/spectator_home_mock.dart';
import '../../repositories/auth_repository.dart';
import '../../routes/app_routes.dart';
import '../../utils/app_toast.dart';
import '../../widgets/common/profile_avatar.dart';
import '../../widgets/spectator/spectator_app_bar.dart';
import '../../widgets/spectator/spectator_glass_card.dart';

class SpectatorProfileScreen extends StatefulWidget {
  const SpectatorProfileScreen({super.key});

  @override
  State<SpectatorProfileScreen> createState() => _SpectatorProfileScreenState();
}

class _SpectatorProfileScreenState extends State<SpectatorProfileScreen> {
  final AuthRepository _authRepository = AuthRepository();
  String? _fullName;
  String? _email;
  String? _avatarUrl;
  bool _isLoading = true;

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
        _fullName = user.fullName;
        _email = user.email;
        _avatarUrl = user.avatarUrl;
        _isLoading = false;
      });
    } catch (_) {
      try {
        final profile = await _authRepository.loadProfile();
        if (!mounted) return;
        setState(() {
          _fullName = profile.fullName;
          _email = profile.email;
          _isLoading = false;
        });
      } catch (_) {
        if (!mounted) return;
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _logout() async {
    await _authRepository.logout();
    if (!mounted) return;
    AppToast.showSuccess(context, 'Đã đăng xuất');
    AppRoutes.openAfterLogout(context);
  }

  @override
  Widget build(BuildContext context) {
    final avatarUrl = _avatarUrl ?? SpectatorHomeMock.defaultProfileImageUrl;

    return Scaffold(
      backgroundColor: RefereeColors.background,
      appBar: SpectatorAppBar(
        displayName: 'Khán giả',
        profileImageUrl: avatarUrl,
        profileInteractive: false,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: RefereeColors.championshipGold,
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                AppSpacing.lg,
                AppSpacing.screenPadding,
                120,
              ),
              children: [
                SpectatorGlassCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      ProfileAvatar(
                        size: 96,
                        imageUrl: avatarUrl,
                        fallbackIcon: Icons.person_rounded,
                        ringWidth: 3,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _fullName ?? 'Khán giả',
                        style: AppTypography.headlineSm(Colors.white),
                      ),
                      if (_email != null && _email!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          _email!,
                          style: AppTypography.bodySm(
                            Colors.white.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: RefereeColors.championshipGold.withValues(
                            alpha: 0.15,
                          ),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'SPECTATOR',
                          style: AppTypography.labelCaps(
                            RefereeColors.championshipGold,
                          ).copyWith(fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.section),
                SpectatorGlassCard(
                  child: Column(
                    children: [
                      _ProfileActionTile(
                        icon: Icons.logout,
                        label: 'Đăng xuất',
                        onTap: _logout,
                        destructive: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _ProfileActionTile extends StatelessWidget {
  const _ProfileActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final color = destructive
        ? RefereeColors.statusRed
        : RefereeColors.onSurface;

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        label,
        style: AppTypography.bodyMd(color),
      ),
      onTap: onTap,
    );
  }
}
