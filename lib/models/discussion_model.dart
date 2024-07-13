import 'package:gemini_risk_assessor/constants.dart';

class DiscussionModel {
  String id;
  String title;
  String description;
  String discussingAbout;
  String createdBy;
  String organizationID;
  String createdAt;

  // constructor
  DiscussionModel({
    required this.id,
    required this.title,
    required this.description,
    required this.discussingAbout,
    required this.createdBy,
    required this.organizationID,
    required this.createdAt,
  });

  // fromJson method
  factory DiscussionModel.fromJson(Map<String, dynamic> json) {
    return DiscussionModel(
      id: json[Constants.id] ?? '',
      title: json[Constants.title] ?? '',
      description: json[Constants.description] ?? '',
      discussingAbout: json[Constants.discussingAbout] ?? '',
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
      Constants.discussingAbout: discussingAbout,
      Constants.createdBy: createdBy,
      Constants.organizationID: organizationID,
      Constants.createdAt: createdAt,
    };
  }
}
