import 'dart:math';

import 'package:flutter/material.dart';

import '../../constants/referee_colors.dart';

class RefereeAmbientBackground extends StatefulWidget {
  const RefereeAmbientBackground({super.key, required this.child});

  final Widget child;

  @override
  State<RefereeAmbientBackground> createState() =>
      _RefereeAmbientBackgroundState();
}

class _RefereeAmbientBackgroundState extends State<RefereeAmbientBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
    _particles = _createParticles(50);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<_Particle> _createParticles(int count) {
    final random = Random(7);
    return List.generate(count, (_) {
      return _Particle(
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: random.nextDouble() * 2 + 0.5,
        speedX: (random.nextDouble() - 0.5) * 0.0004,
        speedY: (random.nextDouble() - 0.5) * 0.0004,
        color: random.nextDouble() > 0.8
            ? RefereeColors.tertiary
            : RefereeColors.secondary,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return CustomPaint(
                painter: _AmbientParticlePainter(
                  particles: _particles,
                  tick: _controller.value,
                ),
              );
            },
          ),
        ),
        widget.child,
      ],
    );
  }
}

class _Particle {
  _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speedX,
    required this.speedY,
    required this.color,
  });

  double x;
  double y;
  final double size;
  final double speedX;
  final double speedY;
  final Color color;
}

class _AmbientParticlePainter extends CustomPainter {
  _AmbientParticlePainter({
    required this.particles,
    required this.tick,
  });

  final List<_Particle> particles;
  final double tick;

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      particle.x = (particle.x + particle.speedX) % 1.0;
      particle.y = (particle.y + particle.speedY) % 1.0;
      if (particle.x < 0) particle.x += 1;
      if (particle.y < 0) particle.y += 1;

      final paint = Paint()
        ..color = particle.color.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(particle.x * size.width, particle.y * size.height),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _AmbientParticlePainter oldDelegate) => true;
}
