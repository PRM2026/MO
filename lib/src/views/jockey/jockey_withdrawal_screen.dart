import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../constants/app_spacing.dart';
import '../../constants/app_theme_tokens.dart';
import '../../constants/referee_colors.dart';
import '../../models/withdrawal_response.dart';
import '../../utils/currency_format.dart';
import '../../viewmodels/jockey_withdrawal_viewmodel.dart';
import '../../widgets/jockey/jockey_app_bar.dart';
import '../../widgets/jockey/jockey_dashboard_widgets.dart';
import '../../widgets/jockey/jockey_wallet_widgets.dart';
import '../../widgets/referee/referee_glass_card.dart';

class JockeyWithdrawalScreen extends StatefulWidget {
  const JockeyWithdrawalScreen({super.key, this.viewModel});

  final JockeyWithdrawalViewModel? viewModel;

  @override
  State<JockeyWithdrawalScreen> createState() => _JockeyWithdrawalScreenState();
}

class _JockeyWithdrawalScreenState extends State<JockeyWithdrawalScreen> {
  late final JockeyWithdrawalViewModel _viewModel;
  late final bool _ownsViewModel;
  final _amount = TextEditingController();
  final _bankName = TextEditingController();
  final _accountNumber = TextEditingController();
  final _accountName = TextEditingController();
  final _reason = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ownsViewModel = widget.viewModel == null;
    _viewModel = widget.viewModel ?? JockeyWithdrawalViewModel();
    _viewModel.addListener(_onChanged);
    for (final controller in _controllers) {
      controller.addListener(_viewModel.clearError);
    }
  }

  List<TextEditingController> get _controllers => [
    _amount,
    _bankName,
    _accountNumber,
    _accountName,
    _reason,
  ];

  void _onChanged() {
    if (mounted) setState(() {});
  }

  JockeyWithdrawalInput get _input => JockeyWithdrawalInput(
    amount: _amount.text,
    bankName: _bankName.text,
    bankAccountNumber: _accountNumber.text,
    bankAccountName: _accountName.text,
    reason: _reason.text,
  );

  @override
  void dispose() {
    _viewModel.removeListener(_onChanged);
    if (_ownsViewModel) _viewModel.dispose();
    for (final controller in _controllers) {
      controller
        ..removeListener(_viewModel.clearError)
        ..dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RefereeColors.background,
      appBar: const JockeyAppBar(
        showBack: true,
        titleOverride: 'Rút tiền',
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
                    ? _WithdrawalForm(
                        amount: _amount,
                        bankName: _bankName,
                        accountNumber: _accountNumber,
                        accountName: _accountName,
                        reason: _reason,
                        isSubmitting: _viewModel.isSubmitting,
                        errorMessage: _viewModel.errorMessage,
                        onSubmit: () => _viewModel.submit(_input),
                      )
                    : _WithdrawalResult(
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

class _WithdrawalForm extends StatelessWidget {
  const _WithdrawalForm({
    required this.amount,
    required this.bankName,
    required this.accountNumber,
    required this.accountName,
    required this.reason,
    required this.isSubmitting,
    required this.errorMessage,
    required this.onSubmit,
  });

  final TextEditingController amount;
  final TextEditingController bankName;
  final TextEditingController accountNumber;
  final TextEditingController accountName;
  final TextEditingController reason;
  final bool isSubmitting;
  final String? errorMessage;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'YÊU CẦU RÚT TIỀN',
          style: AppTypography.labelCaps(RefereeColors.championshipGold),
        ),
        const SizedBox(height: 4),
        Text(
          'Thông tin nhận tiền',
          style: AppTypography.displayLg(
            RefereeColors.onSurface,
          ).copyWith(fontSize: 28),
        ),
        const SizedBox(height: AppSpacing.lg),
        RefereeGlassCard(
          child: Column(
            children: [
              _Field(
                key: const Key('jockey-withdrawal-amount'),
                controller: amount,
                label: 'Số tiền (VND)',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              _Field(controller: bankName, label: 'Tên ngân hàng'),
              _Field(
                controller: accountNumber,
                label: 'Số tài khoản',
                keyboardType: TextInputType.number,
              ),
              _Field(controller: accountName, label: 'Tên chủ tài khoản'),
              _Field(
                controller: reason,
                label: 'Lý do (không bắt buộc)',
                maxLines: 3,
              ),
              if (errorMessage != null) ...[
                JockeyWalletInfoBanner(message: errorMessage!),
                const SizedBox(height: AppSpacing.md),
              ],
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  key: const Key('jockey-withdrawal-submit'),
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
                      : const Icon(Icons.send_outlined),
                  label: Text(
                    isSubmitting ? 'Đang gửi...' : 'Gửi yêu cầu rút tiền',
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _WithdrawalResult extends StatelessWidget {
  const _WithdrawalResult({required this.result, required this.onDone});

  final WithdrawalResponse result;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const JockeyWalletInfoBanner(
          message: 'Đã gửi yêu cầu rút tiền thành công.',
          isError: false,
        ),
        const SizedBox(height: AppSpacing.lg),
        RefereeGlassCard(
          highlighted: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.schedule_send_outlined,
                size: 52,
                color: RefereeColors.championshipGold,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                formatVnd(result.amount),
                textAlign: TextAlign.center,
                style: AppTypography.displayLg(
                  RefereeColors.championshipGold,
                ).copyWith(fontSize: 30),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Yêu cầu #${result.id} • ${result.status ?? 'PENDING'}',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMd(RefereeColors.onSurface),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                '${result.bankName}\n${result.bankAccountNumber} • ${result.bankAccountName}',
                textAlign: TextAlign.center,
                style: AppTypography.bodySm(RefereeColors.onSurfaceVariant),
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton(
                key: const Key('jockey-withdrawal-done'),
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

class _Field extends StatelessWidget {
  const _Field({
    super.key,
    required this.controller,
    required this.label,
    this.keyboardType,
    this.inputFormatters,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
