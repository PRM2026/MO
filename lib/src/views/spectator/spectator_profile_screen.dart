import 'package:flutter/material.dart';

import '../../constants/app_spacing.dart';
import '../../constants/app_theme_tokens.dart';
import '../../constants/referee_colors.dart';
import '../../models/spectator_models.dart';
import '../../repositories/auth_repository.dart';
import '../../routes/app_routes.dart';
import '../../utils/app_toast.dart';
import '../../viewmodels/spectator_profile_viewmodel.dart';
import '../../widgets/common/profile_avatar.dart';
import '../../widgets/spectator/spectator_app_bar.dart';
import '../../widgets/spectator/spectator_glass_card.dart';

class SpectatorProfileScreen extends StatefulWidget {
  const SpectatorProfileScreen({
    super.key,
    this.viewModel,
    this.authRepository,
    this.onLoggedOut,
  });

  final SpectatorProfileViewModel? viewModel;
  final AuthRepository? authRepository;
  final VoidCallback? onLoggedOut;

  @override
  State<SpectatorProfileScreen> createState() => _SpectatorProfileScreenState();
}

class _SpectatorProfileScreenState extends State<SpectatorProfileScreen> {
  late final SpectatorProfileViewModel _viewModel;
  late final AuthRepository _authRepository;
  late final bool _ownsViewModel;
  bool _isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    _ownsViewModel = widget.viewModel == null;
    _viewModel = widget.viewModel ?? SpectatorProfileViewModel();
    _authRepository = widget.authRepository ?? AuthRepository();
    _viewModel.load();
  }

  @override
  void dispose() {
    if (_ownsViewModel) {
      _viewModel.dispose();
    }
    super.dispose();
  }

  Future<void> _logout() async {
    setState(() => _isLoggingOut = true);
    await _authRepository.logout();
    if (!mounted) return;
    setState(() => _isLoggingOut = false);
    AppToast.showSuccess(context, 'Da dang xuat');

    final onLoggedOut = widget.onLoggedOut;
    if (onLoggedOut != null) {
      onLoggedOut();
      return;
    }

    AppRoutes.openAfterLogout(context);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _viewModel,
      builder: (context, _) {
        final profile = _viewModel.data;
        final avatarUrl = profile?.avatarUrl.trim();

        return Scaffold(
          backgroundColor: RefereeColors.background,
          appBar: SpectatorAppBar(
            displayName: profile?.displayName ?? 'Khan gia',
            profileImageUrl: avatarUrl == null || avatarUrl.isEmpty
                ? null
                : avatarUrl,
            profileInteractive: false,
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenPadding,
              AppSpacing.lg,
              AppSpacing.screenPadding,
              120,
            ),
            children: [
              if (_viewModel.isLoading && profile == null)
                const _ProfileLoadingState()
              else if (_viewModel.errorMessage != null && profile == null)
                _ProfileErrorState(
                  message: _viewModel.errorMessage!,
                  onRetry: _viewModel.retry,
                )
              else
                _ProfileContent(
                  profile: profile,
                  isLoggingOut: _isLoggingOut,
                  onLogout: _logout,
                  onWallet: () => AppRoutes.openSpectatorWallet(context),
                  onNotifications: () =>
                      AppRoutes.openSpectatorNotifications(context),
                  onBetting: () => AppRoutes.openSpectatorBetting(context),
                  onChangePassword: () => AppRoutes.openSpectatorChangePassword(
                    context,
                    profileImageUrl: profile?.avatarUrl,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ProfileContent extends StatelessWidget {
  const _ProfileContent({
    required this.profile,
    required this.isLoggingOut,
    required this.onLogout,
    required this.onWallet,
    required this.onNotifications,
    required this.onBetting,
    required this.onChangePassword,
  });

  final SpectatorProfileData? profile;
  final bool isLoggingOut;
  final VoidCallback onLogout;
  final VoidCallback onWallet;
  final VoidCallback onNotifications;
  final VoidCallback onBetting;
  final VoidCallback onChangePassword;

  @override
  Widget build(BuildContext context) {
    final avatarUrl = profile?.avatarUrl.trim();
    final email = profile?.email.trim() ?? '';

    return Column(
      children: [
        SpectatorGlassCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              ProfileAvatar(
                size: 96,
                imageUrl: avatarUrl == null || avatarUrl.isEmpty
                    ? null
                    : avatarUrl,
                fallbackIcon: Icons.person_rounded,
                ringWidth: 3,
              ),
              const SizedBox(height: 16),
              Text(
                profile?.displayName ?? 'Khan gia',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppTypography.headlineSm(Colors.white),
              ),
              if (email.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
                  color: RefereeColors.championshipGold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  profile?.role.isNotEmpty == true
                      ? profile!.role
                      : 'SPECTATOR',
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
                icon: Icons.sports_score_outlined,
                label: 'Đặt cược & lịch sử',
                onTap: onBetting,
              ),
              Divider(height: 1, color: Colors.white.withValues(alpha: 0.08)),
              _ProfileActionTile(
                icon: Icons.account_balance_wallet_outlined,
                label: 'Ví & thanh toán',
                onTap: onWallet,
              ),
              Divider(height: 1, color: Colors.white.withValues(alpha: 0.08)),
              _ProfileActionTile(
                icon: Icons.notifications_outlined,
                label: 'Thông báo',
                onTap: onNotifications,
              ),
              Divider(height: 1, color: Colors.white.withValues(alpha: 0.08)),
              _ProfileActionTile(
                icon: Icons.security_outlined,
                label: 'Bảo mật & mật khẩu',
                onTap: onChangePassword,
              ),
              Divider(height: 1, color: Colors.white.withValues(alpha: 0.08)),
              _ProfileActionTile(
                icon: Icons.logout,
                label: isLoggingOut ? 'Dang dang xuat...' : 'Dang xuat',
                onTap: isLoggingOut ? null : onLogout,
                destructive: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileLoadingState extends StatelessWidget {
  const _ProfileLoadingState();

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

class _ProfileErrorState extends StatelessWidget {
  const _ProfileErrorState({required this.message, required this.onRetry});

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

class _ProfileActionTile extends StatelessWidget {
  const _ProfileActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final color = destructive
        ? RefereeColors.statusRed
        : RefereeColors.onSurface;

    return Material(
      color: Colors.transparent,
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(label, style: AppTypography.bodyMd(color)),
        enabled: onTap != null,
        onTap: onTap,
      ),
    );
  }
}
