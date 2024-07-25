import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/discussions/contact_discussion_message.dart';
import 'package:gemini_risk_assessor/discussions/discussion_message.dart';
import 'package:gemini_risk_assessor/discussions/my_discussion_message.dart';
import 'package:gemini_risk_assessor/discussions/quiz_widget.dart';
import 'package:swipe_to/swipe_to.dart';

class MessageWidget extends StatelessWidget {
  const MessageWidget({
    super.key,
    required this.message,
    required this.isMe,
    required this.currentUserUID,
    required this.onRightSwipe,
    required this.onSubmitQuizResult,
  });

  final DiscussionMessage message;
  final bool isMe;
  final String currentUserUID;
  final Function() onRightSwipe;
  final Function(String messageID, Map<String, dynamic>) onSubmitQuizResult;

  Widget _buildMessageWidget() {
    if (message.quizData.isNotEmpty) {
      return QuizWidget(
        quizData: message.quizData,
        userUID: currentUserUID,
        onSubmit: (result) {
          onSubmitQuizResult(message.messageID, result);
        },
        quizResults: message.quizResults,
      );
    } else {
      return _buildSwipeWidget();
    }
  }

  Widget _buildSwipeWidget() {
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
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildMessageWidget();
  }
}
