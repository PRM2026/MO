import 'package:flutter/material.dart';

import '../../services/admin_api_service.dart';
import '../../widgets/admin/admin_dialogs.dart';
import '../../widgets/admin/admin_ui.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final AdminApiService _service = AdminApiService();
  final TextEditingController _search = TextEditingController();
  List<JsonMap> _users = const [];
  List<JsonMap> _applications = const [];
  bool _loading = true;
  bool _showApplications = false;
  String _role = 'ALL';
  String? _busyId;
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
      final values = await Future.wait<Object>([
        _service.getUsers(),
        _service.getRoleApplications(),
      ]);
      if (!mounted) return;
      setState(() {
        _users = values[0] as List<JsonMap>;
        _applications = values[1] as List<JsonMap>;
      });
    } catch (error) {
      if (mounted) setState(() => _error = '$error');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<JsonMap> get _visibleUsers {
    final query = _search.text.trim().toLowerCase();
    return _users.where((user) {
      final roleMatches =
          _role == 'ALL' || adminText(user, 'role').toUpperCase() == _role;
      final haystack = [
        adminText(user, 'fullName'),
        adminText(user, 'username'),
        adminText(user, 'email'),
        adminText(user, 'phone'),
      ].join(' ').toLowerCase();
      return roleMatches && (query.isEmpty || haystack.contains(query));
    }).toList();
  }

  List<JsonMap> get _pendingApplications => _applications
      .where(
        (item) =>
            adminText(item, 'status', 'PENDING').toUpperCase() == 'PENDING',
      )
      .toList();

  Future<void> _toggleUser(JsonMap user) async {
    final id = adminText(user, 'id');
    final active = user['active'] != false;
    final confirmed = await showAdminConfirm(
      context,
      title: active ? 'Khóa tài khoản?' : 'Kích hoạt tài khoản?',
      message: active
          ? 'Người dùng sẽ không thể đăng nhập cho đến khi được mở khóa.'
          : 'Người dùng sẽ có thể đăng nhập lại ngay.',
      confirmLabel: active ? 'Khóa' : 'Kích hoạt',
      danger: active,
    );
    if (!confirmed || !mounted) return;
    await _run(id, () async {
      if (active) {
        await _service.deactivateUser(id);
      } else {
        await _service.activateUser(id);
      }
    });
  }

  Future<void> _changeRole(JsonMap user) async {
    final id = adminText(user, 'id');
    var selected = adminText(user, 'role', 'USER').toUpperCase();
    final role = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AdminPalette.navyLight,
        title: const Text(
          'Cập nhật vai trò',
          style: TextStyle(color: Colors.white),
        ),
        content: StatefulBuilder(
          builder: (context, setLocalState) => DropdownButtonFormField<String>(
            initialValue: selected,
            dropdownColor: AdminPalette.navyLight,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Vai trò',
              labelStyle: TextStyle(color: AdminPalette.muted),
            ),
            items:
                const [
                      'USER',
                      'OWNER',
                      'JOCKEY',
                      'REFEREE',
                      'SPECTATOR',
                      'ADMIN',
                    ]
                    .map(
                      (value) =>
                          DropdownMenuItem(value: value, child: Text(value)),
                    )
                    .toList(),
            onChanged: (value) =>
                setLocalState(() => selected = value ?? selected),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, selected),
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
    if (role == null || !mounted) return;
    await _run(id, () => _service.updateUserRole(id, role));
  }

  Future<void> _reviewApplication(JsonMap application, bool approve) async {
    final id = adminText(
      application,
      'profileId',
      adminText(application, 'id'),
    );
    final role = adminText(application, 'role');
    String? reason;
    if (!approve) {
      reason = await showAdminPrompt(
        context,
        title: 'Từ chối yêu cầu vai trò',
        label: 'Lý do từ chối',
      );
      if (reason == null || !mounted) return;
    } else {
      final confirmed = await showAdminConfirm(
        context,
        title: 'Duyệt yêu cầu vai trò?',
        message: 'Tài khoản sẽ được cấp vai trò $role.',
        confirmLabel: 'Duyệt',
      );
      if (!confirmed || !mounted) return;
    }
    await _run(id, () async {
      if (approve) {
        await _service.approveRoleApplication(id, role: role);
      } else {
        await _service.rejectRoleApplication(id, role: role, reason: reason!);
      }
    });
  }

  Future<void> _run(String id, Future<void> Function() action) async {
    setState(() => _busyId = id);
    try {
      await action();
      if (!mounted) return;
      showAdminMessage(context, 'Đã cập nhật thành công.');
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
        title: 'Người dùng',
        subtitle: 'Quản lý tài khoản và xét duyệt yêu cầu vai trò',
        child: _body(),
      ),
    );
  }

  Widget _body() {
    if (_loading && _users.isEmpty) return const AdminLoading();
    if (_error != null && _users.isEmpty) {
      return AdminErrorCard(message: _error!, onRetry: _load);
    }
    return Column(
      children: [
        SegmentedButton<bool>(
          segments: [
            const ButtonSegment(
              value: false,
              label: Text('Tài khoản'),
              icon: Icon(Icons.people_alt_rounded),
            ),
            ButtonSegment(
              value: true,
              label: Text('Chờ duyệt (${_pendingApplications.length})'),
              icon: const Icon(Icons.approval_rounded),
            ),
          ],
          selected: {_showApplications},
          onSelectionChanged: (value) =>
              setState(() => _showApplications = value.first),
          style: const ButtonStyle(
            foregroundColor: WidgetStatePropertyAll(Colors.white),
            backgroundColor: WidgetStatePropertyAll(AdminPalette.navyLight),
          ),
        ),
        const SizedBox(height: 16),
        if (_showApplications)
          _applicationsList()
        else ...[
          TextField(
            controller: _search,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Tìm tên, email, số điện thoại...',
              hintStyle: const TextStyle(color: AdminPalette.muted),
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: AdminPalette.muted,
              ),
              filled: true,
              fillColor: AdminPalette.card,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AdminPalette.line),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: ['ALL', 'USER', 'OWNER', 'JOCKEY', 'REFEREE', 'ADMIN']
                  .map(
                    (role) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(role == 'ALL' ? 'Tất cả' : role),
                        selected: _role == role,
                        onSelected: (_) => setState(() => _role = role),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 12),
          if (_visibleUsers.isEmpty)
            const AdminEmptyState(message: 'Không tìm thấy người dùng')
          else
            ..._visibleUsers.map(_userCard),
        ],
      ],
    );
  }

  Widget _userCard(JsonMap user) {
    final id = adminText(user, 'id');
    final active = user['active'] != false;
    final name = adminText(
      user,
      'fullName',
      adminText(user, 'username', 'Người dùng'),
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AdminCard(
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AdminPalette.gold,
                  foregroundColor: AdminPalette.navy,
                  child: Text(
                    name.isEmpty ? 'U' : name.characters.first.toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        adminText(user, 'email'),
                        style: const TextStyle(
                          color: AdminPalette.muted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                AdminStatusChip(active ? 'ACTIVE' : 'SUSPENDED'),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                AdminStatusChip(adminText(user, 'role', 'USER')),
                const Spacer(),
                IconButton(
                  tooltip: 'Đổi vai trò',
                  onPressed: _busyId == id ? null : () => _changeRole(user),
                  icon: const Icon(
                    Icons.manage_accounts_rounded,
                    color: AdminPalette.info,
                  ),
                ),
                IconButton(
                  tooltip: active ? 'Khóa' : 'Mở khóa',
                  onPressed: _busyId == id ? null : () => _toggleUser(user),
                  icon: Icon(
                    active ? Icons.lock_rounded : Icons.lock_open_rounded,
                    color: active ? AdminPalette.danger : AdminPalette.success,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _applicationsList() {
    if (_pendingApplications.isEmpty) {
      return const AdminEmptyState(
        message: 'Không có yêu cầu vai trò đang chờ',
        icon: Icons.task_alt_rounded,
      );
    }
    return Column(
      children: _pendingApplications.map((application) {
        final id = adminText(
          application,
          'profileId',
          adminText(application, 'id'),
        );
        final name = adminText(
          application,
          'fullName',
          adminText(application, 'username', 'Người dùng'),
        );
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
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    AdminStatusChip(adminText(application, 'role')),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  adminText(application, 'email', 'Chưa có email'),
                  style: const TextStyle(color: AdminPalette.muted),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _busyId == id
                            ? null
                            : () => _reviewApplication(application, false),
                        icon: const Icon(Icons.close_rounded),
                        label: const Text('Từ chối'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AdminPrimaryButton(
                        label: 'Duyệt',
                        icon: Icons.check_rounded,
                        busy: _busyId == id,
                        onPressed: () => _reviewApplication(application, true),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
