import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/screens/chat_screen.dart';
import 'package:gemini_risk_assessor/widgets/main_app_button.dart';

class ChatButton extends StatelessWidget {
  const ChatButton({
    super.key,
    this.docID = '',
    this.orgID = '',
  });

  final String docID;
  final String orgID;

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
                docID: docID,
                isTool: false,
              ),
            ),
          );
        });
  }
}
