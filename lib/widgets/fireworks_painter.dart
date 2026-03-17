import 'dart:math';
import 'package:flutter/material.dart';

class FireworksPainter extends CustomPainter {
  final Animation<double> animation;
  final List<Firework> fireworks;

  FireworksPainter({required this.animation, required this.fireworks})
      : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    for (var firework in fireworks) {
      firework.paint(canvas, size, animation.value);
    }
  }

  @override
  bool shouldRepaint(FireworksPainter oldDelegate) => true;
}

class Firework {
  final Offset startPosition;
  final List<Particle> particles;
  final double startTime;
  final double duration;

  Firework({
    required this.startPosition,
    required this.startTime,
    this.duration = 1.0,
  }) : particles = List.generate(
          40,
          (index) {
            final angle = (index / 40) * 2 * pi;
            final speed = 100 + Random().nextDouble() * 100;
            return Particle(
              angle: angle,
              speed: speed,
              color: _getRandomColor(),
              size: 3 + Random().nextDouble() * 3,
            );
          },
        );

  static Color _getRandomColor() {
    final colors = [
      const Color(0xFF268BD2), // Solarized blue
      const Color(0xFF2AA198), // Solarized cyan
      const Color(0xFFB58900), // Solarized yellow
      const Color(0xFFCB4B16), // Solarized orange
      const Color(0xFFDC322F), // Solarized red
      const Color(0xFF6C71C4), // Solarized violet
      const Color(0xFF859900), // Solarized green
    ];
    return colors[Random().nextInt(colors.length)];
  }

  void paint(Canvas canvas, Size size, double time) {
    final progress = ((time - startTime) / duration).clamp(0.0, 1.0);

    if (progress == 0 || progress >= 1.0) return;

    for (var particle in particles) {
      final dx = cos(particle.angle) * particle.speed * progress;
      final dy = sin(particle.angle) * particle.speed * progress +
          (progress * progress * 200); // Gravity

      final opacity = (1.0 - progress).clamp(0.0, 1.0);
      final position = Offset(
        startPosition.dx + dx,
        startPosition.dy + dy,
      );

      // Outer glow for sparkle effect
      final glowPaint = Paint()
        ..color = Colors.white.withValues(alpha: opacity * 0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      canvas.drawCircle(
        position,
        particle.size * 2,
        glowPaint,
      );

      // Main particle
      final paint = Paint()
        ..color = particle.color.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        position,
        particle.size * (1.0 - progress * 0.5),
        paint,
      );

      // Bright center sparkle
      final sparklePaint = Paint()
        ..color = Colors.white.withValues(alpha: opacity * 0.8)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        position,
        particle.size * 0.4,
        sparklePaint,
      );

      // Twinkling sparkle effect
      final twinkle = sin(time * 20 + particle.angle * 10);
      if (twinkle > 0.7 && progress < 0.6) {
        final twinklePaint = Paint()
          ..color = Colors.yellow.withValues(alpha: opacity * twinkle)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

        canvas.drawCircle(
          position,
          particle.size * 1.5,
          twinklePaint,
        );
      }

      // Trail effect
      if (progress < 0.5) {
        final trailPaint = Paint()
          ..color = particle.color.withValues(alpha: opacity * 0.3)
          ..style = PaintingStyle.fill;

        canvas.drawCircle(
          Offset(
            startPosition.dx + dx * 0.7,
            startPosition.dy + dy * 0.7,
          ),
          particle.size * 0.5,
          trailPaint,
        );
      }
    }
  }
}

class Particle {
  final double angle;
  final double speed;
  final Color color;
  final double size;

  Particle({
    required this.angle,
    required this.speed,
    required this.color,
    required this.size,
  });
}
