import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/appBars/my_app_bar.dart';
import 'package:gemini_risk_assessor/constants.dart';

class GroupHelpDetails extends StatelessWidget {
  const GroupHelpDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(
        leading: BackButton(),
        title: 'Group Management',
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Managing and Interacting with Groups',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Constants.buildSection('Creating an Group', [
                'Navigate to the Groups tab',
                'Click on the "Create New Group" button',
                'Provide the Group name and other required details',
                'Set up initial roles and permissions',
                'Invite initial members to join the Group'
              ]),
              Constants.buildSection('Joining an Group', [
                'Receive an invitation notification from an admin',
                'Click on notification or navigate to notification in your profile and click on a notification',
                'Navigate to "Group details screen"',
                'Review and accept the Group\'s terms if applicable to join the Group',
              ]),
              Constants.buildSection('Admin Responsibilities', [
                'Manage member roles and permissions',
                'Create and manage Group-wide DSTIs and Risk Assessments',
                'Monitor and moderate Group activity',
                'Ensure compliance with safety standards and regulations'
              ]),
              Constants.buildSection('Collaborating within an Group', [
                'Access shared DSTIs, Risk Assessments, and Tools',
                'Contribute to Group-wide safety documentation',
                'Participate in discussions and provide feedback',
                'Report issues or suggest improvements to admins',
                'Stay updated with Group announcements and changes'
              ]),
            ],
          ),
        ),
      ),
    );
  }
}
