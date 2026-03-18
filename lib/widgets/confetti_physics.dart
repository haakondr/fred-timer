import 'dart:math';
import 'package:flutter/material.dart';
import 'package:forge2d/forge2d.dart' as box2d;

class ConfettiPhysicsWorld {
  late box2d.World world;
  final List<ConfettiBody> confettiBodies = [];
  final Size screenSize;

  // Scale factor: pixels to meters (Box2D works in meters)
  static const double pixelsPerMeter = 100.0;

  // Performance: limit total particles and freeze settled ones
  static const int maxActiveParticles = 200;
  static const int maxTotalParticles = 2000; // Allow larger pile to build up

  ConfettiPhysicsWorld({required this.screenSize}) {
    // Create physics world with gravity (10 m/s² is realistic earth gravity)
    world = box2d.World(box2d.Vector2(0, 20.0));

    // Create ground body
    _createGround();
    // Create walls
    _createWalls();
  }

  // Convert pixel coordinates to physics world coordinates
  box2d.Vector2 _toPhysics(Offset pixels) {
    return box2d.Vector2(
      pixels.dx / pixelsPerMeter,
      pixels.dy / pixelsPerMeter,
    );
  }

  double _toPhysicsScalar(double pixels) {
    return pixels / pixelsPerMeter;
  }

  // Convert physics coordinates back to pixels
  Offset _toPixels(box2d.Vector2 physics) {
    return Offset(
      physics.x * pixelsPerMeter,
      physics.y * pixelsPerMeter,
    );
  }

  void _createGround() {
    // Place ground at the very bottom of the screen
    final groundThickness = 100.0;
    final groundYPixels = screenSize.height + (groundThickness / 2);

    final groundDef = box2d.BodyDef()
      ..position = _toPhysics(Offset(screenSize.width / 2, groundYPixels))
      ..type = box2d.BodyType.static;

    final groundBody = world.createBody(groundDef);

    final groundBox = box2d.PolygonShape()
      ..setAsBox(_toPhysicsScalar(screenSize.width / 2), _toPhysicsScalar(groundThickness / 2), box2d.Vector2.zero(), 0);

    final fixtureDef = box2d.FixtureDef(groundBox)
      ..friction = 0.6
      ..restitution = 0.2
      ..density = 0.0;

    groundBody.createFixture(fixtureDef);
  }

  void _createWalls() {
    // Left wall
    final leftWallDef = box2d.BodyDef()
      ..position = _toPhysics(Offset(-5, screenSize.height / 2))
      ..type = box2d.BodyType.static;

    final leftWallBody = world.createBody(leftWallDef);

    final leftWallBox = box2d.PolygonShape()
      ..setAsBox(_toPhysicsScalar(10.0), _toPhysicsScalar(screenSize.height / 2), box2d.Vector2.zero(), 0);

    leftWallBody.createFixture(box2d.FixtureDef(leftWallBox)
      ..friction = 0.6
      ..restitution = 0.2);

    // Right wall
    final rightWallDef = box2d.BodyDef()
      ..position = _toPhysics(Offset(screenSize.width + 5, screenSize.height / 2))
      ..type = box2d.BodyType.static;

    final rightWallBody = world.createBody(rightWallDef);

    final rightWallBox = box2d.PolygonShape()
      ..setAsBox(_toPhysicsScalar(10.0), _toPhysicsScalar(screenSize.height / 2), box2d.Vector2.zero(), 0);

    rightWallBody.createFixture(box2d.FixtureDef(rightWallBox)
      ..friction = 0.6
      ..restitution = 0.2);
  }

  ConfettiBody addConfetti(Offset position, Color color, double size, ConfettiShape shape) {
    final bodyDef = box2d.BodyDef()
      ..position = _toPhysics(position)
      ..type = box2d.BodyType.dynamic
      ..angle = Random().nextDouble() * 2 * pi
      ..angularVelocity = (Random().nextDouble() - 0.5) * 10;

    final body = world.createBody(bodyDef);

    // Create circle shape for physics (simpler and more stable than polygons)
    final circle = box2d.CircleShape()
      ..radius = _toPhysicsScalar(size / 2);

    final fixtureDef = box2d.FixtureDef(circle)
      ..density = 1.0
      ..friction = 0.8
      ..restitution = 0.3; // Some bounce

    body.createFixture(fixtureDef);

    final confettiBody = ConfettiBody(
      body: body,
      color: color,
      size: size,
      shape: shape,
    );

    confettiBodies.add(confettiBody);
    return confettiBody;
  }

