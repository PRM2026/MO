import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../constants/app_spacing.dart';
import '../../constants/app_theme_tokens.dart';
import '../../constants/referee_colors.dart';
import '../../models/deposit_order_response.dart';
import '../../utils/currency_format.dart';
import '../../utils/date_format.dart';
import '../../viewmodels/jockey_deposit_viewmodel.dart';
import '../../widgets/jockey/jockey_app_bar.dart';
import '../../widgets/jockey/jockey_dashboard_widgets.dart';
import '../../widgets/jockey/jockey_wallet_widgets.dart';
import '../../widgets/referee/referee_glass_card.dart';

class JockeyDepositScreen extends StatefulWidget {
  const JockeyDepositScreen({super.key, this.viewModel});

  final JockeyDepositViewModel? viewModel;

  @override
  State<JockeyDepositScreen> createState() => _JockeyDepositScreenState();
}

class _JockeyDepositScreenState extends State<JockeyDepositScreen> {
  late final JockeyDepositViewModel _viewModel;
  late final bool _ownsViewModel;
  final _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ownsViewModel = widget.viewModel == null;
    _viewModel = widget.viewModel ?? JockeyDepositViewModel();
    _viewModel.addListener(_onChanged);
    _amountController.addListener(_viewModel.clearError);
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onChanged);
    if (_ownsViewModel) _viewModel.dispose();
    _amountController
      ..removeListener(_viewModel.clearError)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RefereeColors.background,
      appBar: const JockeyAppBar(
        showBack: true,
        titleOverride: 'Nạp tiền',
        showBrandTitle: false,
      ),
      body: JockeySpeedlineBackground(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: _viewModel.result == null
                    ? _DepositForm(
                        controller: _amountController,
                        isSubmitting: _viewModel.isSubmitting,
                        errorMessage: _viewModel.errorMessage,
                        onSubmit: () =>
                            _viewModel.submit(_amountController.text),
                      )
                    : _DepositResult(
                        result: _viewModel.result!,
                        onDone: () => Navigator.of(context).pop(true),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DepositForm extends StatelessWidget {
  const _DepositForm({
    required this.controller,
    required this.isSubmitting,
    required this.errorMessage,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final bool isSubmitting;
  final String? errorMessage;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'TẠO LỆNH NẠP',
          style: AppTypography.labelCaps(RefereeColors.championshipGold),
        ),
        const SizedBox(height: 4),
        Text(
          'Nạp tiền qua ZaloPay',
          style: AppTypography.displayLg(
            RefereeColors.onSurface,
          ).copyWith(fontSize: 28),
        ),
        const SizedBox(height: AppSpacing.lg),
        RefereeGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                key: const Key('jockey-deposit-amount'),
                controller: controller,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Số tiền (VND)',
                  border: OutlineInputBorder(),
                ),
              ),
              if (errorMessage != null) ...[
                const SizedBox(height: AppSpacing.md),
                JockeyWalletInfoBanner(message: errorMessage!),
              ],
              const SizedBox(height: AppSpacing.lg),
              FilledButton.icon(
                key: const Key('jockey-deposit-submit'),
                onPressed: isSubmitting ? null : onSubmit,
                icon: isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.qr_code_2),
                label: Text(
                  isSubmitting ? 'Đang tạo...' : 'Tạo lệnh thanh toán',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DepositResult extends StatelessWidget {
  const _DepositResult({required this.result, required this.onDone});

  final DepositOrderResponse result;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final qrData = result.qrCode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const JockeyWalletInfoBanner(
          message: 'Đã tạo lệnh nạp tiền thành công.',
          isError: false,
        ),
        const SizedBox(height: AppSpacing.lg),
        RefereeGlassCard(
          highlighted: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                formatVnd(result.amount),
                textAlign: TextAlign.center,
                style: AppTypography.displayLg(
                  RefereeColors.championshipGold,
                ).copyWith(fontSize: 30),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '${result.status ?? 'PENDING'} • ${result.referenceCode ?? '#${result.id}'}',
                textAlign: TextAlign.center,
                style: AppTypography.bodySm(RefereeColors.onSurfaceVariant),
              ),
              if (qrData != null) ...[
                const SizedBox(height: AppSpacing.lg),
                Center(
                  child: Container(
                    key: const Key('jockey-deposit-qr'),
                    color: Colors.white,
                    padding: const EdgeInsets.all(12),
                    child: QrImageView(data: qrData, size: 220),
                  ),
                ),
                _CopyValue(label: 'Dữ liệu QR', value: qrData),
              ],
              if (result.checkoutUrl != null)
                _CopyValue(label: 'Checkout URL', value: result.checkoutUrl!),
              if (result.transferContent != null)
                _CopyValue(
                  label: 'Nội dung chuyển khoản',
                  value: result.transferContent!,
                ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Hết hạn: ${formatDisplayDateTime(result.expiredAt?.toIso8601String())}',
                style: AppTypography.bodySm(RefereeColors.onSurfaceVariant),
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton(
                key: const Key('jockey-deposit-done'),
                onPressed: onDone,
                child: const Text('Hoàn tất'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CopyValue extends StatelessWidget {
  const _CopyValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.labelCaps(
                    RefereeColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                SelectableText(
                  value,
                  style: AppTypography.bodySm(RefereeColors.onSurface),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Sao chép',
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: value));
              if (!context.mounted) return;
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Đã sao chép.')));
            },
            icon: const Icon(Icons.copy_outlined),
          ),
        ],
      ),
    );
  }
}
