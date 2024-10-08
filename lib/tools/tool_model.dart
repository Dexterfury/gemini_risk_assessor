import 'dart:convert';
import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:gemini_risk_assessor/constants.dart';
import '../utilities/global.dart';

class ToolModel {
  String id;
  String title;
  String description;
  String summary;
  List<String> images;
  List<String> reactions;
  List<String> sharedWith;
  String createdBy;
  String groupID;
  DateTime createdAt;

  // constructor
  ToolModel({
    required this.id,
    required this.title,
    required this.description,
    required this.summary,
    required this.images,
    required this.reactions,
    required this.sharedWith,
    required this.createdBy,
    required this.groupID,
    required this.createdAt,
  });

  factory ToolModel.fromGeneratedContent(
    GenerateContentResponse content,
    String toolId,
    String creatorID,
    String groupID,
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
        images: images,
        reactions: List<String>.from(json[Constants.reactions] ?? []),
        sharedWith: List<String>.from(json[Constants.sharedWith] ?? []),
        createdBy: creatorID,
        groupID: groupID,
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
      images: List<String>.from(json[Constants.images] ?? []),
      reactions: List<String>.from(json[Constants.reactions] ?? []),
      sharedWith: List<String>.from(json[Constants.sharedWith] ?? []),
      createdBy: json[Constants.createdBy] ?? '',
      groupID: json[Constants.groupID] ?? '',
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
      Constants.images: images,
      Constants.reactions: reactions,
      Constants.sharedWith: sharedWith,
      Constants.createdBy: createdBy,
      Constants.groupID: groupID,
      Constants.createdAt: createdAt.millisecondsSinceEpoch,
    };
  }

  // create a copy with method
  ToolModel copyWith({
    String? id,
    String? title,
    String? description,
    String? summary,
    List<String>? images,
    List<String>? reactions,
    List<String>? sharedWith,
    int? discussions,
    String? createdBy,
    String? groupID,
    DateTime? createdAt,
  }) {
    return ToolModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      summary: summary ?? this.summary,
      images: images ?? this.images,
      reactions: reactions ?? this.reactions,
      sharedWith: sharedWith ?? this.sharedWith,
      createdBy: createdBy ?? this.createdBy,
      groupID: groupID ?? this.groupID,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
