import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/discussions/display_message_type.dart';
import 'package:gemini_risk_assessor/enums/enums.dart';
import 'package:gemini_risk_assessor/discussions/discussion_message.dart';
import 'package:gemini_risk_assessor/models/message_reply_model.dart';
import 'package:gemini_risk_assessor/discussions/discussion_chat_provider.dart';
import 'package:gemini_risk_assessor/auth/authentication_provider.dart';
import 'package:gemini_risk_assessor/utilities/global.dart';
import 'package:provider/provider.dart';

class MessageReplyPreview extends StatelessWidget {
  const MessageReplyPreview({
    super.key,
    this.replyMessageModel,
    this.message,
    this.viewOnly = false,
    this.textColor = Colors.white,
  });

  final MessageReply? replyMessageModel;
  final DiscussionMessage? message;
  final bool viewOnly;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final discussionChatProvider = context.read<DiscussionChatProvider>();
    final uid = context.read<AuthenticationProvider>().userModel!.uid;
    final type = replyMessageModel != null
        ? replyMessageModel!.messageType
        : message!.messageType;

    final intrisitPadding = replyMessageModel != null
        ? const EdgeInsets.all(10)
        : const EdgeInsets.only(top: 5, right: 5, bottom: 5);

    final decorationColor = replyMessageModel != null
        ? Theme.of(context).textTheme.titleLarge!.color!.withOpacity(0.1)
        : Theme.of(context).primaryColorDark.withOpacity(0.2);
    return IntrinsicHeight(
      child: Container(
        padding: intrisitPadding,
        decoration: BoxDecoration(
          color: decorationColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
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
            Expanded(
              child: buildNameAndMessage(
                type,
                uid,
                textColor,
              ),
            ),
            replyMessageModel != null
                ? closeButton(discussionChatProvider, context)
                : const SizedBox(),
          ],
        ),
      ),
    );
  }

  InkWell closeButton(
    DiscussionChatProvider chatProvider,
    BuildContext context,
  ) {
    return InkWell(
      onTap: () {
        chatProvider.setMessageReplyModel(null);
      },
      child: Container(
          decoration: BoxDecoration(
            color:
                Theme.of(context).textTheme.titleLarge!.color!.withOpacity(0.1),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: Theme.of(context).textTheme.titleLarge!.color!,
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(2),
          child: const Icon(Icons.close)),
    );
  }

  Column buildNameAndMessage(MessageType type, String uid, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        getTitle(uid),
        const SizedBox(height: 5),
        replyMessageModel != null
            ? messageToShow(
                type: type,
                message: replyMessageModel!.message,
              )
            : DisplayMessageType(
                message: message!.repliedMessage.message,
                type: message!.repliedMessage.messageType,
                color: textColor,
                isReply: true,
                maxLines: 2,
                overFlow: TextOverflow.ellipsis,
                viewOnly: viewOnly,
              ),
      ],
    );
  }

  Widget getTitle(String uid) {
    if (replyMessageModel != null) {
      bool isMe = replyMessageModel!.senderUID == uid;
      return Text(
        isMe ? 'You' : replyMessageModel!.senderName,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
        overflow: TextOverflow.ellipsis,
      );
    } else {
      final isMe = message!.repliedMessage.senderUID == uid;
      return Text(
        isMe ? 'You' : message!.repliedMessage.senderName,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
        overflow: TextOverflow.ellipsis,
      );
    }
  }
}
