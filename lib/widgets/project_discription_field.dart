import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/providers/assessment_provider.dart';
import 'package:provider/provider.dart';

class ProjectDiscriptionField extends StatelessWidget {
  const ProjectDiscriptionField({
    super.key,
    required this.labelText,
    required this.hintText,
  });

  final String labelText;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    final isNameInput = labelText == Constants.enterYourName;
    return TextField(
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
        ),
      ),
      maxLines: isNameInput ? 1 : 3,
      onChanged: (value) {
        if (isNameInput) {
          // set creator name
          context.read<AssessmentProvider>().setCreatorName(
                value: value,
              );
        } else {
          //Update discription value
          context.read<AssessmentProvider>().setDescription(
                value: value,
              );
        }
      },
    );
  }
}
