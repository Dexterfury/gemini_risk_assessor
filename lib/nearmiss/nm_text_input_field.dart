import 'package:flutter/material.dart';

class NmTextInputField extends StatelessWidget {
  const NmTextInputField({
    super.key,
    required this.labelText,
    required this.hintText,
    required this.controller,
    required this.maxLines,
    this.isLast = false,
  });

  final String labelText;
  final String hintText;
  final TextEditingController controller;
  final int maxLines;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textCapitalization: TextCapitalization.sentences,
      keyboardType: TextInputType.multiline,
      textInputAction: isLast ? TextInputAction.done : TextInputAction.next,
      maxLength: 500,
      minLines: 1,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        counterText: '',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
