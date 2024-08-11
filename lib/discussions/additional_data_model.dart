import 'dart:convert';
import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/utilities/global.dart';

class AdditionalDataModel {
  final String creatorUID;
  final String itemID;
  final List<String> hazards;
  final List<String> risks;
  final List<String> control;
  final DateTime createdAt;

  // constructor
  AdditionalDataModel({
    required this.creatorUID,
    required this.itemID,
    required this.hazards,
    required this.risks,
    required this.control,
    required this.createdAt,
  });

  factory AdditionalDataModel.fromGeneratedContent(
    GenerateContentResponse content,
    String creatorUID,
    String itemID,
    DateTime createdAt,
  ) {
    assert(content.text != null);

    final validJson = cleanJson(content.text!);
    final json = jsonDecode(validJson);

    if (json is Map<String, dynamic>) {
      return AdditionalDataModel(
        creatorUID: creatorUID,
        itemID: itemID,
        hazards: List<String>.from(json[Constants.hazards] ?? []),
        risks: List<String>.from(json[Constants.risks] ?? []),
        control: List<String>.from(json[Constants.control] ?? []),
        createdAt: createdAt,
      );
    }

    throw JsonUnsupportedObjectError(json);
  }

  // fromJson constructor
  factory AdditionalDataModel.fromJson(Map<String, dynamic> json) {
    return AdditionalDataModel(
      creatorUID: json[Constants.creatorUID] ?? '',
      itemID: json[Constants.itemID] ?? '',
      hazards: List<String>.from(json[Constants.hazards] ?? []),
      risks: List<String>.from(json[Constants.risks] ?? []),
      control: List<String>.from(json[Constants.control] ?? []),
      createdAt:
          DateTime.fromMillisecondsSinceEpoch(json[Constants.createdAt] ?? 0),
    );
  }

  // toJson constructor
  Map<String, dynamic> toJson() {
    return {
      Constants.creatorUID: creatorUID,
      Constants.itemID: itemID,
      Constants.hazards: hazards,
      Constants.risks: risks,
      Constants.control: control,
      Constants.createdAt: createdAt.millisecondsSinceEpoch,
    };
  }

  // copy with constructor
  AdditionalDataModel copyWith({
    String? creatorUID,
    String? itemID,
    List<String>? hazards,
    List<String>? risks,
    List<String>? control,
    DateTime? createdAt,
  }) {
    return AdditionalDataModel(
      creatorUID: creatorUID ?? this.creatorUID,
      itemID: itemID ?? this.itemID,
      hazards: hazards ?? this.hazards,
      risks: risks ?? this.risks,
      control: control ?? this.control,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // empty constructor
  static AdditionalDataModel empty() {
    return AdditionalDataModel(
      creatorUID: '',
      itemID: '',
      hazards: [],
      risks: [],
      control: [],
      createdAt: DateTime.now(),
    );
  }
}
