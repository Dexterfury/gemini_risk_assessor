import 'dart:convert';
import 'dart:developer';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/utilities/global.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class QuizModel {
  final String creatorUID;
  final String title;
  final String quizID;
  final String itemID;
  final DateTime createdAt;
  final List<Map<String, dynamic>> questions;

  // constructor
  QuizModel({
    required this.creatorUID,
    required this.title,
    required this.quizID,
    required this.itemID,
    required this.createdAt,
    required this.questions,
  });

  factory QuizModel.fromGeneratedContent(
    GenerateContentResponse content,
    String itemID,
    String creatorUID,
    String quizID,
    DateTime createdAt,
  ) {
    assert(content.text != null);

    final validJson = cleanJson(content.text!);
    final json = jsonDecode(validJson);

    if (json is Map<String, dynamic>) {
      return QuizModel(
        creatorUID: creatorUID,
        title: json[Constants.title],
        quizID: quizID,
        itemID: itemID,
        createdAt: createdAt,
        questions: List<Map<String, dynamic>>.from(
          json[Constants.questions].map((q) => Map<String, dynamic>.from(q)),
        ),
      );
    }

    throw JsonUnsupportedObjectError(json);
  }

  // factory method from json
  factory QuizModel.fromJson(Map<String, dynamic> json) {
    return QuizModel(
      creatorUID: json[Constants.creatorUID] ?? '',
      title: json[Constants.title] ?? '',
      quizID: json[Constants.quizID] ?? '',
      itemID: json[Constants.itemID] ?? '',
      createdAt:
          DateTime.fromMillisecondsSinceEpoch(json[Constants.createdAt] ?? 0),
      questions: List<Map<String, dynamic>>.from(
        json[Constants.questions]?.map((x) => x as Map<String, dynamic>) ?? [],
      ),
    );
  }

  // to json
  Map<String, dynamic> toJson() {
    return {
      Constants.creatorUID: creatorUID,
      Constants.title: title,
      Constants.quizID: quizID,
      Constants.itemID: itemID,
      Constants.createdAt: createdAt.millisecondsSinceEpoch,
      Constants.questions: questions,
    };
  }

  // copywith
  QuizModel copyWith({
    String? creatorUID,
    String? title,
    String? quizID,
    String? itemID,
    DateTime? createdAt,
    List<Map<String, dynamic>>? questions,
  }) {
    return QuizModel(
      creatorUID: creatorUID ?? this.creatorUID,
      title: title ?? this.title,
      quizID: quizID ?? this.quizID,
      itemID: itemID ?? this.itemID,
      createdAt: createdAt ?? this.createdAt,
      questions: questions ?? this.questions,
    );
  }

  // empty quiz model
  static QuizModel get empty => QuizModel(
        creatorUID: '',
        title: '',
        quizID: '',
        itemID: '',
        createdAt: DateTime.now(),
        questions: [],
      );
}
