import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/discussions/discussion_message.dart';
import 'package:gemini_risk_assessor/firebase_options.dart';
import 'package:gemini_risk_assessor/models/assessment_model.dart';
import 'package:gemini_risk_assessor/models/prompt_data_model.dart';
import 'package:gemini_risk_assessor/tools/tool_model.dart';
import 'package:firebase_vertexai/firebase_vertexai.dart';

class GeminiModelManager {
  // Singleton instance
  static final GeminiModelManager _instance = GeminiModelManager._internal();

  // Initialize Firebase and App Check
  Future<void> initializeFirebaseAndAppCheck() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.debug,
      appleProvider: AppleProvider.appAttest,
    );
  }

  // Factory constructor to return the singleton instance
  factory GeminiModelManager() {
    return _instance;
  }

  // Private constructor for singleton pattern
  GeminiModelManager._internal();

  // Configuration for model generation
  final GenerationConfig _config = GenerationConfig(
    temperature: 0.4,
    topK: 32,
    topP: 1,
  );

  // Safety settings to prevent harmful content
  final List<SafetySetting> _safetySettings = [
    SafetySetting(HarmCategory.harassment, HarmBlockThreshold.high),
    SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.high),
    SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.medium),
    SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.none),
  ];

  // Create a new GenerativeModel instance
  GenerativeModel createModel() {
    return FirebaseVertexAI.instance.generativeModel(
      model: 'gemini-1.5-flash',
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

  // generate safety advice using the generated content
  Future<GenerateContentResponse> generateSafetyAdvice(
    String question,
    AssessmentModel assessment,
  ) async {
    final model = await createModel();

    final prompt = PromptDataModel(
      textInput: '''
You are a Safety AI Advisor participating in a group discussion about a safety assessment. 
Provide a concise, professional response to the following question, considering the context of the assessment:

Assessment Context:
Title: ${assessment.title}
Task: ${assessment.taskToAchieve}
Hazards: ${assessment.hazards.join(', ')}
Risks: ${assessment.risks.join(', ')}
Control Measures: ${assessment.control.join(', ')}

Question: $question

Respond in a helpful, safety-focused manner, providing practical advice or clarifications related to the assessment.
''',
      additionalTextInputs: [],
      images: [],
      numberOfPeople: '',
    );

    return await generateContent(model, prompt);
  }

// generate safety quiz using the generated content
  Future<GenerateContentResponse> generateSafetyQuiz(
    AssessmentModel assessment,
    int numberOfQuestions,
  ) async {
    final model = await createModel();

    final prompt = PromptDataModel(
      textInput: '''
Generate a short safety quiz based on the following assessment:

Title: ${assessment.title}
Task: ${assessment.taskToAchieve}
Hazards: ${assessment.hazards.join(', ')}
Risks: ${assessment.risks.join(', ')}
Control Measures: ${assessment.control.join(', ')}

Create $numberOfQuestions multiple-choice questions related to the safety aspects of this assessment. 
Format the response as a JSON object with the following structure:
{
  "title": \$quizTitle,
  "questions": [
    {
      "question": "Question text",
      "options": ["Option A", "Option B", "Option C", "Option D"],
      "correctAnswer": "Correct option letter (A, B, C, or D)"
    },
    // ... (2 more questions)
  ]
}
''',
      additionalTextInputs: [],
      images: [],
    );

    final response = await generateContent(model, prompt);

    return response;
  }

  Future<GenerateContentResponse> generateSafetyToolsQuiz(
      ToolModel tool) async {
    final model = await createModel();

    final prompt = PromptDataModel(
      textInput: '''
Generate a short safety quiz based on the following tool:

Title: ${tool.title}
description: ${tool.description}

Create 3 multiple-choice questions related to the safety aspects of this tool. 
Format the response as a JSON object with the following structure:
{
  "title": \$quizTitle,
  "questions": [
    {
      "question": "Question text",
      "options": ["Option A", "Option B", "Option C", "Option D"],
      "correctAnswer": "Correct option letter (A, B, C, or D)"
    },
    // ... (2 more questions)
  ]
}
''',
      additionalTextInputs: [],
      images: [],
    );

    final response = await generateContent(model, prompt);

    return response;
  }

// generate safety tip of the day using the generated content
  Future<String> generateSafetyTipOfTheDay(List<String> recentTopics) async {
    final model = await createModel();

    final prompt = PromptDataModel(
      textInput: '''
Generate a concise, practical "Safety Tip of the Day" related to one of the following recent topics in our safety discussions:

${recentTopics.join('\n')}

The tip should be informative, easy to understand, and immediately applicable in a workplace setting.
Limit the response to 2-3 sentences.
''',
      additionalTextInputs: [],
      images: [],
    );

    final response = await generateContent(model, prompt);
    return response.text ?? 'Unable to generate a safety tip at this time.';
  }

// generate a list of additional risks based on the given assessment
  Future<GenerateContentResponse> suggestAdditionalRisks(
      AssessmentModel assessment) async {
    final model = await createModel();

    final prompt = PromptDataModel(
      textInput: '''
Review the following safety assessment and suggest up to 3 potential additional risks or hazards that may have been overlooked:

Title: ${assessment.title}
Task: ${assessment.taskToAchieve}
Current Hazards: ${assessment.hazards.join(', ')}
Current Risks: ${assessment.risks.join(', ')}
Control Measures: ${assessment.control.join(', ')}

Format the response as a JSON object with the following structure:
{
  "hazards": \$hazards,
  "risks": \$risks,
  "control": \$control,
}

all data should be of type List<String>
''',
      additionalTextInputs: [],
      images: [],
    );

    final response = await generateContent(model, prompt);
    return response;
  }

// summerize the list of chat messages
  Future<GenerateContentResponse> summarizeChatMessages(
      List<DiscussionMessage> messages) async {
    final model = await createModel();

    // Extract relevant data from messages
    List<Map<String, String>> relevantData = messages
        .map((msg) => {
              Constants.senderName: msg.senderName,
              Constants.message: msg.message,
            })
        .toList();

    // Prepare the prompt
    String prompt = 'Summarize the following conversation:\n\n';

    // Handle token limit (we start at 500000)
    int tokenLimit = 500000;
    int estimatedTokens =
        prompt.length ~/ 4; // Rough estimate: 1 token ≈ 4 characters

    for (var i = relevantData.length - 1; i >= 0; i--) {
      String messageText =
          '${relevantData[i][Constants.senderName]}: ${relevantData[i][Constants.message]}\n';
      int messageTokens = messageText.length ~/ 4;

      if (estimatedTokens + messageTokens > tokenLimit) {
        // If adding this message would exceed the token limit, stop here
        break;
      }

      prompt = messageText + prompt;
      estimatedTokens += messageTokens;
    }

    prompt +=
        '\nPlease provide a concise summary of the main points discussed in this conversation.';

    final promptData = PromptDataModel(
      textInput: prompt,
      additionalTextInputs: [],
      images: [],
    );

    return await generateContent(model, promptData);
  }

  Future<GenerateContentResponse> generateNearMissReport(
      String nearMissDescription) async {
    final model = await createModel();

    final prompt = PromptDataModel(
      textInput: '''
You are a Safety AI Advisor tasked with analyzing a near miss report and suggesting appropriate control measures to prevent similar incidents or accidents from occurring in the future.

Near Miss Description:
$nearMissDescription

Based on this near miss report, generate a list of 3-5 practical and effective control measures. These measures should aim to eliminate or reduce the risk of similar incidents occurring in the future. Consider the hierarchy of controls (Elimination, Substitution, Engineering Controls, Administrative Controls, and Personal Protective Equipment) when suggesting measures.

Format the response as a JSON object with the following structure:
{
  "controlMeasures": [
    {
      "measure": "Description of the control measure",
      "type": "Type of control (e.g., Engineering, Administrative, PPE)",
      "reason": "Brief explanation of why this measure is effective"
    },
    // ... (2-4 more control measures)
  ]
}
''',
      additionalTextInputs: [],
      images: [],
    );

    return await generateContent(model, prompt);
  }
}
