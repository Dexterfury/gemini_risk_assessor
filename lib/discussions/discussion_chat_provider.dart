import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/discussions/discussion_message.dart';
import 'package:gemini_risk_assessor/enums/enums.dart';
import 'package:gemini_risk_assessor/firebase_methods/firebase_methods.dart';
import 'package:gemini_risk_assessor/models/assessment_model.dart';
import 'package:gemini_risk_assessor/models/message_reply_model.dart';
import 'package:gemini_risk_assessor/models/user_model.dart';
import 'package:gemini_risk_assessor/service/gemini_model_manager.dart';
import 'package:gemini_risk_assessor/utilities/global.dart';
import 'package:uuid/uuid.dart';

class DiscussionChatProvider extends ChangeNotifier {
  final GeminiModelManager _modelManager = GeminiModelManager();
  bool _isLoading = false;
  MessageReplyModel? _messageReplyModel;

  bool get isLoading => _isLoading;
  MessageReplyModel? get messageReplyModel => _messageReplyModel;

  void setMessageReplyModel(MessageReplyModel? messageReply) {
    _messageReplyModel = messageReply;
    notifyListeners();
  }

  Future<void> generateQuiz({
    required AssessmentModel assessment,
  }) async {
    _isLoading = true;
    notifyListeners();
    log('generating a quiz');
    final quiz = await _modelManager.generateSafetyQuiz(assessment);

    _isLoading = false;
    notifyListeners();
    log('quiz: $quiz');
  }

  // send text message to firestore
  Future<void> sendTextMessage({
    required UserModel sender,
    required String message,
    required MessageType messageType,
    required String groupID,
    required String itemID,
    required bool isAIMessage,
    required GenerationType generationType,
    required Function onSucess,
    required Function(String) onError,
  }) async {
    // set loading to true
    _isLoading = true;
    notifyListeners();
    try {
      var messageID = const Uuid().v4();

      // 1. check if its a message reply and add the replied message to the message
      String repliedMessage = _messageReplyModel?.message ?? '';
      String repliedTo =
          _messageReplyModel == null ? '' : messageReplyModel!.senderUID;
      MessageType repliedMessageType =
          _messageReplyModel?.messageType ?? MessageType.text;

      // 2. update/set the messagemodel
      final discussionMessage = DiscussionMessage(
        senderUID: sender.uid,
        senderName: sender.name,
        senderImage: sender.imageUrl,
        groupID: groupID,
        message: message,
        messageType: messageType,
        timeSent: DateTime.now(),
        messageID: messageID,
        isSeen: false,
        isAIMessage: isAIMessage,
        repliedMessage: repliedMessage,
        repliedTo: repliedTo,
        repliedMessageType: repliedMessageType,
        reactions: [],
        seenBy: [sender.uid],
        deletedBy: [],
      );

      final collection = getCollectionRef(generationType);

      await FirebaseMethods.groupsCollection
          .doc(groupID)
          .collection(collection)
          .doc(itemID)
          .collection(Constants.chatMessagesCollection)
          .doc(messageID)
          .set(discussionMessage.toMap());

      // set loading to false
      _isLoading = false;
      notifyListeners();
      onSucess();
      // set message reply model to null
      setMessageReplyModel(null);
    } catch (e) {
      // set loading to false
      _isLoading = false;
      onError(e.toString());
    }
  }
}
