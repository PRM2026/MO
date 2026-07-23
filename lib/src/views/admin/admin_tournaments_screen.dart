import 'package:flutter/material.dart';

import '../../services/admin_api_service.dart';
import '../../widgets/admin/admin_dialogs.dart';
import '../../widgets/admin/admin_ui.dart';

class AdminTournamentsScreen extends StatefulWidget {
  const AdminTournamentsScreen({super.key});

  @override
  State<AdminTournamentsScreen> createState() => _AdminTournamentsScreenState();
}

class _AdminTournamentsScreenState extends State<AdminTournamentsScreen> {
  final AdminApiService _service = AdminApiService();
  final TextEditingController _search = TextEditingController();
  List<JsonMap> _tournaments = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
    _search.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final tournaments = await _service.getTournaments();
      if (mounted) setState(() => _tournaments = tournaments);
    } catch (error) {
      if (mounted) setState(() => _error = '$error');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<JsonMap> get _visible {
    final query = _search.text.trim().toLowerCase();
    if (query.isEmpty) return _tournaments;
    return _tournaments
        .where(
          (item) => [
            adminText(item, 'name'),
            adminText(item, 'location'),
            adminText(item, 'provinceName'),
            adminText(item, 'status'),
          ].join(' ').toLowerCase().contains(query),
        )
        .toList();
  }

  Future<void> _createTournament() async {
    final result = await showModalBottomSheet<JsonMap>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AdminPalette.navyLight,
      builder: (_) => const _TournamentFormSheet(),
    );
    if (result == null || !mounted) return;
    try {
      await _service.createTournament(result);
      if (!mounted) return;
      showAdminMessage(context, 'Tạo giải đấu thành công.');
      await _load();
    } catch (error) {
      if (mounted) showAdminMessage(context, '$error', error: true);
    }
  }

  Future<void> _openTournament(JsonMap item) async {
    final id = adminText(item, 'id');
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AdminPalette.navy,
      builder: (_) =>
          _TournamentDetailSheet(tournamentId: id, service: _service),
    );
    if (mounted) await _load();
  }

  @override
  Widget build(BuildContext context) {
    return AdminRefreshHost(
      onRefresh: _load,
      child: AdminPage(
        title: 'Giải đấu',
        subtitle: 'Khởi tạo, công bố và cấu hình các cuộc đua',
        action: IconButton.filled(
          tooltip: 'Tạo giải đấu',
          style: IconButton.styleFrom(
            backgroundColor: AdminPalette.gold,
            foregroundColor: AdminPalette.navy,
          ),
          onPressed: _createTournament,
          icon: const Icon(Icons.add_rounded),
        ),
        child: _body(),
      ),
    );
  }

  Widget _body() {
    if (_loading && _tournaments.isEmpty) return const AdminLoading();
    if (_error != null && _tournaments.isEmpty) {
      return AdminErrorCard(message: _error!, onRetry: _load);
    }
    return Column(
      children: [
        TextField(
          controller: _search,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Tìm giải đấu, địa điểm, trạng thái...',
            hintStyle: const TextStyle(color: AdminPalette.muted),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: AdminPalette.muted,
            ),
            filled: true,
            fillColor: AdminPalette.card,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
        const SizedBox(height: 14),
        if (_visible.isEmpty)
          const AdminEmptyState(message: 'Chưa có giải đấu')
        else
          ..._visible.map(_tournamentCard),
      ],
    );
  }

  Widget _tournamentCard(JsonMap tournament) {
    final image = adminText(
      tournament,
      'bannerUrl',
      adminText(tournament, 'banner'),
    );
    final races = tournament['races'] is List
        ? (tournament['races'] as List).length
        : adminNumber(tournament, 'raceCount').toInt();
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _openTournament(tournament),
        child: AdminCard(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (image.isNotEmpty)
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: Image.network(
                    image,
                    width: double.infinity,
                    height: 135,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const SizedBox.shrink(),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            adminText(tournament, 'name', 'Giải đấu'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        AdminStatusChip(
                          adminText(tournament, 'status', 'DRAFT'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${adminText(tournament, 'location', adminText(tournament, 'provinceName', 'Chưa có địa điểm'))} · $races cuộc đua',
                      style: const TextStyle(
                        color: AdminPalette.muted,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_month_rounded,
                          color: AdminPalette.gold,
                          size: 17,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '${_date(adminText(tournament, 'startAt'))} – ${_date(adminText(tournament, 'endAt'))}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: AdminPalette.muted,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _date(String value) =>
      value.length >= 10 ? value.substring(0, 10) : 'Chưa đặt';
}

class _TournamentFormSheet extends StatefulWidget {
  const _TournamentFormSheet();

  @override
  State<_TournamentFormSheet> createState() => _TournamentFormSheetState();
}

class _TournamentFormSheetState extends State<_TournamentFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _description = TextEditingController();
  final _location = TextEditingController();
  final _rules = TextEditingController();
  DateTime? _registrationOpen;
  DateTime? _registrationClose;
  DateTime? _start;
  DateTime? _end;

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _location.dispose();
    _rules.dispose();
    super.dispose();
  }

  Future<void> _pick(String field) async {
    final initial = switch (field) {
      'registrationOpen' => _registrationOpen,
      'registrationClose' => _registrationClose,
      'start' => _start,
      _ => _end,
    };
    final date = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 1095)),
    );
    if (date == null) return;
    setState(() {
      switch (field) {
        case 'registrationOpen':
          _registrationOpen = date;
        case 'registrationClose':
          _registrationClose = date;
        case 'start':
          _start = date;
        case 'end':
          _end = date;
      }
    });
  }

  String _iso(DateTime date, int hour) =>
      DateTime(date.year, date.month, date.day, hour).toIso8601String();

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if ([
      _registrationOpen,
      _registrationClose,
      _start,
      _end,
    ].any((value) => value == null)) {
      showAdminMessage(
        context,
        'Vui lòng chọn đủ các mốc thời gian.',
        error: true,
      );
      return;
    }
    Navigator.pop<JsonMap>(context, {
      'name': _name.text.trim(),
      'description': _description.text.trim(),
      'location': _location.text.trim(),
      'registrationOpenAt': _iso(_registrationOpen!, 8),
      'registrationCloseAt': _iso(_registrationClose!, 17),
      'startAt': _iso(_start!, 8),
      'endAt': _iso(_end!, 18),
      'checkInDeadlineAt': _iso(_registrationClose!, 17),
      'rules': _rules.text.trim(),
      'minTeams': 1,
      'maxTeams': 100,
      'minHorsesPerOwner': 1,
      'maxHorsesPerOwner': 10,
      'jockeyChallengeEnabled': false,
      'jockeyChallengeFirstPoints': 3,
      'jockeyChallengeSecondPoints': 2,
      'jockeyChallengeThirdPoints': 1,
      'jockeyChallengePrizes': <Object>[],
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          18,
          18,
          18,
          MediaQuery.viewInsetsOf(context).bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tạo giải đấu mới',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 18),
                _field(_name, 'Tên giải đấu', required: true),
                _field(_description, 'Mô tả', maxLines: 3),
                _field(_location, 'Địa điểm', required: true),
                _field(_rules, 'Luật giải đấu', maxLines: 4),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _dateButton(
                      'Mở đăng ký',
                      _registrationOpen,
                      () => _pick('registrationOpen'),
                    ),
                    _dateButton(
                      'Đóng đăng ký',
                      _registrationClose,
                      () => _pick('registrationClose'),
                    ),
                    _dateButton('Bắt đầu', _start, () => _pick('start')),
                    _dateButton('Kết thúc', _end, () => _pick('end')),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: AdminPrimaryButton(
                    label: 'Tạo giải đấu',
                    icon: Icons.add_rounded,
                    onPressed: _submit,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    bool required = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        validator: required
            ? (value) =>
                  value == null || value.trim().isEmpty ? 'Bắt buộc' : null
            : null,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AdminPalette.muted),
          filled: true,
          fillColor: AdminPalette.card,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  Widget _dateButton(String label, DateTime? value, VoidCallback onTap) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.calendar_month_rounded),
      label: Text(
        value == null
            ? label
            : '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}',
      ),
    );
  }
}

