import 'package:flutter/material.dart';

class GradientOrb extends StatefulWidget {
  const GradientOrb({super.key});
  @override
  State<GradientOrb> createState() => _GradientOrbState();
}

class _GradientOrbState extends State<GradientOrb>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          painter: GradientOrbPainter(_animation.value),
          child: Container(),
        );
      },
    );
  }
}

class GradientOrbPainter extends CustomPainter {
  final double progress;

  GradientOrbPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double radius = size.width / 2;

    final Rect rect =
        Rect.fromCircle(center: Offset(centerX, centerY), radius: radius);
    final Gradient gradient = RadialGradient(
      colors: const [
        Colors.blue,
        Colors.purple,
        Colors.red,
        Colors.orange,
        Colors.yellow
      ],
      stops: [
        progress * 0.2,
        progress * 0.4,
        progress * 0.6,
        progress * 0.8,
        progress,
      ],
    );

    final Paint paint = Paint()..shader = gradient.createShader(rect);

    canvas.drawCircle(Offset(centerX, centerY), radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
