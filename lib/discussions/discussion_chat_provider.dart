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
  bool _isLoadingQuiz = false;
  bool _isLoadingAnswer = false;
  MessageReplyModel? _messageReplyModel;

  bool get isLoading => _isLoading;
  bool get isLoadingQuiz => _isLoadingQuiz;
  bool get isLoadingAnswer => _isLoadingAnswer;
  MessageReplyModel? get messageReplyModel => _messageReplyModel;

  void setMessageReplyModel(MessageReplyModel? messageReply) {
    _messageReplyModel = messageReply;
    notifyListeners();
  }

  Future<void> generateQuiz({
    required UserModel userModel,
    required AssessmentModel assessment,
    required String groupID,
    required GenerationType generationType,
  }) async {
    _isLoadingQuiz = true;
    notifyListeners();
    try {
      final quiz = await _modelManager.generateSafetyQuiz(assessment);

      final messageID = const Uuid().v4();

      final discussionMessage = DiscussionMessage(
        senderUID: userModel.uid,
        senderName: userModel.name,
        senderImage: userModel.imageUrl,
        groupID: groupID,
        message: 'New safety quiz available! Tap to participate.',
        messageType: MessageType.quiz,
        timeSent: DateTime.now(),
        messageID: messageID,
        isSeen: false,
        isAIMessage: true,
        repliedMessage: '',
        repliedTo: '',
        repliedMessageType: MessageType.text,
        reactions: [],
        seenBy: [],
        deletedBy: [],
        quizData: quiz,
        quizResults: {},
      );

      final collection = getCollectionRef(generationType);

      // save the quiz to firestore
      await FirebaseMethods.groupsCollection
          .doc(groupID)
          .collection(collection)
          .doc(assessment.id)
          .collection(Constants.chatMessagesCollection)
          .doc(messageID)
          .set(discussionMessage.toMap());

      _isLoadingQuiz = false;
      notifyListeners();
    } catch (e) {
      log('Error generating quiz: $e');
      _isLoadingQuiz = false;
      notifyListeners();
    }
  }

  // update quiz in firestore
  Future<void> updateQuiz({
    required UserModel currenUser,
    required String groupID,
    required String messageID,
    required String itemID,
    required GenerationType generationType,
    required Map<String, dynamic> quizResults,
  }) async {
    log('quizResults: $quizResults');
    try {
      _isLoadingAnswer = true;
      notifyListeners();
      final collection = getCollectionRef(generationType);

      // Fetch the current message data
      final docSnapshot = await FirebaseMethods.groupsCollection
          .doc(groupID)
          .collection(collection)
          .doc(itemID)
          .collection(Constants.chatMessagesCollection)
          .doc(messageID)
          .get();

      if (docSnapshot.exists) {
        final currentData = docSnapshot.data() as Map<String, dynamic>;
        final currentQuizResults =
            Map<String, dynamic>.from(currentData[Constants.quizResults] ?? {});

        // Convert int keys to string keys in the answers map
        final answers =
            (quizResults[Constants.answers] as Map<dynamic, dynamic>).map(
          (key, value) => MapEntry(key.toString(), value),
        );

        // Add or update the current user's quiz results
        currentQuizResults[currenUser.uid] = {
          Constants.userUID: currenUser.uid,
          Constants.answers: answers,
        };

        // Update the document with the new quiz results
        await FirebaseMethods.groupsCollection
            .doc(groupID)
            .collection(collection)
            .doc(itemID)
            .collection(Constants.chatMessagesCollection)
            .doc(messageID)
            .update({
          Constants.quizResults: currentQuizResults,
        });

        final answerMessageID = const Uuid().v4();

        final answerMessage = DiscussionMessage(
          senderUID: currenUser.uid,
          senderName: currenUser.name,
          senderImage: currenUser.imageUrl,
          groupID: groupID,
          message: 'Results',
          messageType: MessageType.quizAnser,
          timeSent: DateTime.now(),
          messageID: answerMessageID,
          isSeen: false,
          isAIMessage: false,
          repliedMessage: repliedMessage,
          repliedTo: repliedTo,
          repliedMessageType: repliedMessageType,
          reactions: reactions,
          seenBy: seenBy,
          deletedBy: deletedBy,
          quizData: quizData,
          quizResults: quizResults,
        );
      }
      _isLoadingAnswer = false;
      notifyListeners();
    } catch (e) {
      log('Error updating quiz: $e');
      _isLoadingAnswer = false;
      notifyListeners();
    }
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
        quizData: {},
        quizResults: {},
      );

      log('Message Data: ${discussionMessage.toMap()}');

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
