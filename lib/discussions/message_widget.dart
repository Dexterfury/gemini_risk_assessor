import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/discussions/contact_discussion_message.dart';
import 'package:gemini_risk_assessor/discussions/my_discussion_message.dart';
import 'package:gemini_risk_assessor/discussions/discussion_message.dart';
import 'package:swipe_to/swipe_to.dart';

class MessageWidget extends StatelessWidget {
  const MessageWidget({
    super.key,
    required this.message,
    required this.onRightSwipe,
    required this.isMe,
  });

  final DiscussionMessage message;
  final Function() onRightSwipe;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return SwipeTo(
        onRightSwipe: (details) {
          onRightSwipe();
        },
        child: isMe
            ? MyDiscussionMessage(
                message: message,
              )
            : ContactDiscussionMessage(
                message: message,
              ));
  }
}
