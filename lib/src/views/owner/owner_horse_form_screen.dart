import 'package:flutter/material.dart';

import '../../constants/app_spacing.dart';
import '../../constants/app_theme_tokens.dart';
import '../../constants/referee_colors.dart';
import '../../models/owner_horse_item.dart';
import '../../utils/app_toast.dart';
import '../../utils/role_file_picker.dart';
import '../../viewmodels/owner_horse_form_viewmodel.dart';
import '../../widgets/owner/owner_app_bar.dart';
import '../../widgets/owner/owner_dashboard_widgets.dart';
import '../../widgets/referee/referee_glass_card.dart';

class OwnerHorseFormScreen extends StatefulWidget {
  const OwnerHorseFormScreen({super.key, this.initialDetail, this.viewModel});

  final OwnerHorseDetail? initialDetail;
  final OwnerHorseFormViewModel? viewModel;

  @override
  State<OwnerHorseFormScreen> createState() => _OwnerHorseFormScreenState();
}

class _OwnerHorseFormScreenState extends State<OwnerHorseFormScreen> {
  late final OwnerHorseFormViewModel _viewModel;
  late final bool _ownsViewModel;
  late final TextEditingController _nameController;
  late final TextEditingController _breedController;
  late final TextEditingController _ageController;
  late final TextEditingController _colorController;
  late final TextEditingController _heightController;
  late final TextEditingController _weightController;
  PickedUploadFile? _image;
  String? _imageName;
  PickedUploadFile? _document;
  String? _documentName;
  String? _gender;

