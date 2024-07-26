import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/discussions/message_reply_preview.dart';
import 'package:gemini_risk_assessor/enums/enums.dart';
import 'package:gemini_risk_assessor/models/assessment_model.dart';
import 'package:gemini_risk_assessor/authentication/authentication_provider.dart';
import 'package:gemini_risk_assessor/discussions/discussion_chat_provider.dart';
import 'package:gemini_risk_assessor/tools/tool_model.dart';
import 'package:provider/provider.dart';

class DiscussionChatField extends StatefulWidget {
  const DiscussionChatField({
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
  State<DiscussionChatField> createState() => _BottomChatFieldState();
}

class _BottomChatFieldState extends State<DiscussionChatField> {
  //FlutterSoundRecord? _soundRecord;
  late TextEditingController _textEditingController;
  late FocusNode _focusNode;

  // show keyboard
  void showKeyBoard() {
    _focusNode.requestFocus();
  }

  // hide keyboard
  void hideKeyNoard() {
    _focusNode.unfocus();
  }

  @override
  void initState() {
    _textEditingController = TextEditingController();
    //_soundRecord = FlutterSoundRecord();
    _focusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    //_soundRecord?.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // send text message to firestore
  void sendTextMessage() {
    if (_textEditingController.text.isNotEmpty) {
      final currentUser = context.read<AuthenticationProvider>().userModel!;
      final discussionChatProvider = context.read<DiscussionChatProvider>();
      final itemID =
          widget.tool != null ? widget.tool!.id : widget.assessment!.id;

      discussionChatProvider.sendTextMessage(
        sender: currentUser,
        message: _textEditingController.text,
        messageType: MessageType.text,
        groupID: widget.groupID,
        itemID: itemID,
        isAIMessage: false,
        generationType: widget.generationType,
        onSucess: () {
          // clear controller
          setState(() {
            _textEditingController.clear();
          });
          // remove keyboard focus
          _focusNode.unfocus();
        },
        onError: (error) {},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return buildBottomChatField();
  }

  buildisMember(bool isLocked) {
    return isLocked
        ? const SizedBox(
            height: 50,
            child: Center(
              child: Text(
                'Messages are locked, only admins can send messages',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )
        : buildBottomChatField();
  }

  buildBottomChatField() {
    return Consumer<DiscussionChatProvider>(
      builder: (context, chatProvider, child) {
        final messageReply = chatProvider.messageReplyModel;
        final isMessageReply = messageReply != null;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Theme.of(context).cardColor,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                    )),
                child: Column(
                  children: [
                    if (isMessageReply)
                      MessageReplyPreview(
                        replyMessageModel: messageReply,
                      ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _textEditingController,
                              focusNode: _focusNode,
                              decoration: const InputDecoration.collapsed(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(30),
                                  ),
                                  borderSide: BorderSide.none,
                                ),
                                hintText: 'Type a message',
                              ),
                            ),
                          ),
                          chatProvider.isLoading
                              ? const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: CircularProgressIndicator(),
                                )
                              : GestureDetector(
                                  onTap: sendTextMessage,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30),
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    margin: const EdgeInsets.all(5),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: const Icon(
                                        Icons.arrow_upward,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
