import 'package:flutter/material.dart';

import '../../constants/app_spacing.dart';
import '../../constants/app_theme_tokens.dart';
import '../../constants/referee_colors.dart';
import '../../utils/app_toast.dart';
import '../../viewmodels/owner_jockey_invitation_viewmodels.dart';
import '../../widgets/owner/owner_app_bar.dart';
import '../../widgets/owner/owner_dashboard_widgets.dart';
import '../../widgets/referee/referee_glass_card.dart';

class OwnerCreateJockeyInvitationScreen extends StatefulWidget {
  const OwnerCreateJockeyInvitationScreen({
    super.key,
    this.initialHorseId,
    this.initialHorseName,
    this.initialRaceId,
    this.initialRaceName,
    this.initialTournamentId,
    this.initialTournamentName,
    this.viewModel,
  });

  final String? initialHorseId;
  final String? initialHorseName;
  final String? initialRaceId;
  final String? initialRaceName;
  final String? initialTournamentId;
  final String? initialTournamentName;
  final OwnerCreateJockeyInvitationViewModel? viewModel;

  @override
  State<OwnerCreateJockeyInvitationScreen> createState() =>
      _OwnerCreateJockeyInvitationScreenState();
}

class _OwnerCreateJockeyInvitationScreenState
    extends State<OwnerCreateJockeyInvitationScreen> {
  late final OwnerCreateJockeyInvitationViewModel _viewModel;
  late final bool _ownsViewModel;
  late final TextEditingController _amountController;
  late final TextEditingController _messageController;

  @override
  void initState() {
    super.initState();
    _ownsViewModel = widget.viewModel == null;
    _viewModel =
        widget.viewModel ??
        OwnerCreateJockeyInvitationViewModel(
          initialHorseId: widget.initialHorseId,
          initialHorseName: widget.initialHorseName,
          initialRaceId: widget.initialRaceId,
          initialRaceName: widget.initialRaceName,
          initialTournamentId: widget.initialTournamentId,
          initialTournamentName: widget.initialTournamentName,
        );
    _amountController = TextEditingController();
    _messageController = TextEditingController();
    _viewModel.addListener(_onChanged);
    _viewModel.loadOptions();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _submit() async {
    final success = await _viewModel.submit(
      remunerationText: _amountController.text,
      message: _messageController.text,
    );
    if (!mounted) return;

    if (!success) {
      final message = _viewModel.submitError;
      if (message != null && message.isNotEmpty) {
        AppToast.showError(context, message);
      }
      return;
    }

    AppToast.showSuccess(context, 'Đã tạo lời mời jockey.');
    Navigator.of(context).pop(true);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onChanged);
    if (_ownsViewModel) _viewModel.dispose();
    _amountController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RefereeColors.background,
      appBar: const OwnerAppBar(
        showBack: true,
        titleOverride: 'Mời jockey',
      ),
      body: OwnerPortalBackground(
        child: _viewModel.isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: RefereeColors.championshipGold,
                ),
              )
            : _viewModel.errorMessage != null
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(32),
                children: [
                  const SizedBox(height: 96),
                  _FormStateMessage(
                    message: _viewModel.errorMessage!,
                    icon: Icons.error_outline,
                    actionLabel: 'Thử lại',
                    onAction: _viewModel.loadOptions,
                  ),
                ],
              )
            : SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.contentBottomPadding(context),
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: RefereeGlassCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Tạo lời mời jockey',
                            style: AppTypography.displayMd(
                              RefereeColors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Chọn ngựa, cuộc đua và jockey để gửi lời mời.',
                            style: AppTypography.bodyMd(
                              RefereeColors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _HorseDropdown(viewModel: _viewModel),
                          const SizedBox(height: 14),
                          if (!_viewModel.hasLockedRace) ...[
                            _TournamentDropdown(viewModel: _viewModel),
                            const SizedBox(height: 14),
                          ],
                          _RaceDropdown(viewModel: _viewModel),
                          if (_viewModel.raceErrorMessage != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              _viewModel.raceErrorMessage!,
                              style: AppTypography.bodySm(
                                RefereeColors.statusRed,
                              ),
                            ),
                          ],
                          const SizedBox(height: 14),
                          _JockeyDropdown(viewModel: _viewModel),
                          const SizedBox(height: 14),
                          _OwnerTextField(
                            controller: _amountController,
                            label: 'Thù lao',
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                          ),
                          const SizedBox(height: 14),
                          _OwnerTextField(
                            controller: _messageController,
                            label: 'Lời nhắn',
                            maxLines: 4,
                          ),
                          const SizedBox(height: 22),
                          if (_viewModel.approvedHorses.isEmpty)
                            const _InlineNotice(
                              text: 'Bạn cần ngựa đã duyệt để mời jockey.',
                            ),
                          if (_viewModel.availableJockeys.isEmpty)
                            const _InlineNotice(
                              text: 'Chưa có jockey khả dụng.',
                            ),
                          if (_viewModel.raceOptions.isEmpty &&
                              _viewModel.hasLockedRace == false)
                            const _InlineNotice(
                              text: 'Chọn giải đấu để tải cuộc đua phù hợp.',
                            ),
                          FilledButton(
                            onPressed: _viewModel.isSubmitting ? null : _submit,
                            style: FilledButton.styleFrom(
                              backgroundColor: RefereeColors.championshipGold,
                              foregroundColor: RefereeColors.background,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: _viewModel.isSubmitting
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: RefereeColors.background,
                                    ),
                                  )
                                : Text(
                                    'Gửi lời mời',
                                    style: AppTypography.labelCaps(
                                      RefereeColors.background,
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

class _HorseDropdown extends StatelessWidget {
  const _HorseDropdown({required this.viewModel});

  final OwnerCreateJockeyInvitationViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return _OwnerDropdown<String>(
      label: 'Ngựa đã duyệt',
      value: viewModel.selectedHorseId,
      items: [
        for (final horse in viewModel.approvedHorses)
          DropdownMenuItem(value: horse.id, child: Text(horse.name)),
      ],
      onChanged: viewModel.selectHorse,
    );
  }
}

class _TournamentDropdown extends StatelessWidget {
  const _TournamentDropdown({required this.viewModel});

  final OwnerCreateJockeyInvitationViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return _OwnerDropdown<String>(
      label: 'Giải đấu',
      value: viewModel.selectedTournamentId,
      items: [
        for (final tournament in viewModel.tournaments)
          DropdownMenuItem(value: tournament.id, child: Text(tournament.title)),
      ],
      onChanged: viewModel.isLoadingRaces ? null : viewModel.selectTournament,
    );
  }
}

class _RaceDropdown extends StatelessWidget {
  const _RaceDropdown({required this.viewModel});

  final OwnerCreateJockeyInvitationViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.centerRight,
      children: [
        _OwnerDropdown<String>(
          label: 'Cuộc đua',
          value: viewModel.selectedRaceId,
          items: [
            for (final race in viewModel.raceOptions)
              DropdownMenuItem(value: race.id, child: Text(race.label)),
          ],
          onChanged: viewModel.hasLockedRace || viewModel.isLoadingRaces
              ? null
              : viewModel.selectRace,
        ),
        if (viewModel.isLoadingRaces)
          const Padding(
            padding: EdgeInsets.only(right: 14),
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
      ],
    );
  }
}

