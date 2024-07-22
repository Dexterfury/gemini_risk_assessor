import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/enums/enums.dart';
import 'package:gemini_risk_assessor/models/assessment_model.dart';
import 'package:gemini_risk_assessor/models/message.dart';
import 'package:gemini_risk_assessor/models/tool_model.dart';
import 'package:gemini_risk_assessor/service/gemini_model_manager.dart';
import 'package:gemini_risk_assessor/utilities/global.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:uuid/uuid.dart';

class MyProviderClass extends ChangeNotifier {
  final GeminiModelManager _modelManager = GeminiModelManager();
  GenerativeModel? _model;
  List<Message> _messages = [];
  List<Content> _historyMessages = [];
  bool _userHasSentMessage = false;
  // loading bool
  bool _isLoading = false;
  // images file list
  List<XFile>? _imagesFileList = [];

  // current assessment
  AssessmentModel? _currentAssessment;
  ToolModel? _toolModel;

  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection(Constants.usersCollection);

  Future<void> getChatHistoryFromFirebase({
    required String uid,
    required GenerationType generationType,
    AssessmentModel? assessmentModel,
    ToolModel? toolModel,
  }) async {
    // empty all messages
    _historyMessages = [];
    _messages = [];
    _isLoading = true;
    notifyListeners();

    final collection = getCollectionRef(generationType);
    final chatID =
        toolModel != null ? toolModel.id : assessmentModel!.id; // get chat id
    await _usersCollection
        .doc(uid)
        .collection(collection)
        .doc(chatID)
        .collection(Constants.chatMessagesCollection)
        .orderBy(Constants.timeSent)
        .get()
        .then((value) {
      for (var doc in value.docs) {
        final message = Message.fromJson(doc.data());

        // populate the messages from firebase and store them in a list
        _messages.add(message);

        // add user message to history
        _historyMessages.add(
          Content.text(message.question),
        );
        // add assistant message to history
        _historyMessages.add(
          Content.model(
            [
              TextPart(
                message.answer.toString(),
              ),
            ],
          ),
        );
      }
    });

    await setChatContext(
      assessment: assessmentModel,
      tool: toolModel,
      generationType: generationType,
    );

    // Check if messages are empty and send AI first message if needed
    if (_messages.isEmpty) {
      await sendAIFirstMessage(generationType);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<Content> getContent({
    required String message,
  }) async {
    if (_imagesFileList!.isEmpty) {
      // generate text from text-only input
      return Content.text(message);
    } else {
      // generate image from text and image input
      final imageFutures = _imagesFileList
          ?.map((imageFile) => imageFile.readAsBytes())
          .toList(growable: false);

      final imageBytes = await Future.wait(imageFutures!);
      final prompt = TextPart(message);
      final imageParts = imageBytes
          .map((bytes) => DataPart('image/jpeg', Uint8List.fromList(bytes)))
          .toList();

      return Content.multi([prompt, ...imageParts]);
    }
  }

  Future<void> sendAIFirstMessage(GenerationType generationType) async {
    final String messageID = const Uuid().v4();
    final String aiMessage = _getAIFirstMessage(generationType);

    final newMessage = Message(
      senderID: 'AI',
      messageID: messageID,
      chatID: _currentAssessment?.id ?? _toolModel!.id,
      question: '',
      answer: StringBuffer(aiMessage),
      imagesUrls: [],
      reactions: [],
      sentencesUrls: [],
      finalWords: true,
      timeSent: DateTime.now(),
    );

    _messages.add(newMessage);
    _historyMessages.add(Content.model([TextPart(aiMessage)]));

    notifyListeners();
  }

  String _getAIFirstMessage(GenerationType generationType) {
    if (_currentAssessment != null) {
      final docType = generationType == GenerationType.dsti
          ? 'daily safety task instruction'
          : 'risk assessment';
      return "Hello! I'm here to discuss the $docType titled '${_currentAssessment!.title}'. I have information about the task, equipment, hazards, risks, control measures, and more. Feel free to ask any questions related to this specific $docType.";
    } else if (_toolModel != null) {
      return "Hello! I'm here to discuss the tool '${_toolModel!.title}'. I can provide information on how to use this tool, give practical use case examples, and offer guidance on its safe and effective use. Please feel free to ask any questions related to this specific tool.";
    } else {
      return "Hello! I'm here to assist you. How can I help you today?";
    }
  }

  Future<void> sendMessage({
    required String uid,
    required String chatID,
    required String message,
    required GenerationType generationType,
    required Function onSuccess,
    required Function(String) onError,
    AudioPlayer? audioPlayer,
  }) async {
    try {
      String messageID = const Uuid().v4();

      final newMessage = Message(
        senderID: uid,
        messageID: messageID,
        chatID: chatID,
        question: message,
        answer: StringBuffer(),
        imagesUrls: [],
        reactions: [],
        sentencesUrls: [],
        finalWords: true,
        timeSent: DateTime.now(),
      );

      _messages.add(newMessage);
      notifyListeners();

      await sendMessageToGeminiAndGetStreamedAnswer(
        uid: uid,
        chatID: chatID,
        messageID: messageID,
        message: message,
        generationType: generationType,
        onError: onError,
      );

      // Set the flag indicating the user has sent a message
      _userHasSentMessage = true;

      // Save all messages to Firestore if this is the first user message
      if (_messages.length > 1) {
        await saveAllMessagesToFirestore(uid, chatID, generationType);
      }

      onSuccess();
    } catch (error) {
      _isLoading = false;
      notifyListeners();
      onError(error.toString());
    }
  }

  Future<void> sendMessageToGeminiAndGetStreamedAnswer({
    required String uid,
    required String chatID,
    required String messageID,
    required String message,
    required GenerationType generationType,
    required Function(String) onError,
  }) async {
    await setModel();

    _isLoading = true;
    notifyListeners();

    final collection = getCollectionRef(generationType);

    await streamResponse(
      uid,
      messageID,
      chatID,
      message,
      collection,
    );
  }

  Future<void> streamResponse(
    String uid,
    String messageID,
    String chatID,
    String message,
    String collectionRef,
  ) async {
    String fullStreamedAnswer = '';

    final chatSession = _model!.startChat(history: _historyMessages);

    final content = await getContent(message: message);

    await for (final eventData in chatSession.sendMessageStream(content)) {
      final streamedAnswer = eventData.text;
      fullStreamedAnswer += streamedAnswer!;

      _messages
          .firstWhere((element) => element.messageID == messageID)
          .answer
          .write(streamedAnswer);
      notifyListeners();
    }

    _historyMessages.add(Content.text(message));
    _historyMessages.add(Content.model([TextPart(fullStreamedAnswer)]));

    // Save the message to Firestore
    final messageModel = Message(
      senderID: uid,
      messageID: messageID,
      chatID: chatID,
      question: message,
      answer: StringBuffer(fullStreamedAnswer),
      imagesUrls: [],
      reactions: [],
      sentencesUrls: [],
      finalWords: true,
      timeSent: DateTime.now(),
    );

    await _usersCollection
        .doc(uid)
        .collection(collectionRef)
        .doc(chatID)
        .collection(Constants.chatMessagesCollection)
        .doc(messageID)
        .set(messageModel.toJson());
    _isLoading = false;
    notifyListeners();
  }

  Future<void> saveAllMessagesToFirestore(
      String uid, String chatID, GenerationType generationType) async {
    final collection = getCollectionRef(generationType);
    final batch = FirebaseFirestore.instance.batch();

    for (var message in _messages) {
      final docRef = _usersCollection
          .doc(uid)
          .collection(collection)
          .doc(chatID)
          .collection(Constants.chatMessagesCollection)
          .doc(message.messageID);
      batch.set(docRef, message.toJson());
    }

    await batch.commit();
  }

  Future<void> setModel() async {
    _model = await _modelManager.getModel(
      isVision: _imagesFileList?.isNotEmpty ?? false,
      isDocumentSpecific: _currentAssessment != null || _toolModel != null,
    );
    notifyListeners();
  }

  Future<void> setChatContext({
    AssessmentModel? assessment,
    ToolModel? tool,
    GenerationType? generationType,
  }) async {
    if (assessment != null) {
      String docType = generationType == GenerationType.dsti
          ? 'daily safety task instruction'
          : 'risk assessment';
      _currentAssessment = assessment;
      _toolModel = null;

      final contextPrompt = '''
You are a Safety officer discussing a specific $docType. Here are the details:

Title: ${assessment.title}
Task to Achieve: ${assessment.taskToAchieve}
Equipments: ${assessment.equipments.join(', ')}
Hazards: ${assessment.hazards.join(', ')}
Risks: ${assessment.risks.join(', ')}
Control Measures: ${assessment.control.join(', ')}
PPE: ${assessment.ppe.join(', ')}
Weather: ${assessment.weather}
Summary: ${assessment.summary}

Only answer questions related to this specific $docType. If asked about something unrelated, politely remind the user that you can only discuss this particular $docType.
''';

      _historyMessages = [Content.text(contextPrompt)];
    } else if (tool != null) {
      _toolModel = tool;
      _currentAssessment = null;

      final contextPrompt = '''
You are a tools expert discussing a specific tool. Here are the details:

Name: ${tool.title}
Description: ${tool.description}
Summary: ${tool.summary}

Explain how to use this tool and give practical use case examples. Adhere to safety standards and regulations, providing guidance on safe and effective use of the tool.

Only answer questions related to this specific tool. If asked about something unrelated, politely remind the user that you can only discuss this particular tool.
''';

      _historyMessages = [Content.text(contextPrompt)];
    } else {
      throw ArgumentError('Either assessment or tool must be provided');
    }

    await setModel();
    notifyListeners();
  }
}
