import 'dart:convert';

import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/utilities/global.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class AssessmentModel {
  String id;
  String title;
  String tastToAchieve;
  List<String> equipments;
  List<String> hazards;
  List<String> risks;
  List<String> signatures;
  List<String> approvers;
  List<String> ppe;
  String control;
  String summary;
  String createdBy;
  DateTime createdAt;

  // constructor
  AssessmentModel({
    required this.id,
    required this.title,
    required this.tastToAchieve,
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

  factory AssessmentModel.fromGeneratedContent(
    GenerateContentResponse content,
    String creatorName,
    DateTime createdAt,
  ) {
    /// failures should be handled when the response is received
    assert(content.text != null);

    final validJson = cleanJson(content.text!);
    final json = jsonDecode(validJson);

    if (json
        case {
          Constants.id: String id,
          Constants.title: String title,
          Constants.taskToAchieve: String taskToAchieve,
          Constants.equipments: List<String> equipments,
          Constants.hazards: List<String> hazards,
          Constants.risks: List<String> risks,
          Constants.signatures: List<String> signatures,
          Constants.approvers: List<String> approvers,
          Constants.ppe: List<String> ppe,
          Constants.control: String control,
          Constants.summary: String summary,
        }) {
      return AssessmentModel(
        id: id,
        title: title,
        tastToAchieve: taskToAchieve,
        equipments: equipments.map((i) => i.toString()).toList(),
        hazards: hazards.map((i) => i.toString()).toList(),
        risks: risks.map((i) => i.toString()).toList(),
        signatures: signatures.map((i) => i.toString()).toList(),
        approvers: approvers.map((i) => i.toString()).toList(),
        ppe: ppe.map((i) => i.toString()).toList(),
        control: control,
        summary: summary,
        createdBy: creatorName,
        createdAt: createdAt,
      );
    }

    throw JsonUnsupportedObjectError(json);
  }

  // factory method
  factory AssessmentModel.fromJson(Map<String, dynamic> json) {
    return AssessmentModel(
      id: json[Constants.id] ?? '',
      title: json[Constants.title] ?? '',
      tastToAchieve: json[Constants.taskToAchieve] ?? '',
      equipments: json[Constants.equipments] ?? [],
      hazards: json[Constants.hazards] ?? [],
      risks: json[Constants.risks] ?? [],
      signatures: json[Constants.signatures] ?? [],
      approvers: json[Constants.approvers] ?? [],
      ppe: json[Constants.ppe] ?? [],
      control: json[Constants.control] ?? '',
      summary: json[Constants.summary] ?? '',
      createdBy: json[Constants.createdBy] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(json[Constants.createdAt]),
    );
  }

  // to json method
  Map<String, dynamic> toJson() {
    return {
      Constants.id: id,
      Constants.title: title,
      Constants.taskToAchieve: tastToAchieve,
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

  // copy with method
  copyWith(
      {String? id,
      String? title,
      String? tastToAchieve,
      List<String>? equipments,
      List<String>? hazards,
      List<String>? risks,
      List<String>? signatures,
      List<String>? approvers,
      List<String>? ppe,
      String? control,
      String? summary,
      String? createdBy,
      DateTime? createdAt}) {
    return AssessmentModel(
      id: id ?? this.id,
      title: title ?? this.title,
      tastToAchieve: tastToAchieve ?? this.tastToAchieve,
      equipments: equipments ?? this.equipments,
      hazards: hazards ?? this.hazards,
      risks: risks ?? this.risks,
      signatures: signatures ?? this.signatures,
      approvers: approvers ?? this.approvers,
      ppe: ppe ?? this.ppe,
      control: control ?? this.control,
      summary: summary ?? this.summary,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