class _JockeyDropdown extends StatelessWidget {
  const _JockeyDropdown({required this.viewModel});

  final OwnerCreateJockeyInvitationViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return _OwnerDropdown<String>(
      label: 'Jockey',
      value: viewModel.selectedJockeyId,
      items: [
        for (final jockey in viewModel.availableJockeys)
          DropdownMenuItem(value: '${jockey.id}', child: Text(jockey.displayName)),
      ],
      onChanged: viewModel.selectJockey,
    );
  }
}

class _OwnerDropdown<T> extends StatelessWidget {
  const _OwnerDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;

  @override
  Widget build(BuildContext context) {
    final selectedExists = items.any((item) => item.value == value);
    return DropdownButtonFormField<T>(
      value: selectedExists ? value : null,
      items: items,
      onChanged: onChanged,
      dropdownColor: RefereeColors.portalSurface,
      style: AppTypography.bodyMd(RefereeColors.onSurface),
      decoration: _inputDecoration(label),
    );
  }
}

class _OwnerTextField extends StatelessWidget {
  const _OwnerTextField({
    required this.controller,
    required this.label,
    this.keyboardType,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: AppTypography.bodyMd(RefereeColors.onSurface),
      decoration: _inputDecoration(label),
    );
  }
}

class _InlineNotice extends StatelessWidget {
  const _InlineNotice({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: AppTypography.bodySm(RefereeColors.onSurfaceVariant),
      ),
    );
  }
}

class _FormStateMessage extends StatelessWidget {
  const _FormStateMessage({
    required this.message,
    required this.icon,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return RefereeGlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(icon, size: 40, color: RefereeColors.onSurfaceVariant),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTypography.bodyMd(RefereeColors.onSurfaceVariant),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 12),
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}

InputDecoration _inputDecoration(String label) {
  return InputDecoration(
    labelText: label,
    labelStyle: AppTypography.bodySm(RefereeColors.onSurfaceVariant),
    filled: true,
    fillColor: Colors.white.withValues(alpha: 0.05),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
    ),
    focusedBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: RefereeColors.championshipGold),
    ),
  );
}
