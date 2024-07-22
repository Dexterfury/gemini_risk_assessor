import 'package:gemini_risk_assessor/constants.dart';

class NearMissModel {
  String id;
  String title;
  String description;
  List<String> images;
  List<String> sharedWith;
  List<String> reactions;
  String createdBy;
  String organizationID;
  String createdAt;

  // constructor
  NearMissModel({
    required this.id,
    required this.title,
    required this.description,
    required this.images,
    required this.sharedWith,
    required this.reactions,
    required this.createdBy,
    required this.organizationID,
    required this.createdAt,
  });

  // fromJson method
  factory NearMissModel.fromJson(Map<String, dynamic> json) {
    return NearMissModel(
      id: json[Constants.id] ?? '',
      title: json[Constants.title] ?? '',
      description: json[Constants.description] ?? '',
      images: List<String>.from(json[Constants.images] ?? []),
      sharedWith: List<String>.from(json[Constants.sharedWith] ?? []),
      reactions: List<String>.from(json[Constants.reactions] ?? []),
      createdBy: json[Constants.createdBy] ?? '',
      organizationID: json[Constants.organizationID] ?? '',
      createdAt: json[Constants.createdAt] ?? '',
    );
  }

  // toJson method
  Map<String, dynamic> toJson() {
    return {
      Constants.id: id,
      Constants.title: title,
      Constants.description: description,
      Constants.images: images,
      Constants.sharedWith: sharedWith,
      Constants.reactions: reactions,
      Constants.createdBy: createdBy,
      Constants.organizationID: organizationID,
      Constants.createdAt: createdAt,
    };
  }
}
