import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/providers/auth_provider.dart';

class InputField extends StatelessWidget {
  const InputField({
    super.key,
    required this.labelText,
    required this.hintText,
    required this.controller,
    this.authProvider,
  });

  final String labelText;
  final String hintText;
  final TextEditingController controller;
  final AuthProvider? authProvider;

  @override
  Widget build(BuildContext context) {
    // check if its name imput
    final isNameInput = labelText == Constants.enterYourName;
    // check if its enabled
    final enabled = authProvider != null && !authProvider!.isLoading;
    return TextField(
      controller: controller,
      textCapitalization: TextCapitalization.sentences,
      keyboardType: isNameInput ? TextInputType.text : TextInputType.multiline,
      textInputAction:
          isNameInput ? TextInputAction.next : TextInputAction.done,
      maxLength: isNameInput ? 20 : 500,
      maxLines: isNameInput ? 1 : 3,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
