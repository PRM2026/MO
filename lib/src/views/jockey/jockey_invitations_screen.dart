import 'package:flutter/material.dart';

import '../../constants/app_spacing.dart';
import '../../constants/app_theme_tokens.dart';
import '../../constants/referee_colors.dart';
import '../../models/jockey_invitation_data.dart';
import '../../utils/app_toast.dart';
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
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (context) =>
            widget.detailBuilder?.call(context, id) ??
            JockeyInvitationDetailScreen(invitationId: id),
      ),
    );
    if (!mounted || changed != true) return;
    await _viewModel.loadInvitations();
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

  Future<void> _handleAccept() async {
    final note = await _showDecisionDialog(
      title: 'Chấp nhận lời mời',
      confirmLabel: 'Chấp nhận',
      noteHint: 'Ghi chú cho chủ ngựa (không bắt buộc)',
    );
    if (!mounted || note == null) return;

    final success = await _viewModel.acceptInvitation(note: note);
    if (!mounted) return;
    if (success) {
      AppToast.showSuccess(context, 'Đã chấp nhận lời mời');
      return;
    }

    AppToast.showError(
      context,
      _viewModel.actionError ?? 'Không thể chấp nhận lời mời.',
    );
  }

  Future<void> _handleReject() async {
    final note = await _showDecisionDialog(
      title: 'Từ chối lời mời',
      confirmLabel: 'Từ chối',
      noteHint: 'Lý do từ chối (không bắt buộc)',
    );
    if (!mounted || note == null) return;

    final success = await _viewModel.rejectInvitation(note: note);
    if (!mounted) return;
    if (success) {
      AppToast.showSuccess(context, 'Đã từ chối lời mời');
      return;
    }

    AppToast.showError(
      context,
      _viewModel.actionError ?? 'Không thể từ chối lời mời.',
    );
  }

  Future<String?> _showDecisionDialog({
    required String title,
    required String confirmLabel,
    required String noteHint,
  }) => showDialog<String>(
    context: context,
    builder: (context) => _InvitationDecisionDialog(
      title: title,
      confirmLabel: confirmLabel,
      noteHint: noteHint,
      isSubmitting: _viewModel.isProcessing,
    ),
  );

  @override
  void dispose() {
    _viewModel.removeListener(_onChanged);
    if (_ownsViewModel) _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = _viewModel.data;
    final isPending = data?.statusCode == 'PENDING';

    return PopScope<bool>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.of(context).pop(_viewModel.actionCompleted);
      },
      child: Scaffold(
        backgroundColor: RefereeColors.background,
        appBar: const JockeyAppBar(
          showBack: true,
          showBrandTitle: false,
          titleOverride: 'CHI TIẾT LỜI MỜI',
          showNotificationAction: false,
        ),
        bottomNavigationBar: isPending
            ? JockeyInvitationActionBar(
                isProcessing: _viewModel.isProcessing,
                onReject: _handleReject,
                onAccept: _handleAccept,
              )
            : null,
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
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.lg,
                      AppSpacing.md,
                      isPending ? 120 : AppSpacing.xl,
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
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  if (_viewModel.actionError != null) ...[
                                    Text(
                                      _viewModel.actionError!,
                                      textAlign: TextAlign.center,
                                      style: AppTypography.bodyMd(
                                        RefereeColors.statusRed,
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.md),
                                  ],
                                  _InvitationDetailContent(data: data),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

class _InvitationDecisionDialog extends StatefulWidget {
  const _InvitationDecisionDialog({
    required this.title,
    required this.confirmLabel,
    required this.noteHint,
    required this.isSubmitting,
  });

  final String title;
  final String confirmLabel;
  final String noteHint;
  final bool isSubmitting;

  @override
  State<_InvitationDecisionDialog> createState() =>
      _InvitationDecisionDialogState();
}

class _InvitationDecisionDialogState extends State<_InvitationDecisionDialog> {
  late final TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final note = _controller.text.trim();
    if (note.length > JockeyInvitationDetailViewModel.maxDecisionNoteLength) {
      setState(() => _errorText = 'Ghi chú tối đa 1000 ký tự.');
      return;
    }
    Navigator.pop(context, note);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        enabled: !widget.isSubmitting,
        maxLength: JockeyInvitationDetailViewModel.maxDecisionNoteLength,
        maxLines: 4,
        decoration: InputDecoration(
          hintText: widget.noteHint,
          errorText: _errorText,
          border: const OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: widget.isSubmitting ? null : () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        FilledButton(
          onPressed: widget.isSubmitting ? null : _submit,
          child: widget.isSubmitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.confirmLabel),
        ),
      ],
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
