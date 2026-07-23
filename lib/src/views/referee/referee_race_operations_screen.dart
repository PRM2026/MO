import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../constants/app_spacing.dart';
import '../../constants/app_theme_tokens.dart';
import '../../constants/referee_colors.dart';
import '../../models/assigned_race_item.dart';
import '../../models/referee_race_participant_response.dart';
import '../../services/referee_dashboard_service.dart';
import '../../utils/app_toast.dart';
import '../../widgets/referee/referee_ambient_background.dart';
import '../../widgets/referee/referee_app_bar.dart';
import '../../widgets/referee/referee_glass_card.dart';

class RefereeRaceOperationsScreen extends StatefulWidget {
  const RefereeRaceOperationsScreen({super.key, required this.race});

  final AssignedRaceItem race;

  @override
  State<RefereeRaceOperationsScreen> createState() =>
      _RefereeRaceOperationsScreenState();
}

class _RefereeRaceOperationsScreenState
    extends State<RefereeRaceOperationsScreen> {
  final _service = RefereeDashboardService();
  final Map<int, TextEditingController> _finishTimes = {};
  List<RefereeRaceParticipantResponse> _participants = const [];
  bool _loading = true;
  bool _mutating = false;
  String? _error;
  late String _status;

  int get _raceId => int.tryParse(widget.race.id) ?? 0;

  @override
  void initState() {
    super.initState();
    _status = widget.race.beStatus.toUpperCase();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final participants = await _service.getRaceParticipants(_raceId);
      if (!mounted) return;
      setState(() => _participants = participants);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _checkIn(RefereeRaceParticipantResponse participant) async {
    final id = participant.id;
    if (id == null) return;
    setState(() => _mutating = true);
    try {
      await _service.checkInParticipant(
        raceId: _raceId,
        participantId: id,
        status: 'CHECKED_IN',
      );
      if (!mounted) return;
      AppToast.showSuccess(
        context,
        'Đã check-in ${participant.horseName ?? 'ngựa'}.',
      );
      await _load();
    } catch (error) {
      if (mounted) AppToast.showError(context, error.toString());
    } finally {
      if (mounted) setState(() => _mutating = false);
    }
  }

  Future<void> _startRace() async {
    setState(() => _mutating = true);
    try {
      final race = await _service.startRace(_raceId);
      if (!mounted) return;
      setState(() => _status = (race.status ?? 'ONGOING').toUpperCase());
      AppToast.showSuccess(context, 'Cuộc đua đã bắt đầu.');
    } catch (error) {
      if (mounted) AppToast.showError(context, error.toString());
    } finally {
      if (mounted) setState(() => _mutating = false);
    }
  }

  Future<void> _finalize() async {
    final checkedIn = _participants.where(_isCheckedIn).toList();
    final results = <Map<String, dynamic>>[];
    for (var index = 0; index < checkedIn.length; index++) {
      final participant = checkedIn[index];
      final id = participant.id;
      final time = int.tryParse(_controllerFor(id).text.trim());
      if (id == null || time == null || time < 0) {
        AppToast.showError(
          context,
          'Vui lòng nhập thời gian về đích hợp lệ cho mọi ngựa.',
        );
        return;
      }
      results.add({
        'participantId': id,
        'rank': index + 1,
        'finishTimeMillis': time,
        'status': 'FINISHED',
      });
    }
    if (results.isEmpty) {
      AppToast.showError(context, 'Không có ngựa đã check-in để chốt kết quả.');
      return;
    }
    setState(() => _mutating = true);
    try {
      await _service.finalizeRaceResults(_raceId, results);
      if (!mounted) return;
      setState(() => _status = 'RESULT_CONFIRMED');
      AppToast.showSuccess(context, 'Đã chốt kết quả cuộc đua.');
    } catch (error) {
      if (mounted) AppToast.showError(context, error.toString());
    } finally {
      if (mounted) setState(() => _mutating = false);
    }
  }

  TextEditingController _controllerFor(int? participantId) {
    return _finishTimes.putIfAbsent(
      participantId ?? 0,
      TextEditingController.new,
    );
  }

  bool _isCheckedIn(RefereeRaceParticipantResponse participant) {
    final status = (participant.status ?? '').toUpperCase();
    return status == 'CHECKED_IN' || status == 'READY' || status == 'FINISHED';
  }

  @override
  void dispose() {
    for (final controller in _finishTimes.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final checkedCount = _participants.where(_isCheckedIn).length;
    return Scaffold(
      backgroundColor: RefereeColors.background,
      appBar: RefereeAppBar(
        showBack: true,
        titleOverride: widget.race.title,
        profileInteractive: false,
      ),
      body: RefereeAmbientBackground(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: RefereeColors.tertiary),
              )
            : RefreshIndicator(
                color: RefereeColors.tertiary,
                onRefresh: _load,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.lg,
                    AppSpacing.md,
                    80,
                  ),
                  children: [
                    RefereeGlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            widget.race.raceCode,
                            style: AppTypography.labelCaps(
                              RefereeColors.tertiary,
                            ),
                          ),
                          Text(
                            widget.race.title,
                            style: AppTypography.headlineSm(Colors.white),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            '$_status • $checkedCount/${_participants.length} đã check-in',
                          ),
                          if (_status == 'SCHEDULED' ||
                              _status == 'CHECK_IN') ...[
                            const SizedBox(height: AppSpacing.md),
                            FilledButton.icon(
                              onPressed: _mutating || checkedCount == 0
                                  ? null
                                  : _startRace,
                              icon: const Icon(Icons.flag_outlined),
                              label: const Text('Bắt đầu cuộc đua'),
                            ),
                          ],
                          if (_status == 'ONGOING') ...[
                            const SizedBox(height: AppSpacing.md),
                            FilledButton.icon(
                              onPressed: _mutating ? null : _finalize,
                              icon: const Icon(Icons.emoji_events_outlined),
                              label: const Text('Chốt kết quả theo thứ tự'),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    if (_error != null)
                      RefereeGlassCard(
                        child: Text(
                          _error!,
                          style: const TextStyle(
                            color: RefereeColors.statusRed,
                          ),
                        ),
                      )
                    else if (_participants.isEmpty)
                      const RefereeGlassCard(
                        child: Text('Chưa có người tham gia cuộc đua.'),
                      )
                    else
                      for (var index = 0; index < _participants.length; index++)
                        _ParticipantCard(
                          participant: _participants[index],
                          position: index + 1,
                          raceOngoing: _status == 'ONGOING',
                          checkedIn: _isCheckedIn(_participants[index]),
                          controller: _controllerFor(_participants[index].id),
                          disabled: _mutating,
                          onCheckIn: () => _checkIn(_participants[index]),
                        ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _ParticipantCard extends StatelessWidget {
  const _ParticipantCard({
    required this.participant,
    required this.position,
    required this.raceOngoing,
    required this.checkedIn,
    required this.controller,
    required this.disabled,
    required this.onCheckIn,
  });

  final RefereeRaceParticipantResponse participant;
  final int position;
  final bool raceOngoing;
  final bool checkedIn;
  final TextEditingController controller;
  final bool disabled;
  final VoidCallback onCheckIn;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: RefereeGlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: RefereeColors.tertiary,
                  child: Text('$position'),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        participant.horseName ?? 'Ngựa #${participant.horseId}',
                        style: AppTypography.bodyMd(Colors.white),
                      ),
                      Text(
                        '${participant.jockeyUsername ?? 'Chưa có jockey'} • '
                        'Ô ${participant.gateNumber ?? '—'}',
                        style: AppTypography.bodySm(
                          RefereeColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (checkedIn)
                  const Icon(
                    Icons.verified,
                    color: RefereeColors.successEmerald,
                  ),
              ],
            ),
            if (!checkedIn && !raceOngoing) ...[
              const SizedBox(height: AppSpacing.md),
              OutlinedButton.icon(
                onPressed: disabled ? null : onCheckIn,
                icon: const Icon(Icons.login),
                label: const Text('Check-in'),
              ),
            ],
            if (raceOngoing && checkedIn) ...[
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Thời gian về đích (milliseconds)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
