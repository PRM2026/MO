import 'package:flutter/material.dart';

import '../../constants/app_spacing.dart';
import '../../constants/app_theme_tokens.dart';
import '../../constants/referee_colors.dart';
import '../../viewmodels/jockey_horses_viewmodel.dart';
import '../../widgets/jockey/jockey_app_bar.dart';
import '../../widgets/jockey/jockey_dashboard_widgets.dart';
import '../../widgets/jockey/jockey_horse_widgets.dart';
import '../../widgets/jockey/jockey_state_widgets.dart';

class JockeyHorsesScreen extends StatefulWidget {
  const JockeyHorsesScreen({super.key, this.viewModel});

  final JockeyHorsesViewModel? viewModel;

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
    _viewModel.loadHorses();
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
                onRefresh: _viewModel.loadHorses,
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
                                Text(
                                  'Ngua duoc phan cong',
                                  style: AppTypography.displayLg(
                                    RefereeColors.onSurface,
                                  ).copyWith(fontSize: 28),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Danh sach chien ma duoc phan cong hien tai.',
                                  style: AppTypography.bodyMd(
                                    RefereeColors.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.lg),
                                if (data == null)
                                  JockeyStateMessage(
                                    message:
                                        _viewModel.errorMessage ??
                                        'Chua co du lieu ngua duoc phan cong.',
                                    onRetry: _viewModel.loadHorses,
                                  )
                                else if (data.horses.isEmpty)
                                  const JockeyStateMessage(
                                    message: 'Chua co ngua nao duoc phan cong.',
                                  )
                                else
                                  LayoutBuilder(
                                    builder: (context, constraints) {
                                      final width = constraints.maxWidth;
                                      final crossAxisCount = width >= 960
                                          ? 3
                                          : width >= 640
                                          ? 2
                                          : 1;

                                      return GridView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: crossAxisCount,
                                              crossAxisSpacing: 24,
                                              mainAxisSpacing: 24,
                                              childAspectRatio:
                                                  crossAxisCount == 1
                                                  ? 0.82
                                                  : 0.72,
                                            ),
                                        itemCount: data.horses.length,
                                        itemBuilder: (context, index) {
                                          final horse = data.horses[index];
                                          return JockeyHorseGridCard(
                                            horse: horse,
                                            onTap: () =>
                                                showJockeyHorseDetailSheet(
                                                  context,
                                                  horse,
                                                ),
                                          );
                                        },
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
