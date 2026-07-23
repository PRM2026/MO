import 'package:flutter/material.dart';

import '../../services/admin_api_service.dart';
import '../../widgets/admin/admin_dialogs.dart';
import '../../widgets/admin/admin_ui.dart';

class AdminWalletScreen extends StatefulWidget {
  const AdminWalletScreen({super.key});

  @override
  State<AdminWalletScreen> createState() => _AdminWalletScreenState();
}

class _AdminWalletScreenState extends State<AdminWalletScreen> {
  final AdminApiService _service = AdminApiService();
  JsonMap? _wallet;
  JsonMap? _reconciliation;
  List<JsonMap> _transactions = const [];
  List<JsonMap> _withdrawals = const [];
  bool _loading = true;
  String? _busyId;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final values = await Future.wait<Object>([
        _service.getWallet(),
        _service.getWalletTransactions(),
        _service.getWithdrawals(),
        _service.getWalletReconciliation(),
      ]);
      if (!mounted) return;
      setState(() {
        _wallet = values[0] as JsonMap;
        _transactions = values[1] as List<JsonMap>;
        _withdrawals = values[2] as List<JsonMap>;
        _reconciliation = values[3] as JsonMap;
      });
    } catch (error) {
      if (mounted) setState(() => _error = '$error');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _withdrawalAction(JsonMap item, String action) async {
    final id = adminText(item, 'id');
    String note = '';
    if (action == 'reject') {
      final result = await showAdminPrompt(
        context,
        title: 'Từ chối rút tiền',
        label: 'Lý do từ chối',
      );
      if (result == null || !mounted) return;
      note = result;
    } else {
      final confirmed = await showAdminConfirm(
        context,
        title: action == 'approve'
            ? 'Duyệt yêu cầu rút tiền?'
            : 'Xác nhận đã thanh toán?',
        message: formatAdminMoney(item['amount']),
        confirmLabel: action == 'approve' ? 'Duyệt' : 'Đã thanh toán',
      );
      if (!confirmed || !mounted) return;
    }
    setState(() => _busyId = id);
    try {
      switch (action) {
        case 'approve':
          await _service.approveWithdrawal(id);
        case 'reject':
          await _service.rejectWithdrawal(id, note);
        case 'paid':
          await _service.markWithdrawalPaid(id);
      }
      if (!mounted) return;
      showAdminMessage(context, 'Đã cập nhật yêu cầu rút tiền.');
      await _load();
    } catch (error) {
      if (mounted) showAdminMessage(context, '$error', error: true);
    } finally {
      if (mounted) setState(() => _busyId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminRefreshHost(
      onRefresh: _load,
      child: AdminPage(
        title: 'Ví hệ thống',
        subtitle: 'Theo dõi số dư, giao dịch và xử lý rút tiền',
        child: _body(),
      ),
    );
  }

  Widget _body() {
    if (_loading && _wallet == null) return const AdminLoading();
    if (_error != null && _wallet == null) {
      return AdminErrorCard(message: _error!, onRetry: _load);
    }
    final wallet = _wallet ?? const <String, dynamic>{};
    return Column(
      children: [
        AdminCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet_rounded,
                    color: AdminPalette.gold,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Số dư hệ thống',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                formatAdminMoney(wallet['totalBalance']),
                style: const TextStyle(
                  color: AdminPalette.goldLight,
                  fontSize: 29,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _balance(
                      'Khả dụng',
                      wallet['availableBalance'],
                      AdminPalette.success,
                    ),
                  ),
                  Expanded(
                    child: _balance(
                      'Đang giữ',
                      wallet['holdBalance'],
                      AdminPalette.info,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (_reconciliation != null) ...[
          const SizedBox(height: 14),
          AdminCard(
            child: Row(
              children: [
                const Icon(
                  Icons.fact_check_rounded,
                  color: AdminPalette.success,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Đối soát sổ cái',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        _reconciliation!['balanced'] == false
                            ? 'Phát hiện chênh lệch cần xử lý'
                            : 'Dữ liệu tài chính cân bằng',
                        style: TextStyle(
                          color: _reconciliation!['balanced'] == false
                              ? AdminPalette.danger
                              : AdminPalette.success,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 20),
        _sectionTitle('Yêu cầu rút tiền', _withdrawals.length),
        const SizedBox(height: 10),
        if (_withdrawals.isEmpty)
          const AdminEmptyState(message: 'Không có yêu cầu rút tiền')
        else
          ..._withdrawals.map(_withdrawalCard),
        const SizedBox(height: 20),
        _sectionTitle('Giao dịch gần đây', _transactions.length),
        const SizedBox(height: 10),
        if (_transactions.isEmpty)
          const AdminEmptyState(message: 'Chưa có giao dịch')
        else
          ..._transactions.take(30).map(_transactionCard),
      ],
    );
  }

  Widget _balance(String label, Object? value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AdminPalette.muted)),
        const SizedBox(height: 4),
        Text(
          formatAdminMoney(value),
          style: TextStyle(color: color, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title, int count) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        AdminStatusChip('$count mục'),
      ],
    );
  }

  Widget _withdrawalCard(JsonMap item) {
    final id = adminText(item, 'id');
    final status = adminText(item, 'status', 'PENDING');
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AdminCard(
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        adminText(
                          item,
                          'fullName',
                          adminText(item, 'userName', 'Người dùng'),
                        ),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        formatAdminMoney(item['amount']),
                        style: const TextStyle(
                          color: AdminPalette.goldLight,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                AdminStatusChip(status),
              ],
            ),
            if (status == 'PENDING') ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _busyId == id
                          ? null
                          : () => _withdrawalAction(item, 'reject'),
                      child: const Text('Từ chối'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AdminPrimaryButton(
                      label: 'Duyệt',
                      icon: Icons.check_rounded,
                      busy: _busyId == id,
                      onPressed: () => _withdrawalAction(item, 'approve'),
                    ),
                  ),
                ],
              ),
            ] else if (status == 'APPROVED') ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: AdminPrimaryButton(
                  label: 'Đánh dấu đã thanh toán',
                  icon: Icons.payments_rounded,
                  busy: _busyId == id,
                  onPressed: () => _withdrawalAction(item, 'paid'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _transactionCard(JsonMap item) {
    final amount = adminNumber(item, 'amount');
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AdminCard(
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor:
                  (amount >= 0 ? AdminPalette.success : AdminPalette.danger)
                      .withValues(alpha: .13),
              child: Icon(
                amount >= 0
                    ? Icons.south_west_rounded
                    : Icons.north_east_rounded,
                color: amount >= 0 ? AdminPalette.success : AdminPalette.danger,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    adminText(item, 'type', 'Giao dịch'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    adminText(item, 'description', adminText(item, 'note', '')),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AdminPalette.muted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              formatAdminMoney(amount),
              style: TextStyle(
                color: amount >= 0 ? AdminPalette.success : AdminPalette.danger,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
