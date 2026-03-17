import 'dart:math';
import 'package:flutter/material.dart';

class ConfettiPainter extends CustomPainter {
  final Animation<double> animation;
  final List<ConfettiParticle> particles;

  ConfettiPainter({required this.animation, required this.particles})
      : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      particle.paint(canvas, size, animation.value);
    }
  }

  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) => true;
}

class ConfettiParticle {
  final Offset startPosition;
  final double velocityX;
  final double velocityY;
  final double rotation;
  final double rotationSpeed;
  final Color color;
  final double size;
  final ConfettiShape shape;

  ConfettiParticle({
    required this.startPosition,
    required this.velocityX,
    required this.velocityY,
    required this.rotation,
    required this.rotationSpeed,
    required this.color,
    required this.size,
    required this.shape,
  });

  void paint(Canvas canvas, Size size, double time) {
    final gravity = 500.0; // Pixels per second squared
    final drag = 0.98; // Velocity multiplier per second

    // Physics calculations
    final x = startPosition.dx + velocityX * time * pow(drag, time);
    final y = startPosition.dy + velocityY * time + 0.5 * gravity * time * time;
    final currentRotation = rotation + rotationSpeed * time;

    // Fade out towards end
    final opacity = 1.0 - (time * 0.8).clamp(0.0, 1.0);

    // Only draw if still visible
    if (opacity <= 0 || y > size.height + 100) return;

    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.fill;

    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(currentRotation);

    switch (shape) {
      case ConfettiShape.rectangle:
        canvas.drawRect(
          Rect.fromCenter(center: Offset.zero, width: this.size, height: this.size * 0.6),
          paint,
        );
        break;
      case ConfettiShape.circle:
        canvas.drawCircle(Offset.zero, this.size / 2, paint);
        break;
      case ConfettiShape.triangle:
        final path = Path()
          ..moveTo(0, -this.size / 2)
          ..lineTo(this.size / 2, this.size / 2)
          ..lineTo(-this.size / 2, this.size / 2)
          ..close();
        canvas.drawPath(path, paint);
        break;
      case ConfettiShape.star:
        final path = _createStarPath(this.size);
        canvas.drawPath(path, paint);
        break;
    }

    canvas.restore();
  }

  Path _createStarPath(double size) {
    final path = Path();
    final outerRadius = size / 2;
    final innerRadius = outerRadius * 0.4;

    for (int i = 0; i < 5; i++) {
      final outerAngle = (i * 2 * pi / 5) - pi / 2;
      final innerAngle = outerAngle + pi / 5;

      if (i == 0) {
        path.moveTo(cos(outerAngle) * outerRadius, sin(outerAngle) * outerRadius);
      } else {
        path.lineTo(cos(outerAngle) * outerRadius, sin(outerAngle) * outerRadius);
      }
      path.lineTo(cos(innerAngle) * innerRadius, sin(innerAngle) * innerRadius);
    }
    path.close();
    return path;
  }
}

enum ConfettiShape {
  rectangle,
  circle,
  triangle,
  star,
}

List<ConfettiParticle> generateConfetti(Size screenSize) {
  final random = Random();
  final colors = [
    const Color(0xFF6C71C4), // Solarized violet
    const Color(0xFF2AA198), // Solarized cyan
    const Color(0xFFB58900), // Solarized yellow
    const Color(0xFFCB4B16), // Solarized orange
    const Color(0xFFDC322F), // Solarized red
    const Color(0xFF859900), // Solarized green
    const Color(0xFFD33682), // Solarized magenta
  ];
  final shapes = ConfettiShape.values;

  return List.generate(150, (index) {
    // Random starting position across the top
    final startX = random.nextDouble() * screenSize.width;
    final startY = -50.0 - random.nextDouble() * 200;

    // Random velocities
    final velocityX = (random.nextDouble() - 0.5) * 400;
    final velocityY = random.nextDouble() * 200 + 100;

    // Random rotation
    final rotation = random.nextDouble() * 2 * pi;
    final rotationSpeed = (random.nextDouble() - 0.5) * 10;

    // Random appearance
    final color = colors[random.nextInt(colors.length)];
    final size = random.nextDouble() * 15 + 8;
    final shape = shapes[random.nextInt(shapes.length)];

    return ConfettiParticle(
      startPosition: Offset(startX, startY),
      velocityX: velocityX,
      velocityY: velocityY,
      rotation: rotation,
      rotationSpeed: rotationSpeed,
      color: color,
      size: size,
      shape: shape,
    );
  });
}
