import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/discussions/additional_data_model.dart';
import 'package:gemini_risk_assessor/discussions/discussion_message.dart';
import 'package:gemini_risk_assessor/discussions/quiz_model.dart';
import 'package:gemini_risk_assessor/enums/enums.dart';
import 'package:gemini_risk_assessor/firebase_methods/firebase_methods.dart';
import 'package:gemini_risk_assessor/models/assessment_model.dart';
import 'package:gemini_risk_assessor/models/message_reply_model.dart';
import 'package:gemini_risk_assessor/models/user_model.dart';
import 'package:gemini_risk_assessor/service/gemini_model_manager.dart';
import 'package:gemini_risk_assessor/tools/tool_model.dart';
import 'package:gemini_risk_assessor/utilities/global.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:uuid/uuid.dart';

class DiscussionChatProvider extends ChangeNotifier {
  final GeminiModelManager _modelManager = GeminiModelManager();
  bool _isLoading = false;
  bool _isLoadingQuiz = false;
  bool _isLoadingAnswer = false;
  bool _isLoadingAdditionalData = false;
  bool _isSummarizing = true;
  MessageReplyModel? _messageReplyModel;

  bool get isLoading => _isLoading;
  bool get isLoadingQuiz => _isLoadingQuiz;
  bool get isLoadingAnswer => _isLoadingAnswer;
  bool get isLoadingAdditionalData => _isLoadingAdditionalData;
  bool get isSummarizing => _isSummarizing;
  MessageReplyModel? get messageReplyModel => _messageReplyModel;

  void setMessageReplyModel(MessageReplyModel? messageReply) {
    _messageReplyModel = messageReply;
    notifyListeners();
  }

