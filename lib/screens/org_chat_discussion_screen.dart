import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/appBars/my_app_bar.dart';
import 'package:gemini_risk_assessor/models/assessment_model.dart';

class OrgChatDiscussionScreen extends StatefulWidget {
  const OrgChatDiscussionScreen({
    super.key,
    required this.orgModel,
  });

  final AssessmentModel orgModel;

  @override
  State<OrgChatDiscussionScreen> createState() =>
      _ToolChatDiscussionScreenState();
}

class _ToolChatDiscussionScreenState extends State<OrgChatDiscussionScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: MyAppBar(leading: BackButton(), title: 'Discussion Data'),
      body: Center(
        child: Text('Discussion'),
      ),
    );
  }
}
