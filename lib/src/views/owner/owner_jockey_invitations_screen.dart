import 'package:flutter/material.dart';

import '../../constants/app_spacing.dart';
import '../../constants/app_theme_tokens.dart';
import '../../constants/referee_colors.dart';
import '../../models/owner_jockey_invitation.dart';
import '../../utils/app_toast.dart';
import '../../utils/currency_format.dart';
import '../../viewmodels/owner_jockey_invitation_viewmodels.dart';
import '../../widgets/news/news_network_image.dart';
import '../../widgets/owner/owner_app_bar.dart';
import '../../widgets/owner/owner_dashboard_widgets.dart';
import '../../widgets/referee/referee_glass_card.dart';
import 'owner_create_jockey_invitation_screen.dart';

class OwnerJockeyInvitationsScreen extends StatefulWidget {
  const OwnerJockeyInvitationsScreen({super.key, this.viewModel});

  final OwnerJockeyInvitationsViewModel? viewModel;

  @override
  State<OwnerJockeyInvitationsScreen> createState() =>
      _OwnerJockeyInvitationsScreenState();
}

class _OwnerJockeyInvitationsScreenState
    extends State<OwnerJockeyInvitationsScreen> {
  late final OwnerJockeyInvitationsViewModel _viewModel;
  late final bool _ownsViewModel;

  @override
  void initState() {
    super.initState();
    _ownsViewModel = widget.viewModel == null;
    _viewModel = widget.viewModel ?? OwnerJockeyInvitationsViewModel();
    _viewModel.addListener(_onChanged);
    _viewModel.loadInvitations();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _openCreate() async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => const OwnerCreateJockeyInvitationScreen(),
      ),
    );
    if (!mounted || changed != true) return;
    AppToast.showSuccess(context, 'Đã tạo lời mời jockey.');
    await _viewModel.refreshInvitations();
  }

  Future<void> _openDetail(OwnerJockeyInvitation invitation) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => OwnerJockeyInvitationDetailScreen(
          invitationId: invitation.id,
        ),
      ),
    );
    if (!mounted || changed != true) return;
    AppToast.showSuccess(context, 'Đã cập nhật lời mời.');
    await _viewModel.refreshInvitations();
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onChanged);
    if (_ownsViewModel) _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final invitations = _viewModel.filteredInvitations;

    return Scaffold(
      backgroundColor: RefereeColors.background,
      appBar: const OwnerAppBar(
        showBack: true,
        titleOverride: 'Lời mời jockey',
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreate,
        backgroundColor: RefereeColors.championshipGold,
        foregroundColor: RefereeColors.background,
        child: const Icon(Icons.add),
      ),
      body: OwnerPortalBackground(
        child: _viewModel.isLoading && _viewModel.invitations.isEmpty
            ? const Center(
                child: CircularProgressIndicator(
                  color: RefereeColors.championshipGold,
                ),
              )
            : RefreshIndicator(
                color: RefereeColors.championshipGold,
                onRefresh: _viewModel.refreshInvitations,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        AppSpacing.lg,
                        AppSpacing.md,
                        AppSpacing.contentBottomPadding(context),
                      ),
                      sliver: SliverToBoxAdapter(
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 960),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _HeaderText(
                                  title: 'Lời mời jockey',
                                  subtitle:
                                      'Theo dõi lời mời đã gửi và trạng thái phản hồi.',
                                ),
                                const SizedBox(height: 16),
                                _InvitationFilterChips(
                                  selected: _viewModel.selectedFilter,
                                  onSelected: _viewModel.selectFilter,
                                ),
                                const SizedBox(height: 16),
                                if (_viewModel.errorMessage != null)
                                  _StateMessage(
                                    message: _viewModel.errorMessage!,
                                    icon: Icons.error_outline,
                                    actionLabel: 'Thử lại',
                                    onAction: _viewModel.refreshInvitations,
                                  )
                                else if (invitations.isEmpty)
                                  const _StateMessage(
                                    message: 'Chưa có lời mời jockey nào.',
                                    icon: Icons.mail_outline,
                                  )
                                else
                                  for (final invitation in invitations) ...[
                                    _InvitationCard(
                                      invitation: invitation,
                                      onTap: () => _openDetail(invitation),
                                    ),
                                    const SizedBox(height: 12),
                                  ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class OwnerJockeyInvitationDetailScreen extends StatefulWidget {
  const OwnerJockeyInvitationDetailScreen({
    super.key,
    required this.invitationId,
    this.viewModel,
  });

  final String invitationId;
  final OwnerJockeyInvitationDetailViewModel? viewModel;

  @override
  State<OwnerJockeyInvitationDetailScreen> createState() =>
      _OwnerJockeyInvitationDetailScreenState();
}

class _OwnerJockeyInvitationDetailScreenState
    extends State<OwnerJockeyInvitationDetailScreen> {
  late final OwnerJockeyInvitationDetailViewModel _viewModel;
  late final bool _ownsViewModel;

  @override
  void initState() {
    super.initState();
    _ownsViewModel = widget.viewModel == null;
    _viewModel =
        widget.viewModel ??
        OwnerJockeyInvitationDetailViewModel(
          invitationId: widget.invitationId,
        );
    _viewModel.addListener(_onChanged);
    _viewModel.loadDetail();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _confirmCancel() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hủy lời mời'),
        content: const Text('Bạn có chắc muốn hủy lời mời jockey này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Không'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hủy lời mời'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final success = await _viewModel.cancelInvitation();
    if (!mounted) return;
    if (success) {
      AppToast.showSuccess(context, 'Đã hủy lời mời.');
      Navigator.of(context).pop(true);
      return;
    }

    AppToast.showError(
      context,
      _viewModel.cancelError ?? 'Không thể hủy lời mời.',
    );
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onChanged);
    if (_ownsViewModel) _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final detail = _viewModel.detail;

    return Scaffold(
      backgroundColor: RefereeColors.background,
      appBar: const OwnerAppBar(
        showBack: true,
        titleOverride: 'Chi tiết lời mời',
      ),
      bottomNavigationBar: detail?.isPending == true
          ? _CancelActionBar(
              isLoading: _viewModel.isCancelling,
              onCancel: _confirmCancel,
            )
          : null,
      body: OwnerPortalBackground(
        child: _viewModel.isLoading && detail == null
            ? const Center(
                child: CircularProgressIndicator(
                  color: RefereeColors.championshipGold,
                ),
              )
            : detail == null || _viewModel.errorMessage != null
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(32),
                children: [
                  const SizedBox(height: 96),
                  _StateMessage(
                    message:
                        _viewModel.errorMessage ??
                        'Không thể tải chi tiết lời mời.',
                    icon: Icons.error_outline,
                    actionLabel: 'Thử lại',
                    onAction: _viewModel.refresh,
                  ),
                ],
              )
            : RefreshIndicator(
                color: RefereeColors.championshipGold,
                onRefresh: _viewModel.refresh,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.lg,
                    AppSpacing.md,
                    detail.isPending ? 120 : AppSpacing.contentBottomPadding(context),
                  ),
                  children: [
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 960),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _InvitationHero(invitation: detail),
                            const SizedBox(height: 16),
                            _InvitationInfoSection(invitation: detail),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class OwnerAcceptedJockeysScreen extends StatefulWidget {
  const OwnerAcceptedJockeysScreen({super.key, this.viewModel});

  final OwnerAcceptedJockeysViewModel? viewModel;

  @override
  State<OwnerAcceptedJockeysScreen> createState() =>
      _OwnerAcceptedJockeysScreenState();
}

class _OwnerAcceptedJockeysScreenState
    extends State<OwnerAcceptedJockeysScreen> {
  late final OwnerAcceptedJockeysViewModel _viewModel;
  late final bool _ownsViewModel;

  @override
  void initState() {
    super.initState();
    _ownsViewModel = widget.viewModel == null;
    _viewModel = widget.viewModel ?? OwnerAcceptedJockeysViewModel();
    _viewModel.addListener(_onChanged);
    _viewModel.loadJockeys();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onChanged);
    if (_ownsViewModel) _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RefereeColors.background,
      appBar: const OwnerAppBar(
        showBack: true,
        titleOverride: 'Jockey đã nhận lời',
      ),
      body: OwnerPortalBackground(
        child: _viewModel.isLoading && _viewModel.jockeys.isEmpty
            ? const Center(
                child: CircularProgressIndicator(
                  color: RefereeColors.championshipGold,
                ),
              )
            : RefreshIndicator(
                color: RefereeColors.championshipGold,
                onRefresh: _viewModel.refreshJockeys,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.lg,
                    AppSpacing.md,
                    AppSpacing.contentBottomPadding(context),
                  ),
                  children: [
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 960),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const _HeaderText(
                              title: 'Jockey đã nhận lời',
                              subtitle:
                                  'Danh sách jockey đã đồng ý lời mời của bạn.',
                            ),
                            const SizedBox(height: 16),
                            if (_viewModel.errorMessage != null)
                              _StateMessage(
                                message: _viewModel.errorMessage!,
                                icon: Icons.error_outline,
                                actionLabel: 'Thử lại',
                                onAction: _viewModel.refreshJockeys,
                              )
                            else if (_viewModel.jockeys.isEmpty)
                              const _StateMessage(
                                message: 'Chưa có jockey nào nhận lời.',
                                icon: Icons.groups_outlined,
                              )
                            else
                              for (final jockey in _viewModel.jockeys) ...[
                                _AcceptedJockeyCard(jockey: jockey),
                                const SizedBox(height: 12),
                              ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _HeaderText extends StatelessWidget {
  const _HeaderText({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.displayMd(RefereeColors.onSurface),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: AppTypography.bodyMd(RefereeColors.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _InvitationFilterChips extends StatelessWidget {
  const _InvitationFilterChips({
    required this.selected,
    required this.onSelected,
  });

  final OwnerInvitationFilter selected;
  final ValueChanged<OwnerInvitationFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: OwnerInvitationFilter.values.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final filter = OwnerInvitationFilter.values[index];
          final isSelected = filter == selected;
          return FilterChip(
            selected: isSelected,
            showCheckmark: false,
            label: Text(filter.label),
            onSelected: (_) => onSelected(filter),
            backgroundColor: RefereeColors.portalSurface.withValues(alpha: 0.7),
            selectedColor: RefereeColors.portalSurface.withValues(alpha: 0.7),
            labelStyle: AppTypography.labelCaps(
              isSelected
                  ? RefereeColors.championshipGold
                  : RefereeColors.onSurfaceVariant,
            ).copyWith(fontSize: 12),
            side: BorderSide(
              color: isSelected
                  ? RefereeColors.championshipGold
                  : Colors.white.withValues(alpha: 0.1),
            ),
          );
        },
      ),
    );
  }
}

class _InvitationCard extends StatelessWidget {
  const _InvitationCard({required this.invitation, required this.onTap});

  final OwnerJockeyInvitation invitation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return RefereeGlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _CircleIcon(icon: Icons.sports_outlined),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        invitation.horseName ?? 'Ngựa chưa cập nhật',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.headlineSm(
                          RefereeColors.onSurface,
                        ).copyWith(fontSize: 18),
                      ),
                    ),
                    _StatusBadge(
                      label: invitation.statusLabel,
                      color: _statusColor(invitation.statusCode),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  invitation.jockeyUsername == null
                      ? 'Jockey chưa cập nhật'
                      : 'Jockey: ${invitation.jockeyUsername}',
                  style: AppTypography.bodySm(RefereeColors.onSurfaceVariant),
                ),
                const SizedBox(height: 2),
                Text(
                  [
                    invitation.raceName,
                    invitation.tournamentName,
                  ].whereType<String>().where((value) => value.isNotEmpty).join(
                    ' • ',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySm(RefereeColors.championshipGold),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: RefereeColors.onSurfaceVariant),
        ],
      ),
    );
  }
}

class _InvitationHero extends StatelessWidget {
  const _InvitationHero({required this.invitation});

  final OwnerJockeyInvitation invitation;

  @override
  Widget build(BuildContext context) {
    return RefereeGlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _CircleIcon(icon: Icons.mail_outline),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  invitation.horseName ?? 'Ngựa chưa cập nhật',
                  style: AppTypography.displayMd(RefereeColors.onSurface),
                ),
              ),
              _StatusBadge(
                label: invitation.statusLabel,
                color: _statusColor(invitation.statusCode),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            invitation.message?.isNotEmpty == true
                ? '"${invitation.message}"'
                : 'Chưa có lời nhắn.',
            style: AppTypography.bodyMd(RefereeColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _InvitationInfoSection extends StatelessWidget {
  const _InvitationInfoSection({required this.invitation});

  final OwnerJockeyInvitation invitation;

  @override
  Widget build(BuildContext context) {
    return RefereeGlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          _InfoRow('Jockey', invitation.jockeyUsername ?? 'Chưa cập nhật'),
          _InfoRow('Cuộc đua', invitation.raceName ?? 'Chưa cập nhật'),
          _InfoRow('Giải đấu', invitation.tournamentName ?? 'Chưa cập nhật'),
          _InfoRow('Thù lao', formatVnd(invitation.remunerationAmount)),
          _InfoRow('Phản hồi', invitation.responseNote ?? 'Chưa có phản hồi'),
          _InfoRow('Ngày gửi', _formatDate(invitation.createdAt)),
          if (invitation.respondedAt != null)
            _InfoRow('Ngày phản hồi', _formatDate(invitation.respondedAt)),
          if (invitation.cancelledAt != null)
            _InfoRow('Ngày hủy', _formatDate(invitation.cancelledAt)),
        ],
      ),
    );
  }
}

class _AcceptedJockeyCard extends StatelessWidget {
  const _AcceptedJockeyCard({required this.jockey});

  final OwnerAcceptedJockey jockey;

  @override
  Widget build(BuildContext context) {
    return RefereeGlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          ClipOval(
            child: SizedBox(
              width: 56,
              height: 56,
              child: jockey.jockeyAvatarUrl?.isNotEmpty == true
                  ? NewsNetworkImage(imageUrl: jockey.jockeyAvatarUrl!)
                  : const ColoredBox(
                      color: RefereeColors.surfaceContainer,
                      child: Icon(
                        Icons.person_outline,
                        color: RefereeColors.onSurfaceVariant,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  jockey.displayName,
                  style: AppTypography.headlineSm(
                    RefereeColors.onSurface,
                  ).copyWith(fontSize: 18),
                ),
                Text(
                  jockey.horseName ?? 'Ngựa chưa cập nhật',
                  style: AppTypography.bodySm(RefereeColors.championshipGold),
                ),
                Text(
                  [
                    jockey.raceName,
                    jockey.tournamentName,
                    _formatDate(jockey.acceptedAt),
                  ].whereType<String>().where((value) => value.isNotEmpty).join(
                    ' • ',
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySm(RefereeColors.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CancelActionBar extends StatelessWidget {
  const _CancelActionBar({required this.isLoading, required this.onCancel});

  final bool isLoading;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: RefereeColors.portalSurface.withValues(alpha: 0.95),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: OutlinedButton.icon(
            onPressed: isLoading ? null : onCancel,
            icon: isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.cancel_outlined),
            label: const Text('Hủy lời mời'),
            style: OutlinedButton.styleFrom(
              foregroundColor: RefereeColors.statusRed,
              side: BorderSide(
                color: RefereeColors.statusRed.withValues(alpha: 0.6),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: AppTypography.bodySm(RefereeColors.onSurfaceVariant),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTypography.bodyMd(RefereeColors.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}

class _StateMessage extends StatelessWidget {
  const _StateMessage({
    required this.message,
    required this.icon,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return RefereeGlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(icon, size: 40, color: RefereeColors.onSurfaceVariant),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTypography.bodyMd(RefereeColors.onSurfaceVariant),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 12),
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}

class _CircleIcon extends StatelessWidget {
  const _CircleIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: RefereeColors.championshipGold.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: RefereeColors.championshipGold),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.32)),
      ),
      child: Text(
        label,
        style: AppTypography.labelCaps(color).copyWith(fontSize: 10),
      ),
    );
  }
}

Color _statusColor(String status) {
  return switch (status) {
    'ACCEPTED' => RefereeColors.successEmerald,
    'REJECTED' => RefereeColors.statusRed,
    'CANCELLED' => RefereeColors.onSurfaceVariant,
    _ => RefereeColors.championshipGold,
  };
}

String _formatDate(DateTime? date) {
  if (date == null) return 'Chưa cập nhật';
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '$day/$month/${date.year} $hour:$minute';
}
