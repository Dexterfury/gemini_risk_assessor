import 'package:gemini_risk_assessor/constants.dart';

class ToolModel {
  String id;
  String name;
  String description;
  String toolPdf;
  List<String> images;
  String createdBy;
  DateTime createdAt;

  // constructor
  ToolModel({
    required this.id,
    required this.name,
    required this.description,
    required this.toolPdf,
    required this.images,
    required this.createdBy,
    required this.createdAt,
  });

  // factory method to convert json to ToolModel object
  factory ToolModel.fromJson(Map<String, dynamic> json) {
    return ToolModel(
      id: json[Constants.id] ?? '',
      name: json[Constants.name] ?? '',
      description: json[Constants.description] ?? '',
      toolPdf: json[Constants.toolPdf] ?? '',
      images: List<String>.from(json[Constants.images] ?? []),
      createdBy: json[Constants.createdBy] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(json[Constants.createdAt]),
    );
  }

  // toJson method to convert ToolModel object to json
  Map<String, dynamic> toJson() {
    return {
      Constants.id: id,
      Constants.name: name,
      Constants.description: description,
      Constants.toolPdf: toolPdf,
      Constants.images: images,
      Constants.createdBy: createdBy,
      Constants.createdAt: createdAt.millisecondsSinceEpoch,
    };
  }
}
