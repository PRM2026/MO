import 'package:flutter/material.dart';

import '../../constants/app_spacing.dart';
import '../../constants/app_theme_tokens.dart';
import '../../constants/referee_colors.dart';
import '../../models/jockey_schedule_data.dart';
import '../../utils/app_toast.dart';
import '../../viewmodels/jockey_schedule_viewmodel.dart';
import '../../widgets/jockey/jockey_app_bar.dart';
import '../../widgets/jockey/jockey_dashboard_widgets.dart';
import '../../widgets/jockey/jockey_schedule_widgets.dart';

class JockeyScheduleScreen extends StatefulWidget {
  const JockeyScheduleScreen({super.key, this.viewModel});

  final JockeyScheduleViewModel? viewModel;

  @override
  State<JockeyScheduleScreen> createState() => _JockeyScheduleScreenState();
}

class _JockeyScheduleScreenState extends State<JockeyScheduleScreen> {
  late final JockeyScheduleViewModel _viewModel;
  late final bool _ownsViewModel;

  @override
  void initState() {
    super.initState();
    _ownsViewModel = widget.viewModel == null;
    _viewModel = widget.viewModel ?? JockeyScheduleViewModel();
    _viewModel.addListener(_onChanged);
    _viewModel.loadSchedule();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _handleConfirm(String raceId) async {
    final success = await _viewModel.confirmRace(raceId);
    if (!mounted || !success) return;
    AppToast.showSuccess(context, 'Đã xác nhận tham gia cuộc đua');
  }

  void _handleDirections(JockeyRaceScheduleItem race) {
    AppToast.showSuccess(
      context,
      'Đang mở chỉ đường',
      subtitle: race.venue,
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
    final data = _viewModel.data;

    return Scaffold(
      backgroundColor: RefereeColors.background,
      appBar: JockeyAppBar(profileImageUrl: data?.profileImageUrl),
      body: JockeySpeedlineBackground(
        child: _viewModel.isLoading && data == null
            ? const Center(
                child: CircularProgressIndicator(
                  color: RefereeColors.championshipGold,
                ),
              )
            : RefreshIndicator(
                color: RefereeColors.championshipGold,
                onRefresh: _viewModel.loadSchedule,
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
                            constraints: const BoxConstraints(maxWidth: 1280),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Lịch Thi Đấu',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTypography.displayLg(
                                          RefereeColors.onSurface,
                                        ).copyWith(fontSize: 28),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    JockeyScheduleViewToggle(
                                      mode: _viewModel.viewMode,
                                      onChanged: _viewModel.setViewMode,
                                    ),
                                  ],
                                ),
                                if (_viewModel.viewMode ==
                                    JockeyScheduleViewMode.calendar) ...[
                                  const SizedBox(height: AppSpacing.lg),
                                  JockeyScheduleDateSelector(
                                    dates: data!.dates,
                                    selectedDateKey: _viewModel.selectedDateKey,
                                    onDateSelected: _viewModel.selectDate,
                                  ),
                                ],
                                const SizedBox(height: AppSpacing.xl),
                                JockeyScheduleTimeline(
                                  races: _viewModel.visibleRaces,
                                  onConfirm: _handleConfirm,
                                  onDirections: _handleDirections,
                                ),
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
