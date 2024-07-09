import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gemini_risk_assessor/models/prompt_data_model.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiModelManager {
  // Singleton instance
  static final GeminiModelManager _instance = GeminiModelManager._internal();

  // Factory constructor to return the singleton instance
  factory GeminiModelManager() {
    return _instance;
  }

  // Private constructor for singleton pattern
  GeminiModelManager._internal();

  // Cached instances of text and vision models
  GenerativeModel? _textModel;
  GenerativeModel? _visionModel;

  // Configuration for model generation
  final GenerationConfig _config = GenerationConfig(
    temperature: 0.4,
    topK: 32,
    topP: 1,
    //maxOutputTokens: 4096, // Commented out, adjust if needed
  );

  // Safety settings to prevent harmful content
  final List<SafetySetting> _safetySettings = [
    SafetySetting(HarmCategory.harassment, HarmBlockThreshold.high),
    SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.high),
  ];

  // Retrieve API key from environment variables
  String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

  // Get appropriate model based on task requirements
  Future<GenerativeModel> getModel({
    required bool isVision,
    required bool isDocumentSpecific,
  }) async {
    if (isDocumentSpecific) {
      // For document-specific tasks, always create a new 'gemini-1.5-flash' model
      return _createModel('gemini-1.5-flash');
    } else if (!isVision) {
      // For non-vision tasks, use or create a cached 'gemini-1.5-flash' model
      _textModel ??= _createModel('gemini-1.5-flash');
      // '??=' is the null-aware assignment operator:
      // It only creates a new model if _textModel is null
      return _textModel!;
    } else {
      // For vision tasks, use or create a cached 'gemini-1.0-pro' model
      _visionModel ??= _createModel('gemini-1.0-pro');
      // Similar to above, create a new vision model only if it doesn't exist
      return _visionModel!;
    }
  }

  // Create a new GenerativeModel instance
  GenerativeModel _createModel(String modelName) {
    return GenerativeModel(
      model: modelName,
      apiKey: _apiKey,
      generationConfig: _config,
      safetySettings: _safetySettings,
    );
  }

  // Generate content based on the provided prompt
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

  // Generate content from text-only prompt
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

  // Generate content from multi-modal prompt (text and images)
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
