import 'package:gemini_risk_assessor/constants.dart';

class NotificationModel {
  String creatorUID;
  String recieverUID;
  String organisationID;
  String title;
  String description;
  String imageUrl;
  String aboutOrganisation;
  String notificationType;
  bool wasClicked;
  DateTime createdAt;
  DateTime notificationDate;

// constructor
  NotificationModel({
    required this.creatorUID,
    required this.recieverUID,
    required this.organisationID,
    required this.title,
    required this.description,
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
      recieverUID: json[Constants.recieverUID] ?? '',
      organisationID: json[Constants.organisationID] ?? '',
      title: json[Constants.title] ?? '',
      description: json[Constants.description] ?? '',
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
      Constants.recieverUID: recieverUID,
      Constants.organisationID: organisationID,
      Constants.title: title,
      Constants.description: description,
      Constants.imageUrl: imageUrl,
      Constants.aboutOrganisation: aboutOrganisation,
      Constants.notificationType: notificationType,
      Constants.wasClicked: wasClicked,
      Constants.createdAt: createdAt,
      Constants.notificationDate: notificationDate,
    };
  }
}
