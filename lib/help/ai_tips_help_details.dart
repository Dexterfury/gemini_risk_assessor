import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/appBars/my_app_bar.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/firebase_methods/analytics_helper.dart';

class AiTipsHelpDetails extends StatelessWidget {
  const AiTipsHelpDetails({super.key});

  @override
  Widget build(BuildContext context) {
    AnalyticsHelper.logScreenView(
      screenName: 'Ai Tips Help Details',
      screenClass: 'AiTipsHelpDetails',
    );
    return Scaffold(
      appBar: const MyAppBar(
        leading: BackButton(),
        title: 'AI Integration Tips',
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Get the Most Out of AI-Generated Content',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Constants.buildSection('Phrasing Prompts for Better Results', [
                'Be specific and detailed in your descriptions',
                'Use clear, concise language',
                'Provide context about the task, environment, and industry',
                'Include relevant technical terms or jargon'
              ]),
              Constants.buildSection('Understanding AI Limitations', [
                'AI may not have real-time or location-specific information',
                'It may not understand very specialized or niche topics without explanation',
                'AI can make mistakes or provide incomplete information',
                'It may not account for recent changes in regulations or best practices',
                'AI-generated content should always be reviewed by a human expert'
              ]),
              Constants.buildSection('Verifying AI-Generated Content', [
                'Cross-reference with official safety guidelines and regulations',
                'Consult with experienced team members or safety officers',
                'Check for logical consistency and completeness',
                'Ensure all identified risks and safety measures are relevant',
                'Look for any missing crucial information based on your expertise'
              ]),
              Constants.buildSection('Editing AI-Generated Content', [
                'Remove any irrelevant or redundant information',
                'Add specific details pertinent to your situation',
                'Adjust language for clarity and your group\'s style',
                'Enhance safety measures based on your knowledge and experience',
                'Ensure all content aligns with current best practices and regulations'
              ]),
            ],
          ),
        ),
      ),
    );
  }
}
