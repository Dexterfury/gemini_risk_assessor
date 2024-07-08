import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/models/assessment_model.dart';
import 'package:gemini_risk_assessor/models/tool_model.dart';
import 'package:gemini_risk_assessor/providers/auth_provider.dart';
import 'package:gemini_risk_assessor/providers/chat_provider.dart';
import 'package:gemini_risk_assessor/screens/chat_screen.dart';
import 'package:gemini_risk_assessor/widgets/main_app_button.dart';
import 'package:provider/provider.dart';

class ChatButton extends StatelessWidget {
  const ChatButton({
    super.key,
    required this.isDSTI,
    this.assesmentModel,
    this.toolModel,
    this.isTool = false,
  });
  final bool isDSTI;
  final AssessmentModel? assesmentModel;
  final ToolModel? toolModel;
  final bool isTool;

  @override
  Widget build(BuildContext context) {
    return MainAppButton(
        icon: Icons.chat_outlined,
        label: "Discuss more with Gemini",
        onTap: () async {
          final uid = context.read<AuthProvider>().userModel!.uid;
          final chatProvider = context.read<ChatProvider>();
          await chatProvider
              .getChatHistoryFromFirebase(
            uid: uid,
            isDSTI: isDSTI,
            assessmentModel: assesmentModel,
          )
              .whenComplete(() {
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
        });
  }
}
