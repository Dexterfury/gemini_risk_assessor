import 'dart:convert';
import 'dart:developer';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/utilities/global.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class AssessmentModel {
  final String id;
  final String title;
  final String taskToAchieve;
  final List<String> equipments;
  final List<String> hazards;
  final List<String> risks;
  final List<String> signatures;
  final List<String> approvers;
  final List<String> ppe;
  final List<String> control;
  final String summary;
  final String createdBy;
  final DateTime createdAt;

  const AssessmentModel({
    required this.id,
    required this.title,
    required this.taskToAchieve,
    required this.equipments,
    required this.hazards,
    required this.risks,
    required this.signatures,
    required this.approvers,
    required this.ppe,
    required this.control,
    required this.summary,
    required this.createdBy,
    required this.createdAt,
  });

  factory AssessmentModel.fromTestString(
    String testString,
    String creatorName,
    DateTime createdAt,
  ) {
    final validJson = cleanJson(testString);
    final json = jsonDecode(validJson);

    if (json is Map<String, dynamic>) {
      return AssessmentModel(
        id: json[Constants.id] ?? '',
        title: json[Constants.title] ?? '',
        taskToAchieve: json[Constants.taskToAchieve] ?? '',
        equipments: List<String>.from(json[Constants.equipments] ?? []),
        hazards: List<String>.from(json[Constants.hazards] ?? []),
        risks: List<String>.from(json[Constants.risks] ?? []),
        signatures: List<String>.from(json[Constants.signatures] ?? []),
        approvers: List<String>.from(json[Constants.approvers] ?? []),
        ppe: List<String>.from(json[Constants.ppe] ?? []),
        control: List<String>.from(json[Constants.control] ?? []),
        summary: json[Constants.summary] ?? '',
        createdBy: creatorName,
        createdAt: createdAt,
      );
    }

    throw JsonUnsupportedObjectError(json);
  }

  factory AssessmentModel.fromGeneratedContent(
    GenerateContentResponse content,
    String creatorName,
    DateTime createdAt,
  ) {
    assert(content.text != null);

    final validJson = cleanJson(content.text!);
    final json = jsonDecode(validJson);

    if (json is Map<String, dynamic>) {
      return AssessmentModel(
        id: json[Constants.id] ?? '',
        title: json[Constants.title] ?? '',
        taskToAchieve: json[Constants.taskToAchieve] ?? '',
        equipments: List<String>.from(json[Constants.equipments] ?? []),
        hazards: List<String>.from(json[Constants.hazards] ?? []),
        risks: List<String>.from(json[Constants.risks] ?? []),
        signatures: List<String>.from(json[Constants.signatures] ?? []),
        approvers: List<String>.from(json[Constants.approvers] ?? []),
        ppe: List<String>.from(json[Constants.ppe] ?? []),
        control: List<String>.from(json[Constants.control] ?? []),
        summary: json[Constants.summary] ?? '',
        createdBy: creatorName,
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
      equipments: List<String>.from(json[Constants.equipments] ?? []),
      hazards: List<String>.from(json[Constants.hazards] ?? []),
      risks: List<String>.from(json[Constants.risks] ?? []),
      signatures: List<String>.from(json[Constants.signatures] ?? []),
      approvers: List<String>.from(json[Constants.approvers] ?? []),
      ppe: List<String>.from(json[Constants.ppe] ?? []),
      control: List<String>.from(json[Constants.control] ?? []),
      summary: json[Constants.summary] ?? '',
      createdBy: json[Constants.createdBy] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(json[Constants.createdAt]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      Constants.id: id,
      Constants.title: title,
      Constants.taskToAchieve: taskToAchieve,
      Constants.equipments: equipments,
      Constants.hazards: hazards,
      Constants.risks: risks,
      Constants.signatures: signatures,
      Constants.approvers: approvers,
      Constants.ppe: ppe,
      Constants.control: control,
      Constants.summary: summary,
      Constants.createdBy: createdBy,
      Constants.createdAt: createdAt.millisecondsSinceEpoch,
    };
  }
}
