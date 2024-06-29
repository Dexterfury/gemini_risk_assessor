import 'package:flutter/material.dart';

class MainAppButton extends StatelessWidget {
  const MainAppButton({
    super.key,
    this.icon,
    required this.label,
    this.color = Colors.white,
    required this.onTap,
  });

  final IconData? icon;
  final String label;
  final Color color;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              width: 1,
              color: Colors.grey,
            ),
          ),
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
