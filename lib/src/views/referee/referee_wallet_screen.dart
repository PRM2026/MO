import 'package:flutter/material.dart';

import '../../constants/app_spacing.dart';
import '../../constants/app_theme_tokens.dart';
import '../../constants/referee_colors.dart';
import '../../viewmodels/referee_wallet_viewmodel.dart';
import '../../widgets/referee/referee_app_bar.dart';
import '../../widgets/referee/referee_wallet_widgets.dart';

class RefereeWalletScreen extends StatefulWidget {
  const RefereeWalletScreen({super.key, this.viewModel});

  final RefereeWalletViewModel? viewModel;

  @override
  State<RefereeWalletScreen> createState() => _RefereeWalletScreenState();
}

class _RefereeWalletScreenState extends State<RefereeWalletScreen> {
  late final RefereeWalletViewModel _viewModel;
  late final bool _ownsViewModel;

  @override
  void initState() {
    super.initState();
    _ownsViewModel = widget.viewModel == null;
    _viewModel = widget.viewModel ?? RefereeWalletViewModel();
    _viewModel.addListener(_onChanged);
    _viewModel.loadData();
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
          : data == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.screenPadding),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _viewModel.errorMessage ?? 'Không thể tải số dư ví.',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyMd(
                        RefereeColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    FilledButton(
                      onPressed: _viewModel.loadData,
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
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
                              Text(
                                'Ví của tôi',
                                style: AppTypography.headlineSm(
                                  RefereeColors.onSurface,
                                ).copyWith(fontSize: 24),
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              RefereeWalletBalanceCard(balance: data.balance),
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
