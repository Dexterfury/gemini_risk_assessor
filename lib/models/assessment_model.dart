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
  List<String> signatures;
  List<String> approvers;
  List<String> ppe;
  List<String> control;
  String weather;
  String summary;
  String createdBy;
  String organisationID;
  String pdfUrl;
  DateTime createdAt;

  AssessmentModel({
    required this.id,
    required this.title,
    required this.taskToAchieve,
    required this.images,
    required this.equipments,
    required this.hazards,
    required this.risks,
    required this.signatures,
    required this.approvers,
    required this.ppe,
    required this.control,
    required this.weather,
    required this.summary,
    required this.createdBy,
    required this.organisationID,
    required this.pdfUrl,
    required this.createdAt,
  });

  factory AssessmentModel.fromTestString(
    String testString,
    String creatorID,
    String organisationID,
    String weather,
    List<String> testppe,
    List<String> testImages,
    DateTime createdAt,
  ) {
    final validJson = cleanJson(testString);
    final json = jsonDecode(validJson);

    if (json is Map<String, dynamic>) {
      return AssessmentModel(
        id: json[Constants.id] ?? '',
        title: json[Constants.title] ?? '',
        taskToAchieve: json[Constants.taskToAchieve] ?? '',
        images: testImages,
        equipments: List<String>.from(json[Constants.equipments] ?? []),
        hazards: List<String>.from(json[Constants.hazards] ?? []),
        risks: List<String>.from(json[Constants.risks] ?? []),
        signatures: List<String>.from(json[Constants.signatures] ?? []),
        approvers: List<String>.from(json[Constants.approvers] ?? []),
        ppe: testppe,
        control: List<String>.from(json[Constants.control] ?? []),
        weather: weather,
        summary: json[Constants.summary] ?? '',
        createdBy: creatorID,
        organisationID: organisationID,
        pdfUrl: Constants.pdfUrl,
        createdAt: createdAt,
      );
    }

    throw JsonUnsupportedObjectError(json);
  }

  factory AssessmentModel.fromGeneratedContent(
    GenerateContentResponse content,
    String creatorID,
    String organisationID,
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
        id: json[Constants.id] ?? '',
        title: json[Constants.title] ?? '',
        taskToAchieve: json[Constants.taskToAchieve] ?? '',
        images: images,
        equipments: List<String>.from(json[Constants.equipments] ?? []),
        hazards: List<String>.from(json[Constants.hazards] ?? []),
        risks: List<String>.from(json[Constants.risks] ?? []),
        signatures: List<String>.from(json[Constants.signatures] ?? []),
        approvers: List<String>.from(json[Constants.approvers] ?? []),
        ppe: ppe,
        control: List<String>.from(json[Constants.control] ?? []),
        weather: weather,
        summary: json[Constants.summary] ?? '',
        createdBy: creatorID,
        organisationID: organisationID,
        pdfUrl: json[Constants.pdfUrl] ?? '',
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
      signatures: List<String>.from(json[Constants.signatures] ?? []),
      approvers: List<String>.from(json[Constants.approvers] ?? []),
      ppe: List<String>.from(json[Constants.ppe] ?? []),
      control: List<String>.from(json[Constants.control] ?? []),
      weather: json[Constants.weather] ?? '',
      summary: json[Constants.summary] ?? '',
      createdBy: json[Constants.createdBy] ?? '',
      organisationID: json[Constants.organisationID] ?? '',
      pdfUrl: json[Constants.pdfUrl] ?? '',
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
      Constants.signatures: signatures,
      Constants.approvers: approvers,
      Constants.ppe: ppe,
      Constants.control: control,
      Constants.weather: weather,
      Constants.summary: summary,
      Constants.createdBy: createdBy,
      Constants.organisationID: organisationID,
      Constants.pdfUrl: pdfUrl,
      Constants.createdAt: createdAt.millisecondsSinceEpoch,
    };
  }
}
