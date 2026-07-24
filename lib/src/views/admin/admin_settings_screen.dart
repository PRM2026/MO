import 'package:flutter/material.dart';

import '../../services/admin_api_service.dart';
import '../../widgets/admin/admin_dialogs.dart';
import '../../widgets/admin/admin_ui.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  final AdminApiService _service = AdminApiService();
  final _registrationFee = TextEditingController();
  final _lateFee = TextEditingController();
  final _rules = TextEditingController();
  final _distances = TextEditingController();
  final _winningTax = TextEditingController();
  JsonMap? _settings;
  List<JsonMap> _provinces = const [];
  List<JsonMap> _salaryConfigs = const [];
  int _tab = 0;
  bool _loading = true;
  bool _saving = false;
  bool _bettingEnabled = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _registrationFee.dispose();
    _lateFee.dispose();
    _rules.dispose();
    _distances.dispose();
    _winningTax.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final values = await Future.wait<Object>([
        _service.getSystemSettings(),
        _service.getFinanceSettings(),
        _service.getProvinces(),
        _service.getRefereeSalaryConfigs(),
      ]);
      if (!mounted) return;
      final settings = values[0] as JsonMap;
      final finance = values[1] as JsonMap;
      setState(() {
        _settings = settings;
        _provinces = values[2] as List<JsonMap>;
        _salaryConfigs = values[3] as List<JsonMap>;
        _registrationFee.text = adminText(
          settings,
          'defaultRegistrationFee',
          '0',
        );
        _lateFee.text = adminText(settings, 'lateCheckInFee', '0');
        _rules.text = adminText(settings, 'defaultTournamentRules');
        _distances.text = ((settings['raceDistances'] as List?) ?? const [])
            .map((item) {
              if (item is Map) return '${item['meters'] ?? ''}';
              return '$item';
            })
            .where((value) => value.isNotEmpty)
            .join(', ');
        _bettingEnabled = finance['bettingEnabled'] == true;
        _winningTax.text = adminText(finance, 'betWinningTaxPercent', '0');
      });
    } catch (error) {
      if (mounted) setState(() => _error = '$error');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save(Future<void> Function() action) async {
    setState(() => _saving = true);
    try {
      await action();
      if (!mounted) return;
      showAdminMessage(context, 'Đã lưu cài đặt.');
      await _load();
    } catch (error) {
      if (mounted) showAdminMessage(context, '$error', error: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _addProvince() async {
    final name = await showAdminPrompt(
      context,
      title: 'Thêm tỉnh/thành',
      label: 'Tên tỉnh/thành',
      maxLines: 1,
    );
    if (name == null || !mounted) return;
    final code = await showAdminPrompt(
      context,
      title: 'Mã tỉnh/thành',
      label: 'Mã ngắn, ví dụ HCM',
      maxLines: 1,
    );
    if (code == null || !mounted) return;
    await _save(
      () async =>
          _service.createProvince({'name': name, 'code': code, 'active': true}),
    );
  }

  Future<void> _openProvince(JsonMap province) async {
    final id = adminText(province, 'id');
    List<JsonMap> venues = const [];
    try {
      venues = await _service.getVenues(id);
    } catch (error) {
      if (mounted) showAdminMessage(context, '$error', error: true);
      return;
    }
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AdminPalette.navyLight,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setLocal) => SafeArea(
          child: SizedBox(
            height: MediaQuery.sizeOf(context).height * .72,
            child: ListView(
              padding: const EdgeInsets.all(18),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        adminText(province, 'name'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        final name = await showAdminPrompt(
                          context,
                          title: 'Thêm địa điểm đua',
                          label: 'Tên địa điểm',
                          maxLines: 1,
                        );
                        if (name == null || !context.mounted) return;
                        final address = await showAdminPrompt(
                          context,
                          title: 'Địa chỉ',
                          label: 'Địa chỉ chi tiết',
                          maxLines: 2,
                        );
                        if (address == null || !context.mounted) return;
                        await _service.createVenue(id, {
                          'name': name,
                          'address': address,
                          'active': true,
                        });
                        venues = await _service.getVenues(id);
                        setLocal(() {});
                      },
                      icon: const Icon(
                        Icons.add_location_alt_rounded,
                        color: AdminPalette.gold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                if (venues.isEmpty)
                  const AdminEmptyState(message: 'Chưa có địa điểm đua')
                else
                  ...venues.map(
                    (venue) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: AdminCard(
                        child: Row(
                          children: [
                            const Icon(
                              Icons.stadium_rounded,
                              color: AdminPalette.gold,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    adminText(venue, 'name'),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  Text(
                                    adminText(venue, 'address'),
                                    style: const TextStyle(
                                      color: AdminPalette.muted,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch.adaptive(
                              value: venue['active'] != false,
                              onChanged: (active) async {
                                await _service.setVenueActive(
                                  adminText(venue, 'id'),
                                  active,
                                );
                                venues = await _service.getVenues(id);
                                setLocal(() {});
                              },
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
      ),
    );
  }

  Future<void> _addSalaryConfig() async {
    final fee = await showAdminPrompt(
      context,
      title: 'Thêm mức lương trọng tài',
      label: 'Số tiền mỗi cuộc đua',
      maxLines: 1,
    );
    if (fee == null || !mounted) return;
    await _save(
      () async => _service.createRefereeSalaryConfig({
        'name': 'Mức lương ${_salaryConfigs.length + 1}',
        'amount': num.tryParse(fee) ?? 0,
        'active': true,
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminRefreshHost(
      onRefresh: _load,
      child: AdminPage(
        title: 'Cài đặt hệ thống',
        subtitle: 'Cấu hình mặc định dùng chung cho nền tảng',
        child: _body(),
      ),
    );
  }

  Widget _body() {
    if (_loading && _settings == null) return const AdminLoading();
    if (_error != null && _settings == null) {
      return AdminErrorCard(message: _error!, onRetry: _load);
    }
    const tabs = [
      ('Lệ phí', Icons.payments_rounded),
      ('Luật', Icons.gavel_rounded),
      ('Khoảng cách', Icons.straighten_rounded),
      ('Địa điểm', Icons.map_rounded),
      ('Trọng tài', Icons.sports_rounded),
      ('Tài chính', Icons.account_balance_rounded),
      ('Vi phạm', Icons.warning_amber_rounded),
    ];
    return Column(
      children: [
        SizedBox(
          height: 46,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: tabs.length,
            itemBuilder: (_, index) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                avatar: Icon(tabs[index].$2, size: 17),
                label: Text(tabs[index].$1),
                selected: _tab == index,
                onSelected: (_) => setState(() => _tab = index),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        switch (_tab) {
          0 => _fees(),
          1 => _rulesPanel(),
          2 => _distancePanel(),
          3 => _locations(),
          4 => _salaryPanel(),
          5 => _financePanel(),
          _ => _violationsPanel(),
        },
      ],
    );
  }

  Widget _fees() {
    return AdminCard(
      child: Column(
        children: [
          _numberField(_registrationFee, 'Lệ phí đăng ký mặc định'),
          const SizedBox(height: 12),
          _numberField(_lateFee, 'Phí check-in trễ'),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: AdminPrimaryButton(
              label: 'Lưu lệ phí',
              icon: Icons.save_rounded,
              busy: _saving,
              onPressed: () => _save(
                () async => _service.updateSystemFees(
                  defaultRegistrationFee:
                      num.tryParse(_registrationFee.text) ?? 0,
                  lateCheckInFee: num.tryParse(_lateFee.text) ?? 0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _rulesPanel() {
    return AdminCard(
      child: Column(
        children: [
          TextField(
            controller: _rules,
            minLines: 8,
            maxLines: 14,
            style: const TextStyle(color: Colors.white, height: 1.5),
            decoration: const InputDecoration(
              labelText: 'Luật giải đấu mặc định',
              labelStyle: TextStyle(color: AdminPalette.muted),
              alignLabelWithHint: true,
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: AdminPrimaryButton(
              label: 'Lưu luật',
              icon: Icons.save_rounded,
              busy: _saving,
              onPressed: () =>
                  _save(() async => _service.updateDefaultRules(_rules.text)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _distancePanel() {
    return AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nhập các khoảng cách (mét), cách nhau bằng dấu phẩy',
            style: TextStyle(color: AdminPalette.muted),
          ),
          const SizedBox(height: 12),
          _numberField(_distances, 'Ví dụ: 800, 1000, 1200'),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: AdminPrimaryButton(
              label: 'Lưu khoảng cách',
              icon: Icons.save_rounded,
              busy: _saving,
              onPressed: () {
                final values =
                    _distances.text
                        .split(',')
                        .map((item) => int.tryParse(item.trim()))
                        .whereType<int>()
                        .where((item) => item > 0)
                        .toSet()
                        .toList()
                      ..sort();
                _save(() async => _service.updateRaceDistances(values));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _locations() {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: AdminPrimaryButton(
            label: 'Thêm tỉnh',
            icon: Icons.add_rounded,
            onPressed: _addProvince,
          ),
        ),
        const SizedBox(height: 12),
        if (_provinces.isEmpty)
          const AdminEmptyState(message: 'Chưa có tỉnh/thành')
        else
          ..._provinces.map(
            (province) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AdminCard(
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_city_rounded,
                      color: AdminPalette.gold,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () => _openProvince(province),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              adminText(province, 'name'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              adminText(province, 'code'),
                              style: const TextStyle(
                                color: AdminPalette.muted,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Switch.adaptive(
                      value: province['active'] != false,
                      onChanged: (active) => _save(
                        () async => _service.setProvinceActive(
                          adminText(province, 'id'),
                          active,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _salaryPanel() {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: AdminPrimaryButton(
            label: 'Thêm mức lương',
            icon: Icons.add_rounded,
            onPressed: _addSalaryConfig,
          ),
        ),
        const SizedBox(height: 12),
        if (_salaryConfigs.isEmpty)
          const AdminEmptyState(message: 'Chưa có cấu hình lương trọng tài')
        else
          ..._salaryConfigs.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AdminCard(
                child: Row(
                  children: [
                    const Icon(Icons.sports_rounded, color: AdminPalette.gold),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            adminText(item, 'name', 'Mức lương trọng tài'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            formatAdminMoney(
                              item['amount'] ?? item['perRaceFee'],
                            ),
                            style: const TextStyle(
                              color: AdminPalette.goldLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AdminStatusChip(
                      item['active'] == false ? 'INACTIVE' : 'ACTIVE',
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _financePanel() {
    return AdminCard(
      child: Column(
        children: [
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: _bettingEnabled,
            onChanged: (value) => setState(() => _bettingEnabled = value),
            title: const Text(
              'Cho phép đặt cược',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
            subtitle: const Text(
              'Bật/tắt toàn bộ tính năng cược trên hệ thống',
              style: TextStyle(color: AdminPalette.muted),
            ),
          ),
          const SizedBox(height: 10),
          _numberField(_winningTax, 'Thuế tiền thắng (%)'),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: AdminPrimaryButton(
              label: 'Lưu tài chính',
              icon: Icons.save_rounded,
              busy: _saving,
              onPressed: () => _save(
                () async => _service.updateFinanceSettings({
                  'bettingEnabled': _bettingEnabled,
                  'betWinningTaxPercent': num.tryParse(_winningTax.text) ?? 0,
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _violationsPanel() {
    final types = (_settings?['violationTypes'] as List?) ?? const [];
    final rules = (_settings?['violationPenaltyRules'] as List?) ?? const [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AdminCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Loại vi phạm',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              if (types.isEmpty)
                const Text(
                  'Chưa có loại vi phạm',
                  style: TextStyle(color: AdminPalette.muted),
                )
              else
                ...types.map(
                  (item) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.warning_amber_rounded,
                      color: AdminPalette.gold,
                    ),
                    title: Text(
                      item is Map
                          ? '${item['label'] ?? item['name'] ?? item['code']}'
                          : '$item',
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: item is Map
                        ? Text(
                            '${item['description'] ?? ''}',
                            style: const TextStyle(color: AdminPalette.muted),
                          )
                        : null,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        AdminCard(
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Quy tắc xử phạt',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              AdminStatusChip('${rules.length} quy tắc'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _numberField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AdminPalette.muted),
        filled: true,
        fillColor: AdminPalette.navyLight,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
