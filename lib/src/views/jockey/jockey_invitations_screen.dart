import 'package:flutter/material.dart';

import '../../constants/app_spacing.dart';
import '../../constants/app_theme_tokens.dart';
import '../../constants/referee_colors.dart';
import '../../models/jockey_invitation_data.dart';
import '../../viewmodels/jockey_invitation_viewmodel.dart';
import '../../widgets/jockey/jockey_app_bar.dart';
import '../../widgets/jockey/jockey_dashboard_widgets.dart';
import '../../widgets/jockey/jockey_invitation_widgets.dart';
import '../../widgets/jockey/jockey_state_widgets.dart';

typedef JockeyInvitationDetailBuilder =
    Widget Function(BuildContext context, String invitationId);

class JockeyInvitationsScreen extends StatefulWidget {
  const JockeyInvitationsScreen({
    super.key,
    this.viewModel,
    this.detailBuilder,
  });

  final JockeyInvitationsViewModel? viewModel;
  final JockeyInvitationDetailBuilder? detailBuilder;

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

  Future<void> _openDetail(String id) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) =>
            widget.detailBuilder?.call(context, id) ??
            JockeyInvitationDetailScreen(invitationId: id),
      ),
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
    final visibleInvitations = _viewModel.visibleInvitations;

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
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1000),
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
                                  'Theo dõi các lời mời từ chủ ngựa và trạng thái phản hồi.',
                                  style: AppTypography.bodyMd(
                                    RefereeColors.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.lg),
                                JockeyInvitationFilterChips(
                                  selected: _viewModel.selectedFilter,
                                  onSelected: _viewModel.selectFilter,
                                ),
                                const SizedBox(height: AppSpacing.lg),
                                if (_viewModel.loadError != null)
                                  JockeyStateMessage(
                                    message: _viewModel.loadError!,
                                    onRetry: _viewModel.loadInvitations,
                                    icon: Icons.error_outline,
                                  )
                                else if (visibleInvitations.isEmpty)
                                  JockeyStateMessage(
                                    message: _viewModel.emptyMessage,
                                    icon: Icons.mark_email_unread_outlined,
                                  )
                                else
                                  for (final item in visibleInvitations) ...[
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
    _viewModel =
        widget.viewModel ??
        JockeyInvitationDetailViewModel(invitationId: widget.invitationId);
    _viewModel.addListener(_onChanged);
    _viewModel.loadDetail();
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
    final data = _viewModel.data;

    return Scaffold(
      backgroundColor: RefereeColors.background,
      appBar: const JockeyAppBar(
        showBack: true,
        showBrandTitle: false,
        titleOverride: 'CHI TIẾT LỜI MỜI',
        showNotificationAction: false,
      ),
      body: JockeySpeedlineBackground(
        child: _viewModel.isLoading && data == null
            ? const Center(
                child: CircularProgressIndicator(
                  color: RefereeColors.championshipGold,
                ),
              )
            : RefreshIndicator(
                color: RefereeColors.championshipGold,
                onRefresh: _viewModel.loadDetail,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.lg,
                    AppSpacing.md,
                    AppSpacing.xl,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1000),
                      child: _viewModel.loadError != null
                          ? JockeyStateMessage(
                              message: _viewModel.loadError!,
                              onRetry: _viewModel.loadDetail,
                              icon: Icons.error_outline,
                            )
                          : data == null
                          ? const JockeyStateMessage(
                              message: 'Không có dữ liệu lời mời.',
                            )
                          : _InvitationDetailContent(data: data),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

class _InvitationDetailContent extends StatelessWidget {
  const _InvitationDetailContent({required this.data});

  final JockeyInvitationDetail data;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 760;
        final left = Column(
          children: [
            JockeyInvitationPartyCard(detail: data),
            const SizedBox(height: AppSpacing.lg),
            JockeyInvitationMessageCard(detail: data),
          ],
        );
        final right = Column(
          children: [
            JockeyInvitationRaceCard(detail: data),
            const SizedBox(height: AppSpacing.lg),
            JockeyInvitationTimelineCard(detail: data),
          ],
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            JockeyInvitationDetailHeader(detail: data),
            const SizedBox(height: AppSpacing.lg),
            if (isWide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: left),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(child: right),
                ],
              )
            else ...[
              left,
              const SizedBox(height: AppSpacing.lg),
              right,
            ],
          ],
        );
      },
    );
  }
}
