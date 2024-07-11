import 'package:gemini_risk_assessor/constants.dart';

class NotificationModel {
  String creatorUID;
  String recieverUID;
  String organizationID;
  String notificationID;
  String title;
  String description;
  String imageUrl;
  String aboutOrganization;
  String notificationType;
  String organizationTerms;
  bool wasClicked;
  DateTime createdAt;
  DateTime notificationDate;

// constructor
  NotificationModel({
    required this.creatorUID,
    required this.recieverUID,
    required this.organizationID,
    required this.notificationID,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.aboutOrganization,
    required this.notificationType,
    required this.organizationTerms,
    required this.wasClicked,
    required this.createdAt,
    required this.notificationDate,
  });

  // from json method
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      creatorUID: json[Constants.creatorUID] ?? '',
      recieverUID: json[Constants.recieverUID] ?? '',
      organizationID: json[Constants.organizationID] ?? '',
      notificationID: json[Constants.notificationID] ?? '',
      title: json[Constants.title] ?? '',
      description: json[Constants.description] ?? '',
      imageUrl: json[Constants.imageUrl] ?? '',
      aboutOrganization: json[Constants.aboutOrganization] ?? '',
      notificationType: json[Constants.notificationType] ?? '',
      organizationTerms: json[Constants.organizationTerms] ?? '',
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
      Constants.organizationID: organizationID,
      Constants.notificationID: notificationID,
      Constants.title: title,
      Constants.description: description,
      Constants.imageUrl: imageUrl,
      Constants.aboutOrganization: aboutOrganization,
      Constants.notificationType: notificationType,
      Constants.organizationTerms: organizationTerms,
      Constants.wasClicked: wasClicked,
      Constants.createdAt: createdAt,
      Constants.notificationDate: notificationDate,
    };
  }
}
