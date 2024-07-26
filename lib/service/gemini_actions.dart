import 'dart:developer';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/authentication/authentication_provider.dart';
import 'package:gemini_risk_assessor/buttons/animated_chat_button.dart';
import 'package:gemini_risk_assessor/dialogs/my_dialogs.dart';
import 'package:gemini_risk_assessor/discussions/additional_data_widget.dart';
import 'package:gemini_risk_assessor/discussions/discussion_chat_provider.dart';
import 'package:gemini_risk_assessor/discussions/discussion_message.dart';
import 'package:gemini_risk_assessor/enums/enums.dart';
import 'package:gemini_risk_assessor/models/assessment_model.dart';
import 'package:gemini_risk_assessor/utilities/global.dart';
import 'package:provider/provider.dart';

class GeminiActions extends StatefulWidget {
  const GeminiActions({
    super.key,
    required this.groupID,
    required this.assessment,
    required this.generationType,
    required this.onTapAction,
  });

  final String groupID;
  final AssessmentModel assessment;
  final GenerationType generationType;
  final Function(AiActions) onTapAction;

  @override
  State<GeminiActions> createState() => _GeminiActionsState();
}

class _GeminiActionsState extends State<GeminiActions> {
  void _selectAndPop(AiActions action) {
    final discussionsProvider = context.read<DiscussionChatProvider>();
    final userModel = context.read<AuthenticationProvider>().userModel!;

    switch (action) {
      case AiActions.safetyQuiz:
        MyDialogs.showMyAnimatedDialog(
          context: context,
          title: 'Creating Safety Quiz',
          loadingIndicator: const SizedBox(
            height: 100,
            width: 100,
            child: LoadingPPEIcons(),
          ),
        );
        discussionsProvider
            .generateQuiz(
          userModel: userModel,
          assessment: widget.assessment,
          groupID: widget.groupID,
          generationType: widget.generationType,
        )
            .whenComplete(() {
          // pop the loading dialog
          Navigator.pop(context);

          Future.delayed(const Duration(seconds: 1)).whenComplete(() {
            Navigator.of(context).pop();
          });
        });

        break;
      case AiActions.additionalData:
        MyDialogs.showMyAnimatedDialog(
          context: context,
          title: 'Generating...',
          loadingIndicator: const SizedBox(
            height: 100,
            width: 100,
            child: LoadingPPEIcons(),
          ),
        );
        discussionsProvider
            .addAdditionalData(
          userModel: userModel,
          assessment: widget.assessment,
          groupID: widget.groupID,
          generationType: widget.generationType,
        )
            .then((message) {
          // pop the loading dialog
          Navigator.pop(context);

          if (message != null) {
            Future.delayed(const Duration(seconds: 1)).whenComplete(() {
              MyDialogs.showMyAnimatedDialog(
                  context: context,
                  title: 'Additional Data',
                  signatureInput: AdditionalDataWidget(
                    message: message,
                    isDialog: true,
                  ),
                  actions: [
                    TextButton(
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: Colors.red),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
                      child: Text(
                        'Add to Chat',
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ]);
            });
          }
        });

        break;
      case AiActions.summerize:
        MyDialogs.showMyAnimatedDialog(
          context: context,
          title: 'Summerizing...',
          loadingIndicator: const SizedBox(
            height: 100,
            width: 100,
            child: LoadingPPEIcons(),
          ),
        );
        discussionsProvider
            .summerizeChatMessages(
          groupID: widget.groupID,
          itemID: widget.assessment.id,
          generationType: widget.generationType,
        )
            .then((summery) {
          // pop the loading dialog
          Navigator.pop(context);

          log('summery: $summery');
          showSnackBar(
            context: context,
            message: summery,
          );
        });
        break;
      case AiActions.tipOfTheDay:
        log('generate a tip of the day');
        break;
      case AiActions.identifyRisk:
        log('generate a risk identification');
        break;

      case AiActions.none:
        log('do nothing');
        break;
      default:
        break;
    }
  }

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
                  _buildActionButton(
                    context: context,
                    label: 'Generate Safety Quiz',
                    onPressed: () {
                      _selectAndPop(AiActions.safetyQuiz);
                    },
                  ),
                  _buildActionButton(
                    context: context,
                    label: 'Suggest Additional Risks',
                    onPressed: () {
                      _selectAndPop(AiActions.additionalData);
                    },
                  ),
                  _buildActionButton(
                    context: context,
                    label: 'Summerize Chat',
                    onPressed: () {
                      _selectAndPop(AiActions.summerize);
                    },
                  ),
                  _buildActionButton(
                    context: context,
                    label: 'Get Safety Tip',
                    onPressed: () {},
                  ),
                  _buildActionButton(
                    context: context,
                    label: 'Identify Risks',
                    onPressed: () {},
                  ),
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
