import 'package:flutter/material.dart';

class MainAppButton extends StatelessWidget {
  const MainAppButton({
    super.key,
    this.icon,
    required this.label,
    this.color = Colors.white,
    this.borderRadius = 15.0,
    required this.onTap,
  });

  final IconData? icon;
  final String label;
  final Color color;
  final double borderRadius;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            width: 1,
            color: Colors.grey,
          ),
        ),
        child: GestureDetector(
          onTap: onTap,
          child: icon != null
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      color: color,
                    ),
                    const SizedBox(
                      width: 8.0,
                    ),
                    Text(
                      label,
                      style: TextStyle(
                        color: color,
                      ),
                    ),
                  ],
                )
              : Text(
                  label,
                  style: TextStyle(
                    color: color,
                  ),
                ),
        ));
  }
}
