import 'dart:math';
import 'package:flutter/material.dart';

class ConfettiPainter extends CustomPainter {
  final Animation<double> animation;
  final List<ActiveConfetti> activeParticles;
  final List<LandedConfetti> landedParticles;

  ConfettiPainter({
    required this.animation,
    required this.activeParticles,
    required this.landedParticles,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final currentTime = DateTime.now().millisecondsSinceEpoch / 1000.0;

    // Draw landed confetti first (on the ground)
    for (var landed in landedParticles) {
      landed.paint(canvas);
    }

    // Draw active falling confetti
    for (var active in activeParticles) {
      active.paint(canvas, size, currentTime);
    }
  }

  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) => true;
}

class ActiveConfetti {
  final ConfettiParticle particle;
  final double spawnTime; // Unix timestamp in seconds

  ActiveConfetti({required this.particle, required this.spawnTime});

  void paint(Canvas canvas, Size size, double currentTime) {
    final age = currentTime - spawnTime;
    if (age < 0) return; // Not spawned yet
    particle.paint(canvas, size, age);
  }
}

class LandedConfetti {
  Offset position;
  final double rotation;
  final Color color;
  final double size;
  final ConfettiShape shape;

  LandedConfetti({
    required this.position,
    required this.rotation,
    required this.color,
    required this.size,
    required this.shape,
  });

  void paint(Canvas canvas) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.save();
    canvas.translate(position.dx, position.dy);
    canvas.rotate(rotation);

    switch (shape) {
      case ConfettiShape.rectangle:
        canvas.drawRect(
          Rect.fromCenter(center: Offset.zero, width: size, height: size * 0.6),
          paint,
        );
        break;
      case ConfettiShape.circle:
        canvas.drawCircle(Offset.zero, size / 2, paint);
        break;
      case ConfettiShape.triangle:
        final path = Path()
          ..moveTo(0, -size / 2)
          ..lineTo(size / 2, size / 2)
          ..lineTo(-size / 2, size / 2)
          ..close();
        canvas.drawPath(path, paint);
        break;
      case ConfettiShape.star:
        final path = _createStarPath(size);
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

    // Don't draw if off screen
    if (y > size.height + 100) return;

    final paint = Paint()
      ..color = color
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

  // Calculate final position when particle lands
  Offset getFinalPosition(Size screenSize, double time) {
    final gravity = 500.0;
    final drag = 0.98;
    final x = startPosition.dx + velocityX * time * pow(drag, time);
    final y = startPosition.dy + velocityY * time + 0.5 * gravity * time * time;
    return Offset(x, y);
  }

  double getFinalRotation(double time) {
    return rotation + rotationSpeed * time;
  }

  // Check if particle has landed (reached bottom)
  bool hasLanded(Size screenSize, double time) {
    final y = startPosition.dy + velocityY * time + 0.5 * 500.0 * time * time;
    return y >= screenSize.height;
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

final _confettiColors = [
  const Color(0xFF6C71C4), // Solarized violet
  const Color(0xFF2AA198), // Solarized cyan
  const Color(0xFFB58900), // Solarized yellow
  const Color(0xFFCB4B16), // Solarized orange
  const Color(0xFFDC322F), // Solarized red
  const Color(0xFF859900), // Solarized green
  const Color(0xFFD33682), // Solarized magenta
];

ConfettiParticle generateSingleConfetti(Size screenSize) {
  final random = Random();
  final shapes = ConfettiShape.values;

  // Random starting position across the top
  final startX = random.nextDouble() * screenSize.width;
  final startY = -50.0 - random.nextDouble() * 100;

  // Random velocities - less horizontal spread
  final velocityX = (random.nextDouble() - 0.5) * 200;
  final velocityY = random.nextDouble() * 100 + 50;

  // Random rotation
  final rotation = random.nextDouble() * 2 * pi;
  final rotationSpeed = (random.nextDouble() - 0.5) * 8;

  // Random appearance
  final color = _confettiColors[random.nextInt(_confettiColors.length)];
  final size = random.nextDouble() * 12 + 6;
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
}
