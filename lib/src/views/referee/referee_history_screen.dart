import 'package:flutter/material.dart';

import '../../constants/app_spacing.dart';
import '../../constants/app_theme_tokens.dart';
import '../../constants/referee_colors.dart';
import '../../models/race_result_confirmation.dart';
import '../../utils/app_toast.dart';
import '../../viewmodels/referee_history_viewmodel.dart';
import '../../widgets/referee/referee_app_bar.dart';
import '../../widgets/referee/referee_result_widgets.dart';

class RefereeHistoryScreen extends StatefulWidget {
  const RefereeHistoryScreen({super.key, this.viewModel});

  final RefereeHistoryViewModel? viewModel;

  @override
  State<RefereeHistoryScreen> createState() => _RefereeHistoryScreenState();
}

class _RefereeHistoryScreenState extends State<RefereeHistoryScreen> {
  late final RefereeHistoryViewModel _viewModel;
  late final bool _ownsViewModel;

  @override
  void initState() {
    super.initState();
    _ownsViewModel = widget.viewModel == null;
    _viewModel = widget.viewModel ?? RefereeHistoryViewModel();
    _viewModel.addListener(_onChanged);
    _viewModel.loadData();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _handleConfirm() async {
    final agreed = await showRefereeConfirmResultDialog(context);
    if (!mounted || agreed != true) return;

    final success = await _viewModel.confirmResults();
    if (!mounted || !success) return;

    AppToast.showSuccess(
      context,
      'Đã chốt kết quả cuối cùng',
      subtitle: 'Quy trình giải ngân tiền thưởng đã được kích hoạt.',
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
      appBar: RefereeAppBar(profileImageUrl: data?.profileImageUrl),
      body: _viewModel.isLoading && data == null
          ? const Center(
              child: CircularProgressIndicator(color: RefereeColors.tertiary),
            )
          : RefreshIndicator(
              color: RefereeColors.tertiary,
              onRefresh: _viewModel.loadData,
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
                              _PageHeader(
                                raceCode: data?.raceCode ?? '#829',
                                onPrint: () {},
                                onConfirm: _handleConfirm,
                                isConfirming: _viewModel.isConfirming,
                              ),
                              const SizedBox(height: AppSpacing.xl),
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  final isWide = constraints.maxWidth >= 960;

                                  if (isWide) {
                                    return Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          flex: 8,
                                          child: _MainColumn(data: data!),
                                        ),
                                        const SizedBox(width: AppSpacing.lg),
                                        Expanded(
                                          flex: 4,
                                          child: _SideColumn(data: data),
                                        ),
                                      ],
                                    );
                                  }

                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      _MainColumn(data: data!),
                                      const SizedBox(height: AppSpacing.lg),
                                      _SideColumn(data: data),
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
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({
    required this.raceCode,
    required this.onPrint,
    required this.onConfirm,
    required this.isConfirming,
  });

  final String raceCode;
  final VoidCallback onPrint;
  final VoidCallback onConfirm;
  final bool isConfirming;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 720;

        final titleBlock = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RefereeBreadcrumb(raceCode: raceCode),
            const SizedBox(height: 8),
            Text(
              'Xem lại & Xác nhận Kết quả',
              style: AppTypography.displayLg(RefereeColors.onSurface),
            ),
            const SizedBox(height: 4),
            Text(
              'Vui lòng kiểm tra kỹ các thông số hoàn thành và vi phạm trước khi chốt sổ.',
              style: AppTypography.bodyMd(RefereeColors.onSurfaceVariant),
            ),
          ],
        );

        final actions = Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.end,
          children: [
            OutlinedButton.icon(
              onPressed: onPrint,
              style: OutlinedButton.styleFrom(
                foregroundColor: RefereeColors.onSurface,
                side: const BorderSide(color: RefereeColors.outlineVariant),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              icon: const Icon(Icons.print_outlined, size: 20),
              label: const Text('In báo cáo'),
            ),
            FilledButton(
              onPressed: isConfirming ? null : onConfirm,
              style: FilledButton.styleFrom(
                backgroundColor: RefereeColors.championshipGold,
                foregroundColor: RefereeColors.portalSurface,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              child: isConfirming
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: RefereeColors.portalSurface,
                      ),
                    )
                  : const Text(
                      'Xác nhận kết quả cuối cùng',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
            ),
          ],
        );

        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(child: titleBlock),
              actions,
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            titleBlock,
            const SizedBox(height: 16),
            actions,
          ],
        );
      },
    );
  }
}

class _MainColumn extends StatelessWidget {
  const _MainColumn({required this.data});

  final RaceResultConfirmationData data;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        RefereeResultsTable(rows: data.finishers),
        const SizedBox(height: AppSpacing.lg),
        RefereeAppliedViolationsCard(violations: data.appliedViolations),
      ],
    );
  }
}

class _SideColumn extends StatelessWidget {
  const _SideColumn({required this.data});

  final RaceResultConfirmationData data;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        RefereePrizePreviewCard(
          totalPrizePool: data.totalPrizePool,
          breakdown: data.prizeBreakdown,
        ),
        const SizedBox(height: AppSpacing.lg),
        RefereeActivityTimeline(entries: data.activityLog),
      ],
    );
  }
}
