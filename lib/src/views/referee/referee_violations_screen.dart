import 'package:flutter/material.dart';

import '../../constants/app_spacing.dart';
import '../../constants/app_theme_tokens.dart';
import '../../constants/referee_colors.dart';
import '../../models/violation_record.dart';
import '../../utils/app_toast.dart';
import '../../viewmodels/referee_violations_viewmodel.dart';
import '../../widgets/referee/referee_app_bar.dart';
import '../../widgets/referee/referee_form_fields.dart';
import '../../widgets/referee/referee_glass_card.dart';
import '../../widgets/referee/referee_violation_panel.dart';

class RefereeViolationsScreen extends StatefulWidget {
  const RefereeViolationsScreen({super.key, this.viewModel});

  final RefereeViolationsViewModel? viewModel;

  @override
  State<RefereeViolationsScreen> createState() =>
      _RefereeViolationsScreenState();
}

class _RefereeViolationsScreenState extends State<RefereeViolationsScreen> {
  late final RefereeViolationsViewModel _viewModel;
  late final TextEditingController _penaltyController;
  late final TextEditingController _notesController;
  late final bool _ownsViewModel;

  @override
  void initState() {
    super.initState();
    _ownsViewModel = widget.viewModel == null;
    _viewModel = widget.viewModel ?? RefereeViolationsViewModel();
    _viewModel.addListener(_onChanged);
    _penaltyController = TextEditingController();
    _notesController = TextEditingController();
    _viewModel.loadPage();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _handleSubmit() async {
    final success = await _viewModel.submitViolation();
    if (!mounted || !success) return;
    _penaltyController.clear();
    _notesController.clear();
    AppToast.showSuccess(
      context,
      'Đã ghi nhận thành công',
      subtitle: 'Dữ liệu đã được gửi tới hội đồng trọng tài.',
    );
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onChanged);
    if (_ownsViewModel) _viewModel.dispose();
    _penaltyController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = _viewModel.data;
    final options = data?.options;

    return Scaffold(
      backgroundColor: RefereeColors.background,
      appBar: RefereeAppBar(profileImageUrl: data?.profileImageUrl),
      body: _viewModel.isLoading && data == null
          ? const Center(
              child: CircularProgressIndicator(color: RefereeColors.tertiary),
            )
          : RefreshIndicator(
              color: RefereeColors.tertiary,
              onRefresh: _viewModel.loadPage,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screenPadding,
                      AppSpacing.lg,
                      AppSpacing.screenPadding,
                      100,
                    ),
                    sliver: SliverLayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.crossAxisExtent >= 960;

                        final form = _ViolationForm(
                          viewModel: _viewModel,
                          options: options!,
                          penaltyController: _penaltyController,
                          notesController: _notesController,
                          onSubmit: _handleSubmit,
                        );

                        final sidebar = Column(
                          children: [
                            RefereeViolationSummaryCard(
                              totalViolations: data!.totalViolations,
                              pendingCount: data.pendingCount,
                            ),
                            const SizedBox(height: 24),
                            RefereeViolationListPanel(
                              records: data.records,
                            ),
                          ],
                        );

                        if (isWide) {
                          return SliverToBoxAdapter(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(flex: 7, child: form),
                                const SizedBox(width: 24),
                                Expanded(flex: 5, child: sidebar),
                              ],
                            ),
                          );
                        }

                        return SliverList(
                          delegate: SliverChildListDelegate([
                            form,
                            const SizedBox(height: 24),
                            sidebar,
                          ]),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _ViolationForm extends StatelessWidget {
  const _ViolationForm({
    required this.viewModel,
    required this.options,
    required this.penaltyController,
    required this.notesController,
    required this.onSubmit,
  });

  final RefereeViolationsViewModel viewModel;
  final ViolationFormOptions options;
  final TextEditingController penaltyController;
  final TextEditingController notesController;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return RefereeGlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.report_problem_outlined,
                color: RefereeColors.tertiary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Ghi nhận vi phạm mới',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.headlineSm(RefereeColors.onSurface)
                      .copyWith(fontSize: 22, height: 28 / 22),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final threeCol = constraints.maxWidth >= 640;
              if (threeCol) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: RefereeFormDropdown(
                        label: 'Làn đua',
                        value: viewModel.selectedLane,
                        items: options.lanes,
                        onChanged: viewModel.updateLane,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: RefereeFormDropdown(
                        label: 'Ngựa (Horse)',
                        value: viewModel.selectedHorse,
                        items: options.horses,
                        onChanged: viewModel.updateHorse,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: RefereeFormDropdown(
                        label: 'Nài ngựa (Jockey)',
                        value: viewModel.selectedJockey,
                        items: options.jockeys,
                        onChanged: viewModel.updateJockey,
                      ),
                    ),
                  ],
                );
              }

              return Column(
                children: [
                  RefereeFormDropdown(
                    label: 'Làn đua',
                    value: viewModel.selectedLane,
                    items: options.lanes,
                    onChanged: viewModel.updateLane,
                  ),
                  const SizedBox(height: 16),
                  RefereeFormDropdown(
                    label: 'Ngựa (Horse)',
                    value: viewModel.selectedHorse,
                    items: options.horses,
                    onChanged: viewModel.updateHorse,
                  ),
                  const SizedBox(height: 16),
                  RefereeFormDropdown(
                    label: 'Nài ngựa (Jockey)',
                    value: viewModel.selectedJockey,
                    items: options.jockeys,
                    onChanged: viewModel.updateJockey,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth >= 480) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: RefereeFormDropdown(
                        label: 'Loại vi phạm',
                        value: viewModel.selectedViolationType,
                        items: options.violationTypes,
                        onChanged: viewModel.updateViolationType,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: RefereeFormTextField(
                        label: 'Mức phạt đề xuất',
                        controller: penaltyController,
                        hint: 'Ví dụ: 5.000.000 VND / Cấm 2 trận',
                        onChanged: viewModel.updatePenalty,
                      ),
                    ),
                  ],
                );
              }

              return Column(
                children: [
                  RefereeFormDropdown(
                    label: 'Loại vi phạm',
                    value: viewModel.selectedViolationType,
                    items: options.violationTypes,
                    onChanged: viewModel.updateViolationType,
                  ),
                  const SizedBox(height: 16),
                  RefereeFormTextField(
                    label: 'Mức phạt đề xuất',
                    controller: penaltyController,
                    hint: 'Ví dụ: 5.000.000 VND / Cấm 2 trận',
                    onChanged: viewModel.updatePenalty,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          const RefereeUploadZone(),
          const SizedBox(height: 16),
          RefereeFormTextField(
            label: 'Ghi chú chi tiết',
            controller: notesController,
            hint: 'Mô tả diễn biến vi phạm...',
            maxLines: 4,
            onChanged: viewModel.updateNotes,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: viewModel.isSubmitting ? null : onSubmit,
            style: FilledButton.styleFrom(
              backgroundColor: RefereeColors.tertiary,
              foregroundColor: RefereeColors.onTertiary,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: viewModel.isSubmitting
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'XÁC NHẬN GHI NHẬN',
                        style: AppTypography.labelCaps(RefereeColors.onTertiary)
                            .copyWith(fontSize: 14),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.check_circle_outline, size: 20),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
