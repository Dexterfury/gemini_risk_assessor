import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/discussions/message_widget.dart';
import 'package:gemini_risk_assessor/enums/enums.dart';
import 'package:gemini_risk_assessor/firebase_methods/firebase_methods.dart';
import 'package:gemini_risk_assessor/models/assessment_model.dart';
import 'package:gemini_risk_assessor/discussions/discussion_message.dart';
import 'package:gemini_risk_assessor/models/message_reply_model.dart';
import 'package:gemini_risk_assessor/providers/authentication_provider.dart';
import 'package:gemini_risk_assessor/providers/discussion_chat_provider.dart';
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

  // void onContextMenyClicked(
  //     {required String item, required MessageModel message}) {
  //   switch (item) {
  //     case 'Reply':
  //       // set the message reply to true
  //       final messageReply = MessageReplyModel(
  //         message: message.message,
  //         senderUID: message.senderUID,
  //         senderName: message.senderName,
  //         senderImage: message.senderImage,
  //         messageType: message.messageType,
  //         isMe: true,
  //       );

  //       context.read<ChatProvider>().setMessageReplyModel(messageReply);
  //       break;
  //     case 'Copy':
  //       // copy message to clipboard
  //       Clipboard.setData(ClipboardData(text: message.message));
  //       showSnackBar(context, 'Message copied to clipboard');
  //       break;
  //     case 'Delete':
  //       final currentUserId =
  //           context.read<AuthenticationProvider>().userModel!.uid;
  //       final groupProvider = context.read<GroupProvider>();

  //       if (widget.groupId.isNotEmpty) {
  //         if (groupProvider.isSenderOrAdmin(
  //             message: message, uid: currentUserId)) {
  //           showDeletBottomSheet(
  //             message: message,
  //             currentUserId: currentUserId,
  //             isSenderOrAdmin: true,
  //           );
  //           return;
  //         } else {
  //           showDeletBottomSheet(
  //             message: message,
  //             currentUserId: currentUserId,
  //             isSenderOrAdmin: false,
  //           );
  //           return;
  //         }
  //       }
  //       showDeletBottomSheet(
  //         message: message,
  //         currentUserId: currentUserId,
  //         isSenderOrAdmin: true,
  //       );
  //       break;
  //   }
  // }

  // void showDeletBottomSheet({
  //   required MessageModel message,
  //   required String currentUserId,
  //   required bool isSenderOrAdmin,
  // }) {
  //   showModalBottomSheet(
  //       context: context,
  //       isDismissible: false,
  //       builder: (context) {
  //         return Consumer<ChatProvider>(
  //             builder: (context, chatProvider, child) {
  //           return SizedBox(
  //             width: double.infinity,
  //             child: Padding(
  //               padding: const EdgeInsets.symmetric(
  //                 vertical: 20.0,
  //                 horizontal: 20.0,
  //               ),
  //               child: Column(
  //                 mainAxisSize: MainAxisSize.min,
  //                 children: [
  //                   if (chatProvider.isLoading) const LinearProgressIndicator(),
  //                   ListTile(
  //                     leading: const Icon(Icons.delete),
  //                     title: const Text('Delete for me'),
  //                     onTap: chatProvider.isLoading
  //                         ? null
  //                         : () async {
  //                             await chatProvider
  //                                 .deleteMessage(
  //                               currentUserId: currentUserId,
  //                               contactUID: widget.contactUID,
  //                               messageId: message.messageId,
  //                               messageType: message.messageType.name,
  //                               isGroupChat: widget.groupId.isNotEmpty,
  //                               deleteForEveryone: false,
  //                             )
  //                                 .whenComplete(() {
  //                               Navigator.pop(context);
  //                             });
  //                           },
  //                   ),
  //                   isSenderOrAdmin
  //                       ? ListTile(
  //                           leading: const Icon(Icons.delete_forever),
  //                           title: const Text('Delete for everyone'),
  //                           onTap: chatProvider.isLoading
  //                               ? null
  //                               : () async {
  //                                   await chatProvider
  //                                       .deleteMessage(
  //                                     currentUserId: currentUserId,
  //                                     contactUID: widget.contactUID,
  //                                     messageId: message.messageId,
  //                                     messageType: message.messageType.name,
  //                                     isGroupChat: widget.groupId.isNotEmpty,
  //                                     deleteForEveryone: true,
  //                                   )
  //                                       .whenComplete(() {
  //                                     Navigator.pop(context);
  //                                   });
  //                                 },
  //                         )
  //                       : const SizedBox.shrink(),
  //                   ListTile(
  //                     leading: const Icon(Icons.cancel),
  //                     title: const Text('cancel'),
  //                     onTap: chatProvider.isLoading
  //                         ? null
  //                         : () {
  //                             Navigator.pop(context);
  //                           },
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           );
  //         });
  //       });
  // }

  // void sendReactionToMessage(
  //     {required String reaction, required String messageId}) {
  //   // get the sender uid
  //   final senderUID = context.read<AuthenticationProvider>().userModel!.uid;

  //   context.read<ChatProvider>().sendReactionToMessage(
  //         senderUID: senderUID,
  //         contactUID: widget.contactUID,
  //         messageId: messageId,
  //         reaction: reaction,
  //         groupId: widget.groupId.isNotEmpty,
  //       );
  // }

  // void showEmojiContainer({required String messageId}) {
  //   showModalBottomSheet(
  //     context: context,
  //     builder: (context) => SizedBox(
  //       height: 300,
  //       child: EmojiPicker(
  //         onEmojiSelected: (category, emoji) {
  //           Navigator.pop(context);
  //           // add emoji to message
  //           sendReactionToMessage(
  //             reaction: emoji.emoji,
  //             messageId: messageId,
  //           );
  //         },
  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    // current user uid
    final uid = context.read<AuthenticationProvider>().userModel!.uid;
    return StreamBuilder<List<DiscussionMessage>>(
      stream: FirebaseMethods.getMessagesStream(
        groupID: widget.groupID,
        itemID: widget.assessment.id,
        generationType: widget.generationType,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
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
                currentUserId: uid,
                groupID: widget.assessment.groupID,
                messageID: message.messageID,
                itemID: widget.assessment.id,
                isSeenByList: message.seenBy,
                generationType: widget.generationType,
              );

              // check if we sent the last message
              final isMe = element.senderUID == uid;
              // if the deletedBy contains the current user id then dont show the message
              bool deletedByCurrentUser = message.deletedBy.contains(uid);
              return deletedByCurrentUser
                  ? const SizedBox.shrink()
                  : GestureDetector(
                      onLongPress: () async {
                        // Navigator.of(context).push(
                        //   HeroDialogRoute(builder: (context) {
                        //     return ReactionsDialogWidget(
                        //       id: element.messageId,
                        //       messageWidget: isMe
                        //           ? AlignMessageRightWidget(
                        //               message: message,
                        //               viewOnly: true,
                        //               isGroupChat: widget.groupId.isNotEmpty,
                        //             )
                        //           : AlignMessageLeftWidget(
                        //               message: message,
                        //               viewOnly: true,
                        //               isGroupChat: widget.groupId.isNotEmpty,
                        //             ),
                        //       onReactionTap: (reaction) {
                        //         if (reaction == '➕') {
                        //           showEmojiContainer(
                        //             messageId: element.messageId,
                        //           );
                        //         } else {
                        //           sendReactionToMessage(
                        //             reaction: reaction,
                        //             messageId: element.messageId,
                        //           );
                        //         }
                        //       },
                        //       onContextMenuTap: (item) {
                        //         onContextMenyClicked(
                        //           item: item.label,
                        //           message: message,
                        //         );
                        //       },
                        //       widgetAlignment: isMe
                        //           ? Alignment.centerRight
                        //           : Alignment.centerLeft,
                        //     );
                        //   }),
                        // );
                      },
                      child: Hero(
                        tag: element.messageID,
                        child: MessageWidget(
                          message: element,
                          onRightSwipe: () {
                            // set the message reply to true
                            final messageReply = MessageReplyModel(
                              message: element.message,
                              senderUID: element.senderUID,
                              senderName: element.senderName,
                              senderImage: element.senderImage,
                              messageType: element.messageType,
                              isMe: isMe,
                            );

                            context
                                .read<DiscussionChatProvider>()
                                .setMessageReplyModel(messageReply);
                          },
                          isMe: isMe,
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
