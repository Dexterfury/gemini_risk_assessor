import 'package:gemini_risk_assessor/constants.dart';

class OrganisationModel {
  String creatorUID;
  String organisationID;
  String organisationName;
  String imageUrl;
  String aboutOrganisation;
  String address;
  String phoneNumber;
  String emailAddress;
  String websiteURL;
  List<String> awaitingApprovalUIDs;
  List<String> membersUIDs;
  List<String> adminsUIDs;
  DateTime createdAt;

  // constructor
  OrganisationModel({
    required this.creatorUID,
    required this.organisationID,
    required this.organisationName,
    required this.imageUrl,
    required this.aboutOrganisation,
    required this.address,
    required this.phoneNumber,
    required this.emailAddress,
    required this.websiteURL,
    required this.awaitingApprovalUIDs,
    required this.membersUIDs,
    required this.adminsUIDs,
    required this.createdAt,
  });
  // factory constructor
  factory OrganisationModel.fromJson(Map<String, dynamic> json) {
    return OrganisationModel(
      creatorUID: json[Constants.creatorUID] ?? '',
      organisationID: json[Constants.organisationID] ?? '',
      organisationName: json[Constants.organisationName] ?? '',
      imageUrl: json[Constants.imageUrl],
      aboutOrganisation: json[Constants.aboutOrganisation] ?? '',
      address: json[Constants.address] ?? '',
      phoneNumber: json[Constants.phoneNumber] ?? '',
      emailAddress: json[Constants.emailAddress] ?? '',
      websiteURL: json[Constants.websiteURL] ?? '',
      awaitingApprovalUIDs:
          List<String>.from(json[Constants.awaitingApprovalUIDs] ?? []),
      membersUIDs: List<String>.from(json[Constants.membersUIDs] ?? []),
      adminsUIDs: List<String>.from(json[Constants.adminsUIDs] ?? []),
      createdAt: DateTime.fromMillisecondsSinceEpoch(
          json[Constants.createdAt] ?? DateTime.now().millisecondsSinceEpoch),
    );
  }

  //  to json method
  Map<String, dynamic> toJson() {
    return {
      Constants.creatorUID: creatorUID,
      Constants.organisationID: organisationID,
      Constants.organisationName: organisationName,
      Constants.imageUrl: imageUrl,
      Constants.aboutOrganisation: aboutOrganisation,
      Constants.address: address,
      Constants.phoneNumber: phoneNumber,
      Constants.emailAddress: emailAddress,
      Constants.websiteURL: websiteURL,
      Constants.awaitingApprovalUIDs: awaitingApprovalUIDs,
      Constants.membersUIDs: membersUIDs,
      Constants.adminsUIDs: adminsUIDs,
      Constants.createdAt: createdAt.millisecondsSinceEpoch,
    };
  }
}
