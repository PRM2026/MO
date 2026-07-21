import 'package:flutter/material.dart';

import '../../constants/app_spacing.dart';
import '../../constants/app_theme_tokens.dart';
import '../../constants/referee_colors.dart';
import '../../viewmodels/referee_violations_viewmodel.dart';
import '../../widgets/referee/referee_app_bar.dart';
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
  late final bool _ownsViewModel;

  @override
  void initState() {
    super.initState();
    _ownsViewModel = widget.viewModel == null;
    _viewModel = widget.viewModel ?? RefereeViolationsViewModel();
    _viewModel.addListener(_onChanged);
    _viewModel.loadPage();
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
      appBar: RefereeAppBar(profileImageUrl: data?.profileImageUrl),
      body: _viewModel.isLoading && data == null
          ? const Center(
              child: CircularProgressIndicator(color: RefereeColors.tertiary),
            )
          : _viewModel.errorMessage != null && data == null
          ? _ErrorState(
              message: _viewModel.errorMessage!,
              onRetry: _viewModel.loadPage,
            )
          : RefreshIndicator(
              color: RefereeColors.tertiary,
              onRefresh: _viewModel.loadPage,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenPadding,
                  AppSpacing.lg,
                  AppSpacing.screenPadding,
                  100,
                ),
                children: [
                  Text(
                    'Vi phạm đã ghi',
                    style: AppTypography.headlineSm(
                      RefereeColors.onSurface,
                    ).copyWith(fontSize: 24),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Danh sách vi phạm bạn đã ghi nhận trong các cuộc đua.',
                    style: AppTypography.bodyMd(RefereeColors.onSurfaceVariant),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  RefereeViolationListPanel(records: data!.records),
                ],
              ),
            ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.bodyMd(RefereeColors.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.md),
            FilledButton(onPressed: onRetry, child: const Text('Thử lại')),
          ],
        ),
      ),
    );
  }
}
