import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/appBars/my_app_bar.dart';
import 'package:gemini_risk_assessor/models/assessment_model.dart';
import 'package:gemini_risk_assessor/models/tool_model.dart';

class ChatDiscussionScreen extends StatefulWidget {
  const ChatDiscussionScreen({
    super.key,
    required this.orgID,
    this.currentModel,
    this.toolModel,
  });

  final String orgID;
  final AssessmentModel? currentModel;
  final ToolModel? toolModel;

  @override
  State<ChatDiscussionScreen> createState() => _ChatDiscussionScreenState();
}

class _ChatDiscussionScreenState extends State<ChatDiscussionScreen> {
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
