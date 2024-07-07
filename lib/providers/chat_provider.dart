import 'dart:developer';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/models/message.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class ChatProvider extends ChangeNotifier {
  // list of messages
  List<Message> _messages = [];

  // images file list
  List<XFile>? _imagesFileList = [];

  // history of messages
  List<Content> _historyMessages = [];

  List<dynamic> _sentencesAudioFileList = [];

  bool _allSentencesAudioFilesPlayed = false;

  int _selectedVoiceIndex = 0;
  double _audioSpeed = 1.0;
  double _audioVolume = 0.5;

  int _fileToPlay = 0;
  int _allSentencesCount = 0;

  bool _isListening = false;
  bool _isPlaySample = false;
  bool _shouldSpeak = true;
  bool _startListeningOnNew = true;
  bool _geminiTalking = false;
  bool _isAudioSending = false;
  bool _isStreaming = false;

  // initialize generative model
  GenerativeModel? _model;

  // itialize text model
  GenerativeModel? _textModel;

  // initialize vision model
  GenerativeModel? _visionModel;

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
  bool get startListeningOnNew => _startListeningOnNew;
  bool get geminiTalking => _geminiTalking;
  bool get isAudioSending => _isAudioSending;
  bool get isStreaming => _isStreaming;
  String get googleVoiceName => _googleVoiceName;
  String get googelVoiceLanguageCode => _googelVoiceLanguageCode;
  List<dynamic> get sentencesAudioFileList => _sentencesAudioFileList;
  bool get allSentencesAudioFilesPlayed => _allSentencesAudioFilesPlayed;
  int get fileToPlay => _fileToPlay;
  bool get isLoading => _isLoading;
  List<XFile>? get imagesFileList => _imagesFileList;
  GenerativeModel? get model => _model;
  GenerativeModel? get textModel => _textModel;
  GenerativeModel? get visionModel => _visionModel;
  String get modelType => _modelType;

  final CollectionReference _chatsCollection =
      FirebaseFirestore.instance.collection(Constants.chatsCollection);

  set fileToPlay(int value) {
    _fileToPlay = value;
    notifyListeners();
  }

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

  // function to set the model based on bool - isTextOnly
  Future<void> setModel() async {
    if (_imagesFileList!.isEmpty) {
      _model = _textModel ??
          GenerativeModel(
              model: setCurrentModel(newModel: 'gemini-1.0-pro'),
              apiKey: getApiKey(),
              generationConfig: GenerationConfig(
                temperature: 0.4,
                topK: 32,
                topP: 1,
                maxOutputTokens: 4096,
              ),
              safetySettings: [
                SafetySetting(HarmCategory.harassment, HarmBlockThreshold.high),
                SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.high),
              ]);
    } else {
      _model = _visionModel ??
          GenerativeModel(
              model: setCurrentModel(newModel: 'gemini-1.5-flash'),
              apiKey: getApiKey(),
              generationConfig: GenerationConfig(
                temperature: 0.4,
                topK: 32,
                topP: 1,
                maxOutputTokens: 4096,
              ),
              safetySettings: [
                SafetySetting(HarmCategory.harassment, HarmBlockThreshold.high),
                SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.high),
              ]);
    }
    notifyListeners();
  }

  String getApiKey() {
    return dotenv.env['GEMINI_API_KEY'].toString();
  }

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
        audioPlayer: audioPlayer,
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
    AudioPlayer? audioPlayer,
    required Function(String) onError,
  }) async {
    await setModel();

    _isLoading = true;
    notifyListeners();

    final collection = isTool
        ? Constants.toolsChatsCollection
        : Constants.assessmentsChatsCollection;

    audioPlayer?.stop();

    _isStreaming = true;
    _sentencesAudioFileList = [];
    notifyListeners();

    await streamResponse(
      uid,
      messageID,
      chatID,
      message,
      collection,
      audioPlayer,
    );
  }

  Future<void> streamResponse(
    String uid,
    String messageID,
    String chatID,
    String message,
    String collectionRef,
    AudioPlayer? audioPlayer,
  ) async {
    String fullSentence = '';
    String fullStreamedAnswer = '';

    int counter = 0;
    _fileToPlay = 0;
    _allSentencesCount = 0;
    _allSentencesAudioFilesPlayed = false;

    final chatSession = _model!.startChat(
      history: _historyMessages.isEmpty || _imagesFileList!.isNotEmpty
          ? null
          : _historyMessages,
    );

    final content = await getContent(message: message);

    // log('content: $content');

    // final chatMessage = Message(
    //   senderID: uid,
    //   messageID: messageID,
    //   chatID: chatID,
    //   question: message,
    //   answer: StringBuffer(),
    //   imagesUrls: [],
    //   sentencesUrls: [],
    //   finalWords: false,
    //   timeSent: DateTime.now(),
    // );

    // _messages.add(chatMessage);

    //log('messages: $_messages');

    await for (final eventData in chatSession.sendMessageStream(content)) {
      final streamedAnswer = eventData.text;
      fullSentence += streamedAnswer!;
      fullStreamedAnswer += streamedAnswer;

      _messages
          .firstWhere((element) => element.messageID == messageID)
          .answer
          .write(streamedAnswer);
      log('event: $streamedAnswer');
      notifyListeners();

      if (streamedAnswer.endsWith('.') ||
          streamedAnswer.endsWith('!') ||
          streamedAnswer.endsWith('?')) {
        log('counter ${counter++}');
        log('full sentence $fullSentence');
        fullSentence = '';
      }
    }

    log('full Streamed answer $fullStreamedAnswer');

    _historyMessages.add(Content.text(message));
    _historyMessages.add(Content.model([TextPart(fullStreamedAnswer)]));

    List<String> sentencesUrls = [];

    log('lastMessage: ');

    // TODO: Save the message to Firestore
    // Save the message to Firestore
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
          audioPlayer: audioPlayer,
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

  String get mainPrompt {
    return '''
You are a Safety officer who ensures safe work practices.

Generate a risk assessment based on the data information provided below.
The assessment should only contain real practical risks identified and mitigation measures proposed without any unnecessary information.
If there are no images attached, or if the image does not contain any identifiable risks, respond exactly with: $noRiskFound.

Adhere to Safety standards and regulations. Identify any potential risks and propose practical mitigation measures.
The number of people is: $_numberOfPeople
The weather is: ${_weather.name}

After providing the assessment, advice the equipment and tools to be used if required.
Advise about the dangers that could injure people or harm the enviroment, the hazards and risks involved.
Propose practical measures to eliminate or minimize each risk identified.
Suggest use of proper personal protective equipment if not among these: ${getSelectedPpe.toString()}
Provide a summary of this assessment.

${_description.isNotEmpty ? _description : ''}
''';
  }
}
