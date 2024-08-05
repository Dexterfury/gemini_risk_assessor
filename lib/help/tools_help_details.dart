import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/appBars/my_app_bar.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/firebase_methods/analytics_helper.dart';

class ToolsHelpDetails extends StatelessWidget {
  const ToolsHelpDetails({super.key});

  @override
  Widget build(BuildContext context) {
    AnalyticsHelper.logScreenView(
      screenName: 'Tools Help Details',
      screenClass: 'ToolsHelpDetails',
    );
    return Scaffold(
      appBar: const MyAppBar(
        leading: BackButton(),
        title: 'Tools Explainer',
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'How to Use the Tools Feature Effectively',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Constants.buildSection('Adding New Tools', [
                'Navigate to the Tools section',
                'Click on the "Add New Tool" button',
                'Choose to either select images from gallery or take new photos',
                'Provide a detailed description of the tool',
                'Click "Generate" to create an AI-powered tool explanation'
              ]),
              Constants.buildSection('Best Practices for Tool Descriptions', [
                'Include the tool\'s full name and any common aliases',
                'Describe the tool\'s primary function and typical use cases',
                'Mention any specific models or variations of the tool',
                'Include relevant specifications (size, weight, power requirements)',
                'Note any special features or attachments'
              ]),
              Constants.buildSection('Tips for Tool Images', [
                'Capture clear, well-lit images of the entire tool',
                'Include close-up shots of important features or controls',
                'Show the tool from multiple angles if relevant',
                'Include images of the tool in use, if possible',
                'Ensure any text on the tool (labels, warnings) is legible'
              ]),
              Constants.buildSection(
                  'Understanding AI-generated Safety Instructions', [
                'Review all safety instructions carefully',
                'Verify that the instructions match the specific tool you\'ve added',
                'Look for any missing crucial safety steps and add them manually',
                'Consider both obvious and non-obvious safety concerns',
                'If in doubt, consult the tool\'s official manual or an expert'
              ]),
            ],
          ),
        ),
      ),
    );
  }
}
