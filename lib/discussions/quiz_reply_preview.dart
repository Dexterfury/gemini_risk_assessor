import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/discussions/discussion_message.dart';

class QuizReplyPreview extends StatelessWidget {
  const QuizReplyPreview({
    super.key,
    required this.message,
    this.viewOnly = false,
  });

  final DiscussionMessage message;
  final bool viewOnly;

  @override
  Widget build(BuildContext context) {
    final intrisitPadding = const EdgeInsets.all(10);
    ;

    final decorationColor = Theme.of(context).primaryColorDark.withOpacity(0.2);
    //Theme.of(context).textTheme.titleLarge!.color!.withOpacity(0.1);
    //Theme.of(context).primaryColorDark.withOpacity(0.2);
    return IntrinsicHeight(
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: intrisitPadding,
        decoration: BoxDecoration(
          color: decorationColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(
              10,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 5,
              decoration: const BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(child: buildTitleAndMessage(message)),
          ],
        ),
      ),
    );
  }

  Column buildTitleAndMessage(DiscussionMessage message) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          message.repliedTo,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blue,
            //fontSize: 12,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          message.repliedMessage,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            //fontSize: 12,
          ),
        ),
      ],
    );
  }
}
