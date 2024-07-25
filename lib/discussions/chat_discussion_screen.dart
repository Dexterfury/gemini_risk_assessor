import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_chat_reactions/utilities/hero_dialog_route.dart';
import 'package:gemini_risk_assessor/appBars/discussion_app_bar.dart';
import 'package:gemini_risk_assessor/buttons/animated_chat_button.dart';
import 'package:gemini_risk_assessor/discussions/chat_list.dart';
import 'package:gemini_risk_assessor/discussions/discussion_chat_field.dart';
import 'package:gemini_risk_assessor/discussions/discussion_chat_provider.dart';
import 'package:gemini_risk_assessor/enums/enums.dart';
import 'package:gemini_risk_assessor/models/assessment_model.dart';
import 'package:gemini_risk_assessor/providers/authentication_provider.dart';
import 'package:gemini_risk_assessor/service/gemini_actions.dart';
import 'package:provider/provider.dart';

class ChatDiscussionScreen extends StatefulWidget {
  const ChatDiscussionScreen({
    super.key,
    required this.groupID,
    required this.assessment,
    required this.generationType,
  });
  final String groupID;
  final AssessmentModel assessment;
  final GenerationType generationType;

  @override
  State<ChatDiscussionScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatDiscussionScreen> {
  void showGeminiActions() {
    final discussionsProvider = context.read<DiscussionChatProvider>();
    Navigator.of(context).push(
      HeroDialogRoute(builder: (context) {
        return GeminiActions(
          onTapAction: (AiActions aiAction) async {
            switch (aiAction) {
              case AiActions.safetyQuiz:
                final userModel =
                    context.read<AuthenticationProvider>().userModel!;
                await discussionsProvider.generateQuiz(
                  userModel: userModel,
                  assessment: widget.assessment,
                  groupID: widget.groupID,
                  generationType: widget.generationType,
                );
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
          },
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appBarTitle = widget.assessment.title;
    final appBarSubtitle = widget.assessment.summary;
    final appBarImage =
        widget.assessment.images.isNotEmpty ? widget.assessment.images[0] : '';
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: DiscussionAppBar(
        title: appBarTitle,
        subtitle: appBarSubtitle,
        imageUrl: appBarImage,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GeminiFloatingChatButton(
              onPressed: showGeminiActions,
              size: ChatButtonSize.small,
              iconColor: Colors.white,
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8.0),
          child: Column(
            children: [
              Expanded(
                child: ChatList(
                  groupID: widget.groupID,
                  assessment: widget.assessment,
                  generationType: widget.generationType,
                ),
              ),
              DiscussionChatField(
                groupID: widget.groupID,
                assessment: widget.assessment,
                generationType: widget.generationType,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
