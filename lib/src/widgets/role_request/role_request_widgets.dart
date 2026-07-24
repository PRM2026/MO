import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_theme_tokens.dart';
import '../../constants/referee_colors.dart';
import '../../models/role_application_field.dart';
import '../../models/role_request_data.dart';
import '../../utils/platform_utils.dart';
import '../../utils/role_application_validation.dart';
import '../../utils/role_file_picker.dart';

class RoleSelectorGrid extends StatelessWidget {
  const RoleSelectorGrid({super.key, required this.onRoleTap});

  final ValueChanged<SystemRoleType> onRoleTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 960
            ? 4
            : constraints.maxWidth >= 640
            ? 2
            : 1;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            mainAxisExtent: crossAxisCount == 1 ? 172 : 184,
          ),
          itemCount: SystemRoleType.values.length,
          itemBuilder: (context, index) {
            final role = SystemRoleType.values[index];
            return _RoleOptionCard(role: role, onTap: () => onRoleTap(role));
          },
        );
      },
    );
  }
}

class _RoleOptionCard extends StatelessWidget {
  const _RoleOptionCard({required this.role, required this.onTap});

  final SystemRoleType role;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.outlineVariant),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      role.icon,
                      size: 22,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    role.label,
                    style: AppTypography.labelCaps(
                      AppColors.onSurface,
                    ).copyWith(fontSize: 14, letterSpacing: 0.2),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    role.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.labelCaps(
                      AppColors.onSurfaceVariant,
                    ).copyWith(fontWeight: FontWeight.w400, fontSize: 11),
                  ),
                ],
              ),
              Text(
                'Gửi yêu cầu cấp quyền →',
                style: AppTypography.labelCaps(
                  AppColors.primary,
                ).copyWith(fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

typedef RoleApplicationSubmit =
    Future<String?> Function(
      Map<String, String> values,
      Map<String, File> files,
    );

class RoleRequestModalSheet extends StatefulWidget {
  const RoleRequestModalSheet({
    super.key,
    required this.role,
    required this.fullName,
    required this.onSubmit,
    this.isSubmitting = false,
  });

  final SystemRoleType role;
  final String fullName;
  final RoleApplicationSubmit onSubmit;
  final bool isSubmitting;

  @override
  State<RoleRequestModalSheet> createState() => _RoleRequestModalSheetState();
}

class _RoleRequestModalSheetState extends State<RoleRequestModalSheet> {
  late final List<RoleApplicationField> _fields;
  late final Map<String, TextEditingController> _controllers;
  final Map<String, File> _files = {};
  final Map<String, String> _fileNames = {};
  String? _errorMessage;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _fields = widget.role.applicationFields;
    _controllers = {
      for (final field in _fields.where((f) => f.type != RoleFieldType.file))
        field.name: TextEditingController(
          text: field.name == 'displayName' ? widget.fullName : '',
        ),
    };
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Map<String, String> _collectValues() {
    return {
      for (final entry in _controllers.entries) entry.key: entry.value.text,
    };
  }

  Future<void> _pickFile(RoleApplicationField field) async {
    final isImage = field.name == 'avatar' || field.name == 'achievements';

    try {
      final picked = await RoleFilePicker.pick(
        context: context,
        fieldName: field.name,
        imageOnly: isImage,
      );
      if (picked == null) return;

      final fileError = RoleApplicationValidation.validateFile(
        field.name,
        picked.sizeBytes,
        picked.extension,
      );
      if (fileError != null) {
        setState(() => _errorMessage = fileError);
        return;
      }

      setState(() {
        _files[field.name] = picked.file;
        _fileNames[field.name] = picked.displayName;
        _errorMessage = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(
        () => _errorMessage =
            'Không thể mở trình chọn ảnh/tệp. Vui lòng thử lại.',
      );
    }
  }

  Future<void> _handleSubmit() async {
    final values = _collectValues();
    final validationError = RoleApplicationValidation.validateFields(
      _fields,
      values,
      _fileNames,
    );
    if (validationError != null) {
      setState(() => _errorMessage = validationError);
      return;
    }

    setState(() {
      _submitting = true;
      _errorMessage = null;
    });

    final error = await widget.onSubmit(values, Map.unmodifiable(_files));
    if (!mounted) return;

    if (error == null) {
      Navigator.of(context).pop(true);
      return;
    }

    setState(() {
      _submitting = false;
      _errorMessage = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final isBusy = _submitting || widget.isSubmitting;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: DraggableScrollableSheet(
        initialChildSize: 0.88,
        minChildSize: 0.45,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Material(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 12, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hồ sơ xin cấp quyền: ${widget.role.label}',
                              style: AppTypography.headlineSm(
                                AppColors.onSurface,
                              ),
                            ),
                            if (widget.fullName.isNotEmpty)
                              Text(
                                'Người đăng ký: ${widget.fullName}',
                                style: AppTypography.bodySm(
                                  AppColors.onSurfaceVariant,
                                ),
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: isBusy ? null : () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 24, color: AppColors.outlineVariant),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    children: [
                      for (final field in _fields) ...[
                        _RoleApplicationFieldWidget(
                          field: field,
                          controller: _controllers[field.name],
                          fileName: _fileNames[field.name],
                          onPickFile: () => _pickFile(field),
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (_errorMessage != null) ...[
                        Text(
                          _errorMessage!,
                          style: AppTypography.bodySm(RefereeColors.statusRed),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ],
                  ),
                ),
                const Divider(height: 1, color: AppColors.outlineVariant),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final stacked = constraints.maxWidth < 420;
                      final cancel = TextButton(
                        onPressed: isBusy ? null : () => Navigator.pop(context),
                        child: const Text('Hủy'),
                      );
                      final submit = FilledButton(
                        onPressed: isBusy ? null : _handleSubmit,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isBusy
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Gửi hồ sơ'),
                      );

                      if (stacked) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [submit, cancel],
                        );
                      }

                      return Row(
                        children: [
                          Expanded(child: cancel),
                          const SizedBox(width: 12),
                          Expanded(flex: 2, child: submit),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _RoleApplicationFieldWidget extends StatelessWidget {
  const _RoleApplicationFieldWidget({
    required this.field,
    required this.controller,
    required this.fileName,
    required this.onPickFile,
  });

  final RoleApplicationField field;
  final TextEditingController? controller;
  final String? fileName;
  final VoidCallback onPickFile;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text.rich(
            TextSpan(
              text: field.label,
              style: AppTypography.labelCaps(
                AppColors.onSurfaceVariant,
              ).copyWith(fontWeight: FontWeight.w500),
              children: [
                if (field.required)
                  const TextSpan(
                    text: ' *',
                    style: TextStyle(color: RefereeColors.statusRed),
                  ),
              ],
            ),
          ),
        ),
        if (field.type == RoleFieldType.file)
          _UploadField(
            label:
                fileName ??
                (supportsLocalComputerFilePicker
                    ? 'Chọn file từ máy tính...'
                    : 'Chọn file để tải lên...'),
            hint: fileName != null
                ? 'Nhấn để đổi file khác'
                : RoleApplicationValidation.fileHint(field.name),
            hasFile: fileName != null,
            onTap: onPickFile,
          )
        else
          TextField(
            controller: controller,
            maxLines: field.type == RoleFieldType.textarea ? 3 : 1,
            maxLength: field.maxLength,
            keyboardType: switch (field.type) {
              RoleFieldType.number => const TextInputType.numberWithOptions(
                decimal: true,
              ),
              RoleFieldType.tel => TextInputType.phone,
              _ => TextInputType.text,
            },
            inputFormatters: switch (field.type) {
              RoleFieldType.number => [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              RoleFieldType.tel => [
                TextInputFormatter.withFunction((oldValue, newValue) {
                  final sanitized = RoleApplicationValidation.sanitizePhone(
                    newValue.text,
                  );
                  return TextEditingValue(
                    text: sanitized,
                    selection: TextSelection.collapsed(
                      offset: sanitized.length,
                    ),
                  );
                }),
              ],
              _ => null,
            },
            style: AppTypography.bodyMd(AppColors.onSurface),
            decoration: InputDecoration(
              hintText: field.placeholder,
              hintStyle: AppTypography.bodyMd(
                AppColors.onSurfaceVariant.withValues(alpha: 0.7),
              ),
              filled: true,
              fillColor: AppColors.surfaceContainer,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.outlineVariant),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.outlineVariant),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.5,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _UploadField extends StatelessWidget {
  const _UploadField({
    required this.label,
    required this.hint,
    required this.onTap,
    this.hasFile = false,
  });

  final String label;
  final String hint;
  final VoidCallback onTap;
  final bool hasFile;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: hasFile
                ? RefereeColors.successEmerald.withValues(alpha: 0.08)
                : AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasFile
                  ? RefereeColors.successEmerald.withValues(alpha: 0.45)
                  : AppColors.primary.withValues(alpha: 0.25),
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Icon(
                hasFile
                    ? Icons.check_circle_outline
                    : Icons.cloud_upload_outlined,
                size: 36,
                color: hasFile
                    ? RefereeColors.successEmerald
                    : AppColors.primary,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.labelCaps(
                  hasFile ? RefereeColors.successEmerald : AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                hasFile ? 'Nhấn để đổi file khác' : hint,
                textAlign: TextAlign.center,
                style: AppTypography.labelCaps(
                  AppColors.onSurfaceVariant,
                ).copyWith(fontWeight: FontWeight.w400, fontSize: 11),
              ),
              if (!hasFile && supportsLocalComputerFilePicker) ...[
                const SizedBox(height: 6),
                Text(
                  'VD: D:\\Downloads\\giay-to.jpg',
                  textAlign: TextAlign.center,
                  style: AppTypography.labelCaps(
                    AppColors.onSurfaceVariant.withValues(alpha: 0.75),
                  ).copyWith(fontWeight: FontWeight.w400, fontSize: 10),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class RoleRequestHistorySection extends StatelessWidget {
  const RoleRequestHistorySection({super.key, required this.history});

  final List<RoleApplicationHistoryItem> history;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Lịch sử yêu cầu',
          style: AppTypography.headlineSm(
            AppColors.onSurface,
          ).copyWith(fontSize: 22),
        ),
        const SizedBox(height: 16),
        _RoleLightCard(
          padding: history.isEmpty ? const EdgeInsets.all(24) : EdgeInsets.zero,
          child: history.isEmpty
              ? Column(
                  children: [
                    Icon(
                      Icons.history_outlined,
                      size: 40,
                      color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Chưa có yêu cầu vai trò nào',
                      style: AppTypography.bodyMd(AppColors.onSurface),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Gửi hồ sơ xin cấp quyền để theo dõi trạng thái tại đây.',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodySm(AppColors.onSurfaceVariant),
                    ),
                  ],
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 768) {
                      return Column(
                        children: [
                          for (var i = 0; i < history.length; i++) ...[
                            _HistoryMobileTile(item: history[i]),
                            if (i < history.length - 1)
                              const Divider(
                                height: 1,
                                color: AppColors.outlineVariant,
                              ),
                          ],
                        ],
                      );
                    }

                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: constraints.maxWidth,
                        ),
                        child: DataTable(
                          headingRowColor: WidgetStateProperty.all(
                            AppColors.surfaceContainer,
                          ),
                          columnSpacing: 24,
                          horizontalMargin: 24,
                          headingTextStyle: AppTypography.labelCaps(
                            AppColors.onSurfaceVariant,
                          ).copyWith(fontSize: 12),
                          columns: const [
                            DataColumn(label: Text('Vai trò')),
                            DataColumn(label: Text('Ngày gửi')),
                            DataColumn(label: Text('Trạng thái')),
                            DataColumn(label: Text('Ghi chú Admin')),
                          ],
                          rows: history.map((item) {
                            return DataRow(
                              cells: [
                                DataCell(
                                  Row(
                                    children: [
                                      Container(
                                        width: 32,
                                        height: 32,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withValues(
                                            alpha: 0.12,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Icon(
                                          item.role.icon,
                                          size: 18,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(item.role.label),
                                    ],
                                  ),
                                ),
                                DataCell(Text(item.submittedDate)),
                                DataCell(_StatusBadge(item: item)),
                                DataCell(Text(item.adminNote)),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _HistoryMobileTile extends StatelessWidget {
  const _HistoryMobileTile({required this.item});

  final RoleApplicationHistoryItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(item.role.icon, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      item.role.label,
                      style: AppTypography.labelCaps(AppColors.onSurface),
                    ),
                  ],
                ),
              ),
              _StatusBadge(item: item),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Ngày gửi: ${item.submittedDate}',
            style: AppTypography.bodySm(AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 4),
          Text(
            item.adminNote,
            style: AppTypography.bodySm(AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.item});

  final RoleApplicationHistoryItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: item.statusColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: item.statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            item.statusLabel,
            style: AppTypography.labelCaps(
              item.statusColor,
            ).copyWith(fontSize: 11, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _RoleLightCard extends StatelessWidget {
  const _RoleLightCard({
    required this.child,
    this.padding = const EdgeInsets.all(24),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
