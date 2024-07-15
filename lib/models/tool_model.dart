import 'dart:convert';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../utilities/global.dart';

class ToolModel {
  String id;
  String title;
  String description;
  String summary;
  String toolPdf;
  List<String> images;
  List<String> reactions;
  List<String> sharedWith;
  String createdBy;
  String organizationID;
  DateTime createdAt;

  // constructor
  ToolModel({
    required this.id,
    required this.title,
    required this.description,
    required this.summary,
    required this.toolPdf,
    required this.images,
    required this.reactions,
    required this.sharedWith,
    required this.createdBy,
    required this.organizationID,
    required this.createdAt,
  });

  factory ToolModel.fromGeneratedContent(
    GenerateContentResponse content,
    String toolId,
    String creatorID,
    String organizationID,
    List<String> images,
    DateTime createdAt,
  ) {
    assert(content.text != null);

    final validJson = cleanJson(content.text!);
    final json = jsonDecode(validJson);

    if (json is Map<String, dynamic>) {
      return ToolModel(
        id: toolId,
        title: json[Constants.title] ?? '',
        description: json[Constants.description] ?? '',
        summary: json[Constants.summary] ?? '',
        toolPdf: json[Constants.toolPdf] ?? '',
        images: images,
        reactions: List<String>.from(json[Constants.reactions] ?? []),
        sharedWith: List<String>.from(json[Constants.sharedWith] ?? []),
        createdBy: creatorID,
        organizationID: organizationID,
        createdAt: createdAt,
      );
    }

    throw JsonUnsupportedObjectError(json);
  }

  // factory method to convert json to ToolModel object
  factory ToolModel.fromJson(Map<String, dynamic> json) {
    return ToolModel(
      id: json[Constants.id] ?? '',
      title: json[Constants.title] ?? '',
      description: json[Constants.description] ?? '',
      summary: json[Constants.summary] ?? '',
      toolPdf: json[Constants.toolPdf] ?? '',
      images: List<String>.from(json[Constants.images] ?? []),
      reactions: List<String>.from(json[Constants.reactions] ?? []),
      sharedWith: List<String>.from(json[Constants.sharedWith] ?? []),
      createdBy: json[Constants.createdBy] ?? '',
      organizationID: json[Constants.organizationID] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(json[Constants.createdAt]),
    );
  }

  // toJson method to convert ToolModel object to json
  Map<String, dynamic> toJson() {
    return {
      Constants.id: id,
      Constants.title: title,
      Constants.description: description,
      Constants.summary: summary,
      Constants.toolPdf: toolPdf,
      Constants.images: images,
      Constants.reactions: reactions,
      Constants.sharedWith: sharedWith,
      Constants.createdBy: createdBy,
      Constants.organizationID: organizationID,
      Constants.createdAt: createdAt.millisecondsSinceEpoch,
    };
  }

  // create a copy with method
  ToolModel copyWith({
    String? id,
    String? title,
    String? description,
    String? summary,
    String? toolPdf,
    List<String>? images,
    List<String>? reactions,
    List<String>? sharedWith,
    String? createdBy,
    String? organizationID,
    DateTime? createdAt,
  }) {
    return ToolModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      summary: summary ?? this.summary,
      toolPdf: toolPdf ?? this.toolPdf,
      images: images ?? this.images,
      reactions: reactions ?? this.reactions,
      sharedWith: sharedWith ?? this.sharedWith,
      createdBy: createdBy ?? this.createdBy,
      organizationID: organizationID ?? this.organizationID,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