  Future<void> generateQuiz({
    required UserModel userModel,
    AssessmentModel? assessment,
    ToolModel? tool,
    required String groupID,
    required GenerationType generationType,
    int numberOfQuestions = 3,
  }) async {
    try {
      _isLoadingQuiz = true;
      notifyListeners();

      final collection = getCollectionRef(generationType);

      GenerateContentResponse content;
      final itemID = tool != null ? tool.id : assessment!.id;

      if (generationType != GenerationType.tool) {
        content = await _modelManager.generateSafetyQuiz(
            assessment!, numberOfQuestions);
      } else {
        content = await _modelManager.generateSafetyToolsQuiz(tool!);
      }

      final messageID = const Uuid().v4();

      var quizCount = await FirebaseMethods.getQuizCount(
        groupID: groupID,
        itemID: itemID,
        collection: collection,
      );

      log('count: $quizCount');

      final quiz = QuizModel.fromGeneratedContent(
        content,
        itemID,
        userModel.uid,
        messageID,
        DateTime.now(),
        quizCount + 1,
      );

      // get empty additional data
      final additionalData = AdditionalDataModel.empty();

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
        seenBy: [userModel.uid],
        deletedBy: [],
        additionalData: additionalData,
        quizData: quiz,
        quizResults: {},
      );

      // save the quiz to firestore
      await FirebaseMethods.groupsCollection
          .doc(groupID)
          .collection(collection)
          .doc(itemID)
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
    required UserModel currentUser,
    required String groupID,
    required String messageID,
    required String itemID,
    required GenerationType generationType,
    required QuizModel quizData,
    required Map<String, dynamic> quizResults,
  }) async {
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
        currentQuizResults[currentUser.uid] = {
          Constants.quizTitle: quizData.title,
          Constants.uid: currentUser.uid,
          Constants.name: currentUser.name,
          Constants.imageUrl: currentUser.imageUrl,
          Constants.answers: answers,
          Constants.createdAt: DateTime.now().millisecondsSinceEpoch,
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

        // get empty additional data
        final additionalData = AdditionalDataModel.empty();

        final answerMessage = DiscussionMessage(
          senderUID: currentUser.uid,
          senderName: currentUser.name,
          senderImage: currentUser.imageUrl,
          groupID: groupID,
          message: 'Results',
          messageType: MessageType.quizAnswer,
          timeSent: DateTime.now(),
          messageID: answerMessageID,
          isSeen: false,
          isAIMessage: false,
          repliedMessage: quizData.title,
          repliedTo: 'Safety Quiz Results',
          repliedMessageType: MessageType.quizAnswer,
          reactions: [],
          seenBy: [currentUser.uid],
          deletedBy: [],
          additionalData: additionalData,
          quizData: quizData,
          quizResults: currentQuizResults,
        );

        // Add the answer message to the chat messages collection
        await FirebaseMethods.groupsCollection
            .doc(groupID)
            .collection(collection)
            .doc(itemID)
            .collection(Constants.chatMessagesCollection)
            .doc(answerMessageID)
            .set(answerMessage.toMap());
      }
      _isLoadingAnswer = false;
      notifyListeners();
    } catch (e) {
      log('Error updating quiz: $e');
      _isLoadingAnswer = false;
      notifyListeners();
    }
  }

  // add additional data
  Future<DiscussionMessage?> addAdditionalData({
    required UserModel userModel,
    required AssessmentModel assessment,
    required String groupID,
    required GenerationType generationType,
  }) async {
    try {
      _isLoadingAdditionalData = true;
      notifyListeners();
      final content = await _modelManager.suggestAdditionalRisks(assessment);

      final messageID = const Uuid().v4();

      final additionalDataModel = AdditionalDataModel.fromGeneratedContent(
        content,
        userModel.uid,
        assessment.id,
        DateTime.now(),
      );

      // get empty quiz
      final quiz = QuizModel.empty;

      final additionalDataMessage = DiscussionMessage(
        senderUID: userModel.uid,
        senderName: userModel.name,
        senderImage: userModel.imageUrl,
        groupID: groupID,
        message: 'Additional Data',
        messageType: MessageType.additional,
        timeSent: DateTime.now(),
        messageID: messageID,
        isSeen: false,
        isAIMessage: true,
        repliedMessage: '',
        repliedTo: '',
        repliedMessageType: MessageType.text,
        reactions: [],
        seenBy: [userModel.uid],
        deletedBy: [],
        additionalData: additionalDataModel,
        quizData: quiz,
        quizResults: {},
      );

      _isLoadingQuiz = false;
      notifyListeners();
      return additionalDataMessage;
    } catch (e) {
      _isLoadingAdditionalData = false;
      notifyListeners();
      return null;
    }
  }

  // summerize chat messages
  Future<String> summerizeChatMessages({
    required String groupID,
    required String itemID,
    required GenerationType generationType,
  }) async {
    _isSummarizing = true;
    notifyListeners();
    try {
      // get the message
      List<DiscussionMessage> messages = await FirebaseMethods.getMessages(
        groupID: groupID,
        itemID: itemID,
        generationType: generationType,
      );

      if (messages.isEmpty) {
        _isSummarizing = false;
        notifyListeners();
        return 'No messages found';
      }

      final content = await _modelManager.summarizeChatMessages(messages);

      if (content.text != null) {
        return content.text!;
      }
      return '';
    } catch (e) {
      _isSummarizing = false;
      notifyListeners();
      return e.toString();
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

      // craete an empty quiz model if it is an AI generated message
      QuizModel quiz = QuizModel.empty;

      // get empty additional data
      final additionalData = AdditionalDataModel.empty();

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
        additionalData: additionalData,
        quizData: quiz,
        quizResults: {},
      );

      await saveDiscussionMessage(
        message: discussionMessage,
        groupID: groupID,
        itemID: itemID,
        messageID: messageID,
        generationType: generationType,
      );

      // set loading to false
      _isLoading = false;
      notifyListeners();
      onSucess();
      // set message reply model to null
      setMessageReplyModel(null);
    } catch (e) {
      // set loading to false
      log('erro message: $e');
      _isLoading = false;
      onError(e.toString());
    }
  }

  // save discussion message to firestore
  Future<void> saveDiscussionMessage({
    required DiscussionMessage message,
    required String groupID,
    required String itemID,
    required String messageID,
    required GenerationType generationType,
  }) async {
    final collection = getCollectionRef(generationType);
    _isLoading = true;
    notifyListeners();
    await FirebaseMethods.groupsCollection
        .doc(groupID)
        .collection(collection)
        .doc(itemID)
        .collection(Constants.chatMessagesCollection)
        .doc(messageID)
        .set(message.toMap());
    _isLoading = false;
    notifyListeners();
  }
}
