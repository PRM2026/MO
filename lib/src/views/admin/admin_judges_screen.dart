import 'package:flutter/material.dart';

import '../../services/admin_api_service.dart';
import '../../widgets/admin/admin_dialogs.dart';
import '../../widgets/admin/admin_ui.dart';

class AdminJudgesScreen extends StatefulWidget {
  const AdminJudgesScreen({super.key});

  @override
  State<AdminJudgesScreen> createState() => _AdminJudgesScreenState();
}

class _AdminJudgesScreenState extends State<AdminJudgesScreen> {
  final AdminApiService _service = AdminApiService();
  List<JsonMap> _tournaments = const [];
  List<JsonMap> _referees = const [];
  List<JsonMap> _invitations = const [];
  List<JsonMap> _salaryConfigs = const [];
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
        _service.getTournaments(),
        _service.getUsers(),
        _service.getRefereeInvitations(),
        _service.getRefereeSalaryConfigs(),
      ]);
      if (!mounted) return;
      setState(() {
        _tournaments = (values[0] as List<JsonMap>)
            .where(
              (item) => adminText(item, 'status').toUpperCase() == 'PUBLISHED',
            )
            .toList();
        _referees = (values[1] as List<JsonMap>)
            .where(
              (item) =>
                  adminText(item, 'role').toUpperCase() == 'REFEREE' &&
                  item['active'] != false,
            )
            .toList();
        _invitations = values[2] as List<JsonMap>;
        _salaryConfigs = values[3] as List<JsonMap>;
      });
    } catch (error) {
      if (mounted) setState(() => _error = '$error');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openTournament(JsonMap tournament) async {
    final detail = await _service.getTournament(adminText(tournament, 'id'));
    if (!mounted) return;
    final races =
        (detail['races'] as List?)
            ?.whereType<Map<String, dynamic>>()
            .toList() ??
        const [];
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AdminPalette.navy,
      builder: (_) => SafeArea(
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * .82,
          child: ListView(
            padding: const EdgeInsets.all(18),
            children: [
              Text(
                adminText(detail, 'name'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Chọn cuộc đua để gửi lời mời trọng tài',
                style: TextStyle(color: AdminPalette.muted),
              ),
              const SizedBox(height: 16),
              if (races.isEmpty)
                const AdminEmptyState(message: 'Giải chưa có cuộc đua')
              else
                ...races.map(
                  (race) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: AdminCard(
                      child: Row(
                        children: [
                          const Icon(
                            Icons.flag_rounded,
                            color: AdminPalette.gold,
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
                                  adminText(
                                    race,
                                    'refereeUsername',
                                    adminText(
                                      race,
                                      'refereeName',
                                      'Chưa phân công',
                                    ),
                                  ),
                                  style: const TextStyle(
                                    color: AdminPalette.muted,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          AdminPrimaryButton(
                            label: 'Mời',
                            icon: Icons.send_rounded,
                            onPressed: () => _invite(race),
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
  }

  Future<void> _invite(JsonMap race) async {
    if (_referees.isEmpty) {
      showAdminMessage(
        context,
        'Chưa có tài khoản trọng tài hoạt động.',
        error: true,
      );
      return;
    }
    var refereeId = adminText(_referees.first, 'id');
    String? salaryConfigId = _salaryConfigs.isEmpty
        ? null
        : adminText(_salaryConfigs.first, 'id');
    final selected = await showDialog<JsonMap>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setLocal) => AlertDialog(
          backgroundColor: AdminPalette.navyLight,
          title: const Text(
            'Gửi lời mời trọng tài',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: refereeId,
                dropdownColor: AdminPalette.navyLight,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Trọng tài',
                  labelStyle: TextStyle(color: AdminPalette.muted),
                ),
                items: _referees
                    .map(
                      (item) => DropdownMenuItem(
                        value: adminText(item, 'id'),
                        child: Text(
                          adminText(
                            item,
                            'fullName',
                            adminText(item, 'username'),
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) =>
                    setLocal(() => refereeId = value ?? refereeId),
              ),
              if (_salaryConfigs.isNotEmpty) ...[
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: salaryConfigId,
                  dropdownColor: AdminPalette.navyLight,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Cấu hình lương',
                    labelStyle: TextStyle(color: AdminPalette.muted),
                  ),
                  items: _salaryConfigs
                      .map(
                        (item) => DropdownMenuItem(
                          value: adminText(item, 'id'),
                          child: Text(
                            '${adminText(item, 'name')} · ${formatAdminMoney(item['amount'])}',
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setLocal(() => salaryConfigId = value),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () {
                final payload = <String, dynamic>{'refereeId': refereeId};
                if (salaryConfigId case final salaryId?) {
                  payload['salaryConfigId'] = salaryId;
                }
                Navigator.pop(context, payload);
              },
              child: const Text('Gửi lời mời'),
            ),
          ],
        ),
      ),
    );
    if (selected == null || !mounted) return;
    try {
      await _service.createRefereeInvitation({
        'raceId': adminText(race, 'id'),
        ...selected,
        'message': 'Lời mời phân công từ Admin',
      });
      if (!mounted) return;
      showAdminMessage(context, 'Đã gửi lời mời trọng tài.');
      Navigator.pop(context);
      await _load();
    } catch (error) {
      if (mounted) showAdminMessage(context, '$error', error: true);
    }
  }

  Future<void> _cancel(JsonMap invitation) async {
    final id = adminText(invitation, 'id');
    final confirmed = await showAdminConfirm(
      context,
      title: 'Hủy lời mời?',
      message: 'Trọng tài sẽ không thể phản hồi lời mời này.',
      confirmLabel: 'Hủy lời mời',
      danger: true,
    );
    if (!confirmed || !mounted) return;
    setState(() => _busyId = id);
    try {
      await _service.cancelRefereeInvitation(id);
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
        title: 'Phân công trọng tài',
        subtitle: 'Mời trọng tài vào các cuộc đua đã công bố',
        child: _body(),
      ),
    );
  }

  Widget _body() {
    if (_loading && _invitations.isEmpty) return const AdminLoading();
    if (_error != null && _invitations.isEmpty) {
      return AdminErrorCard(message: _error!, onRetry: _load);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Giải đấu đã công bố',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        if (_tournaments.isEmpty)
          const AdminEmptyState(message: 'Chưa có giải đấu được công bố')
        else
          ..._tournaments.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: () => _openTournament(item),
                borderRadius: BorderRadius.circular(20),
                child: AdminCard(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.emoji_events_rounded,
                        color: AdminPalette.gold,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          adminText(item, 'name'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AdminPalette.muted,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        const SizedBox(height: 20),
        const Text(
          'Lịch sử lời mời',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        if (_invitations.isEmpty)
          const AdminEmptyState(message: 'Chưa có lời mời trọng tài')
        else
          ..._invitations.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AdminCard(
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AdminPalette.gold.withValues(alpha: .15),
                      child: const Icon(
                        Icons.sports_rounded,
                        color: AdminPalette.gold,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            adminText(
                              item,
                              'refereeUsername',
                              adminText(item, 'refereeName'),
                            ),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            '${adminText(item, 'tournamentName')} · ${adminText(item, 'raceName')}',
                            style: const TextStyle(
                              color: AdminPalette.muted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        AdminStatusChip(adminText(item, 'status')),
                        if (adminText(item, 'status') == 'Chờ xử lý')
                          TextButton(
                            onPressed: _busyId == adminText(item, 'id')
                                ? null
                                : () => _cancel(item),
                            child: const Text('Hủy'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
