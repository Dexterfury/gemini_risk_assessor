import 'package:flutter/material.dart';

class ImagePickerItem extends StatelessWidget {
  const ImagePickerItem({
    super.key,
    required this.label,
    required this.iconData,
    required this.onPressed,
  });

  final String label;
  final IconData iconData;
  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(),
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(iconData),
              const SizedBox(
                height: 5,
              ),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }
}
