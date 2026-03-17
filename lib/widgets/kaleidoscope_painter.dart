import 'dart:math';
import 'package:flutter/material.dart';

class KaleidoscopePainter extends CustomPainter {
  final Animation<double> animation;
  final List<Color> colors = [
    const Color(0xFF6C71C4), // Solarized violet
    const Color(0xFF2AA198), // Solarized cyan
    const Color(0xFFB58900), // Solarized yellow
    const Color(0xFFCB4B16), // Solarized orange
    const Color(0xFFDC322F), // Solarized red
    const Color(0xFF6C71C4), // Solarized violet
    const Color(0xFF859900), // Solarized green
    const Color(0xFFD33682), // Solarized magenta
  ];

  KaleidoscopePainter({required this.animation}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final progress = animation.value;

    // Rotation animation
    final rotation = progress * 2 * pi;

    // Number of symmetrical segments
    const segments = 8;
    final segmentAngle = 2 * pi / segments;

    // Pulsing scale
    final pulseScale = 0.8 + (sin(progress * 4 * pi) * 0.2);

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    canvas.scale(pulseScale);

    // Draw each segment
    for (int i = 0; i < segments; i++) {
      canvas.save();
      canvas.rotate(i * segmentAngle);

      // Draw multiple layers of shapes for depth
      _drawSegmentPattern(canvas, size, progress, i);

      canvas.restore();
    }

    canvas.restore();

    // Add color explosion particles
    _drawExplosionParticles(canvas, center, progress);
  }

  void _drawSegmentPattern(Canvas canvas, Size size, double progress, int segmentIndex) {
    final maxRadius = min(size.width, size.height) * 0.5;

    // Layer 1: Large rotating triangles
    final color1 = colors[segmentIndex % colors.length];
    final paint1 = Paint()
      ..color = color1.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    final trianglePath = Path()
      ..moveTo(0, -maxRadius * 0.8)
      ..lineTo(maxRadius * 0.3, maxRadius * 0.2)
      ..lineTo(-maxRadius * 0.3, maxRadius * 0.2)
      ..close();

    canvas.drawPath(trianglePath, paint1);

    // Layer 2: Inner circles with gradient effect
    final color2 = colors[(segmentIndex + 2) % colors.length];
    final circleRadius = maxRadius * 0.2 * (1 + sin(progress * 6 * pi) * 0.3);

    final paint2 = Paint()
      ..color = color2.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(0, -maxRadius * 0.4), circleRadius, paint2);

    // Layer 3: Diamond shapes
    final color3 = colors[(segmentIndex + 5) % colors.length];
    final paint3 = Paint()
      ..color = color3.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    final diamondSize = maxRadius * 0.15;
    final diamondPath = Path()
      ..moveTo(0, -maxRadius * 0.6 - diamondSize)
      ..lineTo(diamondSize * 0.5, -maxRadius * 0.6)
      ..lineTo(0, -maxRadius * 0.6 + diamondSize)
      ..lineTo(-diamondSize * 0.5, -maxRadius * 0.6)
      ..close();

    canvas.drawPath(diamondPath, paint3);

    // Layer 4: Glowing outline
    final paint4 = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    canvas.drawPath(trianglePath, paint4);
  }

  void _drawExplosionParticles(Canvas canvas, Offset center, double progress) {
    final random = Random(42); // Fixed seed for consistent animation

    // Create expanding circle waves
    for (int wave = 0; wave < 3; wave++) {
      final waveProgress = (progress + wave * 0.3) % 1.0;
      final radius = waveProgress * min(center.dx, center.dy) * 2;
      final opacity = (1.0 - waveProgress) * 0.4;

      final color = colors[wave % colors.length];
      final paint = Paint()
        ..color = color.withValues(alpha: opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

      canvas.drawCircle(center, radius, paint);
    }

    // Sparkle particles
    for (int i = 0; i < 50; i++) {
      final angle = random.nextDouble() * 2 * pi;
      final distance = random.nextDouble() * 300 * progress;
      final particleProgress = (progress + i * 0.02) % 1.0;

      if (particleProgress > 0.3) continue; // Only show early in animation

      final x = center.dx + cos(angle) * distance;
      final y = center.dy + sin(angle) * distance;

      final opacity = (1.0 - particleProgress / 0.3) * random.nextDouble();
      final color = colors[i % colors.length];

      final paint = Paint()
        ..color = color.withValues(alpha: opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

      canvas.drawCircle(Offset(x, y), 4, paint);
    }
  }

  @override
  bool shouldRepaint(KaleidoscopePainter oldDelegate) => true;
}
