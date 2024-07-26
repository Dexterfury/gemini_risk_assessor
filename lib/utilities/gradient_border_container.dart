import 'package:flutter/material.dart';

class GradientBorderContainer extends StatelessWidget {
  final Widget child;
  final List<Color> gradientColors;
  final double borderWidth;
  final double borderRadius;
  final Alignment beginAlignment;
  final Alignment endAlignment;

  const GradientBorderContainer({
    Key? key,
    required this.child,
    this.gradientColors = const [Colors.blue, Colors.purple],
    this.borderWidth = 2.0,
    this.borderRadius = 12.0,
    this.beginAlignment = Alignment.topLeft,
    this.endAlignment = Alignment.bottomRight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: beginAlignment,
          end: endAlignment,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Padding(
        padding: EdgeInsets.all(borderWidth),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius - borderWidth),
          child: child,
        ),
      ),
    );
  }
}
