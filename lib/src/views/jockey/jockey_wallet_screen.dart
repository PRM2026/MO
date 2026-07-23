import 'package:flutter/material.dart';

import '../../constants/app_spacing.dart';
import '../../constants/app_theme_tokens.dart';
import '../../constants/referee_colors.dart';
import '../../models/deposit_order_response.dart';
import '../../models/withdrawal_response.dart';
import '../../routes/app_routes.dart';
import '../../utils/currency_format.dart';
import '../../utils/date_format.dart';
import '../../viewmodels/jockey_wallet_viewmodel.dart';
import '../../widgets/jockey/jockey_app_bar.dart';
import '../../widgets/jockey/jockey_dashboard_widgets.dart';
import '../../widgets/jockey/jockey_state_widgets.dart';
import '../../widgets/jockey/jockey_wallet_widgets.dart';

class JockeyWalletScreen extends StatefulWidget {
  const JockeyWalletScreen({
    super.key,
    this.viewModel,
    this.onOpenDeposit,
    this.onOpenWithdrawal,
    this.title = 'Ví jockey',
    this.sectionTitle = 'Ví của tôi',
  });

  final JockeyWalletViewModel? viewModel;
  final Future<bool?> Function(BuildContext context)? onOpenDeposit;
  final Future<bool?> Function(BuildContext context)? onOpenWithdrawal;
  final String title;
  final String sectionTitle;

  @override
  State<JockeyWalletScreen> createState() => _JockeyWalletScreenState();
}

class _JockeyWalletScreenState extends State<JockeyWalletScreen> {
  late final JockeyWalletViewModel _viewModel;
  late final bool _ownsViewModel;

  @override
  void initState() {
    super.initState();
    _ownsViewModel = widget.viewModel == null;
    _viewModel = widget.viewModel ?? JockeyWalletViewModel();
    _viewModel.addListener(_onChanged);
    _viewModel.loadWallet();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _openDeposit() async {
    final changed =
        await (widget.onOpenDeposit?.call(context) ??
            AppRoutes.openJockeyDeposit(context));
    if (changed == true) await _viewModel.loadWallet();
  }

  Future<void> _openWithdrawal() async {
    final changed =
        await (widget.onOpenWithdrawal?.call(context) ??
            AppRoutes.openJockeyWithdrawal(context));
    if (changed == true) await _viewModel.loadWallet();
  }

  Future<void> _openDepositDetail(DepositOrderResponse item) async {
    final detail = await _viewModel.loadDepositDetail(item.id);
    if (!mounted) return;
    if (detail == null) {
      _showDetailError();
      return;
    }
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: RefereeColors.portalSurface,
      showDragHandle: true,
      builder: (_) => JockeyWalletDetailSheet(
        title: 'Chi tiết lệnh nạp #${detail.id}',
        rows: [
          ('Số tiền', '${formatVnd(detail.amount)} ${detail.currency}'),
          ('Trạng thái', detail.status ?? '—'),
          ('Nhà cung cấp', detail.provider ?? 'ZALOPAY'),
          ('Mã tham chiếu', detail.referenceCode ?? '—'),
          ('Nội dung', detail.transferContent ?? '—'),
          (
            'Hết hạn',
            formatDisplayDateTime(detail.expiredAt?.toIso8601String()),
          ),
        ],
      ),
    );
  }

  Future<void> _openWithdrawalDetail(WithdrawalResponse item) async {
    final detail = await _viewModel.loadWithdrawalDetail(item.id);
    if (!mounted) return;
    if (detail == null) {
      _showDetailError();
      return;
    }
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: RefereeColors.portalSurface,
      showDragHandle: true,
      builder: (_) => JockeyWalletDetailSheet(
        title: 'Chi tiết yêu cầu rút #${detail.id}',
        rows: [
          ('Số tiền', '${formatVnd(detail.amount)} ${detail.currency}'),
          ('Trạng thái', detail.status ?? '—'),
          ('Ngân hàng', detail.bankName),
          ('Số tài khoản', detail.bankAccountNumber),
          ('Chủ tài khoản', detail.bankAccountName),
          ('Lý do', detail.reason ?? '—'),
          ('Ghi chú admin', detail.adminNote ?? '—'),
          (
            'Ngày tạo',
            formatDisplayDateTime(detail.createdAt?.toIso8601String()),
          ),
        ],
      ),
    );
  }

  void _showDetailError() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_viewModel.detailError ?? 'Không thể tải chi tiết.'),
      ),
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
      appBar: JockeyAppBar(
        showBack: true,
        titleOverride: widget.title,
        showBrandTitle: false,
      ),
      body: JockeySpeedlineBackground(
        child: _viewModel.isLoading && data == null
            ? const Center(
                child: CircularProgressIndicator(
                  color: RefereeColors.championshipGold,
                ),
              )
            : RefreshIndicator(
                color: RefereeColors.championshipGold,
                onRefresh: _viewModel.loadWallet,
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
                            constraints: const BoxConstraints(maxWidth: 1040),
                            child: data == null
                                ? JockeyStateMessage(
                                    message:
                                        _viewModel.errorMessage ??
                                        'Chưa có dữ liệu ví.',
                                    onRetry: _viewModel.loadWallet,
                                  )
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Text(
                                        'TÀI CHÍNH',
                                        style: AppTypography.labelCaps(
                                          RefereeColors.championshipGold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        widget.sectionTitle,
                                        style: AppTypography.displayLg(
                                          RefereeColors.onSurface,
                                        ).copyWith(fontSize: 28),
                                      ),
                                      const SizedBox(height: AppSpacing.lg),
                                      if (_viewModel.errorMessage != null) ...[
                                        JockeyWalletInfoBanner(
                                          message: _viewModel.errorMessage!,
                                        ),
                                        const SizedBox(height: AppSpacing.md),
                                      ],
                                      JockeyWalletBalanceCard(
                                        wallet: data.wallet,
                                        onDeposit: data.wallet.isActive
                                            ? _openDeposit
                                            : null,
                                        onWithdraw: data.wallet.isActive
                                            ? _openWithdrawal
                                            : null,
                                      ),
                                      const SizedBox(height: AppSpacing.lg),
                                      JockeyWalletTabs(
                                        selected: _viewModel.selectedTab,
                                        onSelected: _viewModel.selectTab,
                                      ),
                                      const SizedBox(height: AppSpacing.lg),
                                      JockeyWalletTabContent(
                                        tab: _viewModel.selectedTab,
                                        transactions: data.transactions,
                                        depositOrders: data.depositOrders,
                                        withdrawals: data.withdrawals,
                                        onDepositTap: _openDepositDetail,
                                        onWithdrawalTap: _openWithdrawalDetail,
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
