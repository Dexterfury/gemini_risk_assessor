import 'package:flutter/material.dart';

class MainAppButton extends StatelessWidget {
  const MainAppButton({
    super.key,
    required this.widget,
    required this.label,
    required this.onTap,
  });

  final Widget widget;
  final String label;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(context).dialogBackgroundColor,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              width: 1,
              color: Colors.grey,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              widget,
              const SizedBox(
                width: 10,
              ),
              Text(label),
            ],
          ),
        ));
  }
}
