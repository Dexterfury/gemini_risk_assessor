import 'package:flutter/material.dart';

class IconContainer extends StatelessWidget {
  const IconContainer({
    super.key,
    required this.icon,
    this.color,
    this.padding = 8.0,
    this.borderRadius = 10.0,
  });

  final Color?
      color; // You can use this to change the color of the icon container
  final IconData
      icon; // This is the icon that will be displayed in the container
  final double padding; // padding of the icon
  final double borderRadius; // borderRadius of the container

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: getColor(
            context), // This function is used to get the color of the icon container
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Icon(
          icon,
          color: Colors.white,
        ),
      ),
    );
  }

  Color getColor(BuildContext context) {
    if (color != null) {
      return color!; // use the provided color if it's not null
    } else {
      return Theme.of(context)
          .colorScheme
          .primary; // default color if no color is provided
    }
  }
}
