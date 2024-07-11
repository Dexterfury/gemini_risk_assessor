import 'dart:convert';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../utilities/global.dart';

class ToolModel {
  String id;
  String name;
  String description;
  String summary;
  String toolPdf;
  List<String> images;
  List<String> reactions;
  String createdBy;
  String organizationID;
  bool isShared;
  DateTime createdAt;

  // constructor
  ToolModel({
    required this.id,
    required this.name,
    required this.description,
    required this.summary,
    required this.toolPdf,
    required this.images,
    required this.reactions,
    required this.createdBy,
    required this.organizationID,
    required this.isShared,
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
        name: json[Constants.name] ?? '',
        description: json[Constants.description] ?? '',
        summary: json[Constants.summary] ?? '',
        toolPdf: json[Constants.toolPdf] ?? '',
        images: images,
        reactions: List<String>.from(json[Constants.reactions] ?? []),
        createdBy: creatorID,
        organizationID: organizationID,
        isShared: json[Constants.isShared] ?? false,
        createdAt: createdAt,
      );
    }

    throw JsonUnsupportedObjectError(json);
  }

  // factory method to convert json to ToolModel object
  factory ToolModel.fromJson(Map<String, dynamic> json) {
    return ToolModel(
      id: json[Constants.id] ?? '',
      name: json[Constants.name] ?? '',
      description: json[Constants.description] ?? '',
      summary: json[Constants.summary] ?? '',
      toolPdf: json[Constants.toolPdf] ?? '',
      images: List<String>.from(json[Constants.images] ?? []),
      reactions: List<String>.from(json[Constants.reactions] ?? []),
      createdBy: json[Constants.createdBy] ?? '',
      organizationID: json[Constants.organizationID] ?? '',
      isShared: json[Constants.isShared] ?? false,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json[Constants.createdAt]),
    );
  }

  // toJson method to convert ToolModel object to json
  Map<String, dynamic> toJson() {
    return {
      Constants.id: id,
      Constants.name: name,
      Constants.description: description,
      Constants.summary: summary,
      Constants.toolPdf: toolPdf,
      Constants.images: images,
      Constants.reactions: reactions,
      Constants.createdBy: createdBy,
      Constants.organizationID: organizationID,
      Constants.isShared: isShared,
      Constants.createdAt: createdAt.millisecondsSinceEpoch,
    };
  }
}
