import 'package:flutter/material.dart';

import '../../constants/app_spacing.dart';
import '../../constants/app_theme_tokens.dart';
import '../../constants/referee_colors.dart';
import '../../models/jockey_horse_data.dart';
import '../../routes/app_routes.dart';
import '../../viewmodels/jockey_horses_viewmodel.dart';
import '../../widgets/jockey/jockey_app_bar.dart';
import '../../widgets/jockey/jockey_dashboard_widgets.dart';
import '../../widgets/jockey/jockey_horse_widgets.dart';
import '../../widgets/jockey/jockey_state_widgets.dart';

typedef JockeyAssignmentDestinationBuilder =
    Widget Function(BuildContext context, String id);

class JockeyHorsesScreen extends StatefulWidget {
  const JockeyHorsesScreen({
    super.key,
    this.viewModel,
    this.raceDetailBuilder,
    this.invitationDetailBuilder,
  });

  final JockeyHorsesViewModel? viewModel;
  final JockeyAssignmentDestinationBuilder? raceDetailBuilder;
  final JockeyAssignmentDestinationBuilder? invitationDetailBuilder;

  @override
  State<JockeyHorsesScreen> createState() => _JockeyHorsesScreenState();
}

class _JockeyHorsesScreenState extends State<JockeyHorsesScreen> {
  late final JockeyHorsesViewModel _viewModel;
  late final bool _ownsViewModel;

  @override
  void initState() {
    super.initState();
    _ownsViewModel = widget.viewModel == null;
    _viewModel = widget.viewModel ?? JockeyHorsesViewModel();
    _viewModel.addListener(_onChanged);
    _viewModel.loadAssignments();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _openAssignment(JockeyHorseAssignmentItem assignment) async {
    if (assignment.hasRaceDetail && assignment.raceId != null) {
      final builder = widget.raceDetailBuilder;
      if (builder != null) {
        await Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (context) => builder(context, assignment.raceId!),
          ),
        );
      } else {
        AppRoutes.openJockeyRaceDetail(context, assignment.raceId!);
      }
      return;
    }

    final builder = widget.invitationDetailBuilder;
    if (builder != null) {
      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (context) => builder(context, assignment.invitationId),
        ),
      );
    } else {
      await AppRoutes.openJockeyInvitationDetail(
        context,
        assignment.invitationId,
      );
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
                onRefresh: _viewModel.loadAssignments,
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
                            constraints: const BoxConstraints(maxWidth: 1100),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'Ngựa được phân công',
                                  style: AppTypography.displayLg(
                                    RefereeColors.onSurface,
                                  ).copyWith(fontSize: 28),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Các phân công bạn đã nhận từ chủ ngựa.',
                                  style: AppTypography.bodyMd(
                                    RefereeColors.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.lg),
                                if (data == null)
                                  JockeyStateMessage(
                                    message:
                                        _viewModel.errorMessage ??
                                        'Chưa có dữ liệu ngựa được phân công.',
                                    onRetry: _viewModel.loadAssignments,
                                  )
                                else if (data.assignments.isEmpty)
                                  const JockeyStateMessage(
                                    message: 'Chưa có ngựa nào được phân công.',
                                    icon: Icons.pets_outlined,
                                  )
                                else
                                  LayoutBuilder(
                                    builder: (context, constraints) {
                                      final isWide =
                                          constraints.maxWidth >= 720;
                                      final cardWidth = isWide
                                          ? (constraints.maxWidth -
                                                    AppSpacing.lg) /
                                                2
                                          : constraints.maxWidth;
                                      return Wrap(
                                        spacing: AppSpacing.lg,
                                        runSpacing: AppSpacing.lg,
                                        children: [
                                          for (final assignment
                                              in data.assignments)
                                            SizedBox(
                                              width: cardWidth,
                                              child: JockeyHorseAssignmentCard(
                                                assignment: assignment,
                                                onTap: () =>
                                                    _openAssignment(assignment),
                                              ),
                                            ),
                                        ],
                                      );
                                    },
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
