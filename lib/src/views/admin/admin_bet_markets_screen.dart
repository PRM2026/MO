import 'package:flutter/material.dart';

import '../../services/admin_api_service.dart';
import '../../widgets/admin/admin_dialogs.dart';
import '../../widgets/admin/admin_ui.dart';

class AdminBetMarketsScreen extends StatefulWidget {
  const AdminBetMarketsScreen({super.key});

  @override
  State<AdminBetMarketsScreen> createState() => _AdminBetMarketsScreenState();
}

class _AdminBetMarketsScreenState extends State<AdminBetMarketsScreen> {
  final AdminApiService _service = AdminApiService();
  List<JsonMap> _markets = const [];
  List<JsonMap> _tournaments = const [];
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
        _service.getBetMarkets(),
        _service.getTournaments(),
      ]);
      if (!mounted) return;
      setState(() {
        _markets = values[0] as List<JsonMap>;
        _tournaments = values[1] as List<JsonMap>;
      });
    } catch (error) {
      if (mounted) setState(() => _error = '$error');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _createMarket() async {
    final published = _tournaments.where(
      (item) => ![
        'COMPLETED',
        'CANCELLED',
      ].contains(adminText(item, 'status').toUpperCase()),
    );
    final races = <JsonMap>[];
    for (final tournament in published) {
      final detail = await _service.getTournament(adminText(tournament, 'id'));
      for (final race
          in ((detail['races'] as List?) ?? const [])
              .whereType<Map<String, dynamic>>()) {
        races.add({
          ...Map<String, dynamic>.from(race),
          '_tournamentName': adminText(tournament, 'name'),
        });
      }
    }
    if (!mounted) return;
    if (races.isEmpty) {
      showAdminMessage(context, 'Không có cuộc đua để mở cược.', error: true);
      return;
    }
    var raceId = adminText(races.first, 'id');
    final min = TextEditingController(text: '10000');
    final max = TextEditingController(text: '1000000');
    final result = await showDialog<JsonMap>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setLocal) => AlertDialog(
          backgroundColor: AdminPalette.navyLight,
          title: const Text(
            'Tạo thị trường cược',
            style: TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: raceId,
                  isExpanded: true,
                  dropdownColor: AdminPalette.navyLight,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Cuộc đua',
                    labelStyle: TextStyle(color: AdminPalette.muted),
                  ),
                  items: races
                      .map(
                        (race) => DropdownMenuItem(
                          value: adminText(race, 'id'),
                          child: Text(
                            '${adminText(race, '_tournamentName')} · ${adminText(race, 'name')}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setLocal(() => raceId = value ?? raceId),
                ),
                const SizedBox(height: 12),
                _dialogNumberField(min, 'Mức cược tối thiểu'),
                const SizedBox(height: 12),
                _dialogNumberField(max, 'Mức cược tối đa'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, {
                'raceId': raceId,
                'minStake': num.tryParse(min.text) ?? 0,
                'maxStake': num.tryParse(max.text) ?? 0,
                'note': '',
              }),
              child: const Text('Tạo'),
            ),
          ],
        ),
      ),
    );
    min.dispose();
    max.dispose();
    if (result == null || !mounted) return;
    final selectedRaceId = result.remove('raceId') as String;
    try {
      await _service.createBetMarket(selectedRaceId, result);
      if (!mounted) return;
      showAdminMessage(context, 'Đã tạo thị trường cược.');
      await _load();
    } catch (error) {
      if (mounted) showAdminMessage(context, '$error', error: true);
    }
  }

  Widget _dialogNumberField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AdminPalette.muted),
      ),
    );
  }

  Future<void> _action(JsonMap market, String action) async {
    final id = adminText(market, 'id');
    final confirmed = await showAdminConfirm(
      context,
      title: switch (action) {
        'open' => 'Mở nhận cược?',
        'close' => 'Đóng nhận cược?',
        _ => 'Quyết toán thị trường?',
      },
      message: adminText(market, 'raceName', 'Thị trường cược'),
      confirmLabel: switch (action) {
        'open' => 'Mở cược',
        'close' => 'Đóng cược',
        _ => 'Quyết toán',
      },
      danger: action == 'settle',
    );
    if (!confirmed || !mounted) return;
    setState(() => _busyId = id);
    try {
      switch (action) {
        case 'open':
          await _service.openBetMarket(id);
        case 'close':
          await _service.closeBetMarket(id);
        case 'settle':
          await _service.settleBetMarket(id);
      }
      await _load();
    } catch (error) {
      if (mounted) showAdminMessage(context, '$error', error: true);
    } finally {
      if (mounted) setState(() => _busyId = null);
    }
  }

  Future<void> _showBets(JsonMap market) async {
    try {
      final bets = await _service.getMarketBets(adminText(market, 'id'));
      if (!mounted) return;
      await showModalBottomSheet<void>(
        context: context,
        backgroundColor: AdminPalette.navy,
        isScrollControlled: true,
        builder: (_) => SafeArea(
          child: SizedBox(
            height: MediaQuery.sizeOf(context).height * .72,
            child: ListView(
              padding: const EdgeInsets.all(18),
              children: [
                const Text(
                  'Danh sách cược',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 14),
                if (bets.isEmpty)
                  const AdminEmptyState(message: 'Chưa có lượt cược')
                else
                  ...bets.map(
                    (bet) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: AdminCard(
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                adminText(
                                  bet,
                                  'username',
                                  adminText(bet, 'userName', 'Người chơi'),
                                ),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            Text(
                              formatAdminMoney(bet['stake'] ?? bet['amount']),
                              style: const TextStyle(
                                color: AdminPalette.goldLight,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    } catch (error) {
      if (mounted) showAdminMessage(context, '$error', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminRefreshHost(
      onRefresh: _load,
      child: AdminPage(
        title: 'Cấu hình cược',
        subtitle: 'Tạo, mở, đóng và quyết toán thị trường cược',
        action: IconButton.filled(
          tooltip: 'Tạo thị trường',
          style: IconButton.styleFrom(
            backgroundColor: AdminPalette.gold,
            foregroundColor: AdminPalette.navy,
          ),
          onPressed: _createMarket,
          icon: const Icon(Icons.add_rounded),
        ),
        child: _body(),
      ),
    );
  }

  Widget _body() {
    if (_loading && _markets.isEmpty) return const AdminLoading();
    if (_error != null && _markets.isEmpty) {
      return AdminErrorCard(message: _error!, onRetry: _load);
    }
    if (_markets.isEmpty) {
      return const AdminEmptyState(message: 'Chưa có thị trường cược');
    }
    return Column(children: _markets.map(_marketCard).toList());
  }

  Widget _marketCard(JsonMap market) {
    final id = adminText(market, 'id');
    final status = adminText(market, 'status', 'DRAFT').toUpperCase();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AdminCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    adminText(market, 'raceName', 'Thị trường cược'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                AdminStatusChip(status),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${formatAdminMoney(market['minStake'])} – ${formatAdminMoney(market['maxStake'])}',
              style: const TextStyle(color: AdminPalette.goldLight),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (status == 'DRAFT' || status == 'CLOSED')
                  AdminPrimaryButton(
                    label: 'Mở cược',
                    icon: Icons.play_arrow_rounded,
                    busy: _busyId == id,
                    onPressed: () => _action(market, 'open'),
                  ),
                if (status == 'OPEN')
                  AdminPrimaryButton(
                    label: 'Đóng cược',
                    icon: Icons.stop_rounded,
                    busy: _busyId == id,
                    onPressed: () => _action(market, 'close'),
                  ),
                if (status == 'CLOSED')
                  AdminPrimaryButton(
                    label: 'Quyết toán',
                    icon: Icons.fact_check_rounded,
                    danger: true,
                    busy: _busyId == id,
                    onPressed: () => _action(market, 'settle'),
                  ),
                OutlinedButton.icon(
                  onPressed: () => _showBets(market),
                  icon: const Icon(Icons.receipt_long_rounded),
                  label: const Text('Xem lượt cược'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
