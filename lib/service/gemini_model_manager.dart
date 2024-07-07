import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gemini_risk_assessor/models/prompt_data_model.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiModelManager {
  static final GeminiModelManager _instance = GeminiModelManager._internal();

  factory GeminiModelManager() {
    return _instance;
  }

  GeminiModelManager._internal();

  GenerativeModel? _textModel;
  GenerativeModel? _visionModel;

  final GenerationConfig _config = GenerationConfig(
    temperature: 0.4,
    topK: 32,
    topP: 1,
    maxOutputTokens: 4096,
  );

  final List<SafetySetting> _safetySettings = [
    SafetySetting(HarmCategory.harassment, HarmBlockThreshold.high),
    SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.high),
  ];

  String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

  Future<GenerativeModel> getModel({
    required bool isVision,
    required bool isDocumentSpecific,
  }) async {
    if (isDocumentSpecific) {
      return _createModel('gemini-1.5-flash');
    } else if (!isVision) {
      _textModel ??= _createModel('gemini-1.5-flash');
      return _textModel!;
    } else {
      _visionModel ??= _createModel('gemini-1.0-pro');
      return _visionModel!;
    }
  }

  GenerativeModel _createModel(String modelName) {
    return GenerativeModel(
      model: modelName,
      apiKey: _apiKey,
      generationConfig: _config,
      safetySettings: _safetySettings,
    );
  }

  Future<GenerateContentResponse> generateContent(
    GenerativeModel model,
    PromptDataModel prompt,
  ) async {
    if (prompt.images.isEmpty) {
      return _generateContentFromText(model, prompt);
    } else {
      return _generateContentFromMultiModal(model, prompt);
    }
  }

  Future<GenerateContentResponse> _generateContentFromText(
    GenerativeModel model,
    PromptDataModel prompt,
  ) async {
    final mainText = prompt.textInput;
    final additionalTextParts = prompt.additionalTextInputs.join("\n");

    return await model.generateContent([
      Content.text('$mainText\n$additionalTextParts'),
    ]);
  }

  Future<GenerateContentResponse> _generateContentFromMultiModal(
    GenerativeModel model,
    PromptDataModel prompt,
  ) async {
    final mainText = TextPart(prompt.textInput);
    final additionalTextParts =
        prompt.additionalTextInputs.map((t) => TextPart(t));
    final imagesParts = await Future.wait(
      prompt.images.map((f) async {
        final bytes = await f.readAsBytes();
        return DataPart('image/jpeg', bytes);
      }),
    );

    final input = [
      Content.multi([...imagesParts, mainText, ...additionalTextParts])
    ];

    return await model.generateContent(input);
  }
}
