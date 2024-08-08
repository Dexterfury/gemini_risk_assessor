import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_reactions/utilities/hero_dialog_route.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/discussions/contact_discussion_message.dart';
import 'package:gemini_risk_assessor/discussions/message_widget.dart';
import 'package:gemini_risk_assessor/discussions/my_discussion_message.dart';
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
import 'package:gemini_risk_assessor/utilities/global.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_chat_reactions/flutter_chat_reactions.dart';

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
      for (var change in snapshot.docChanges) {
        final messageData = change.doc.data() as Map<String, dynamic>;
        final message = DiscussionMessage.fromMap(messageData);

        setState(() {
          switch (change.type) {
            case DocumentChangeType.added:
              _handleAddedMessage(message);
              break;
            case DocumentChangeType.modified:
              _handleModifiedMessage(message);
              break;
            case DocumentChangeType.removed:
              _handleRemovedMessage(message);
              break;
          }
        });
      }
    });
  }

  void _handleAddedMessage(DiscussionMessage message) {
    if (!_messages.any((m) => m.messageID == message.messageID)) {
      _messages.insert(0, message);
      _messages.sort((a, b) => b.timeSent.compareTo(a.timeSent));
    }
  }

  void _handleModifiedMessage(DiscussionMessage updatedMessage) {
    final index =
        _messages.indexWhere((m) => m.messageID == updatedMessage.messageID);
    if (index != -1) {
      _messages[index] = updatedMessage;
    }
  }

  void _handleRemovedMessage(DiscussionMessage message) {
    _messages.removeWhere((m) => m.messageID == message.messageID);
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
    }
  }

  @override
  Widget build(BuildContext context) {
    // current user uid
    final userModel = context.read<AuthenticationProvider>().userModel!;
    final discussionChatProvider = context.read<DiscussionChatProvider>();
    final itemID =
        widget.tool != null ? widget.tool!.id : widget.assessment!.id;
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
      itemCount: _messages.length + 1,
      reverse: true,
      itemBuilder: (context, index) {
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
            _buildMessageItem(
              message,
              userModel,
              discussionChatProvider,
              itemID,
              widget.generationType,
            ),
          ],
        );
      },
    );
  }

  Widget _buildMessageItem(
    DiscussionMessage message,
    UserModel userModel,
    DiscussionChatProvider discussionChatProvider,
    String itemID,
    GenerationType generationType,
  ) {
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
      onLongPress: () {
        if (message.messageType == MessageType.quiz.name ||
            message.messageType == MessageType.quizAnswer.name) {
          return;
        }
        _openReactionsMenu(
          context,
          message,
          userModel,
          widget.groupID,
          itemID,
          isMe,
          generationType,
        );
      },
      child: Hero(
        tag: message.messageID,
        child: MessageWidget(
          message: message,
          isMe: isMe,
          currentUserUID: userModel.uid,
          onRightSwipe: () {
            final messageReply = MessageReply(
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

void _openReactionsMenu(
  BuildContext context,
  DiscussionMessage message,
  UserModel userModel,
  String groupID,
  String itemID,
  bool isMe,
  GenerationType generationType,
) {
  Navigator.of(context).push(
    HeroDialogRoute(builder: (context) {
      return ReactionsDialogWidget(
        id: message.messageID,
        messageWidget: isMe
            ? MyDiscussionMessage(
                message: message,
              )
            : ContactDiscussionMessage(
                message: message,
              ),
        onReactionTap: (reaction) {
          if (reaction == '➕') {
            showEmojiContainer(
              uid: userModel.uid,
              groupID: groupID,
              itemID: itemID,
              context: context,
              message: message,
            );
          } else {
            sendReactionToMessage(
              senderUID: userModel.uid,
              groupID: groupID,
              itemID: itemID,
              reaction: reaction,
              message: message,
            );
          }
        },
        onContextMenuTap: (item) {
          onContextMenuClicked(
            context: context,
            item: item.label,
            message: message,
            currentUID: userModel.uid,
            groupID: groupID,
            itemID: itemID,
            generationType: generationType,
          );
        },
        widgetAlignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      );
    }),
  );
}

void onContextMenuClicked({
  required BuildContext context,
  required String item,
  required DiscussionMessage message,
  required String currentUID,
  required String groupID,
  required String itemID,
  required GenerationType generationType,
}) async {
  switch (item) {
    case 'Reply':
      final discussionChatProvider =
          Provider.of<DiscussionChatProvider>(context, listen: false);
      final messageReply = MessageReply(
        message: message.message,
        senderUID: message.senderUID,
        senderName: message.senderName,
        senderImage: message.senderImage,
        messageType: message.messageType,
      );
      discussionChatProvider.setMessageReplyModel(messageReply);
      break;
    case 'Copy':
      await Clipboard.setData(ClipboardData(text: message.message));
      if (context.mounted) {
        showSnackBar(context: context, message: 'Message copied');
      }
      break;
    case 'Delete':
      bool isAdmin = false;
      if (groupID.isNotEmpty) {
        isAdmin = await FirebaseMethods.checkIsAdmin(groupID, currentUID);
      }
      final isSender = message.senderUID == currentUID;
      final isSenderOrAdmin = isAdmin || isSender;

      if (context.mounted) {
        showDeleteBottomSheet(
          context: context,
          message: message,
          groupID: groupID,
          itemID: itemID,
          currentUID: currentUID,
          isSenderOrAdmin: isSenderOrAdmin,
          generationType: generationType,
        );
      }
      break;
    default:
      print('Unhandled menu item: $item');
  }
}

void showDeleteBottomSheet({
  required BuildContext context,
  required DiscussionMessage message,
  required String groupID,
  required String itemID,
  required String currentUID,
  required bool isSenderOrAdmin,
  required GenerationType generationType,
}) {
  showModalBottomSheet(
    context: context,
    isDismissible: false,
    builder: (BuildContext bottomSheetContext) {
      return Consumer<DiscussionChatProvider>(
        builder: (BuildContext providerContext,
            DiscussionChatProvider chatProvider, Widget? child) {
          return SafeArea(
            child: SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 20.0,
                  horizontal: 20.0,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (chatProvider.isLoading) const LinearProgressIndicator(),
                    ListTile(
                      leading: const Icon(Icons.delete),
                      title: const Text('Delete for me'),
                      onTap: chatProvider.isLoading
                          ? null
                          : () => _handleDelete(
                                bottomSheetContext,
                                chatProvider,
                                currentUID,
                                message,
                                groupID,
                                itemID,
                                false,
                                generationType,
                              ),
                    ),
                    if (isSenderOrAdmin)
                      ListTile(
                        leading: const Icon(Icons.delete_forever),
                        title: const Text('Delete for everyone'),
                        onTap: chatProvider.isLoading
                            ? null
                            : () => _handleDelete(
                                  bottomSheetContext,
                                  chatProvider,
                                  currentUID,
                                  message,
                                  groupID,
                                  itemID,
                                  true,
                                  generationType,
                                ),
                      ),
                    ListTile(
                      leading: const Icon(Icons.cancel),
                      title: const Text('Cancel'),
                      onTap: chatProvider.isLoading
                          ? null
                          : () {
                              Navigator.pop(bottomSheetContext);
                            },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

Future<void> _handleDelete(
  BuildContext context,
  DiscussionChatProvider chatProvider,
  String currentUID,
  DiscussionMessage message,
  String groupID,
  String itemID,
  bool deleteForEveryone,
  GenerationType generationType,
) async {
  try {
    await chatProvider.deleteMessage(
      currentUID: currentUID,
      message: message,
      groupID: groupID,
      itemID: itemID,
      deleteForEveryone: deleteForEveryone,
      generationType: generationType,
    );
  } catch (e) {
    print('Error deleting message: $e');
  } finally {
    if (context.mounted) {
      Navigator.pop(context);
    }
  }
}

void showEmojiContainer({
  required String uid,
  required String groupID,
  required String itemID,
  required BuildContext context,
  required DiscussionMessage message,
}) {
  showModalBottomSheet(
    context: context,
    builder: (context) => SizedBox(
      height: 300,
      child: EmojiPicker(
        onEmojiSelected: (category, emoji) {
          Navigator.pop(context);
          // add emoji to message
          sendReactionToMessage(
            senderUID: uid,
            groupID: groupID,
            itemID: itemID,
            reaction: emoji.emoji,
            message: message,
          );
        },
      ),
    ),
  );
}

void sendReactionToMessage({
  required String senderUID,
  required String groupID,
  required String itemID,
  required String reaction,
  required DiscussionMessage message,
}) {
  FirebaseMethods.addReactionToMessage(
    senderUID: senderUID,
    reaction: reaction,
    groupID: groupID,
    itemID: itemID,
    message: message,
    generationType: GenerationType.riskAssessment,
  );
}
