import 'package:flutter/material.dart';

import '../../constants/app_spacing.dart';
import '../../constants/referee_colors.dart';
import '../news/news_network_image.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.size,
    this.imageUrl,
    this.fallbackIcon = Icons.person_rounded,
    this.showOnlineIndicator = false,
    this.isOnline = false,
    this.ringWidth = 2,
  });

  final double size;
  final String? imageUrl;
  final IconData fallbackIcon;
  final bool showOnlineIndicator;
  final bool isOnline;
  final double ringWidth;

  bool get _hasImage => imageUrl != null && imageUrl!.trim().isNotEmpty;

  bool get _isHero => size >= 72;

  @override
  Widget build(BuildContext context) {
    final indicatorSize = (size * 0.2).clamp(12.0, 22.0);
    final effectiveRing = _isHero ? 3.0 : ringWidth;

    final core = SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (_isHero)
            Container(
              width: size * 1.08,
              height: size * 1.08,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: RefereeColors.championshipGold.withValues(alpha: 0.22),
                    blurRadius: size * 0.28,
                    spreadRadius: size * 0.02,
                  ),
                  BoxShadow(
                    color: RefereeColors.tertiary.withValues(alpha: 0.12),
                    blurRadius: size * 0.4,
                  ),
                ],
              ),
            ),
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  RefereeColors.championshipGold.withValues(
                    alpha: _isHero ? 0.95 : 1,
                  ),
                  RefereeColors.tertiary.withValues(alpha: _isHero ? 0.75 : 1),
                  RefereeColors.championshipGold.withValues(alpha: 0.88),
                ],
                stops: const [0.0, 0.55, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: _isHero ? 18 : 8,
                  offset: Offset(0, _isHero ? 8 : 3),
                ),
              ],
            ),
            padding: EdgeInsets.all(effectiveRing),
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: RefereeColors.portalSurface,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08),
                  width: 1,
                ),
              ),
              child: ClipOval(
                child: _hasImage ? _buildPhotoFace() : _buildFallbackFace(),
              ),
            ),
          ),
        ],
      ),
    );

    if (!showOnlineIndicator || !isOnline) return core;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        core,
        Positioned(
          right: effectiveRing,
          bottom: effectiveRing,
          child: Container(
            width: indicatorSize,
            height: indicatorSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: RefereeColors.successEmerald,
              border: Border.all(
                color: RefereeColors.portalSurface,
                width: 2.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: RefereeColors.successEmerald.withValues(alpha: 0.55),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoFace() {
    return Stack(
      fit: StackFit.expand,
      children: [
        NewsNetworkImage(imageUrl: imageUrl!),
        if (_isHero) ...[
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: 0.1),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.28),
                ],
                stops: const [0.0, 0.45, 1.0],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: FractionallySizedBox(
              widthFactor: 0.55,
              heightFactor: 0.45,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.topLeft,
                    radius: 1.1,
                    colors: [
                      Colors.white.withValues(alpha: 0.14),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFallbackFace() {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(-0.2, -0.35),
          radius: 1.1,
          colors: [
            RefereeColors.tertiary.withValues(alpha: 0.28),
            RefereeColors.secondaryContainer,
            RefereeColors.portalSurface,
          ],
          stops: const [0.0, 0.55, 1.0],
        ),
      ),
      child: Center(
        child: Icon(
          fallbackIcon,
          size: size * 0.38,
          color: RefereeColors.championshipGold.withValues(alpha: 0.92),
        ),
      ),
    );
  }
}

class ProfileAvatarButton extends StatefulWidget {
  const ProfileAvatarButton({
    super.key,
    this.imageUrl,
    this.onTap,
    this.size = 40,
    this.fallbackIcon = Icons.person_rounded,
    this.padding,
    this.interactive = true,
  });

  final String? imageUrl;
  final VoidCallback? onTap;
  final double size;
  final IconData fallbackIcon;
  final EdgeInsetsGeometry? padding;
  final bool interactive;

  @override
  State<ProfileAvatarButton> createState() => _ProfileAvatarButtonState();
}

class _ProfileAvatarButtonState extends State<ProfileAvatarButton> {
  bool _pressed = false;

  bool get _canTap => widget.interactive && widget.onTap != null;

  void _setPressed(bool value) {
    if (!_canTap || _pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final avatar = AnimatedScale(
      scale: _pressed ? 0.92 : 1,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: ProfileAvatar(
        size: widget.size,
        imageUrl: widget.imageUrl,
        fallbackIcon: widget.fallbackIcon,
        ringWidth: 2,
      ),
    );

    return Padding(
      padding: widget.padding ?? const EdgeInsets.only(right: AppSpacing.lg),
      child: _canTap
          ? Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                onHighlightChanged: _setPressed,
                customBorder: const CircleBorder(),
                splashColor: RefereeColors.tertiary.withValues(alpha: 0.18),
                highlightColor: RefereeColors.tertiary.withValues(alpha: 0.08),
                child: avatar,
              ),
            )
          : Opacity(
              opacity: widget.interactive ? 1 : 0.92,
              child: avatar,
            ),
    );
  }
}
