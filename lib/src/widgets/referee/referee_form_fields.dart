import 'package:flutter/material.dart';

import '../../constants/app_theme_tokens.dart';
import '../../constants/referee_colors.dart';

class RefereeFormDropdown extends StatelessWidget {
  const RefereeFormDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelCaps(
            RefereeColors.onSurfaceVariant,
          ).copyWith(fontSize: 13, letterSpacing: 0.3),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          key: ValueKey('$label-$value'),
          initialValue: value,
          items: items
              .map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: Text(
                    item,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodyMd(RefereeColors.onSurface),
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
          dropdownColor: RefereeColors.portalSurface,
          decoration: _fieldDecoration(),
          style: AppTypography.bodyMd(RefereeColors.onSurface),
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: RefereeColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class RefereeFormTextField extends StatelessWidget {
  const RefereeFormTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.onChanged,
    this.maxLines = 1,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final ValueChanged<String>? onChanged;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelCaps(
            RefereeColors.onSurfaceVariant,
          ).copyWith(fontSize: 13, letterSpacing: 0.3),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          onChanged: onChanged,
          maxLines: maxLines,
          style: AppTypography.bodyMd(RefereeColors.onSurface),
          decoration: _fieldDecoration(hint: hint),
        ),
      ],
    );
  }
}

InputDecoration _fieldDecoration({String? hint}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: AppTypography.bodyMd(
      RefereeColors.onSurfaceVariant.withValues(alpha: 0.7),
    ),
    filled: true,
    fillColor: Colors.white.withValues(alpha: 0.05),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: RefereeColors.tertiary, width: 1.5),
    ),
  );
}

class RefereeUploadZone extends StatelessWidget {
  const RefereeUploadZone({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bằng chứng (Hình ảnh/Video)',
          style: AppTypography.labelCaps(
            RefereeColors.onSurfaceVariant,
          ).copyWith(fontSize: 13, letterSpacing: 0.3),
        ),
        const SizedBox(height: 8),
        Material(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 2,
                  strokeAlign: BorderSide.strokeAlignInside,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.cloud_upload_outlined,
                    size: 40,
                    color: RefereeColors.onSurfaceVariant,
                  ),
                  const SizedBox(height: 8),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: AppTypography.bodyMd(
                        RefereeColors.onSurfaceVariant,
                      ),
                      children: const [
                        TextSpan(text: 'Kéo thả tệp hoặc '),
                        TextSpan(
                          text: 'chọn từ thiết bị',
                          style: TextStyle(color: RefereeColors.tertiary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Hỗ trợ: MP4, MOV, JPG, PNG (Tối đa 50MB)',
                    textAlign: TextAlign.center,
                    style: AppTypography.labelCaps(
                      RefereeColors.onSurfaceVariant.withValues(alpha: 0.5),
                    ).copyWith(fontSize: 11),
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
