import 'package:flutter/material.dart';

import '../../constants/app_spacing.dart';
import '../../constants/app_theme_tokens.dart';
import '../../constants/referee_colors.dart';
import '../../models/jockey_profile_response.dart';
import '../../utils/jockey_profile_update_validation.dart';
import '../../utils/role_file_picker.dart';
import '../../viewmodels/jockey_profile_edit_viewmodel.dart';
import '../../widgets/jockey/jockey_app_bar.dart';
import '../../widgets/jockey/jockey_dashboard_widgets.dart';
import '../../widgets/referee/referee_glass_card.dart';

class JockeyProfileEditScreen extends StatefulWidget {
  const JockeyProfileEditScreen({
    super.key,
    required this.profile,
    this.viewModel,
  });

  final JockeyProfileResponse profile;
  final JockeyProfileEditViewModel? viewModel;

  @override
  State<JockeyProfileEditScreen> createState() =>
      _JockeyProfileEditScreenState();
}

class _JockeyProfileEditScreenState extends State<JockeyProfileEditScreen> {
  late final JockeyProfileEditViewModel _viewModel;
  late final bool _ownsViewModel;
  late final Map<String, TextEditingController> _controllers;
  final Map<String, PickedRoleFile> _files = {};
  String? _validationError;

  @override
  void initState() {
    super.initState();
    _ownsViewModel = widget.viewModel == null;
    _viewModel =
        widget.viewModel ??
        JockeyProfileEditViewModel(initialProfile: widget.profile);
    _viewModel.addListener(_onViewModelChanged);
    _controllers = {
      for (final entry in _viewModel.initialValues.entries)
        entry.key: TextEditingController(text: entry.value),
    };
    for (final controller in _controllers.values) {
      controller.addListener(_onFormChanged);
    }
  }

  void _onViewModelChanged() {
    if (mounted) setState(() {});
  }

  void _onFormChanged() {
    if (!mounted) return;
    _viewModel.clearSubmitError();
    setState(() => _validationError = null);
  }

  JockeyProfileEditInput get _input => JockeyProfileEditInput.fromFields({
    for (final entry in _controllers.entries) entry.key: entry.value.text,
  });

  JockeyProfileFilePaths get _filePaths => JockeyProfileFilePaths(
    avatar: _files['avatar']?.file.path,
    achievements: _files['achievements']?.file.path,
    licenseDocument: _files['licenseDocument']?.file.path,
  );

