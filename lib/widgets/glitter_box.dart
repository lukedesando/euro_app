import 'package:flutter/material.dart';
import 'dart:math';

class GlitterParticle {
  Offset position;
  double radius;
  Color color;
  Offset velocity;
  String shape; // "circle" or "rectangle"

  GlitterParticle({
    required this.position,
    required this.radius,
    required this.color,
    this.velocity = const Offset(0, 0),
    this.shape = "circle",
  });
}

class GlitterPainter extends CustomPainter {
  final List<GlitterParticle> particles;

  GlitterPainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
  for (final particle in particles) {
    Paint paint = Paint()..color = particle.color;
    switch (particle.shape) {
      case "rectangle":
        Rect rect = Rect.fromCenter(
          center: particle.position,
          width: particle.radius * 1,
          height: particle.radius * 3.5
        );
        canvas.drawRect(rect, paint);
        break;
      case "square":
        Rect rect = Rect.fromCenter(
          center: particle.position,
          width: particle.radius * 2,
          height: particle.radius * 2
        );
        canvas.drawRect(rect, paint);
        break;
      case "star":
        drawStar(canvas, particle.position, particle.radius+3, paint);
        break;
      default: // Default to circle
        canvas.drawCircle(particle.position, particle.radius+1, paint);
      }
    }
  }
  void drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    Path path = Path();
    List<Offset> points = [];
    double innerRadius = radius / 3;  // Adjust this value to make the star pointier
    for (int i = 0; i < 10; i++) {
      double angle = (i * 36.0) * pi / 180;
      double r = (i % 2 == 0) ? radius : innerRadius; // Use innerRadius for inner points
      double x = center.dx + r * cos(angle);
      double y = center.dy + r * sin(angle);
      points.add(Offset(x, y));
    }
    path.addPolygon(points, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class GlitterBox extends StatefulWidget {
  final Widget child;
  final int numberOfParticles;

  GlitterBox({required this.child, this.numberOfParticles = 100});

  @override
  _GlitterBoxState createState() => _GlitterBoxState();
}

class _GlitterBoxState extends State<GlitterBox> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<GlitterParticle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Duration(seconds: 10))..repeat();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeParticles();
    });
    _controller.addListener(() {
      _updateParticles();
    });
  }

  void _initializeParticles() {
    final size = MediaQuery.of(context).size;
    _particles = List.generate(widget.numberOfParticles, (_) {
      List<String> shapes = ["circle", "star", "square"];
      String shape = shapes[_random.nextInt(shapes.length)];

      return GlitterParticle(
        position: Offset(_random.nextDouble() * size.width, _random.nextDouble() * size.height),
        radius: 1 + _random.nextDouble() * 2,
        color: Colors.primaries[_random.nextInt(Colors.primaries.length)].withOpacity(0.8),
        velocity: Offset((_random.nextDouble() - 0.5) * 2, 1.5), // Horizontal and Vertical velocities
        shape: shape,
      );
    });
    setState(() {});
  }

  void _updateParticles() {
    final size = MediaQuery.of(context).size;
    const double maxHorizontalVelocity = 1; // Set the maximum horizontal velocity

    setState(() {
      for (final particle in _particles) {
          // Add slight random horizontal movement
          double horizontalChange = (_random.nextDouble() - 0.5) * 0.2; // Adjust the multiplier for more or less movement
          double newHorizontalVelocity = particle.velocity.dx + horizontalChange;

          // Clamp the horizontal velocity to the maximum
          newHorizontalVelocity = newHorizontalVelocity.clamp(-maxHorizontalVelocity, maxHorizontalVelocity);

          particle.velocity = Offset(newHorizontalVelocity, particle.velocity.dy);

          double dx = particle.position.dx + particle.velocity.dx;
          double dy = particle.position.dy + particle.velocity.dy;

          // Wrap around horizontally and reset from top if they fall off the bottom
          if (dx < 0) dx += size.width;
          if (dx > size.width) dx -= size.width;
          if (dy > size.height) {
            dy = 0;
            dx = _random.nextDouble() * size.width;
            particle.velocity = Offset((_random.nextDouble() - 0.5) * 2, 1.5); // Reset horizontal velocity randomly
          }

          particle.position = Offset(dx, dy);
      }
    });
  }



  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        CustomPaint(
          size: Size.infinite,
          painter: GlitterPainter(particles: _particles),
        ),
        widget.child,
      ],
    );
  }
}
