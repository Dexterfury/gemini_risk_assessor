import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/providers/assessment_provider.dart';
import 'package:provider/provider.dart';

class InputField extends StatelessWidget {
  const InputField({
    super.key,
    required this.labelText,
    required this.hintText,
    required this.controller,
  });

  final String labelText;
  final String hintText;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final isNameInput = labelText == Constants.enterYourName;
    return TextField(
      controller: controller,
      textCapitalization: TextCapitalization.sentences,
      keyboardType: isNameInput ? TextInputType.text : TextInputType.multiline,
      textInputAction:
          isNameInput ? TextInputAction.next : TextInputAction.done,
      maxLength: isNameInput ? 20 : 500,
      maxLines: isNameInput ? 1 : 3,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),

      // onChanged: (value) {
      //   if (isNameInput) {
      //     // set creator name
      //     context.read<AssessmentProvider>().setCreatorName(
      //           value: value,
      //         );
      //   } else {
      //     //Update discription value
      //     context.read<AssessmentProvider>().setDescription(
      //           value: value,
      //         );
      //   }
      // },
    );
  }
}