class _TournamentDetailSheet extends StatefulWidget {
  const _TournamentDetailSheet({
    required this.tournamentId,
    required this.service,
  });

  final String tournamentId;
  final AdminApiService service;

  @override
  State<_TournamentDetailSheet> createState() => _TournamentDetailSheetState();
}

class _TournamentDetailSheetState extends State<_TournamentDetailSheet> {
  JsonMap? _tournament;
  List<JsonMap> _registrations = const [];
  bool _loading = true;
  int _tab = 0;
  String? _busyId;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = _tournament == null;
      _error = null;
    });
    try {
      final values = await Future.wait<Object>([
        widget.service.getTournament(widget.tournamentId),
        widget.service.getTournamentRegistrations(widget.tournamentId),
      ]);
      if (mounted) {
        setState(() {
          _tournament = values[0] as JsonMap;
          _registrations = values[1] as List<JsonMap>;
        });
      }
    } catch (error) {
      if (mounted) setState(() => _error = '$error');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _changeStatus() async {
    final current = adminText(_tournament!, 'status', 'DRAFT');
    final status = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        backgroundColor: AdminPalette.navyLight,
        title: const Text(
          'Cập nhật trạng thái',
          style: TextStyle(color: Colors.white),
        ),
        children:
            const [
                  'DRAFT',
                  'PUBLISHED',
                  'OPEN_REGISTRATION',
                  'REGISTRATION_CLOSED',
                  'SCHEDULED',
                  'ONGOING',
                  'COMPLETED',
                  'CANCELLED',
                ]
                .map(
                  (value) => SimpleDialogOption(
                    onPressed: () => Navigator.pop(context, value),
                    child: Text(
                      value,
                      style: TextStyle(
                        color: value == current
                            ? AdminPalette.gold
                            : Colors.white,
                      ),
                    ),
                  ),
                )
                .toList(),
      ),
    );
    if (status == null || !mounted) return;
    try {
      await widget.service.updateTournamentStatus(widget.tournamentId, status);
      await _load();
    } catch (error) {
      if (mounted) showAdminMessage(context, '$error', error: true);
    }
  }

  Future<void> _addRace() async {
    final name = await showAdminPrompt(
      context,
      title: 'Thêm cuộc đua',
      label: 'Tên cuộc đua',
      maxLines: 1,
    );
    if (name == null || !mounted) return;
    final start = DateTime.now().add(const Duration(days: 8));
    try {
      await widget.service.addTournamentRace(widget.tournamentId, {
        'name': name,
        'distance': '1000m',
        'scheduledStartAt': start.toIso8601String(),
        'scheduledEndAt': start.add(const Duration(hours: 1)).toIso8601String(),
        'minParticipants': 2,
        'maxParticipants': 12,
        'entryFee': 0,
        'note': '',
        'prizes': [
          {'rank': 1, 'amount': 0, 'itemName': 'Giải nhất'},
        ],
      });
      await _load();
    } catch (error) {
      if (mounted) showAdminMessage(context, '$error', error: true);
    }
  }

  Future<void> _deleteRace(JsonMap race) async {
    final id = adminText(race, 'id');
    final confirmed = await showAdminConfirm(
      context,
      title: 'Xóa cuộc đua?',
      message: adminText(race, 'name', 'Cuộc đua'),
      confirmLabel: 'Xóa',
      danger: true,
    );
    if (!confirmed || !mounted) return;
    setState(() => _busyId = id);
    try {
      await widget.service.deleteRace(id);
      await _load();
    } catch (error) {
      if (mounted) showAdminMessage(context, '$error', error: true);
    } finally {
      if (mounted) setState(() => _busyId = null);
    }
  }

  Future<void> _reviewRegistration(JsonMap registration, bool approve) async {
    final id = adminText(registration, 'id');
    String note = '';
    if (!approve) {
      final result = await showAdminPrompt(
        context,
        title: 'Từ chối đăng ký',
        label: 'Lý do từ chối',
      );
      if (result == null || !mounted) return;
      note = result;
    } else {
      final confirmed = await showAdminConfirm(
        context,
        title: 'Duyệt đăng ký?',
        message: adminText(
          registration,
          'horseName',
          adminText(registration, 'ownerName', 'Hồ sơ đăng ký'),
        ),
        confirmLabel: 'Duyệt',
      );
      if (!confirmed || !mounted) return;
    }
    setState(() => _busyId = id);
    try {
      if (approve) {
        await widget.service.approveRegistration(id);
      } else {
        await widget.service.rejectRegistration(id, note);
      }
      await _load();
    } catch (error) {
      if (mounted) showAdminMessage(context, '$error', error: true);
    } finally {
      if (mounted) setState(() => _busyId = null);
    }
  }

  Future<void> _editTournamentField(
    String key,
    String title,
    String label, {
    int maxLines = 2,
  }) async {
    final value = await showAdminPrompt(
      context,
      title: title,
      label: label,
      initialValue: adminText(_tournament!, key),
      maxLines: maxLines,
    );
    if (value == null || !mounted) return;
    try {
      await widget.service.updateTournament(widget.tournamentId, {key: value});
      await _load();
    } catch (error) {
      if (mounted) showAdminMessage(context, '$error', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * .88,
        child: _loading
            ? const AdminLoading()
            : _error != null
            ? AdminErrorCard(message: _error!, onRetry: _load)
            : _content(),
      ),
    );
  }

  Widget _content() {
    final item = _tournament!;
    final races =
        (item['races'] as List?)?.whereType<Map<String, dynamic>>().toList() ??
        const [];
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                adminText(item, 'name'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close_rounded, color: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            AdminStatusChip(adminText(item, 'status', 'DRAFT')),
            const Spacer(),
            TextButton.icon(
              onPressed: _changeStatus,
              icon: const Icon(Icons.sync_alt_rounded),
              label: const Text('Đổi trạng thái'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children:
                const [
                  ('Tổng quan', Icons.dashboard_rounded),
                  ('Cuộc đua', Icons.flag_rounded),
                  ('Tham gia', Icons.groups_rounded),
                  ('Lịch', Icons.calendar_month_rounded),
                  ('Kết quả', Icons.military_tech_rounded),
                  ('Thiết lập', Icons.settings_rounded),
                ].indexed.map((entry) {
                  final index = entry.$1;
                  final tab = entry.$2;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      avatar: Icon(tab.$2, size: 16),
                      label: Text(tab.$1),
                      selected: _tab == index,
                      onSelected: (_) => setState(() => _tab = index),
                    ),
                  );
                }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        ...switch (_tab) {
          0 => _overview(item, races),
          1 => _races(races),
          2 => _participants(),
          3 => _schedule(races),
          4 => _results(races),
          _ => _settings(item),
        },
      ],
    );
  }

  List<Widget> _overview(JsonMap item, List<JsonMap> races) {
    final totalPrize = races.fold<num>(0, (total, race) {
      final prizes = (race['prizes'] as List?) ?? const [];
      return total +
          prizes.whereType<Map>().fold<num>(
            0,
            (sum, prize) =>
                sum + (prize['amount'] is num ? prize['amount'] as num : 0),
          );
    });
    return [
      AdminCard(
        child: Text(
          adminText(item, 'description', 'Chưa có mô tả.'),
          style: const TextStyle(color: Colors.white70, height: 1.5),
        ),
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            child: AdminStatCard(
              label: 'Cuộc đua',
              value: '${races.length}',
              icon: Icons.flag_rounded,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: AdminStatCard(
              label: 'Đăng ký',
              value: '${_registrations.length}',
              icon: Icons.groups_rounded,
              color: AdminPalette.success,
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      AdminStatCard(
        label: 'Tổng giải thưởng',
        value: formatAdminMoney(totalPrize),
        icon: Icons.workspace_premium_rounded,
        color: const Color(0xFFC084FC),
      ),
      const SizedBox(height: 12),
      AdminCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Luật giải đấu',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              adminText(item, 'rules', 'Chưa có luật giải đấu.'),
              style: const TextStyle(color: AdminPalette.muted, height: 1.5),
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _races(List<JsonMap> races) {
    return [
      Row(
        children: [
          const Expanded(
            child: Text(
              'Các cuộc đua',
              style: TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          AdminPrimaryButton(
            label: 'Thêm',
            icon: Icons.add_rounded,
            onPressed: _addRace,
          ),
        ],
      ),
      const SizedBox(height: 12),
      if (races.isEmpty)
        const AdminEmptyState(message: 'Chưa cấu hình cuộc đua')
      else
        ...races.map(
          (race) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: AdminCard(
              child: Row(
                children: [
                  const Icon(Icons.flag_rounded, color: AdminPalette.gold),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          adminText(race, 'name', 'Cuộc đua'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          '${adminText(race, 'distance')} · ${adminText(race, 'maxParticipants', '0')} ngựa · ${formatAdminMoney(race['entryFee'])}',
                          style: const TextStyle(
                            color: AdminPalette.muted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AdminStatusChip(adminText(race, 'status', 'DRAFT')),
                  IconButton(
                    tooltip: 'Xóa cuộc đua',
                    onPressed: _busyId == adminText(race, 'id')
                        ? null
                        : () => _deleteRace(race),
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: AdminPalette.danger,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
    ];
  }

  List<Widget> _participants() {
    if (_registrations.isEmpty) {
      return const [AdminEmptyState(message: 'Chưa có hồ sơ đăng ký tham gia')];
    }
    return _registrations.map((registration) {
      final id = adminText(registration, 'id');
      final status = adminText(registration, 'status', 'Chờ duyệt');
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: AdminCard(
          child: Column(
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: AdminPalette.navyLight,
                    child: Icon(Icons.pets_rounded, color: AdminPalette.gold),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          adminText(registration, 'horseName', 'Hồ sơ đăng ký'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          '${adminText(registration, 'ownerName', adminText(registration, 'ownerUsername'))} · ${adminText(registration, 'raceName')}',
                          style: const TextStyle(
                            color: AdminPalette.muted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AdminStatusChip(status),
                ],
              ),
              if (status == 'Chờ duyệt' || status == 'PENDING') ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _busyId == id
                            ? null
                            : () => _reviewRegistration(registration, false),
                        child: const Text('Từ chối'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AdminPrimaryButton(
                        label: 'Duyệt',
                        icon: Icons.check_rounded,
                        busy: _busyId == id,
                        onPressed: () =>
                            _reviewRegistration(registration, true),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      );
    }).toList();
  }

  List<Widget> _schedule(List<JsonMap> races) {
    if (races.isEmpty) {
      return const [AdminEmptyState(message: 'Chưa có lịch thi đấu')];
    }
    final sorted = [...races]
      ..sort(
        (a, b) => adminText(
          a,
          'scheduledStartAt',
        ).compareTo(adminText(b, 'scheduledStartAt')),
      );
    return sorted.map((race) {
      final date = adminText(race, 'scheduledStartAt');
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: AdminCard(
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: AdminPalette.gold.withValues(alpha: .13),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.calendar_month_rounded,
                  color: AdminPalette.gold,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      adminText(race, 'name'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      date.length >= 16
                          ? '${date.substring(0, 10)} · ${date.substring(11, 16)}'
                          : 'Chưa xếp lịch',
                      style: const TextStyle(
                        color: AdminPalette.muted,
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      adminText(
                        race,
                        'venueName',
                        adminText(race, 'venueAddress', 'Chưa có sân'),
                      ),
                      style: const TextStyle(
                        color: AdminPalette.muted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  List<Widget> _results(List<JsonMap> races) {
    if (races.isEmpty) {
      return const [AdminEmptyState(message: 'Chưa có cuộc đua')];
    }
    return races.map((race) {
      final results = (race['results'] as List?) ?? const [];
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: AdminCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      adminText(race, 'name'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  AdminStatusChip(adminText(race, 'status')),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                results.isEmpty
                    ? 'Chưa có kết quả được xác nhận'
                    : '${results.length} kết quả đã ghi nhận',
                style: const TextStyle(color: AdminPalette.muted),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  List<Widget> _settings(JsonMap item) {
    return [
      AdminCard(
        child: Column(
          children: [
            _settingRow(
              'Tên giải đấu',
              adminText(item, 'name'),
              () => _editTournamentField(
                'name',
                'Đổi tên giải đấu',
                'Tên giải đấu',
                maxLines: 1,
              ),
            ),
            const Divider(color: AdminPalette.line),
            _settingRow(
              'Mô tả',
              adminText(item, 'description', 'Chưa có'),
              () => _editTournamentField(
                'description',
                'Cập nhật mô tả',
                'Mô tả',
                maxLines: 4,
              ),
            ),
            const Divider(color: AdminPalette.line),
            _settingRow(
              'Địa điểm',
              adminText(item, 'location', 'Chưa có'),
              () => _editTournamentField(
                'location',
                'Cập nhật địa điểm',
                'Địa điểm',
                maxLines: 1,
              ),
            ),
            const Divider(color: AdminPalette.line),
            _settingRow(
              'Luật giải đấu',
              adminText(item, 'rules', 'Chưa có'),
              () => _editTournamentField(
                'rules',
                'Cập nhật luật',
                'Luật giải đấu',
                maxLines: 7,
              ),
            ),
          ],
        ),
      ),
    ];
  }

  Widget _settingRow(String label, String value, VoidCallback onTap) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: const TextStyle(color: Colors.white)),
      subtitle: Text(
        value,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: AdminPalette.muted),
      ),
      trailing: IconButton(
        onPressed: onTap,
        icon: const Icon(Icons.edit_rounded, color: AdminPalette.info),
      ),
    );
  }
}
