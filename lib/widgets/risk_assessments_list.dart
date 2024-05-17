import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/constants.dart';

class RistAssessmentsList extends StatelessWidget {
  const RistAssessmentsList({super.key});

  @override
  Widget build(BuildContext context) {
    // listView of risk assessments
    return ListView.builder(
        itemCount:
            Constants.riskAssessmentsList.length, // replace with actual count
        itemBuilder: (context, index) {
          final riskAssessment = Constants.riskAssessmentsList[index];
          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.assessment),
            title: Text(riskAssessment['title']),
            subtitle: Text(riskAssessment['description']),
            trailing: const Icon(Icons.arrow_forward),
          );
        });
  }
}
