import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/constants.dart';

class RistAssessmentsScreen extends StatelessWidget {
  const RistAssessmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // listView of risk assessments
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView.builder(
          itemCount:
              Constants.riskAssessmentsList.length, // replace with actual count
          itemBuilder: (context, index) {
            final riskAssessment = Constants.riskAssessmentsList[index];
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.assignment_late_outlined),
              // SizedBox(
              //   child: ClipRRect(
              //     borderRadius: BorderRadius.circular(10),
              //     child: Image.file(
              //       File(
              //           '/data/user/0/com.raphaeldaka.geminiriskassessor/cache/scaled_1000000033.jpg'),
              //       fit: BoxFit.cover,
              //     ),
              //   ),
              // ),
              title: Text(riskAssessment['title']),
              subtitle: Text(riskAssessment['description']),
              trailing: const Icon(Icons.arrow_forward),
            );
          }),
    );
  }
}
