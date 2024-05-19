import 'package:flutter/material.dart';

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
        labelText: 'Enter discription',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    );
  }
}