  @override
  void initState() {
    super.initState();
    final detail = widget.initialDetail;
    _ownsViewModel = widget.viewModel == null;
    _viewModel =
        widget.viewModel ?? OwnerHorseFormViewModel(initialDetail: detail);
    _viewModel.addListener(_onChanged);
    _nameController = TextEditingController(text: detail?.name ?? '');
    _breedController = TextEditingController(text: detail?.breed ?? '');
    _ageController = TextEditingController(text: _formatInt(detail?.age));
    _gender = _normalizeGender(detail?.gender);
    _colorController = TextEditingController(text: detail?.color ?? '');
    _heightController = TextEditingController(
      text: _formatNumber(detail?.heightCm),
    );
    _weightController = TextEditingController(
      text: _formatNumber(detail?.weightKg),
    );
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _pickImage() async {
    try {
      final picked = await RoleFilePicker.pickUpload(
        context: context,
        fieldName: 'image',
        imageOnly: true,
      );
      if (picked == null || !mounted) return;
      setState(() {
        _image = picked;
        _imageName = picked.displayName;
      });
    } catch (error) {
      if (mounted) {
        AppToast.showError(
          context,
          _filePickerError(error, 'Không thể chọn ảnh ngựa.'),
        );
      }
    }
  }

  Future<void> _pickDocument() async {
    try {
      final picked = await RoleFilePicker.pickUpload(
        context: context,
        fieldName: 'document',
        imageOnly: false,
      );
      if (picked == null || !mounted) return;
      setState(() {
        _document = picked;
        _documentName = picked.displayName;
      });
    } catch (error) {
      if (mounted) {
        AppToast.showError(
          context,
          _filePickerError(error, 'Không thể chọn tài liệu.'),
        );
      }
    }
  }

  Future<void> _submit() async {
    final success = await _viewModel.submit(
      name: _nameController.text,
      breed: _breedController.text,
      age: _ageController.text,
      gender: _gender ?? '',
      color: _colorController.text,
      heightCm: _heightController.text,
      weightKg: _weightController.text,
      imagePath: _image?.path,
      imageBytes: _image?.bytes,
      imageName: _image?.displayName,
      documentPath: _document?.path,
      documentBytes: _document?.bytes,
      documentName: _document?.displayName,
    );
    if (!mounted) return;

    if (!success) {
      final message = _viewModel.submitError;
      if (message != null && message.isNotEmpty) {
        AppToast.showError(context, message);
      }
      return;
    }

    AppToast.showSuccess(
      context,
      _viewModel.isEdit ? 'Đã cập nhật ngựa.' : 'Đã gửi ngựa chờ duyệt.',
    );
    Navigator.of(context).pop(true);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onChanged);
    if (_ownsViewModel) _viewModel.dispose();
    _nameController.dispose();
    _breedController.dispose();
    _ageController.dispose();
    _colorController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = _viewModel.isEdit;

    return Scaffold(
      backgroundColor: RefereeColors.background,
      appBar: OwnerAppBar(
        showBack: true,
        titleOverride: isEdit ? 'Cập nhật ngựa' : 'Thêm ngựa mới',
        profileImageUrl: widget.initialDetail?.imageUrl,
      ),
      body: OwnerPortalBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.xl,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: RefereeGlassCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _OwnerHorseTextField(
                      controller: _nameController,
                      label: isEdit ? 'Tên ngựa' : 'Tên ngựa *',
                      textInputAction: TextInputAction.next,
                    ),
                    _OwnerHorseTextField(
                      controller: _breedController,
                      label: 'Giống',
                      textInputAction: TextInputAction.next,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _OwnerHorseTextField(
                            controller: _ageController,
                            label: 'Tuổi',
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _OwnerHorseGenderField(
                            value: _gender,
                            onChanged: (value) {
                              setState(() => _gender = value);
                            },
                          ),
                        ),
                      ],
                    ),
                    _OwnerHorseTextField(
                      controller: _colorController,
                      label: 'Màu lông',
                      textInputAction: TextInputAction.next,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _OwnerHorseTextField(
                            controller: _heightController,
                            label: 'Chiều cao (cm)',
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            textInputAction: TextInputAction.next,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _OwnerHorseTextField(
                            controller: _weightController,
                            label: 'Cân nặng (kg)',
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            textInputAction: TextInputAction.done,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _FilePickTile(
                      icon: Icons.image_outlined,
                      title: 'Ảnh ngựa',
                      value:
                          _imageName ??
                          _existingFileLabel(widget.initialDetail?.imageUrl),
                      onTap: _pickImage,
                    ),
                    const SizedBox(height: 12),
                    _FilePickTile(
                      icon: Icons.description_outlined,
                      title: 'Tài liệu',
                      value:
                          _documentName ??
                          _existingFileLabel(widget.initialDetail?.documentUrl),
                      onTap: _pickDocument,
                    ),
                    const SizedBox(height: 24),
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
                              isEdit ? 'Lưu thay đổi' : 'Tạo ngựa',
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

class _OwnerHorseTextField extends StatelessWidget {
  const _OwnerHorseTextField({
    required this.controller,
    required this.label,
    this.keyboardType,
    this.textInputAction,
  });

  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        style: AppTypography.bodyMd(RefereeColors.onSurface),
        decoration: InputDecoration(
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
        ),
      ),
    );
  }
}

class _OwnerHorseGenderField extends StatelessWidget {
  const _OwnerHorseGenderField({required this.value, required this.onChanged});

  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        onChanged: onChanged,
        dropdownColor: RefereeColors.background,
        style: AppTypography.bodyMd(RefereeColors.onSurface),
        decoration: InputDecoration(
          labelText: 'Giới tính',
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
        ),
        items: const [
          DropdownMenuItem(value: 'Đực', child: Text('Đực')),
          DropdownMenuItem(value: 'Cái', child: Text('Cái')),
        ],
      ),
    );
  }
}

class _FilePickTile extends StatelessWidget {
  const _FilePickTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: RefereeColors.onSurface,
        side: BorderSide(color: Colors.white.withValues(alpha: 0.14)),
        padding: const EdgeInsets.all(14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Row(
        children: [
          Icon(icon, color: RefereeColors.championshipGold),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyMd(RefereeColors.onSurface),
                ),
                if (value != null && value!.isNotEmpty)
                  Text(
                    value!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodySm(RefereeColors.onSurfaceVariant),
                  ),
              ],
            ),
          ),
          const Icon(Icons.upload_file_outlined),
        ],
      ),
    );
  }
}

String _formatInt(int? value) => value == null ? '' : '$value';

String _formatNumber(double? value) {
  if (value == null) return '';
  return value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toString();
}

String? _existingFileLabel(String? url) {
  final value = url?.trim();
  if (value == null || value.isEmpty) return null;
  final slash = value.lastIndexOf('/');
  return slash >= 0 && slash < value.length - 1
      ? value.substring(slash + 1)
      : value;
}

String? _normalizeGender(String? value) {
  final normalized = value?.trim().toLowerCase();
  return switch (normalized) {
    'đực' || 'duc' || 'male' => 'Đực',
    'cái' || 'cai' || 'female' => 'Cái',
    _ => null,
  };
}

String _filePickerError(Object error, String fallback) {
  final message = error.toString().replaceFirst('Bad state: ', '').trim();
  return message.isEmpty ? fallback : message;
}
