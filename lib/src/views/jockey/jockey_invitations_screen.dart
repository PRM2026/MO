import 'package:flutter/material.dart';

import '../../constants/app_spacing.dart';
import '../../constants/app_theme_tokens.dart';
import '../../constants/referee_colors.dart';
import '../../utils/app_toast.dart';
import '../../viewmodels/jockey_invitation_viewmodel.dart';
import '../../widgets/jockey/jockey_app_bar.dart';
import '../../widgets/jockey/jockey_invitation_widgets.dart';
import '../../widgets/jockey/jockey_dashboard_widgets.dart';

class JockeyInvitationsScreen extends StatefulWidget {
  const JockeyInvitationsScreen({super.key, this.viewModel});

  final JockeyInvitationsViewModel? viewModel;

  @override
  State<JockeyInvitationsScreen> createState() =>
      _JockeyInvitationsScreenState();
}

class _JockeyInvitationsScreenState extends State<JockeyInvitationsScreen> {
  late final JockeyInvitationsViewModel _viewModel;
  late final bool _ownsViewModel;

  @override
  void initState() {
    super.initState();
    _ownsViewModel = widget.viewModel == null;
    _viewModel = widget.viewModel ?? JockeyInvitationsViewModel();
    _viewModel.addListener(_onChanged);
    _viewModel.loadInvitations();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  void _openDetail(String id) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => JockeyInvitationDetailScreen(invitationId: id),
      ),
    );
    if (!mounted || result == null) return;
    if (result) {
      AppToast.showSuccess(
        context,
        'Đã chấp nhận lời mời',
        subtitle: 'Lịch thi đấu đã được cập nhật vào lịch đua của bạn.',
      );
    } else {
      AppToast.showSuccess(context, 'Đã từ chối lời mời');
    }
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
      appBar: const JockeyAppBar(),
      body: JockeySpeedlineBackground(
        child: _viewModel.isLoading && _viewModel.invitations.isEmpty
            ? const Center(
                child: CircularProgressIndicator(
                  color: RefereeColors.championshipGold,
                ),
              )
            : RefreshIndicator(
                color: RefereeColors.championshipGold,
                onRefresh: _viewModel.loadInvitations,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        AppSpacing.lg,
                        AppSpacing.md,
                        120,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Lời mời thi đấu',
                              style: AppTypography.displayLg(
                                RefereeColors.onSurface,
                              ).copyWith(fontSize: 28),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Xem và phản hồi các lời mời từ chủ ngựa.',
                              style: AppTypography.bodyMd(
                                RefereeColors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            if (_viewModel.invitations.isEmpty)
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(32),
                                  child: Text(
                                    'Chưa có lời mời nào.',
                                    style: AppTypography.bodyMd(
                                      RefereeColors.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              )
                            else
                              for (final item in _viewModel.invitations) ...[
                                JockeyInvitationListTile(
                                  item: item,
                                  onTap: () => _openDetail(item.id),
                                ),
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

class JockeyInvitationDetailScreen extends StatefulWidget {
  const JockeyInvitationDetailScreen({
    super.key,
    required this.invitationId,
    this.viewModel,
  });

  final String invitationId;
  final JockeyInvitationDetailViewModel? viewModel;

  @override
  State<JockeyInvitationDetailScreen> createState() =>
      _JockeyInvitationDetailScreenState();
}

class _JockeyInvitationDetailScreenState
    extends State<JockeyInvitationDetailScreen> {
  late final JockeyInvitationDetailViewModel _viewModel;
  late final bool _ownsViewModel;

  @override
  void initState() {
    super.initState();
    _ownsViewModel = widget.viewModel == null;
    _viewModel = widget.viewModel ??
        JockeyInvitationDetailViewModel(invitationId: widget.invitationId);
    _viewModel.addListener(_onChanged);
    _viewModel.loadDetail();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _handleAccept() async {
    final success = await _viewModel.acceptInvitation();
    if (!mounted || !success) return;
    Navigator.of(context).pop(true);
  }

  Future<void> _handleDecline() async {
    final success = await _viewModel.declineInvitation();
    if (!mounted || !success) return;
    Navigator.of(context).pop(false);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onChanged);
    if (_ownsViewModel) _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = _viewModel.data;

    return Scaffold(
      backgroundColor: RefereeColors.background,
      appBar: JockeyAppBar(
        showBack: true,
        showBrandTitle: false,
        titleOverride: 'CHI TIẾT LỜI MỜI',
        profileImageUrl: data?.profileImageUrl,
      ),
      bottomNavigationBar: JockeyInvitationActionBar(
        isProcessing: _viewModel.isProcessing,
        onDecline: _handleDecline,
        onAccept: _handleAccept,
      ),
      body: _viewModel.isLoading && data == null
          ? const Center(
              child: CircularProgressIndicator(
                color: RefereeColors.championshipGold,
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1280),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth >= 960;
                      final leftColumn = Column(
                        children: [
                          JockeyInvitationOwnerCard(detail: data!),
                          const SizedBox(height: AppSpacing.lg),
                          JockeyInvitationScheduleWarning(detail: data),
                        ],
                      );
                      final rightColumn = Column(
                        children: [
                          JockeyInvitationRemunerationCard(detail: data),
                          const SizedBox(height: AppSpacing.lg),
                          JockeyInvitationRaceDetailsCard(detail: data),
                        ],
                      );

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          JockeyInvitationHeroCard(detail: data),
                          const SizedBox(height: AppSpacing.lg),
                          if (isWide)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(flex: 7, child: leftColumn),
                                const SizedBox(width: AppSpacing.lg),
                                Expanded(flex: 5, child: rightColumn),
                              ],
                            )
                          else ...[
                            leftColumn,
                            const SizedBox(height: AppSpacing.lg),
                            rightColumn,
                          ],
                          const SizedBox(height: 100),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
    );
  }
}
