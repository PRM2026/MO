import 'package:flutter/material.dart';

import '../../constants/app_spacing.dart';
import '../../constants/referee_colors.dart';
import '../../models/notification_response.dart';
import '../../viewmodels/jockey_notifications_viewmodel.dart';
import '../../widgets/jockey/jockey_app_bar.dart';
import '../../widgets/jockey/jockey_dashboard_widgets.dart';
import '../../widgets/jockey/jockey_notification_widgets.dart';
import '../../widgets/jockey/jockey_state_widgets.dart';

class JockeyNotificationsScreen extends StatefulWidget {
  const JockeyNotificationsScreen({
    super.key,
    this.viewModel,
    this.title = 'Thông báo',
  });

  final JockeyNotificationsViewModel? viewModel;
  final String title;

  @override
  State<JockeyNotificationsScreen> createState() =>
      _JockeyNotificationsScreenState();
}

class _JockeyNotificationsScreenState extends State<JockeyNotificationsScreen> {
  late final JockeyNotificationsViewModel _viewModel;
  late final bool _ownsViewModel;

  @override
  void initState() {
    super.initState();
    _ownsViewModel = widget.viewModel == null;
    _viewModel = widget.viewModel ?? JockeyNotificationsViewModel();
    _viewModel.addListener(_onChanged);
    _viewModel.loadInitial();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  void _markRead(NotificationResponse item) {
    _viewModel.markRead(item);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onChanged);
    if (_ownsViewModel) _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final initialBlocking =
        _viewModel.isInitialLoading && _viewModel.notifications.isEmpty;
    return Scaffold(
      backgroundColor: RefereeColors.background,
      appBar: JockeyAppBar(
        showBack: true,
        showBrandTitle: false,
        titleOverride: widget.title,
        showNotificationAction: false,
      ),
      body: JockeySpeedlineBackground(
        child: initialBlocking
            ? const Center(
                child: CircularProgressIndicator(
                  color: RefereeColors.championshipGold,
                ),
              )
            : RefreshIndicator(
                color: RefereeColors.championshipGold,
                onRefresh: _viewModel.refresh,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        AppSpacing.lg,
                        AppSpacing.md,
                        AppSpacing.xl,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 920),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                JockeyNotificationHeader(
                                  unreadCount: _viewModel.unreadCount,
                                  isMarkingAll: _viewModel.isMarkingAll,
                                  onMarkAll: _viewModel.canMarkAll
                                      ? _viewModel.markAllRead
                                      : null,
                                ),
                                const SizedBox(height: AppSpacing.lg),
                                JockeyNotificationFilters(
                                  selected: _viewModel.selectedFilter,
                                  onSelected: _viewModel.selectFilter,
                                ),
                                const SizedBox(height: AppSpacing.lg),
                                if (_viewModel.countError != null) ...[
                                  JockeyNotificationInfoBanner(
                                    message: _viewModel.countError!,
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                ],
                                if (_viewModel.mutationError != null) ...[
                                  JockeyNotificationInfoBanner(
                                    message: _viewModel.mutationError!,
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                ],
                                if (_viewModel.pageError != null)
                                  JockeyStateMessage(
                                    message: _viewModel.pageError!,
                                    icon: Icons.error_outline,
                                    onRetry: _viewModel.refresh,
                                  )
                                else if (_viewModel.notifications.isEmpty)
                                  JockeyNotificationEmptyState(
                                    message: _viewModel.emptyMessage,
                                  )
                                else ...[
                                  JockeyNotificationList(
                                    notifications: _viewModel.notifications,
                                    processingIds: _viewModel.processingIds,
                                    onTap: _markRead,
                                  ),
                                  if (_viewModel.hasMore) ...[
                                    const SizedBox(height: AppSpacing.lg),
                                    JockeyNotificationLoadMore(
                                      isLoading: _viewModel.isLoadingMore,
                                      onPressed: _viewModel.loadMore,
                                    ),
                                  ],
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
