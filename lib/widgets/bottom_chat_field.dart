import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/enums/enums.dart';
import 'package:gemini_risk_assessor/authentication/authentication_provider.dart';
import 'package:gemini_risk_assessor/providers/chat_provider.dart';
import 'package:gemini_risk_assessor/themes/app_theme.dart';
import 'package:gemini_risk_assessor/widgets/preview_images.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class BottomChatField extends StatefulWidget {
  const BottomChatField({
    super.key,
    required this.chatProvider,
    required this.docID,
    required this.generationType,
  });

  final ChatProvider chatProvider;
  final String docID;
  final GenerationType generationType;

  @override
  State<BottomChatField> createState() => _BottomChatFieldState();
}

class _BottomChatFieldState extends State<BottomChatField> {
  // controller for the input field
  final TextEditingController textController = TextEditingController();

  // focus node for the input field
  final FocusNode textFieldFocus = FocusNode();

  // initialize image picker
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    textController.dispose();
    textFieldFocus.dispose();
    super.dispose();
  }

  Future<void> sendChatMessage({
    required String message,
    required ChatProvider chatProvider,
    required bool isTextOnly,
  }) async {
    final uid = context.read<AuthenticationProvider>().userModel!.uid;
    try {
      await chatProvider.sendMessage(
        uid: uid,
        chatID: widget.docID,
        message: message,
        generationType: widget.generationType,
        onSuccess: () {},
        onError: (onError) {},
      );
    } catch (e) {
      log('error : $e');
    } finally {
      textController.clear();
      widget.chatProvider.setImagesFileList(listValue: []);
      textFieldFocus.unfocus();
    }
  }

  // pick an image
  void pickImage() async {
    try {
      final pickedImages = await _picker.pickMultiImage(
        maxHeight: 800,
        maxWidth: 800,
        imageQuality: 95,
      );
      widget.chatProvider.setImagesFileList(listValue: pickedImages);
    } catch (e) {
      log('error : $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    bool hasImages = widget.chatProvider.imagesFileList != null &&
        widget.chatProvider.imagesFileList!.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: Theme.of(context).cardColor,
          border: Border.all(
            color: Theme.of(context).colorScheme.primary,
          )),
      child: Column(
        children: [
          if (hasImages) const PreviewImages(),
          Row(
            children: [
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: TextField(
                  focusNode: textFieldFocus,
                  controller: textController,
                  textInputAction: TextInputAction.send,
                  onSubmitted: widget.chatProvider.isLoading
                      ? null
                      : (String value) {
                          if (value.isNotEmpty) {
                            // send the message
                            sendChatMessage(
                              message: textController.text,
                              chatProvider: widget.chatProvider,
                              isTextOnly: hasImages ? false : true,
                            );
                          }
                        },
                  decoration: InputDecoration.collapsed(
                      hintText: 'Enter a message...',
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(30),
                      )),
                ),
              ),
              GestureDetector(
                onTap: widget.chatProvider.isLoading
                    ? null
                    : () {
                        if (textController.text.isNotEmpty) {
                          // send the message
                          sendChatMessage(
                            message: textController.text,
                            chatProvider: widget.chatProvider,
                            isTextOnly: hasImages ? false : true,
                          );
                        }
                      },
                child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.getButtonColor(context),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    margin: const EdgeInsets.all(5.0),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(Icons.arrow_upward, color: Colors.white),
                    )),
              )
            ],
          ),
        ],
      ),
    );
  }
}
