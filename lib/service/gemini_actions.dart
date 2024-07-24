import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/buttons/animated_chat_button.dart';
import 'package:gemini_risk_assessor/enums/enums.dart';

class GeminiActions extends StatefulWidget {
  const GeminiActions({
    super.key,
    required this.geminiID,
  });

  final String geminiID;

  @override
  State<GeminiActions> createState() => _GeminiActionsState();
}

class _GeminiActionsState extends State<GeminiActions> {
  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(right: 20.0, left: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // gemini bubble
              buildGemini(),
              const SizedBox(
                height: 10,
              ),

              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildActionButton(context, 'Generate Safety Quiz', () {
                    // TODO: Implement quiz generation
                    Navigator.of(context).pop();
                  }),
                  _buildActionButton(context, 'Get Safety Tip', () {
                    // TODO: Implement safety tip retrieval
                    Navigator.of(context).pop();
                  }),
                  _buildActionButton(context, 'Identify Risks', () {
                    // TODO: Implement risk identification
                    Navigator.of(context).pop();
                  }),
                ],
              ),
              // context menu
              //buildMenuItems(context),
            ],
          ),
        ),
      ),
    );
  }

  Align buildGemini() {
    return Align(
      alignment: Alignment.centerRight,
      child: GeminiFloatingChatButton(
        onPressed: () {},
        size: ChatButtonSize.small,
        iconColor: Colors.white,
      ),
    );
  }

  Widget _buildActionButton(
      BuildContext context, String label, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(label),
        style: ElevatedButton.styleFrom(
          minimumSize: Size(double.infinity, 48),
        ),
      ),
    );
  }
}
