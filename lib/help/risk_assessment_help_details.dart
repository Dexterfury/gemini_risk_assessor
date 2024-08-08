import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/app_bars/my_app_bar.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/firebase/analytics_helper.dart';

class RiskAssessmentHelpDetails extends StatelessWidget {
  const RiskAssessmentHelpDetails({super.key});
  @override
  Widget build(BuildContext context) {
    AnalyticsHelper.logScreenView(
      screenName: 'Risk Assessment Help Details',
      screenClass: 'RiskAssessmentHelpDetails',
    );
    return Scaffold(
      appBar: const MyAppBar(leading: BackButton(), title: 'Risk Assessments'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Understanding and Creating Risk Assessments',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Constants.buildSection('Steps to Create a Risk Assessment', [
                'Navigate to the Risk Assessment section',
                'Provide detailed information about the task or situation',
                'Include relevant images or documentation',
                'Specify environmental factors and personnel involved',
                'Click "Generate" to create an AI-powered risk assessment',
                'Review and edit the generated assessment',
                'Save the document to data storage'
              ]),
              Constants.buildSection('Interpreting AI-generated Risks', [
                'Review each identified risk carefully',
                'Consider the likelihood and potential impact of each risk',
                'Verify that all risks are relevant to your specific situation',
                'Don\'t hesitate to add any risks the AI might have missed'
              ]),
              Constants.buildSection('Tips for Thorough Risk Identification', [
                'Be specific about the task and environment in your description',
                'Consider all stages of the task, from setup to completion',
                'Think about less obvious risks, such as long-term health effects',
                'Consult with experienced team members for additional insights',
                'Regularly update risk assessments as conditions change'
              ]),
            ],
          ),
        ),
      ),
    );
  }
}
