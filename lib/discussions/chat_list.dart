import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/discussions/message_widget.dart';
import 'package:gemini_risk_assessor/enums/enums.dart';
import 'package:gemini_risk_assessor/firebase_methods/firebase_methods.dart';
import 'package:gemini_risk_assessor/models/assessment_model.dart';
import 'package:gemini_risk_assessor/discussions/discussion_message.dart';
import 'package:gemini_risk_assessor/models/message_reply_model.dart';
import 'package:gemini_risk_assessor/authentication/authentication_provider.dart';
import 'package:gemini_risk_assessor/discussions/discussion_chat_provider.dart';
import 'package:gemini_risk_assessor/themes/app_theme.dart';
import 'package:gemini_risk_assessor/tools/tool_model.dart';
import 'package:gemini_risk_assessor/utilities/global.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:provider/provider.dart';

class ChatList extends StatefulWidget {
  const ChatList({
    super.key,
    required this.groupID,
    this.assessment,
    this.tool,
    required this.generationType,
  });
  final String groupID;
  final AssessmentModel? assessment;
  final ToolModel? tool;
  final GenerationType generationType;

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  // scroll controller
  final ScrollController _scrollController = ScrollController();
  List<DiscussionMessage> _messages = [];
  bool _isLoading = false;
  DocumentSnapshot? _lastDocument;
  static const int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      _loadMessages();
    }
  }

  Future<void> _loadMessages() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    final itemID =
        widget.tool != null ? widget.tool!.id : widget.assessment!.id;

    try {
      final newMessages = await FirebaseMethods.getMessages(
        groupID: widget.groupID,
        itemID: itemID,
        generationType: widget.generationType,
        asStream: false,
        limit: _pageSize,
        startAfter: _lastDocument,
      );

      setState(() {
        _messages.addAll(newMessages);
        _isLoading = false;
        if (newMessages.isNotEmpty) {
          _lastDocument = newMessages.last as DocumentSnapshot;
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      log('Error loading messages: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // current user uid
    final userModel = context.read<AuthenticationProvider>().userModel!;
    final discussionChatProvider = context.read<DiscussionChatProvider>();
    final itemID =
        widget.tool != null ? widget.tool!.id : widget.assessment!.id;
    return _messages.isEmpty && _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _messages.isEmpty
            ? Center(
                child: Text(
                  'Send the first message',
                  textAlign: TextAlign.center,
                  style: AppTheme.textStyle18Bold,
                ),
              )
            : GroupedListView<DiscussionMessage, DateTime>(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                reverse: true,
                controller: _scrollController,
                elements: _messages,
                groupBy: (element) => DateTime(
                  element.timeSent.year,
                  element.timeSent.month,
                  element.timeSent.day,
                ),
                groupHeaderBuilder: (dynamic groupedByValue) =>
                    SizedBox(height: 40, child: buildDateTime(groupedByValue)),
                itemBuilder: (context, DiscussionMessage message) {
                  final isMe = message.senderUID == userModel.uid;
                  final deletedByCurrentUser =
                      message.deletedBy.contains(userModel.uid);

                  FirebaseMethods.setMessageStatus(
                    currentUserId: userModel.uid,
                    groupID: widget.groupID,
                    messageID: message.messageID,
                    itemID: itemID,
                    isSeenByList: message.seenBy,
                    generationType: widget.generationType,
                  );

                  return deletedByCurrentUser
                      ? const SizedBox.shrink()
                      : GestureDetector(
                          onTap: () {},
                          child: Hero(
                            tag: message.messageID,
                            child: MessageWidget(
                              message: message,
                              isMe: isMe,
                              currentUserUID: userModel.uid,
                              onRightSwipe: () {
                                final messageReply = MessageReplyModel(
                                  message: message.message,
                                  senderUID: message.senderUID,
                                  senderName: message.senderName,
                                  senderImage: message.senderImage,
                                  messageType: message.messageType,
                                );
                                context
                                    .read<DiscussionChatProvider>()
                                    .setMessageReplyModel(messageReply);
                              },
                              onSubmitQuizResult: (messageID, results) async {
                                discussionChatProvider.updateQuiz(
                                  currentUser: userModel,
                                  groupID: widget.groupID,
                                  messageID: messageID,
                                  itemID: itemID,
                                  generationType: widget.generationType,
                                  quizData: message.quizData,
                                  quizResults: results,
                                );
                              },
                            ),
                          ),
                        );
                },
                groupComparator: (value1, value2) => value2.compareTo(value1),
                itemComparator: (item1, item2) =>
                    item2.timeSent.compareTo(item1.timeSent!),
                useStickyGroupSeparators: true,
                floatingHeader: true,
                order: GroupedListOrder.ASC,
              );
  }
}
