import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/appBars/my_app_bar.dart';
import 'package:gemini_risk_assessor/constants.dart';

class OrganizationHelpDetails extends StatelessWidget {
  const OrganizationHelpDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(
        leading: BackButton(),
        title: 'Organization Management',
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Managing and Interacting with Organizations',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Constants.buildSection('Creating an Organization', [
                'Navigate to the Organizations tab',
                'Click on the "Create New Organization" button',
                'Provide the organization name and other required details',
                'Set up initial roles and permissions',
                'Invite initial members to join the organization'
              ]),
              Constants.buildSection('Joining an Organization', [
                'Receive an invitation link or code from an organization admin',
                'Navigate to the Organizations tab',
                'Click on "Join Organization" and enter the invitation details',
                'Review and accept the organization\'s terms if applicable',
                'Wait for admin approval if required'
              ]),
              Constants.buildSection('Admin Responsibilities', [
                'Manage member roles and permissions',
                'Approve or deny new member requests',
                'Create and manage organization-wide DSTIs and Risk Assessments',
                'Monitor and moderate organization activity',
                'Ensure compliance with safety standards and regulations'
              ]),
              Constants.buildSection('Collaborating within an Organization', [
                'Access shared DSTIs, Risk Assessments, and Tools',
                'Contribute to organization-wide safety documentation',
                'Participate in discussions and provide feedback',
                'Report issues or suggest improvements to admins',
                'Stay updated with organization announcements and changes'
              ]),
            ],
          ),
        ),
      ),
    );
  }
}
