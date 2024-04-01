import 'package:flutter/material.dart';
import 'dart:math';

class GlitterParticle {
  Offset position;
  double radius;
  Color color;

  GlitterParticle({required this.position, required this.radius, required this.color});
}

class GlitterPainter extends CustomPainter {
  final List<GlitterParticle> particles;

  GlitterPainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      Paint paint = Paint()..color = particle.color;
      canvas.drawCircle(particle.position, particle.radius, paint);
    }
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
      return GlitterParticle(
        position: Offset(_random.nextDouble() * size.width, _random.nextDouble() * size.height),
        radius: 1 + _random.nextDouble() * 2,
        color: Colors.primaries[_random.nextInt(Colors.primaries.length)].withOpacity(0.8),
      );
    });
    setState(() {}); // Trigger a rebuild to display the particles
  }

  void _updateParticles() {
    final size = MediaQuery.of(context).size;
    setState(() {
      for (final particle in _particles) {
        double dx = particle.position.dx + (_random.nextDouble() - 0.5) * 3; // Small random side-to-side movement
        double dy = particle.position.dy + .75; // Move downward
        if (dy > size.height) {
          // Reset the particle to the top of the screen if it falls off the bottom
          dy = 0;
          dx = _random.nextDouble() * size.width;
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
          size: Size.infinite, // Cover the whole screen
          painter: GlitterPainter(particles: _particles),
        ),
        widget.child,
      ],
    );
  }
}

