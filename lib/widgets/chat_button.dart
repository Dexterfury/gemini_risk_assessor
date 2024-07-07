import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/models/assessment_model.dart';
import 'package:gemini_risk_assessor/models/tool_model.dart';
import 'package:gemini_risk_assessor/screens/chat_screen.dart';
import 'package:gemini_risk_assessor/widgets/main_app_button.dart';

class ChatButton extends StatelessWidget {
  const ChatButton({
    super.key,
    this.assesmentModel,
    this.toolModel,
    this.isTool = false,
  });

  final AssessmentModel? assesmentModel;
  final ToolModel? toolModel;
  final bool isTool;

  @override
  Widget build(BuildContext context) {
    return MainAppButton(
        icon: Icons.chat_outlined,
        label: "Discuss more with Gemini",
        onTap: () async {
          // Navigate to the chat screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                assesmentModel: assesmentModel,
                toolModel: toolModel,
              ),
            ),
          );
        });
  }
}
