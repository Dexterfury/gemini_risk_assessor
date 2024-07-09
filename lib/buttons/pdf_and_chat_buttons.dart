import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/buttons/chat_button.dart';
import 'package:gemini_risk_assessor/buttons/main_app_button.dart';
import 'package:gemini_risk_assessor/models/assessment_model.dart';
import 'package:gemini_risk_assessor/models/tool_model.dart';
import 'package:gemini_risk_assessor/providers/auth_provider.dart';
import 'package:gemini_risk_assessor/providers/chat_provider.dart';
import 'package:gemini_risk_assessor/screens/chat_screen.dart';
import 'package:gemini_risk_assessor/widgets/icon_container.dart';
import 'package:provider/provider.dart';

class PdfAndChatButtons extends StatelessWidget {
  const PdfAndChatButtons({
    super.key,
    required this.isDSTI,
    this.assessmentModel,
    this.toolModel,
    this.isTool = false,
  });

  final bool isDSTI;
  final AssessmentModel? assessmentModel;
  final ToolModel? toolModel;
  final bool isTool;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // pdf icon
        GestureDetector(
          onTap: () {
            // open pdf
          },
          child: const IconContainer(
            icon: Icons.picture_as_pdf_rounded,
            containerColor: Colors.blue,
          ),
        ),

        MainAppButton(
            icon: Icons.chat_outlined,
            label: "Discuss more with Gemini",
            borderRadius: 10,
            onTap: () async {
              final uid = context.read<AuthProvider>().userModel!.uid;
              final chatProvider = context.read<ChatProvider>();
              await chatProvider
                  .getChatHistoryFromFirebase(
                uid: uid,
                isDSTI: isDSTI,
                assessmentModel: assessmentModel,
              )
                  .whenComplete(() {
                // Navigate to the chat screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(
                      assesmentModel: assessmentModel,
                      toolModel: toolModel,
                    ),
                  ),
                );
              });
            }),
      ],
    );
  }
}
