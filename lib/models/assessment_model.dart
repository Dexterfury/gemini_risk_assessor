import 'dart:convert';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/utilities/global.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class AssessmentModel {
  String id;
  String title;
  String taskToAchieve;
  List<String> images;
  List<String> equipments;
  List<String> hazards;
  List<String> risks;
  List<String> ppe;
  List<String> control;
  List<String> reactions;
  List<String> sharedWith;
  String weather;
  String summary;
  String createdBy;
  String groupID;
  DateTime createdAt;

  AssessmentModel({
    required this.id,
    required this.title,
    required this.taskToAchieve,
    required this.images,
    required this.equipments,
    required this.hazards,
    required this.risks,
    required this.ppe,
    required this.control,
    required this.reactions,
    required this.sharedWith,
    required this.weather,
    required this.summary,
    required this.createdBy,
    required this.groupID,
    required this.createdAt,
  });

  factory AssessmentModel.fromTestString(
    String testString,
    String assessmentId,
    String creatorID,
    String groupID,
    String weather,
    List<String> testppe,
    List<String> testImages,
    DateTime createdAt,
  ) {
    final validJson = cleanJson(testString);
    final json = jsonDecode(validJson);

    if (json is Map<String, dynamic>) {
      return AssessmentModel(
        id: assessmentId,
        title: json[Constants.title] ?? '',
        taskToAchieve: json[Constants.taskToAchieve] ?? '',
        images: testImages,
        equipments: List<String>.from(json[Constants.equipments] ?? []),
        hazards: List<String>.from(json[Constants.hazards] ?? []),
        risks: List<String>.from(json[Constants.risks] ?? []),
        ppe: testppe,
        control: List<String>.from(json[Constants.control] ?? []),
        reactions: List<String>.from(json[Constants.reactions] ?? []),
        sharedWith: List<String>.from(json[Constants.sharedWith] ?? []),
        weather: weather,
        summary: json[Constants.summary] ?? '',
        createdBy: creatorID,
        groupID: groupID,
        createdAt: createdAt,
      );
    }

    throw JsonUnsupportedObjectError(json);
  }

  factory AssessmentModel.fromGeneratedContent(
    GenerateContentResponse content,
    String assessmentId,
    String creatorID,
    String groupID,
    String weather,
    List<String> ppe,
    List<String> images,
    DateTime createdAt,
  ) {
    assert(content.text != null);

    final validJson = cleanJson(content.text!);
    final json = jsonDecode(validJson);

    if (json is Map<String, dynamic>) {
      return AssessmentModel(
        id: assessmentId,
        title: json[Constants.title] ?? '',
        taskToAchieve: json[Constants.taskToAchieve] ?? '',
        images: images,
        equipments: List<String>.from(json[Constants.equipments] ?? []),
        hazards: List<String>.from(json[Constants.hazards] ?? []),
        risks: List<String>.from(json[Constants.risks] ?? []),
        ppe: ppe,
        control: List<String>.from(json[Constants.control] ?? []),
        reactions: List<String>.from(json[Constants.reactions] ?? []),
        sharedWith: List<String>.from(json[Constants.sharedWith] ?? []),
        weather: weather,
        summary: json[Constants.summary] ?? '',
        createdBy: creatorID,
        groupID: groupID,
        createdAt: createdAt,
      );
    }

    throw JsonUnsupportedObjectError(json);
  }

  factory AssessmentModel.fromJson(Map<String, dynamic> json) {
    return AssessmentModel(
      id: json[Constants.id] ?? '',
      title: json[Constants.title] ?? '',
      taskToAchieve: json[Constants.taskToAchieve] ?? '',
      images: List<String>.from(json[Constants.images] ?? []),
      equipments: List<String>.from(json[Constants.equipments] ?? []),
      hazards: List<String>.from(json[Constants.hazards] ?? []),
      risks: List<String>.from(json[Constants.risks] ?? []),
      ppe: List<String>.from(json[Constants.ppe] ?? []),
      control: List<String>.from(json[Constants.control] ?? []),
      reactions: List<String>.from(json[Constants.reactions] ?? []),
      sharedWith: List<String>.from(json[Constants.sharedWith] ?? []),
      weather: json[Constants.weather] ?? '',
      summary: json[Constants.summary] ?? '',
      createdBy: json[Constants.createdBy] ?? '',
      groupID: json[Constants.groupID] ?? '',
      createdAt:
          DateTime.fromMillisecondsSinceEpoch(json[Constants.createdAt] ?? 0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      Constants.id: id,
      Constants.title: title,
      Constants.taskToAchieve: taskToAchieve,
      Constants.images: images,
      Constants.equipments: equipments,
      Constants.hazards: hazards,
      Constants.risks: risks,
      Constants.ppe: ppe,
      Constants.control: control,
      Constants.reactions: reactions,
      Constants.sharedWith: sharedWith,
      Constants.weather: weather,
      Constants.summary: summary,
      Constants.createdBy: createdBy,
      Constants.groupID: groupID,
      Constants.createdAt: createdAt.millisecondsSinceEpoch,
    };
  }

  // copy with method
  AssessmentModel copyWith({
    String? id,
    String? title,
    String? taskToAchieve,
    List<String>? images,
    List<String>? equipments,
    List<String>? hazards,
    List<String>? risks,
    List<String>? ppe,
    List<String>? control,
    List<String>? reactions,
    List<String>? sharedWith,
    int? discussions,
    String? weather,
    String? summary,
    String? createdBy,
    String? groupID,
    DateTime? createdAt,
  }) {
    return AssessmentModel(
      id: id ?? this.id,
      title: title ?? this.title,
      taskToAchieve: taskToAchieve ?? this.taskToAchieve,
      images: images ?? this.images,
      equipments: equipments ?? this.equipments,
      hazards: hazards ?? this.hazards,
      risks: risks ?? this.risks,
      ppe: ppe ?? this.ppe,
      control: control ?? this.control,
      reactions: reactions ?? this.reactions,
      sharedWith: sharedWith ?? this.sharedWith,
      weather: weather ?? this.weather,
      summary: summary ?? this.summary,
      createdBy: createdBy ?? this.createdBy,
      groupID: groupID ?? this.groupID,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
