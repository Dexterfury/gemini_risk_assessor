import 'dart:async';
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
import 'package:gemini_risk_assessor/models/user_model.dart';
import 'package:gemini_risk_assessor/themes/app_theme.dart';
import 'package:gemini_risk_assessor/tools/tool_model.dart';
import 'package:intl/intl.dart';
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
  final int _pageSize = 20;
  List<DiscussionMessage> _messages = [];
  bool _isLoading = false;
  DocumentSnapshot? _lastDocument;
  bool _hasMore = true;
  StreamSubscription<QuerySnapshot>? _newMessagesSubscription;

  @override
  void initState() {
    super.initState();
    _loadMoreMessages();
    _scrollController.addListener(_scrollListener);
    _setupNewMessagesStream();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _newMessagesSubscription?.cancel();
    super.dispose();
  }

  void _setupNewMessagesStream() {
    final itemID =
        widget.tool != null ? widget.tool!.id : widget.assessment!.id;
    _newMessagesSubscription = FirebaseMethods.getMessagesStream(
      groupID: widget.groupID,
      itemID: itemID,
      generationType: widget.generationType,
      limit: _pageSize,
    ).listen((snapshot) {
      List<DiscussionMessage> liveMessages = snapshot.docs
          .map((doc) =>
              DiscussionMessage.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      setState(() {
        _messages = _mergeMessages(_messages, liveMessages);
      });
    });
  }

  List<DiscussionMessage> _mergeMessages(List<DiscussionMessage> oldMessages,
      List<DiscussionMessage> newMessages) {
    final allMessageIds = Set<String>.from(oldMessages.map((m) => m.messageID));
    for (var message in newMessages) {
      if (!allMessageIds.contains(message.messageID)) {
        oldMessages.add(message);
        allMessageIds.add(message.messageID);
      }
    }
    oldMessages.sort((a, b) => b.timeSent.compareTo(a.timeSent));
    return oldMessages;
  }

  void _scrollListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      _loadMoreMessages();
    }
  }

  Future<void> _loadMoreMessages() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final itemID =
          widget.tool != null ? widget.tool!.id : widget.assessment!.id;
      final query = FirebaseMethods.getMessagesQuery(
        groupID: widget.groupID,
        itemID: itemID,
        generationType: widget.generationType,
      );

      QuerySnapshot querySnapshot;
      if (_lastDocument == null) {
        querySnapshot = await query.limit(_pageSize).get();
      } else {
        querySnapshot = await query
            .startAfterDocument(_lastDocument!)
            .limit(_pageSize)
            .get();
      }

      final newMessages = querySnapshot.docs
          .map((doc) =>
              DiscussionMessage.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      setState(() {
        _messages = _mergeMessages(_messages, newMessages);
        _isLoading = false;
        if (querySnapshot.docs.isNotEmpty) {
          _lastDocument = querySnapshot.docs.last;
        }
        _hasMore = querySnapshot.docs.length == _pageSize;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error loading messages: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // current user uid
    final userModel = context.read<AuthenticationProvider>().userModel!;
    final discussionChatProvider = context.read<DiscussionChatProvider>();
    if (_messages.isEmpty && !_isLoading) {
      return Center(
        child: Text(
          'No messages yet. Start the conversation!',
          style: TextStyle(
            fontSize: 16,
          ),
        ),
      );
    }
    return ListView.builder(
      controller: _scrollController,
      itemCount: _messages.length + 1, // +1 for the loading indicator
      reverse: true,
      itemBuilder: (context, index) {
        // if (index == _messages.length) {
        //   return _isLoading
        //       ? const Center(child: CircularProgressIndicator())
        //       : _hasMore
        //           ? const SizedBox.shrink()
        //           : const Center(child: Text('No more messages'));
        // }

        if (index == _messages.length) {
          return _isLoading
              ? const Center(child: CircularProgressIndicator())
              : const SizedBox.shrink();
        }

        final message = _messages[index];
        final previousMessage =
            index < _messages.length - 1 ? _messages[index + 1] : null;

        final isDateSeparator = previousMessage == null ||
            !isSameDay(message.timeSent, previousMessage.timeSent);

        return Column(
          children: [
            if (isDateSeparator) _buildDateSeparator(message.timeSent),
            _buildMessageItem(message, userModel, discussionChatProvider),
          ],
        );
      },
    );
  }

  Widget _buildMessageItem(DiscussionMessage message, UserModel userModel,
      DiscussionChatProvider discussionChatProvider) {
    final isMe = message.senderUID == userModel.uid;
    final deletedByCurrentUser = message.deletedBy.contains(userModel.uid);

    if (deletedByCurrentUser) return const SizedBox.shrink();

    FirebaseMethods.setMessageStatus(
      currentUserId: userModel.uid,
      groupID: widget.groupID,
      messageID: message.messageID,
      itemID: widget.tool != null ? widget.tool!.id : widget.assessment!.id,
      isSeenByList: message.seenBy,
      generationType: widget.generationType,
    );

    return GestureDetector(
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
            discussionChatProvider.setMessageReplyModel(messageReply);
          },
          onSubmitQuizResult: (messageID, results) async {
            discussionChatProvider.updateQuiz(
              currentUser: userModel,
              groupID: widget.groupID,
              messageID: messageID,
              itemID:
                  widget.tool != null ? widget.tool!.id : widget.assessment!.id,
              generationType: widget.generationType,
              quizData: message.quizData,
              quizResults: results,
            );
          },
        ),
      ),
    );
  }

  Widget _buildDateSeparator(DateTime date) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          DateFormat('MMMM dd, yyyy').format(date),
          style: AppTheme.textStyle16w600,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
