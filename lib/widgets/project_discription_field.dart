import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/providers/assessment_provider.dart';
import 'package:provider/provider.dart';

class ProjectDiscriptionField extends StatefulWidget {
  const ProjectDiscriptionField({super.key});

  @override
  State<ProjectDiscriptionField> createState() =>
      _ProjectDiscriptionFieldState();
}

class _ProjectDiscriptionFieldState extends State<ProjectDiscriptionField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        labelText: 'Enter description',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
        ),
      ),
      maxLines: 3,
      onChanged: (value) {
        //Update discription value
        context.read<AssessmentProvider>().setDescription(
              value: value,
            );
      },
    );
  }
}
