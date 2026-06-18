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
  late final TextEditingController _evidenceController;
  late final TextEditingController _notesController;
  late final bool _ownsViewModel;

  @override
  void initState() {
    super.initState();
    _ownsViewModel = widget.viewModel == null;
    _viewModel = widget.viewModel ?? RefereeViolationsViewModel();
    _viewModel.addListener(_onChanged);
    _evidenceController = TextEditingController();
    _notesController = TextEditingController();
    _viewModel.loadPage();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _handleSubmit() async {
    final success = await _viewModel.submitViolation();
    if (!mounted || !success) return;
    _evidenceController.clear();
    _notesController.clear();
    AppToast.showSuccess(
      context,
      'Đã ghi nhận (thử nghiệm)',
      subtitle: 'Tính năng đang chờ tích hợp API từ backend.',
    );
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onChanged);
    if (_ownsViewModel) _viewModel.dispose();
    _evidenceController.dispose();
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
                          evidenceController: _evidenceController,
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

class _PendingBackendBanner extends StatelessWidget {
  const _PendingBackendBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: RefereeColors.tertiary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: RefereeColors.tertiary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: RefereeColors.tertiary,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Tính năng ghi vi phạm đang chờ tích hợp API. '
              'Dữ liệu chưa được gửi lên máy chủ.',
              style: AppTypography.labelCaps(
                RefereeColors.tertiary,
              ).copyWith(
                fontWeight: FontWeight.w400,
                height: 1.5,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ViolationForm extends StatelessWidget {
  const _ViolationForm({
    required this.viewModel,
    required this.options,
    required this.evidenceController,
    required this.notesController,
    required this.onSubmit,
  });

  final RefereeViolationsViewModel viewModel;
  final ViolationFormOptions options;
  final TextEditingController evidenceController;
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
          const SizedBox(height: 16),
          const _PendingBackendBanner(),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final twoCol = constraints.maxWidth >= 480;
              if (twoCol) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                        label: 'Loại vi phạm',
                        value: viewModel.selectedViolationType,
                        items: options.violationTypes,
                        onChanged: viewModel.updateViolationType,
                      ),
                    ),
                  ],
                );
              }

              return Column(
                children: [
                  RefereeFormDropdown(
                    label: 'Ngựa (Horse)',
                    value: viewModel.selectedHorse,
                    items: options.horses,
                    onChanged: viewModel.updateHorse,
                  ),
                  const SizedBox(height: 16),
                  RefereeFormDropdown(
                    label: 'Loại vi phạm',
                    value: viewModel.selectedViolationType,
                    items: options.violationTypes,
                    onChanged: viewModel.updateViolationType,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          RefereeFormTextField(
            label: 'URL bằng chứng (tùy chọn)',
            controller: evidenceController,
            hint: 'https://...',
            onChanged: viewModel.updateEvidenceUrl,
          ),
          const SizedBox(height: 16),
          RefereeFormTextField(
            label: 'Lý do / Ghi chú chi tiết',
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
