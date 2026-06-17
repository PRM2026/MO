import 'package:flutter/material.dart';

import '../../constants/app_spacing.dart';
import '../../constants/app_theme_tokens.dart';
import '../../constants/referee_colors.dart';
import '../../models/race_result_confirmation.dart';
import '../../utils/app_toast.dart';
import '../../utils/date_format.dart';
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
    if (!mounted) return;

    if (success) {
      AppToast.showSuccess(
        context,
        'Đã chốt kết quả cuối cùng',
        subtitle: 'Quy trình giải ngân tiền thưởng đã được kích hoạt.',
      );
    } else {
      AppToast.showError(
        context,
        'Không thể chốt kết quả. Vui lòng nhập đầy đủ dữ liệu trước khi xác nhận.',
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
                                data: data,
                                onConfirm: _handleConfirm,
                                isConfirming: _viewModel.isConfirming,
                              ),
                              if (data != null && data.races.isNotEmpty) ...[
                                const SizedBox(height: 16),
                                RefereeRaceSelector(
                                  races: data.races,
                                  selectedRaceId: data.selectedRaceId,
                                  onChanged: (raceId) {
                                    if (raceId != null) {
                                      _viewModel.selectRace(raceId);
                                    }
                                  },
                                ),
                              ],
                              if (data != null &&
                                  data.races.isNotEmpty &&
                                  data.infoMessage != null) ...[
                                const SizedBox(height: 16),
                                RefereeInfoBanner(message: data.infoMessage!),
                              ],
                              const SizedBox(height: AppSpacing.xl),
                              if (data != null && data.races.isNotEmpty)
                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    final isWide =
                                        constraints.maxWidth >= 960;

                                    final main = RefereeResultsTable(
                                      rows: data.finishers,
                                      isFinalized: data.isFinalized,
                                    );

                                    final side = RefereePrizePreviewCard(
                                      totalPrizePool: data.totalPrizePool,
                                      breakdown: data.prizeBreakdown,
                                    );

                                    if (isWide) {
                                      return Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(flex: 8, child: main),
                                          const SizedBox(width: AppSpacing.lg),
                                          Expanded(flex: 4, child: side),
                                        ],
                                      );
                                    }

                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        main,
                                        const SizedBox(height: AppSpacing.lg),
                                        side,
                                      ],
                                    );
                                  },
                                )
                              else
                                RefereeInfoBanner(
                                  message: data?.infoMessage ??
                                      'Chưa có cuộc đua nào để xem kết quả.',
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
    required this.data,
    required this.onConfirm,
    required this.isConfirming,
  });

  final RaceResultConfirmationData? data;
  final VoidCallback onConfirm;
  final bool isConfirming;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 720;
        final raceCode = data?.raceCode ?? '—';
        final raceName = data?.raceName ?? '—';
        final statusLabel = data?.raceStatusLabel ?? '—';
        final finalizedAt = data?.resultFinalizedAt;

        final titleBlock = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RefereeBreadcrumb(raceCode: raceCode, raceName: raceName),
            const SizedBox(height: 8),
            Text(
              'Xem lại & Xác nhận Kết quả',
              style: AppTypography.displayLg(RefereeColors.onSurface),
            ),
            const SizedBox(height: 4),
            Text(
              data?.isFinalized == true
                  ? 'Kết quả cuộc đua đã được chốt trên hệ thống.'
                  : 'Xem kết quả và thông tin giải thưởng từ cuộc đua được giao.',
              style: AppTypography.bodyMd(RefereeColors.onSurfaceVariant),
            ),
            if (data?.isFinalized == true) ...[
              const SizedBox(height: 8),
              Text(
                'Trạng thái: $statusLabel'
                '${finalizedAt != null ? ' • ${formatDisplayDateTime(finalizedAt.toIso8601String())}' : ''}',
                style: AppTypography.labelCaps(RefereeColors.successEmerald)
                    .copyWith(fontWeight: FontWeight.w500, letterSpacing: 0),
              ),
            ],
          ],
        );

        final showConfirm = data?.canConfirm == true;
        final actions = showConfirm
            ? FilledButton(
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
              )
            : data?.isFinalized == true
                ? Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: RefereeColors.successEmerald.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color:
                            RefereeColors.successEmerald.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      'ĐÃ CHỐT KẾT QUẢ',
                      style: AppTypography.labelCaps(
                        RefereeColors.successEmerald,
                      ).copyWith(fontWeight: FontWeight.w700),
                    ),
                  )
                : const SizedBox.shrink();

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
            if (showConfirm || data?.isFinalized == true) ...[
              const SizedBox(height: 16),
              actions,
            ],
          ],
        );
      },
    );
  }
}
