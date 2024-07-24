import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/buttons/animated_chat_button.dart';
import 'package:gemini_risk_assessor/enums/enums.dart';

class GeminiActions extends StatefulWidget {
  const GeminiActions({
    super.key,
    required this.onTapAction,
  });

  final Function(AiActions) onTapAction;

  @override
  State<GeminiActions> createState() => _GeminiActionsState();
}

class _GeminiActionsState extends State<GeminiActions> {
  void _selectAndPop(AiActions action) {
    widget.onTapAction(action);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        if (didPop) {
          widget.onTapAction(AiActions.none);
        }
      },
      child: BackdropFilter(
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
                    _buildActionButton(
                      context: context,
                      label: 'Generate Safety Quiz',
                      onPressed: () {
                        _selectAndPop(AiActions.safetyQuiz);
                      },
                    ),
                    _buildActionButton(
                      context: context,
                      label: 'Get Safety Tip',
                      onPressed: () {
                        _selectAndPop(AiActions.tipOfTheDay);
                      },
                    ),
                    _buildActionButton(
                      context: context,
                      label: 'Identify Risks',
                      onPressed: () {
                        _selectAndPop(AiActions.identifyRisk);
                      },
                    ),
                  ],
                ),
                // context menu
                //buildMenuItems(context),
              ],
            ),
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
      {required BuildContext context,
      required String label,
      required VoidCallback onPressed}) {
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
