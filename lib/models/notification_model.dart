import 'package:gemini_risk_assessor/constants.dart';

class NotificationModel {
  String creatorUID;
  String ownerUID;
  String organisationID;
  String organisationName;
  String imageUrl;
  String aboutOrganisation;
  String notificationType;
  bool wasClicked;
  DateTime createdAt;
  DateTime notificationDate;

// constructor
  NotificationModel({
    required this.creatorUID,
    required this.ownerUID,
    required this.organisationID,
    required this.organisationName,
    required this.imageUrl,
    required this.aboutOrganisation,
    required this.notificationType,
    required this.wasClicked,
    required this.createdAt,
    required this.notificationDate,
  });

  // from json method
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      creatorUID: json[Constants.creatorUID] ?? '',
      ownerUID: json[Constants.ownerUID] ?? '',
      organisationID: json[Constants.organisationID] ?? '',
      organisationName: json[Constants.organisationName] ?? '',
      imageUrl: json[Constants.imageUrl] ?? '',
      aboutOrganisation: json[Constants.aboutOrganisation] ?? '',
      notificationType: json[Constants.notificationType] ?? '',
      wasClicked: json[Constants.wasClicked] ?? false,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json[Constants.createdAt]),
      notificationDate:
          DateTime.fromMillisecondsSinceEpoch(json[Constants.notificationDate]),
    );
  }

  // toJson
  Map<String, dynamic> toJson() {
    return {
      Constants.creatorUID: creatorUID,
      Constants.ownerUID: ownerUID,
      Constants.organisationID: organisationID,
      Constants.organisationName: organisationName,
      Constants.imageUrl: imageUrl,
      Constants.aboutOrganisation: aboutOrganisation,
      Constants.notificationType: notificationType,
      Constants.wasClicked: wasClicked,
      Constants.createdAt: createdAt,
      Constants.notificationDate: notificationDate,
    };
  }
}
