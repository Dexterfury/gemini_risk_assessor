import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_reactions/widgets/stacked_reactions.dart';
import 'package:gemini_risk_assessor/discussions/display_message_type.dart';
import 'package:gemini_risk_assessor/discussions/message_reply_preview.dart';
import 'package:gemini_risk_assessor/enums/enums.dart';
import 'package:gemini_risk_assessor/discussions/discussion_message.dart';
import 'package:gemini_risk_assessor/providers/authentication_provider.dart';
import 'package:provider/provider.dart';

class MyDiscussionMessage extends StatelessWidget {
  const MyDiscussionMessage({
    super.key,
    required this.message,
    this.viewOnly = false,
  });

  final DiscussionMessage message;
  final bool viewOnly;

  @override
  Widget build(BuildContext context) {
    final time = formatDate(message.timeSent, [hh, ':', nn, ' ', am]);
    final isReplying = message.repliedTo.isNotEmpty;
    // get the reations from the list
    final messageReations =
        message.reactions.map((e) => e.split('=')[1]).toList();
    final padding = message.reactions.isNotEmpty
        ? const EdgeInsets.only(left: 20.0, bottom: 25.0)
        : const EdgeInsets.only(bottom: 0.0);

    bool messageSeen() {
      final uid = context.read<AuthenticationProvider>().userModel!.uid;
      bool isSeen = false;
      List<String> isSeenByList = message.seenBy;
      if (isSeenByList.contains(uid)) {
        // remove our uid then check again
        isSeenByList.remove(uid);
      }
      isSeen = isSeenByList.isNotEmpty ? true : false;

      return isSeen;
    }

    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
          //minWidth: MediaQuery.of(context).size.width * 0.3,
        ),
        child: Stack(
          children: [
            Padding(
              padding: padding,
              child: Card(
                elevation: 5,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                    bottomLeft: Radius.circular(15),
                  ),
                ),
                color: Theme.of(context).primaryColor,
                child: Padding(
                  padding: message.messageType == MessageType.text
                      ? const EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 10.0)
                      : const EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 10.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isReplying) ...[
                          MessageReplyPreview(
                            message: message,
                            viewOnly: viewOnly,
                          )
                        ],
                        DisplayMessageType(
                          message: message.message,
                          type: message.messageType,
                          color: Colors.white,
                          isReply: false,
                          viewOnly: viewOnly,
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              time,
                              style: const TextStyle(
                                color: Colors.white60,
                                fontSize: 10,
                              ),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Icon(
                              messageSeen() ? Icons.done_all : Icons.done,
                              color:
                                  messageSeen() ? Colors.green : Colors.white60,
                              size: 15,
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 4,
              right: 30,
              child: StackedReactions(
                reactions: messageReations,
              ),
            )
          ],
        ),
      ),
    );
  }
}
