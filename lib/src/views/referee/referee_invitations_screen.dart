import 'package:flutter/material.dart';

import '../../services/api_client.dart';
import '../../widgets/referee/referee_app_bar.dart';

class RefereeInvitation {
  const RefereeInvitation({
    required this.id,
    required this.raceName,
    required this.tournamentName,
    required this.status,
    this.message,
    this.scheduledAt,
  });

  final String id;
  final String raceName;
  final String tournamentName;
  final String status;
  final String? message;
  final DateTime? scheduledAt;

  factory RefereeInvitation.fromJson(Map<String, dynamic> json) {
    return RefereeInvitation(
      id: '${json['id'] ?? ''}',
      raceName: '${json['raceName'] ?? 'Cuộc đua'}',
      tournamentName: '${json['tournamentName'] ?? 'Giải đấu'}',
      status: '${json['status'] ?? 'PENDING'}'.toUpperCase(),
      message: json['message']?.toString(),
      scheduledAt: DateTime.tryParse('${json['raceScheduledStartAt'] ?? ''}'),
    );
  }
}

class RefereeInvitationsScreen extends StatefulWidget {
  const RefereeInvitationsScreen({super.key, this.apiClient});

  final ApiClient? apiClient;

  @override
  State<RefereeInvitationsScreen> createState() =>
      _RefereeInvitationsScreenState();
}

class _RefereeInvitationsScreenState extends State<RefereeInvitationsScreen> {
  late final ApiClient _api;
  List<RefereeInvitation> _items = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _api = widget.apiClient ?? ApiClient();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await _api.getList(
        '/referee/invitations',
        RefereeInvitation.fromJson,
      );
      if (mounted) setState(() => _items = items);
    } catch (error) {
      if (mounted) setState(() => _error = '$error');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _respond(RefereeInvitation item, bool accept) async {
    try {
      await _api.postObject(
        '/referee/invitations/${item.id}/${accept ? 'accept' : 'reject'}',
        const {},
        RefereeInvitation.fromJson,
      );
      await _load();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: const RefereeAppBar(
        showBack: true,
        titleOverride: 'Lời mời điều hành',
        profileInteractive: false,
        showInvitationAction: false,
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Text(_error!, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  FilledButton(onPressed: _load, child: const Text('Thử lại')),
                ],
              )
            : _items.isEmpty
            ? ListView(
                padding: const EdgeInsets.all(32),
                children: const [
                  Icon(Icons.mark_email_read_outlined, size: 52),
                  SizedBox(height: 12),
                  Text(
                    'Chưa có lời mời điều hành.',
                    textAlign: TextAlign.center,
                  ),
                ],
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 100),
                itemCount: _items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (_, index) {
                  final item = _items[index];
                  final pending = item.status == 'PENDING';
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.raceName,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          Text(
                            item.tournamentName,
                            style: TextStyle(color: scheme.onSurfaceVariant),
                          ),
                          if (item.message?.isNotEmpty == true) ...[
                            const SizedBox(height: 8),
                            Text(item.message!),
                          ],
                          const SizedBox(height: 12),
                          if (pending)
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => _respond(item, false),
                                    child: const Text('Từ chối'),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: FilledButton(
                                    onPressed: () => _respond(item, true),
                                    child: const Text('Chấp nhận'),
                                  ),
                                ),
                              ],
                            )
                          else
                            Chip(label: Text(item.status)),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
