import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/appBars/discussion_app_bar.dart';
import 'package:gemini_risk_assessor/buttons/animated_chat_button.dart';
import 'package:gemini_risk_assessor/discussions/chat_list.dart';
import 'package:gemini_risk_assessor/discussions/discussion_chat_field.dart';
import 'package:gemini_risk_assessor/enums/enums.dart';
import 'package:gemini_risk_assessor/models/assessment_model.dart';

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
  @override
  Widget build(BuildContext context) {
    final appBarTitle = widget.assessment.title;
    final appBarSubtitle = widget.assessment.summary;
    final appBarImage = widget.assessment.images[0];
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
                onPressed: () {},
                size: ChatButtonSize.small,
                iconColor: Colors.white,
              ),
            )
          ]),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
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
              assessment: widget.assessment,
              generationType: widget.generationType,
            ),
          ],
        ),
      ),
    );
  }
}
