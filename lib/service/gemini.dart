import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gemini_risk_assessor/models/prompt_data_model.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  static Future<GenerateContentResponse> generateContent(
      GenerativeModel model, PromptDataModel prompt) async {
    if (prompt.images.isEmpty) {
      return await GeminiService.generateContentFromText(model, prompt);
    } else {
      return await GeminiService.generateContentFromMultiModal(model, prompt);
    }
  }

  static Future<GenerateContentResponse> generateContentFromMultiModal(
      GenerativeModel model, PromptDataModel prompt) async {
    final mainText = TextPart(prompt.textInput);
    final additionalTextParts =
        prompt.additionalTextInputs.map((t) => TextPart(t));
    final imagesParts = <DataPart>[];

    for (var f in prompt.images) {
      final bytes = await (f.readAsBytes());
      imagesParts.add(DataPart('image/jpeg', bytes));
    }

    final input = [
      Content.multi([...imagesParts, mainText, ...additionalTextParts])
    ];

    return await model.generateContent(
      input,
      generationConfig: GenerationConfig(
        temperature: 0.4,
        topK: 32,
        topP: 1,
        maxOutputTokens: 4096,
      ),
      safetySettings: [
        SafetySetting(HarmCategory.harassment, HarmBlockThreshold.high),
        SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.high),
      ],
    );
  }

  static Future<GenerateContentResponse> generateContentFromText(
      GenerativeModel model, PromptDataModel prompt) async {
    final mainText = TextPart(prompt.textInput);
    final additionalTextParts =
        prompt.additionalTextInputs.map((t) => TextPart(t)).join("\n");

    return await model.generateContent([
      Content.text(
        '${mainText.text} \n $additionalTextParts',
      )
    ]);
  }


  // function to set the model based on if images are present
  static Future<GenerativeModel> getModel({required int images}) async {
    if (images < 10) {
      return GenerativeModel(
        model: 'gemini-1.5-flash',
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
        ],
      );
    } else {
      return GenerativeModel(
        model: 'gemini-pro',
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
        ],
      );
    }
  }

  // get api key from env
  static String getApiKey() {
    return dotenv.env['GEMINI_API_KEY'].toString();
  }
}
