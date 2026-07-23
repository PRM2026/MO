import 'package:flutter/material.dart';

import '../../constants/app_theme_tokens.dart';
import '../../constants/referee_colors.dart';
import '../../utils/password_strength.dart';

class RefereePasswordField extends StatefulWidget {
  const RefereePasswordField({
    super.key,
    required this.label,
    required this.controller,
    this.onChanged,
    this.textInputAction,
  });

  final String label;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final TextInputAction? textInputAction;

  @override
  State<RefereePasswordField> createState() => _RefereePasswordFieldState();
}

class _RefereePasswordFieldState extends State<RefereePasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label.toUpperCase(),
          style: AppTypography.labelCaps(
            RefereeColors.onSurfaceVariant,
          ).copyWith(fontSize: 13, letterSpacing: 0.8),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: widget.controller,
          onChanged: widget.onChanged,
          obscureText: _obscure,
          textInputAction: widget.textInputAction,
          style: AppTypography.bodyMd(RefereeColors.onSurface),
          decoration: InputDecoration(
            hintText: '••••••••',
            hintStyle: AppTypography.bodyMd(
              RefereeColors.onSurfaceVariant.withValues(alpha: 0.3),
            ),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.05),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: RefereeColors.tertiary,
                width: 1.5,
              ),
            ),
            suffixIcon: IconButton(
              onPressed: () => setState(() => _obscure = !_obscure),
              icon: Icon(
                _obscure
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: RefereeColors.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class PasswordStrengthIndicator extends StatelessWidget {
  const PasswordStrengthIndicator({super.key, required this.strength});

  final PasswordStrength strength;

  @override
  Widget build(BuildContext context) {
    final score = switch (strength) {
      PasswordStrength.weak => 1,
      PasswordStrength.medium => 2,
      PasswordStrength.strong => 3,
    };
    final color = PasswordStrengthUtils.color(strength);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(3, (index) {
            final isActive = index < score;
            return Expanded(
              child: Container(
                height: 6,
                margin: EdgeInsets.only(right: index < 2 ? 4 : 0),
                decoration: BoxDecoration(
                  color: isActive ? color : Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        RichText(
          text: TextSpan(
            style: AppTypography.labelCaps(
              RefereeColors.onSurfaceVariant,
            ).copyWith(fontWeight: FontWeight.w500),
            children: [
              const TextSpan(text: 'Độ mạnh mật khẩu: '),
              TextSpan(
                text: PasswordStrengthUtils.label(strength),
                style: TextStyle(color: color),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class PasswordSecurityRequirements extends StatelessWidget {
  const PasswordSecurityRequirements({super.key});

  static const _requirements = [
    'Tối thiểu 8 ký tự',
    'Bao gồm chữ hoa (A-Z) và chữ thường (a-z)',
    'Bao gồm chữ số (0-9)',
  ];

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0x4D071426),
        borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
        border: Border(
          left: BorderSide(color: RefereeColors.tertiary, width: 4),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'YÊU CẦU BẢO MẬT:',
              style: AppTypography.labelCaps(
                RefereeColors.tertiary,
              ).copyWith(letterSpacing: 0.6),
            ),
            const SizedBox(height: 8),
            for (final requirement in _requirements)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      size: 16,
                      color: RefereeColors.successEmerald,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        requirement,
                        style: AppTypography.labelCaps(
                          RefereeColors.onSurfaceVariant,
                        ).copyWith(fontWeight: FontWeight.w400),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class RefereeChangePasswordGlowBackground extends StatelessWidget {
  const RefereeChangePasswordGlowBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -120,
          right: -120,
          child: Container(
            width: 500,
            height: 500,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: RefereeColors.tertiary.withValues(alpha: 0.1),
            ),
          ),
        ),
        Positioned(
          bottom: -120,
          left: -120,
          child: Container(
            width: 500,
            height: 500,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: RefereeColors.secondaryContainer.withValues(alpha: 0.2),
            ),
          ),
        ),
        child,
      ],
    );
  }
}
