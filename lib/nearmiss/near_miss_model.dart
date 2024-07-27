import 'dart:convert';

import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/nearmiss/control_measure.dart';
import 'package:gemini_risk_assessor/utilities/global.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class NearMissModel {
  String id;
  String location;
  String description;
  String nearMissDateTime;
  List<String> sharedWith;
  List<String> reactions;
  final List<ControlMeasure> controlMeasures;
  String createdBy;
  String groupID;
  DateTime createdAt;

  // constructor
  NearMissModel({
    required this.id,
    required this.location,
    required this.description,
    required this.nearMissDateTime,
    required this.sharedWith,
    required this.reactions,
    required this.controlMeasures,
    required this.createdBy,
    required this.groupID,
    required this.createdAt,
  });

  factory NearMissModel.fromGeneratedContent(
    GenerateContentResponse content,
    String id,
    String location,
    String description,
    String nearMissDateTime,
    String creatorID,
    String groupID,
    DateTime createdAt,
  ) {
    assert(content.text != null);

    final validJson = cleanJson(content.text!);
    final json = jsonDecode(validJson);

    final controlMeasures = (json[Constants.controlMeasures] as List<dynamic>)
        .map((measure) => ControlMeasure(
              measure: measure[Constants.measure],
              type: measure[Constants.type],
              rationale: measure[Constants.rationale],
            ))
        .toList();

    if (json is Map<String, dynamic>) {
      return NearMissModel(
        id: id,
        location: location,
        description: description,
        nearMissDateTime: nearMissDateTime,
        sharedWith: [],
        reactions: [],
        controlMeasures: controlMeasures,
        createdBy: creatorID,
        groupID: groupID,
        createdAt: createdAt,
      );
    }

    throw JsonUnsupportedObjectError(json);
  }

  // fromJson method
  factory NearMissModel.fromJson(Map<String, dynamic> json) {
    return NearMissModel(
      id: json[Constants.id] ?? '',
      location: json[Constants.location] ?? '',
      description: json[Constants.description] ?? '',
      nearMissDateTime: json[Constants.nearMissDateTime] ?? '',
      sharedWith: List<String>.from(json[Constants.sharedWith] ?? []),
      reactions: List<String>.from(json[Constants.reactions] ?? []),
      controlMeasures: (json[Constants.controlMeasures] as List<dynamic>?)
              ?.map((measure) => ControlMeasure.fromMap(measure))
              .toList() ??
          [],
      createdBy: json[Constants.createdBy] ?? '',
      groupID: json[Constants.groupID] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(json[Constants.createdAt]),
    );
  }

  // toJson method
  Map<String, dynamic> toJson() {
    return {
      Constants.id: id,
      Constants.location: location,
      Constants.description: description,
      Constants.nearMissDateTime: nearMissDateTime,
      Constants.sharedWith: sharedWith,
      Constants.reactions: reactions,
      Constants.control:
          controlMeasures.map((measure) => measure.toMap()).toList(),
      Constants.createdBy: createdBy,
      Constants.groupID: groupID,
      Constants.createdAt: createdAt.millisecondsSinceEpoch,
    };
  }
}
