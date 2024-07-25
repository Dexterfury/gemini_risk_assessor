import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/discussions/message_widget.dart';
import 'package:gemini_risk_assessor/enums/enums.dart';
import 'package:gemini_risk_assessor/firebase_methods/firebase_methods.dart';
import 'package:gemini_risk_assessor/models/assessment_model.dart';
import 'package:gemini_risk_assessor/discussions/discussion_message.dart';
import 'package:gemini_risk_assessor/models/message_reply_model.dart';
import 'package:gemini_risk_assessor/providers/authentication_provider.dart';
import 'package:gemini_risk_assessor/discussions/discussion_chat_provider.dart';
import 'package:gemini_risk_assessor/themes/my_themes.dart';
import 'package:gemini_risk_assessor/utilities/global.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:provider/provider.dart';

class ChatList extends StatefulWidget {
  const ChatList({
    super.key,
    required this.groupID,
    required this.assessment,
    required this.generationType,
  });
  final String groupID;
  final AssessmentModel assessment;
  final GenerationType generationType;

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  // scroll controller
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // current user uid
    final userModel = context.read<AuthenticationProvider>().userModel!;
    final discussionChatProvider = context.read<DiscussionChatProvider>();
    return StreamBuilder<List<DiscussionMessage>>(
      stream: FirebaseMethods.getMessagesStream(
        groupID: widget.groupID,
        itemID: widget.assessment.id,
        generationType: widget.generationType,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          log('snapshort error: ${snapshot.error}');
          return const Center(
            child: Text(
              'Something went wrong',
              textAlign: TextAlign.center,
              style: textStyle18Bold,
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              'Send the first message',
              textAlign: TextAlign.center,
              style: textStyle18Bold,
            ),
          );
        }

        // automatically scroll to the bottom on new message
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollController.animateTo(
            _scrollController.position.minScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
          );
        });
        if (snapshot.hasData) {
          final messagesList = snapshot.data!;
          return GroupedListView<dynamic, DateTime>(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            reverse: true,
            controller: _scrollController,
            elements: messagesList,
            groupBy: (element) {
              return DateTime(
                element.timeSent!.year,
                element.timeSent!.month,
                element.timeSent!.day,
              );
            },
            groupHeaderBuilder: (dynamic groupedByValue) =>
                SizedBox(height: 40, child: buildDateTime(groupedByValue)),
            itemBuilder: (context, dynamic element) {
              final message = element as DiscussionMessage;

              // set seen by
              FirebaseMethods.setMessageStatus(
                currentUserId: userModel.uid,
                groupID: widget.groupID,
                messageID: message.messageID,
                itemID: widget.assessment.id,
                isSeenByList: message.seenBy,
                generationType: widget.generationType,
              );

              // check if we sent the last message
              final isMe = element.senderUID == userModel.uid;
              // if the deletedBy contains the current user id then dont show the message
              bool deletedByCurrentUser =
                  message.deletedBy.contains(userModel.uid);
              return deletedByCurrentUser
                  ? const SizedBox.shrink()
                  : GestureDetector(
                      onTap: () {
                        log('type: ${message.messageType}');
                      },
                      child: Hero(
                        tag: element.messageID,
                        child: MessageWidget(
                          message: element,
                          isMe: isMe,
                          currentUserUID: userModel.uid,
                          onRightSwipe: () {
                            // set the message reply to true
                            final messageReply = MessageReplyModel(
                              message: element.message,
                              senderUID: element.senderUID,
                              senderName: element.senderName,
                              senderImage: element.senderImage,
                              messageType: element.messageType,
                            );

                            context
                                .read<DiscussionChatProvider>()
                                .setMessageReplyModel(messageReply);
                          },
                          onSubmitQuizResult: (messageID, reults) async {
                            discussionChatProvider.updateQuiz(
                              currentUser: userModel,
                              groupID: widget.groupID,
                              messageID: messageID,
                              itemID: widget.assessment.id,
                              generationType: widget.generationType,
                              quizData: message.quizData,
                              quizResults: reults,
                            );
                          },
                        ),
                      ),
                    );
            },
            groupComparator: (value1, value2) => value2.compareTo(value1),
            itemComparator: (item1, item2) {
              var firstItem = item1.timeSent;

              var secondItem = item2.timeSent;

              return secondItem!.compareTo(firstItem!);
            }, // optional
            useStickyGroupSeparators: true, // optional
            floatingHeader: true, // optional
            order: GroupedListOrder.ASC, // optional
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
