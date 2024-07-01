import 'package:flutter/material.dart';

class IconContainer extends StatelessWidget {
  const IconContainer({
    super.key,
    required this.icon,
    this.containerColor,
  });

  final Color?
      containerColor; // You can use this to change the color of the icon container
  final IconData
      icon; // This is the icon that will be displayed in the container

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: getColor(
            context), // This function is used to get the color of the icon container
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(
          icon,
          color: Colors.white,
        ),
      ),
    );
  }

  Color getColor(BuildContext context) {
    if (containerColor != null) {
      return containerColor!; // use the provided color if it's not null
    } else {
      return Theme.of(context)
          .colorScheme
          .primary; // default color if no color is provided
    }
  }
}