  Future<void> _pickFile(String fieldName, {required bool imageOnly}) async {
    try {
      final picked = await RoleFilePicker.pick(
        context: context,
        fieldName: fieldName,
        imageOnly: imageOnly,
      );
      if (picked == null || !mounted) return;

      final error = JockeyProfileUpdateValidation.validateFile(
        fieldName,
        picked.sizeBytes,
        picked.extension,
      );
      if (error != null) {
        setState(() => _validationError = error);
        return;
      }

      setState(() {
        _files[fieldName] = picked;
        _validationError = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _validationError = 'Khong the mo trinh chon file.');
    }
  }

  Future<void> _submit() async {
    final error = _viewModel.validate(_input);
    if (error != null) {
      setState(() => _validationError = error);
      return;
    }

    final updated = await _viewModel.submit(
      input: _input,
      filePaths: _filePaths,
    );
    if (!mounted || updated == null) return;
    Navigator.of(context).pop(updated);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    if (_ownsViewModel) _viewModel.dispose();
    for (final controller in _controllers.values) {
      controller
        ..removeListener(_onFormChanged)
        ..dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit =
        !_viewModel.isSubmitting &&
        _viewModel.isDirty(input: _input, filePaths: _filePaths);
    final error = _validationError ?? _viewModel.submitError;

    return Scaffold(
      backgroundColor: RefereeColors.background,
      appBar: JockeyAppBar(
        showBack: true,
        showBrandTitle: false,
        profileImageUrl: widget.profile.avatarUrl,
        showNotificationAction: false,
      ),
      body: JockeySpeedlineBackground(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.xl,
          ),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 860),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Chinh sua ho so',
                      style: AppTypography.displayLg(
                        RefereeColors.onSurface,
                      ).copyWith(fontSize: 28),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    RefereeGlassCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          _EditField(
                            label: 'License number',
                            controller: _controllers['licenseNumber']!,
                            maxLength: 100,
                          ),
                          _EditField(
                            label: 'So nam kinh nghiem',
                            controller: _controllers['experienceYears']!,
                            keyboardType: TextInputType.number,
                          ),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              if (constraints.maxWidth >= 560) {
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: _EditField(
                                        label: 'Chieu cao (cm)',
                                        controller: _controllers['heightCm']!,
                                        keyboardType:
                                            const TextInputType.numberWithOptions(
                                              decimal: true,
                                            ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _EditField(
                                        label: 'Can nang (kg)',
                                        controller: _controllers['weightKg']!,
                                        keyboardType:
                                            const TextInputType.numberWithOptions(
                                              decimal: true,
                                            ),
                                      ),
                                    ),
                                  ],
                                );
                              }
                              return Column(
                                children: [
                                  _EditField(
                                    label: 'Chieu cao (cm)',
                                    controller: _controllers['heightCm']!,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                  ),
                                  _EditField(
                                    label: 'Can nang (kg)',
                                    controller: _controllers['weightKg']!,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                  ),
                                ],
                              );
                            },
                          ),
                          _EditField(
                            label: 'Bio',
                            controller: _controllers['bio']!,
                            maxLength: 1000,
                            maxLines: 4,
                          ),
                          _EditField(
                            label: 'Giai thuong',
                            controller: _controllers['awards']!,
                            maxLength: 2000,
                            maxLines: 4,
                          ),
                          _EditField(
                            label: 'Chuyen mon',
                            controller: _controllers['specialties']!,
                            maxLength: 1000,
                            maxLines: 3,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    RefereeGlassCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Tep dinh kem',
                            style: AppTypography.headlineSm(
                              RefereeColors.onSurface,
                            ).copyWith(fontSize: 20),
                          ),
                          const SizedBox(height: 16),
                          _FileField(
                            label: 'Avatar',
                            currentValue: widget.profile.avatarUrl,
                            picked: _files['avatar'],
                            hint: 'JPG, PNG, WEBP - toi da 5MB',
                            onPick: () => _pickFile('avatar', imageOnly: true),
                            onRemove: () =>
                                setState(() => _files.remove('avatar')),
                          ),
                          _FileField(
                            label: 'Achievements',
                            currentValue: widget.profile.achievements,
                            picked: _files['achievements'],
                            hint: 'JPG, PNG, WEBP - toi da 5MB',
                            onPick: () =>
                                _pickFile('achievements', imageOnly: true),
                            onRemove: () =>
                                setState(() => _files.remove('achievements')),
                          ),
                          _FileField(
                            label: 'License document',
                            currentValue: widget.profile.licenseDocumentUrl,
                            picked: _files['licenseDocument'],
                            hint: 'PDF hoac anh - toi da 10MB',
                            onPick: () =>
                                _pickFile('licenseDocument', imageOnly: false),
                            onRemove: () => setState(
                              () => _files.remove('licenseDocument'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (error != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        error,
                        textAlign: TextAlign.center,
                        style: AppTypography.bodyMd(RefereeColors.statusRed),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    FilledButton.icon(
                      onPressed: canSubmit ? _submit : null,
                      icon: _viewModel.isSubmitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.save_outlined),
                      label: Text(
                        _viewModel.isSubmitting
                            ? 'Dang luu...'
                            : 'Luu thay doi',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditField extends StatelessWidget {
  const _EditField({
    required this.label,
    required this.controller,
    this.keyboardType,
    this.maxLength,
    this.maxLines = 1,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final int? maxLength;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLength: maxLength,
        maxLines: maxLines,
        style: AppTypography.bodyMd(RefereeColors.onSurface),
        decoration: InputDecoration(
          labelText: label,
          counterText: '',
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}

class _FileField extends StatelessWidget {
  const _FileField({
    required this.label,
    required this.currentValue,
    required this.picked,
    required this.hint,
    required this.onPick,
    required this.onRemove,
  });

  final String label;
  final String? currentValue;
  final PickedRoleFile? picked;
  final String hint;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final hasCurrent = currentValue?.trim().isNotEmpty == true;
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            label,
            style: AppTypography.labelCaps(RefereeColors.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  picked?.displayName ??
                      (hasCurrent ? 'Da co file tren he thong' : hint),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySm(
                    picked != null || hasCurrent
                        ? RefereeColors.onSurface
                        : RefereeColors.onSurfaceVariant,
                  ),
                ),
              ),
              IconButton(
                onPressed: onPick,
                tooltip: picked == null ? 'Chon file' : 'Thay file',
                icon: const Icon(Icons.attach_file),
              ),
              if (picked != null)
                IconButton(
                  onPressed: onRemove,
                  tooltip: 'Bo file da chon',
                  icon: const Icon(Icons.close),
                ),
            ],
          ),
          Text(
            hint,
            style: AppTypography.bodySm(RefereeColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
