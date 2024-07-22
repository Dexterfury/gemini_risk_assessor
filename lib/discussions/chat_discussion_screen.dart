import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gemini_risk_assessor/buttons/animated_chat_button.dart';
import 'package:gemini_risk_assessor/discussions/chat_list.dart';
import 'package:gemini_risk_assessor/discussions/discussion_chat_field.dart';
import 'package:gemini_risk_assessor/enums/enums.dart';
import 'package:gemini_risk_assessor/models/assessment_model.dart';

class ChatDiscussionScreen extends StatefulWidget {
  const ChatDiscussionScreen({
    super.key,
    required this.assessment,
    required this.generationType,
  });

  final AssessmentModel assessment;
  final GenerationType generationType;

  @override
  State<ChatDiscussionScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatDiscussionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: BackButton(),
        title: Row(
          children: [
            CircleAvatar(),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.assessment.title,
                ),
                Text(
                  widget.assessment.summary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              // See assessment details
            },
            icon: Icon(FontAwesomeIcons.info),
          ),
          GeminiFloatingChatButton(
            onPressed: () {},
            size: ChatButtonSize.small,
            iconColor: Colors.white,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: ChatList(
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
