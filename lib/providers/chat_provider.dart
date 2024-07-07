import 'dart:developer';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/models/assessment_model.dart';
import 'package:gemini_risk_assessor/models/message.dart';
import 'package:gemini_risk_assessor/models/tool_model.dart';
import 'package:gemini_risk_assessor/service/gemini_model_manager.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class ChatProvider extends ChangeNotifier {
  final GeminiModelManager _modelManager = GeminiModelManager();
  GenerativeModel? _model;

  // list of messages
  List<Message> _messages = [];

  // images file list
  List<XFile>? _imagesFileList = [];

  // history of messages
  List<Content> _historyMessages = [];

  // current assessment
  AssessmentModel? _currentAssessment;
  ToolModel? _toolModel;

  int _selectedVoiceIndex = 0;
  double _audioSpeed = 1.0;
  double _audioVolume = 0.5;

  bool _isListening = false;
  bool _isPlaySample = false;
  bool _shouldSpeak = true;
  bool _geminiTalking = false;
  bool _isAudioSending = false;
  bool _isStreaming = false;

  // current mode
  String _modelType = 'gemini-1.0-pro';

  // loading bool
  bool _isLoading = false;

  String _googleVoiceName = 'en-US-Neural2-G';
  String _googelVoiceLanguageCode = 'en-US';

  // getters
  List<Message> get messages => _messages;
  int get selectedVoiceIndex => _selectedVoiceIndex;
  double get audioSpeed => _audioSpeed;
  double get audioVolume => _audioVolume;
  bool get isListening => _isListening;
  bool get isPlaySample => _isPlaySample;
  bool get shouldSpeak => _shouldSpeak;
  bool get geminiTalking => _geminiTalking;
  bool get isAudioSending => _isAudioSending;
  bool get isStreaming => _isStreaming;
  String get googleVoiceName => _googleVoiceName;
  String get googelVoiceLanguageCode => _googelVoiceLanguageCode;
  bool get isLoading => _isLoading;
  List<XFile>? get imagesFileList => _imagesFileList;
  GenerativeModel? get model => _model;
  String get modelType => _modelType;

  final CollectionReference _chatsCollection =
      FirebaseFirestore.instance.collection(Constants.chatsCollection);

  // set loading
  void setLoading({required bool value}) {
    _isLoading = value;
    notifyListeners();
  }

  //set volume
  Future<void> setVoiceId({
    required String value,
    required int voiceIndex,
  }) async {
    //_voiceId = value;
    _selectedVoiceIndex = voiceIndex;
    // save voice index to shared preferences
    await saveVoiceIndexToSharedPreferences(value: voiceIndex);
    notifyListeners();
  }

  // set chatGRPT talking
  setGeminiTalking({required bool value}) {
    _geminiTalking = value;
    notifyListeners();
  }

  // set audio sending
  setAdudioSending({required bool value}) {
    _isAudioSending = value;
    notifyListeners();
  }

  //set is streaming
  setIsStreaming({required bool value}) {
    _isStreaming = value;
    notifyListeners();
  }

  // set the selected voice index
  setSelectedVoiceIndex({required int index}) {
    _selectedVoiceIndex = index;
    notifyListeners();
  }

  void setIsListening({required bool listening}) {
    _isListening = listening;
    notifyListeners();
  }

  void setIsPlaySample({required bool playSample}) {
    _isPlaySample = playSample;
    notifyListeners();
  }

  resetVoiceSettings() async {
    _audioSpeed = 1.0;
    _audioVolume = 0.5;

    // reset voice settings and AI behavior to default
    await saveAudioSpeedToSharedPreferences(value: 1.0);
    await saveVolumeToSharedPreferences(value: 1.0);

    notifyListeners();
  }

  Future<void> setModel() async {
    _model = await _modelManager.getModel(
      isVision: _imagesFileList?.isNotEmpty ?? false,
      isDocumentSpecific: _currentAssessment != null || _toolModel != null,
    );
    notifyListeners();
  }

//   Future<void> setModel() async {
//   final GenerationConfig config = GenerationConfig(
//     temperature: 0.4,
//     topK: 32,
//     topP: 1,
//     maxOutputTokens: 4096,
//   );