  void step(double dt) {
    // Step the physics simulation
    world.stepDt(dt);

    // Freeze particles that have settled (low velocity + many particles above)
    _freezeSettledParticles();

    // Note: We don't remove frozen particles - they stay visible as part of the pile
    // The spawning code in timer_screen.dart stops spawning when we hit maxTotalParticles
  }

  void _freezeSettledParticles() {
    // Count active (dynamic) particles
    int activeCount = confettiBodies
        .where((c) => c.body.bodyType == box2d.BodyType.dynamic)
        .length;

    // If we have too many active particles, freeze some that are settled
    if (activeCount > maxActiveParticles) {
      for (var confetti in confettiBodies) {
        if (confetti.body.bodyType != box2d.BodyType.dynamic) continue;

        // Check if particle is settled (very low velocity)
        final velocity = confetti.body.linearVelocity;
        final speed = velocity.length;

        if (speed < 0.1) {
          // Count particles above this one
          int particlesAbove = 0;
          final thisY = confetti.body.position.y;

          for (var other in confettiBodies) {
            if (other.body.position.y < thisY) {
              particlesAbove++;
            }
          }

          // Freeze if there are many particles above (this one is buried)
          if (particlesAbove > 20) {
            confetti.body.setType(box2d.BodyType.static);
            activeCount--;

            // Stop once we're under the limit
            if (activeCount <= maxActiveParticles) break;
          }
        }
      }
    }
  }

  void dispose() {
    // Clean up all bodies
    for (var confetti in confettiBodies) {
      world.destroyBody(confetti.body);
    }
    confettiBodies.clear();
  }
}

class ConfettiBody {
  final box2d.Body body;
  final Color color;
  final double size;
  final ConfettiShape shape;

  ConfettiBody({
    required this.body,
    required this.color,
    required this.size,
    required this.shape,
  });

  Offset get position => Offset(
    body.position.x * ConfettiPhysicsWorld.pixelsPerMeter,
    body.position.y * ConfettiPhysicsWorld.pixelsPerMeter,
  );
  double get rotation => body.angle;
}

class ConfettiPhysicsPainter extends CustomPainter {
  final ConfettiPhysicsWorld physicsWorld;

  ConfettiPhysicsPainter({required this.physicsWorld});

  @override
  void paint(Canvas canvas, Size size) {
    for (var confetti in physicsWorld.confettiBodies) {
      final paint = Paint()
        ..color = confetti.color
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(confetti.position.dx, confetti.position.dy);
      canvas.rotate(confetti.rotation);

      switch (confetti.shape) {
        case ConfettiShape.rectangle:
          canvas.drawRect(
            Rect.fromCenter(
              center: Offset.zero,
              width: confetti.size,
              height: confetti.size * 0.6,
            ),
            paint,
          );
          break;
        case ConfettiShape.circle:
          canvas.drawCircle(Offset.zero, confetti.size / 2, paint);
          break;
        case ConfettiShape.triangle:
          final path = Path()
            ..moveTo(0, -confetti.size / 2)
            ..lineTo(confetti.size / 2, confetti.size / 2)
            ..lineTo(-confetti.size / 2, confetti.size / 2)
            ..close();
          canvas.drawPath(path, paint);
          break;
        case ConfettiShape.star:
          final path = _createStarPath(confetti.size);
          canvas.drawPath(path, paint);
          break;
      }

      canvas.restore();
    }
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

  @override
  bool shouldRepaint(ConfettiPhysicsPainter oldDelegate) => true;
}

enum ConfettiShape {
  rectangle,
  circle,
  triangle,
  star,
}

final _confettiColors = [
  const Color(0xFFFDB813), // Yellow (meter bottom)
  const Color(0xFFFF7F50), // Coral (meter middle)
  const Color(0xFFFF1493), // Fuchsia (meter top)
  const Color(0xFF2AA198), // Teal - complement
  const Color(0xFF6C71C4), // Violet - complement
  const Color(0xFFFFB347), // Orange - warm tone
  const Color(0xFFFF69B4), // Hot pink - vibrant accent
];

ConfettiShape randomShape() {
  return ConfettiShape.values[Random().nextInt(ConfettiShape.values.length)];
}

Color randomConfettiColor() {
  return _confettiColors[Random().nextInt(_confettiColors.length)];
}
