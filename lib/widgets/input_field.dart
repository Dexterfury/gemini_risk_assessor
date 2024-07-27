import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/authentication/authentication_provider.dart';
import 'package:gemini_risk_assessor/groups/group_provider.dart';

class InputField extends StatelessWidget {
  const InputField({
    super.key,
    required this.labelText,
    required this.hintText,
    required this.controller,
    this.authProvider,
    this.groupProvider,
  });

  final String labelText;
  final String hintText;
  final TextEditingController controller;
  final AuthenticationProvider? authProvider;
  final GroupProvider? groupProvider;

  @override
  Widget build(BuildContext context) {
    // check if its name imput
    final isNameInput = labelText == Constants.enterYourName ||
        labelText == Constants.groupName;
    return TextField(
      controller: controller,
      textCapitalization: TextCapitalization.sentences,
      keyboardType: isNameInput ? TextInputType.text : TextInputType.multiline,
      textInputAction:
          isNameInput ? TextInputAction.next : TextInputAction.done,
      maxLength: isNameInput ? 25 : 800,
      minLines: 1,
      maxLines: 3,
      enabled: getEnabled(),
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

  // get enabled state - enable or disable input field
  getEnabled() {
    if (authProvider != null && authProvider!.isLoading) {
      return false;
    }

    if (groupProvider != null && groupProvider!.isLoading) {
      return false;
    }
    return true;
  }
}
