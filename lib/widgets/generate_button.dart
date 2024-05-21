import 'package:flutter/material.dart';

class GenerateButton extends StatelessWidget {
  const GenerateButton({
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
    return InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(context).dialogBackgroundColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              width: 1,
              color: Colors.grey,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              widget,
              Text(label),
            ],
          ),
        ));
  }
}
