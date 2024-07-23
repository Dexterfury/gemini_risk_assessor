import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/appBars/my_app_bar.dart';
import 'package:gemini_risk_assessor/tools/tool_model.dart';

class ToolChatDiscussionScreen extends StatefulWidget {
  const ToolChatDiscussionScreen({
    super.key,
    required this.toolModel,
  });

  final ToolModel toolModel;

  @override
  State<ToolChatDiscussionScreen> createState() =>
      _ToolChatDiscussionScreenState();
}

class _ToolChatDiscussionScreenState extends State<ToolChatDiscussionScreen> {
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