//   final List<SafetySetting> safetySettings = [
//     SafetySetting(HarmCategory.harassment, HarmBlockThreshold.high),
//     SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.high),
//   ];

//   if (_currentAssessment != null || _toolModel != null) {
//     // We're in a document-specific chat context (assessment, DSTI, or tool)
//     _model = GenerativeModel(
//       model: setCurrentModel(newModel: 'gemini-1.0-pro'),
//       apiKey: getApiKey(),
//       generationConfig: config,
//       safetySettings: safetySettings,
//     );
//   } else if (_imagesFileList!.isEmpty) {
//     // Text-only model for general chats
//     _model = _textModel ?? GenerativeModel(
//       model: setCurrentModel(newModel: 'gemini-1.0-pro'),
//       apiKey: getApiKey(),
//       generationConfig: config,
//       safetySettings: safetySettings,
//     );
//     _textModel = _model;
//   } else {
//     // Vision model for general chats with images
//     _model = _visionModel ?? GenerativeModel(
//       model: setCurrentModel(newModel: 'gemini-1.5-flash'),
//       apiKey: getApiKey(),
//       generationConfig: config,
//       safetySettings: safetySettings,
//     );
//     _visionModel = _model;
//   }

//   notifyListeners();
// }

//   String getApiKey() {
//     return dotenv.env['GEMINI_API_KEY'].toString();
//   }

  // save volume to shared preferences
  Future<void> saveVolumeToSharedPreferences({required double value}) async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    sharedPreferences.setDouble(Constants.volume, value);
    notifyListeners();
  }

  // get volume from shared preferences
  Future<void> getVolumeFromSharedPreferences() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    _audioVolume = sharedPreferences.getDouble(Constants.volume) ?? 0.5;
    notifyListeners();
  }

  // save audio speed to sahered preferences
  Future<void> saveAudioSpeedToSharedPreferences(
      {required double value}) async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    sharedPreferences.setDouble(Constants.audioSpeed, value);
    notifyListeners();
  }

  // get audio speed from shared preferences
  Future<void> getAudioSpeedFromSahredPreferences() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();

    _audioSpeed = sharedPreferences.getDouble(Constants.audioSpeed) ?? 1.0;

    notifyListeners();
  }

  // set google voice name and language code
  Future<void> setGoogleVoiceNameAndLanguageCode({
    required String voiceName,
    required String languageCode,
    required int voiceIndex,
  }) async {
    _googleVoiceName = voiceName;
    _googelVoiceLanguageCode = languageCode;
    _selectedVoiceIndex = voiceIndex;
    // save voice index to shared preferences
    await saveVoiceIndexToSharedPreferences(value: voiceIndex);
    notifyListeners();
  }

  // save voice index to shared preferences
  Future<void> saveVoiceIndexToSharedPreferences({required int value}) async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    sharedPreferences.setInt(Constants.voiceIndex, value);
    notifyListeners();
  }

  // get voice index from shared preferences
  Future<void> getVoiceIndexFromSharedPreferences() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    _selectedVoiceIndex = sharedPreferences.getInt(Constants.voiceIndex) ?? 0;
    notifyListeners();
  }

  // set should speak to shared preferences
  Future<void> setShouldSpeakToSharedPreferences({required bool value}) async {
    _shouldSpeak = value;
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    sharedPreferences.setBool(Constants.shouldSpeak, value);
    notifyListeners();
  }

  // get should speak from shared preferences
  getShouldSpeakFromSharedPreferences() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    _shouldSpeak = sharedPreferences.getBool(Constants.shouldSpeak) ?? true;
    notifyListeners();
  }

  Future<void> getChatHistoryFromFirebase({
    required String uid,
    required String chatID,
    required bool isTool,
  }) async {
    // empty all messages
    _historyMessages = [];
    _messages = [];
    _isLoading = true;
    notifyListeners();

    final collection = isTool
        ? Constants.toolsChatsCollection
        : Constants.assessmentsChatsCollection;

    try {
      await _chatsCollection
          .doc(uid)
          .collection(collection)
          .doc(chatID)
          .collection(Constants.chatDataCollection)
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
        _isLoading = false;
        notifyListeners();
      });
    } on FirebaseException catch (e) {
      _isLoading = false;
      notifyListeners();
      log('getting history error : ${e.message}');
    }
  }

  Future<void> sendMessage({
    required String uid,
    required String chatID,
    required String message,
    required bool isTool,
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
        isTool: isTool,
        onError: onError,
      );

      onSuccess();
    } catch (error) {
      _isLoading = false;
      notifyListeners();
      log('error XXX: ${error.toString()}');
      onError(error.toString());
    }
  }

  Future<void> sendMessageToGeminiAndGetStreamedAnswer({
    required String uid,
    required String chatID,
    required String messageID,
    required String message,
    required bool isTool,
    required Function(String) onError,
  }) async {
    await setModel();

    _isLoading = true;
    notifyListeners();

    final collection = isTool
        ? Constants.toolsChatsCollection
        : Constants.assessmentsChatsCollection;

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
      log('event: $streamedAnswer');
      notifyListeners();
    }

    _historyMessages.add(Content.text(message));
    _historyMessages.add(Content.model([TextPart(fullStreamedAnswer)]));

    // TODO: Save the message to Firestore
    // await _chatsCollection
    //     .doc(uid)
    //     .collection(collectionRef)
    //     .doc(chatID)
    //     .collection(Constants.chatDataCollection)
    //     .doc(messageID)
    //     .set(lastMessage.toJson());
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

  // set file list
  void setImagesFileList({required List<XFile> listValue}) {
    _imagesFileList = listValue;
    notifyListeners();
  }

  // set the current model
  String setCurrentModel({required String newModel}) {
    _modelType = newModel;
    notifyListeners();
    return newModel;
  }

  // get y=the imagesUrls
  List<String> getImagesUrls({
    required bool isTextOnly,
  }) {
    List<String> imagesUrls = [];
    if (!isTextOnly && imagesFileList != null) {
      for (var image in imagesFileList!) {
        imagesUrls.add(image.path);
      }
    }
    return imagesUrls;
  }

  Future<void> addAndDisplayMessage({
    required String uid,
    required String chatID,
    required bool isTool,
    required bool finalWords,
    AudioPlayer? audioPlayer,
    String? spokenWords,
    required Function onSuccess,
    required Function(String) onError,
  }) async {
    if (spokenWords != null) {
      String messageID;
      if (finalWords) {
        messageID = const Uuid().v4();
        final message = Message(
          senderID: uid,
          messageID: messageID,
          chatID: chatID,
          question: spokenWords,
          answer: StringBuffer(),
          imagesUrls: [],
          sentencesUrls: [],
          finalWords: finalWords,
          timeSent: DateTime.now(),
        );

        _messages.add(message);

        // Send the message to Gemini and get streamed answer
        await sendMessageToGeminiAndGetStreamedAnswer(
          uid: uid,
          chatID: chatID,
          messageID: messageID,
          message: spokenWords,
          isTool: isTool,
          onError: onError,
        );
      } else {
        if (_messages.isNotEmpty && _messages.last.answer.isEmpty) {
          // Update the last message's question field
          _messages.last = _messages.last.copyWith(
            question: '${_messages.last.question} $spokenWords',
          );
        } else {
          // Create a new message if there's no existing message or if the last message has an answer
          messageID = const Uuid().v4();
          _messages.add(Message(
            senderID: uid,
            messageID: messageID,
            chatID: chatID,
            question: spokenWords,
            answer: StringBuffer(),
            imagesUrls: [],
            sentencesUrls: [],
            finalWords: false,
            timeSent: DateTime.now(),
          ));
        }
      }
      notifyListeners();
    }

    onSuccess();
  }

  Future<void> setChatContext({
    AssessmentModel? assessment,
    ToolModel? tool,
    bool isDSTI = false,
  }) async {
    if (assessment != null) {
      String docType =
          isDSTI ? 'daily safety task instruction' : 'risk assessment';
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

Name: ${tool.name}
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
