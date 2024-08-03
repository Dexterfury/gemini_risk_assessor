import 'package:flutter/material.dart';
import 'package:flutter_chat_reactions/widgets/stacked_reactions.dart';
import 'package:gemini_risk_assessor/discussions/display_message_type.dart';
import 'package:gemini_risk_assessor/discussions/message_reply_preview.dart';
import 'package:gemini_risk_assessor/enums/enums.dart';
import 'package:gemini_risk_assessor/discussions/discussion_message.dart';
import 'package:gemini_risk_assessor/widgets/display_user_image.dart';
import 'package:intl/intl.dart';

class ContactDiscussionMessage extends StatelessWidget {
  const ContactDiscussionMessage({
    super.key,
    required this.message,
    this.viewOnly = false,
  });

  final DiscussionMessage message;
  final bool viewOnly;

  @override
  Widget build(BuildContext context) {
    final time = DateFormat('hh:mm a').format(message.timeSent);
    final isReplying = message.repliedTo.isNotEmpty;
    // get the reations from the list
    final messageReations =
        message.reactions.map((e) => e.split('=')[1]).toList();
    // check if its dark mode
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final padding = message.reactions.isNotEmpty
        ? const EdgeInsets.only(right: 20.0, bottom: 25.0)
        : const EdgeInsets.only(bottom: 0.0);
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
          minWidth: MediaQuery.of(context).size.width * 0.3,
        ),
        child: Row(
          children: [
            DisplayUserImage(
              radius: 20,
              isViewOnly: true,
              fileImage: null,
              imageUrl: message.senderImage,
              onPressed: () {},
            ),
            Expanded(
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
                          bottomRight: Radius.circular(15),
                        ),
                      ),
                      color: Colors.grey[isDarkMode ? 800 : 200],
                      child: Padding(
                        padding: message.messageType == MessageType.text
                            ? const EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 10.0)
                            : const EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 10.0),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                color: isDarkMode ? Colors.white : Colors.black,
                                isReply: false,
                                viewOnly: viewOnly,
                              ),
                              Text(
                                time,
                                style: TextStyle(
                                    color: isDarkMode
                                        ? Colors.white60
                                        : Colors.grey.shade500,
                                    fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 50,
                    child: StackedReactions(
                      reactions: messageReations,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
