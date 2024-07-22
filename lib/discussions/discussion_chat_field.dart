import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/discussions/message_reply_preview.dart';
import 'package:gemini_risk_assessor/enums/enums.dart';
import 'package:gemini_risk_assessor/models/assessment_model.dart';
import 'package:gemini_risk_assessor/providers/authentication_provider.dart';
import 'package:gemini_risk_assessor/providers/discussion_chat_provider.dart';
import 'package:provider/provider.dart';

class DiscussionChatField extends StatefulWidget {
  const DiscussionChatField({
    super.key,
    required this.assessment,
    required this.generationType,
  });

  final AssessmentModel assessment;
  final GenerationType generationType;

  @override
  State<DiscussionChatField> createState() => _BottomChatFieldState();
}

class _BottomChatFieldState extends State<DiscussionChatField> {
  //FlutterSoundRecord? _soundRecord;
  late TextEditingController _textEditingController;
  late FocusNode _focusNode;
  //File? finalFileImage;
  //String filePath = '';

  // bool isRecording = false;
  // bool isShowSendButton = false;
  // bool isSendingAudio = false;
  // bool isShowEmojiPicker = false;

  // hide emoji container
  // void hideEmojiContainer() {
  //   setState(() {
  //     isShowEmojiPicker = false;
  //   });
  // }

  // // show emoji container
  // void showEmojiContainer() {
  //   setState(() {
  //     isShowEmojiPicker = true;
  //   });
  // }

  // show keyboard
  void showKeyBoard() {
    _focusNode.requestFocus();
  }

  // hide keyboard
  void hideKeyNoard() {
    _focusNode.unfocus();
  }

  // toggle emoji and keyboard container
  // void toggleEmojiKeyboardContainer() {
  //   if (isShowEmojiPicker) {
  //     showKeyBoard();
  //     hideEmojiContainer();
  //   } else {
  //     hideKeyNoard();
  //     showEmojiContainer();
  //   }
  // }

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

  // check microphone permission
  // Future<bool> checkMicrophonePermission() async {
  //   bool hasPermission = await Permission.microphone.isGranted;
  //   final status = await Permission.microphone.request();
  //   if (status == PermissionStatus.granted) {
  //     hasPermission = true;
  //   } else {
  //     hasPermission = false;
  //   }

  //   return hasPermission;
  // }

  // // start recording audio
  // void startRecording() async {
  //   final hasPermission = await checkMicrophonePermission();
  //   if (hasPermission) {
  //     var tempDir = await getTemporaryDirectory();
  //     filePath = '${tempDir.path}/flutter_sound.aac';
  //     await _soundRecord!.start(
  //       path: filePath,
  //     );
  //     setState(() {
  //       isRecording = true;
  //     });
  //   }
  // }

  // // stop recording audio
  // void stopRecording() async {
  //   await _soundRecord!.stop();
  //   setState(() {
  //     isRecording = false;
  //     isSendingAudio = true;
  //   });
  //   // send audio message to firestore
  //   sendFileMessage(
  //     messageType: MessageEnum.audio,
  //   );
  // }

  // void selectImage(bool fromCamera) async {
  //   finalFileImage = await pickImage(
  //     fromCamera: fromCamera,
  //     onFail: (String message) {
  //       showSnackBar(context, message);
  //     },
  //   );

  //   // crop image
  //   await cropImage(finalFileImage?.path);

  //   popContext();
  // }

  // select a video file from device
  // void selectVideo() async {
  //   File? fileVideo = await pickVideo(
  //     onFail: (String message) {
  //       showSnackBar(context, message);
  //     },
  //   );

  //   popContext();

  //   if (fileVideo != null) {
  //     filePath = fileVideo.path;
  //     // send video message to firestore
  //     sendFileMessage(
  //       messageType: MessageEnum.video,
  //     );
  //   }
  // }

  // popContext() {
  //   Navigator.pop(context);
  // }

  // Future<void> cropImage(croppedFilePath) async {
  //   if (croppedFilePath != null) {
  //     CroppedFile? croppedFile = await ImageCropper().cropImage(
  //       sourcePath: croppedFilePath,
  //       maxHeight: 800,
  //       maxWidth: 800,
  //       compressQuality: 90,
  //     );

  //     if (croppedFile != null) {
  //       filePath = croppedFile.path;
  //       // send image message to firestore
  //       sendFileMessage(
  //         messageType: MessageEnum.image,
  //       );
  //     }
  //   }
  // }

  // // send image message to firestore
  // void sendFileMessage({
  //   required MessageEnum messageType,
  // }) {
  //   final currentUser = context.read<AuthenticationProvider>().userModel!;
  //   final chatProvider = context.read<ChatProvider>();

  //   chatProvider.sendFileMessage(
  //     sender: currentUser,
  //     contactUID: widget.contactUID,
  //     contactName: widget.contactName,
  //     contactImage: widget.contactImage,
  //     file: File(filePath),
  //     messageType: messageType,
  //     groupId: widget.groupId,
  //     onSucess: () {
  //       _textEditingController.clear();
  //       _focusNode.unfocus();
  //       setState(() {
  //         isSendingAudio = false;
  //       });
  //     },
  //     onError: (error) {
  //       setState(() {
  //         isSendingAudio = false;
  //       });
  //       showSnackBar(context, error);
  //     },
  //   );
  // }

  // send text message to firestore
  void sendTextMessage() {
    final currentUser = context.read<AuthenticationProvider>().userModel!;
    final chatProvider = context.read<DiscussionChatProvider>();

    // chatProvider.sendTextMessage(
    //     sender: currentUser,
    //     contactUID: widget.contactUID,
    //     contactName: widget.contactName,
    //     contactImage: widget.contactImage,
    //     message: _textEditingController.text,
    //     messageType: MessageEnum.text,
    //     groupId: widget.groupId,
    //     onSucess: () {
    //       _textEditingController.clear();
    //       _focusNode.unfocus();
    //     },
    //     onError: (error) {
    //       showSnackBar(context, error);
    //     });
  }

  @override
  Widget build(BuildContext context) {
    return buildBottomChatField();
  }

  // Widget buildLoackedMessages() {
  //   final uid = context.read<AuthenticationProvider>().userModel!.uid;

  //   final groupProvider = context.read<GroupProvider>();
  //   // check if is admin
  //   final isAdmin = groupProvider.groupModel.adminsUIDs.contains(uid);

  //   // chec if is member
  //   final isMember = groupProvider.groupModel.membersUIDs.contains(uid);

  //   // check is messages are locked
  //   final isLocked = groupProvider.groupModel.lockMessages;
  //   return isAdmin
  //       ? buildBottomChatField()
  //       : isMember
  //           ? buildisMember(isLocked)
  //           : SizedBox(
  //               height: 60,
  //               child: Center(
  //                 child: TextButton(
  //                   onPressed: () async {
  //                     // send request to join group
  //                     await groupProvider
  //                         .sendRequestToJoinGroup(
  //                       groupId: groupProvider.groupModel.groupId,
  //                       uid: uid,
  //                       groupName: groupProvider.groupModel.groupName,
  //                       groupImage: groupProvider.groupModel.groupImage,
  //                     )
  //                         .whenComplete(() {
  //                       showSnackBar(context, 'Request sent');
  //                     });
  //                     print('request to join group');
  //                   },
  //                   child: const Text(
  //                     'You are not a member of this group, \n click here to send request to join',
  //                     style: TextStyle(
  //                       color: Colors.red,
  //                       fontWeight: FontWeight.bold,
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //             );
  // }

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
        return Column(
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
                  Row(
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
                                  color: Colors.blue,
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
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
