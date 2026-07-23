import 'package:flutter/material.dart';

import '../../services/admin_api_service.dart';
import '../../widgets/admin/admin_dialogs.dart';
import '../../widgets/admin/admin_ui.dart';

class AdminHorsesScreen extends StatefulWidget {
  const AdminHorsesScreen({super.key});

  @override
  State<AdminHorsesScreen> createState() => _AdminHorsesScreenState();
}

class _AdminHorsesScreenState extends State<AdminHorsesScreen> {
  final AdminApiService _service = AdminApiService();
  final TextEditingController _search = TextEditingController();
  List<JsonMap> _horses = const [];
  String _status = 'ALL';
  String? _busyId;
  String? _error;
  bool _loading = true;

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
      final horses = await _service.getHorses();
      if (mounted) setState(() => _horses = horses);
    } catch (error) {
      if (mounted) setState(() => _error = '$error');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<JsonMap> get _visible {
    final query = _search.text.trim().toLowerCase();
    return _horses.where((horse) {
      final status = adminText(
        horse,
        'statusCode',
        adminText(horse, 'approvalStatus'),
      ).toUpperCase();
      final statusMatches = _status == 'ALL' || status == _status;
      final haystack = [
        adminText(horse, 'name'),
        adminText(horse, 'breed'),
        adminText(horse, 'ownerName'),
        adminText(horse, 'ownerUsername'),
      ].join(' ').toLowerCase();
      return statusMatches && (query.isEmpty || haystack.contains(query));
    }).toList();
  }

  Future<void> _action(JsonMap horse, String action) async {
    final id = adminText(horse, 'id');
    String reason = '';
    if (action == 'reject' || action == 'suspend') {
      final value = await showAdminPrompt(
        context,
        title: action == 'reject' ? 'Từ chối ngựa' : 'Tạm khóa ngựa',
        label: 'Lý do',
      );
      if (value == null || !mounted) return;
      reason = value;
    } else {
      final confirmed = await showAdminConfirm(
        context,
        title: 'Duyệt ngựa?',
        message: 'Ngựa sẽ đủ điều kiện tham gia các giải đấu.',
        confirmLabel: 'Duyệt',
      );
      if (!confirmed || !mounted) return;
    }

    setState(() => _busyId = id);
    try {
      switch (action) {
        case 'approve':
          await _service.approveHorse(id);
        case 'reject':
          await _service.rejectHorse(id, reason);
        case 'suspend':
          await _service.suspendHorse(id, reason);
      }
      if (!mounted) return;
      showAdminMessage(context, 'Đã cập nhật trạng thái ngựa.');
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
        title: 'Quản lý ngựa',
        subtitle: 'Duyệt hồ sơ, từ chối và tạm khóa ngựa thi đấu',
        child: _body(),
      ),
    );
  }

  Widget _body() {
    if (_loading && _horses.isEmpty) return const AdminLoading();
    if (_error != null && _horses.isEmpty) {
      return AdminErrorCard(message: _error!, onRetry: _load);
    }
    return Column(
      children: [
        TextField(
          controller: _search,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Tìm ngựa, giống hoặc chủ sở hữu...',
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
        const SizedBox(height: 12),
        SizedBox(
          height: 42,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children:
                const [
                  ('ALL', 'Tất cả'),
                  ('PENDING', 'Chờ duyệt'),
                  ('APPROVED', 'Đã duyệt'),
                  ('REJECTED', 'Từ chối'),
                  ('SUSPENDED', 'Tạm khóa'),
                ].map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(entry.$2),
                      selected: _status == entry.$1,
                      onSelected: (_) => setState(() => _status = entry.$1),
                    ),
                  );
                }).toList(),
          ),
        ),
        const SizedBox(height: 14),
        if (_visible.isEmpty)
          const AdminEmptyState(message: 'Không có ngựa phù hợp')
        else
          ..._visible.map(_horseCard),
      ],
    );
  }

  Widget _horseCard(JsonMap horse) {
    final id = adminText(horse, 'id');
    final status = adminText(
      horse,
      'statusCode',
      adminText(horse, 'approvalStatus', 'PENDING'),
    );
    final imageUrl = adminText(horse, 'imageUrl');
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AdminCard(
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: imageUrl.isEmpty
                      ? Container(
                          width: 72,
                          height: 72,
                          color: AdminPalette.navyLight,
                          child: const Icon(
                            Icons.pets_rounded,
                            color: AdminPalette.gold,
                          ),
                        )
                      : Image.network(
                          imageUrl,
                          width: 72,
                          height: 72,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            width: 72,
                            height: 72,
                            color: AdminPalette.navyLight,
                            child: const Icon(
                              Icons.pets_rounded,
                              color: AdminPalette.gold,
                            ),
                          ),
                        ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        adminText(horse, 'name', 'Ngựa chưa đặt tên'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${adminText(horse, 'breed', 'Chưa rõ giống')} · '
                        '${adminText(horse, 'age', '0')} tuổi',
                        style: const TextStyle(
                          color: AdminPalette.muted,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Chủ: ${adminText(horse, 'ownerName', adminText(horse, 'ownerUsername', 'Chưa cập nhật'))}',
                        style: const TextStyle(
                          color: AdminPalette.muted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                AdminStatusChip(status),
              ],
            ),
            if (adminText(horse, 'reviewReason').isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AdminPalette.navyLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Lý do: ${adminText(horse, 'reviewReason')}',
                  style: const TextStyle(
                    color: AdminPalette.muted,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 13),
            Row(
              children: [
                if (status != 'APPROVED')
                  Expanded(
                    child: AdminPrimaryButton(
                      label: 'Duyệt',
                      icon: Icons.check_rounded,
                      busy: _busyId == id,
                      onPressed: () => _action(horse, 'approve'),
                    ),
                  ),
                if (status != 'APPROVED') const SizedBox(width: 8),
                if (status == 'PENDING')
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _busyId == id
                          ? null
                          : () => _action(horse, 'reject'),
                      child: const Text('Từ chối'),
                    ),
                  ),
                if (status == 'APPROVED')
                  Expanded(
                    child: AdminPrimaryButton(
                      label: 'Tạm khóa',
                      icon: Icons.block_rounded,
                      danger: true,
                      busy: _busyId == id,
                      onPressed: () => _action(horse, 'suspend'),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
