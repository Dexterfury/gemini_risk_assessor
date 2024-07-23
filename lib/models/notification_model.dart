import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gemini_risk_assessor/constants.dart';

class NotificationModel {
  String creatorUID;
  String recieverUID;
  String groupID;
  String notificationID;
  String title;
  String description;
  String imageUrl;
  String aboutGroup;
  String notificationType;
  String groupTerms;
  bool wasClicked;
  DateTime createdAt;
  DateTime notificationDate;

// constructor
  NotificationModel({
    required this.creatorUID,
    required this.recieverUID,
    required this.groupID,
    required this.notificationID,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.aboutGroup,
    required this.notificationType,
    required this.groupTerms,
    required this.wasClicked,
    required this.createdAt,
    required this.notificationDate,
  });

  // from json method
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      creatorUID: json[Constants.creatorUID] ?? '',
      recieverUID: json[Constants.recieverUID] ?? '',
      groupID: json[Constants.groupID] ?? '',
      notificationID: json[Constants.notificationID] ?? '',
      title: json[Constants.title] ?? '',
      description: json[Constants.description] ?? '',
      imageUrl: json[Constants.imageUrl] ?? '',
      aboutGroup: json[Constants.aboutGroup] ?? '',
      notificationType: json[Constants.notificationType] ?? '',
      groupTerms: json[Constants.groupTerms] ?? '',
      wasClicked: json[Constants.wasClicked] ?? false,
      createdAt: (json[Constants.createdAt] as Timestamp).toDate(),
      notificationDate:
          (json[Constants.notificationDate] as Timestamp).toDate(),
    );
  }

  // toJson
  Map<String, dynamic> toJson() {
    return {
      Constants.creatorUID: creatorUID,
      Constants.recieverUID: recieverUID,
      Constants.groupID: groupID,
      Constants.notificationID: notificationID,
      Constants.title: title,
      Constants.description: description,
      Constants.imageUrl: imageUrl,
      Constants.aboutGroup: aboutGroup,
      Constants.notificationType: notificationType,
      Constants.groupTerms: groupTerms,
      Constants.wasClicked: wasClicked,
      Constants.createdAt: createdAt,
      Constants.notificationDate: notificationDate,
    };
  }
}
