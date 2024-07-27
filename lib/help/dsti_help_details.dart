import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/appBars/my_app_bar.dart';

class DstiHelpDetails extends StatelessWidget {
  const DstiHelpDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: MyAppBar(
        leading: BackButton(),
        title: 'Creating a DSTI',
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'How to Create a Daily Safety Task Instruction (DSTI)',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                '1. Select Images: Choose images from your gallery or take new photos related to the task.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                '2. Mark PPE: Select the required Personal Protective Equipment from the grid view.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                '3. Choose Weather: Select the current or expected weather conditions.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                '4. Specify Number of People: Enter the number of people involved in the task.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                '5. Add Description: Provide a detailed description of the task.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                '6. Generate s DSTI: Click the generate button to create an AI-powered DSTI',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                '7. Review and Edit: On the details screen, review the generated content and remove any unwanted items.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                '8. Save the document to your secured Firestore datbase.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                'Tips for Better Results:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '• Provide clear, high-quality images\n'
                '• Be specific and detailed in your task description\n'
                '• Accurately select all relevant PPE items\n'
                '• Double-check all information before generating the DSTI',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
    ;
  }
}
