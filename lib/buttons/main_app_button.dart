import 'package:flutter/material.dart';

class MainAppButton extends StatelessWidget {
  const MainAppButton({
    super.key,
    this.icon,
    required this.label,
    this.color = Colors.white,
    this.contanerColor,
    this.borderRadius = 10.0,
    required this.onTap,
  });

  final IconData? icon;
  final String label;
  final Color color;
  final Color? contanerColor;
  final double borderRadius;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    final btnColor = contanerColor ?? Theme.of(context).primaryColor;
    return Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: btnColor,
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
                      style:
                          TextStyle(color: color, fontWeight: FontWeight.bold),
                    ),
                  ],
                )
              : Center(
                  child: Text(
                    label,
                    style: TextStyle(color: color, fontWeight: FontWeight.bold),
                  ),
                ),
        ));
  }
}
