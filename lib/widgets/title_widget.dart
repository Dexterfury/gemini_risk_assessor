import 'package:flutter/material.dart';

class HeadingTitleWidget extends StatelessWidget {
  const HeadingTitleWidget({
    super.key,
    required this.title,
    this.fontSize = 16,
  });

  final String title;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: fontSize,
      ),
    );
  }
}
