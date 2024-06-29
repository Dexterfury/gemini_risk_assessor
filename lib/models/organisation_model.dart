import 'package:gemini_risk_assessor/constants.dart';

class OrganisationModel {
  String creatorUID;
  String organisationID;
  String organisationName;
  String? imageUrl;
  String aboutOrganisation;
  String address;
  String phoneNumber;
  String emailAddress;
  String websiteURL;
  List<String> awaitingApprovalUIDs;
  List<String> membersUIDs;
  List<String> adminsUIDs;
  DateTime createdAt;

  // Constructor with default values
  OrganisationModel({
    this.creatorUID = '',
    this.organisationID = '',
    this.organisationName = '',
    this.imageUrl,
    this.aboutOrganisation = '',
    this.address = '',
    this.phoneNumber = '',
    this.emailAddress = '',
    this.websiteURL = '',
    List<String>? awaitingApprovalUIDs,
    List<String>? membersUIDs,
    List<String>? adminsUIDs,
    DateTime? createdAt,
  })  : awaitingApprovalUIDs = awaitingApprovalUIDs ?? [],
        membersUIDs = membersUIDs ?? [],
        adminsUIDs = adminsUIDs ?? [],
        createdAt = createdAt ?? DateTime.now();

  // Factory constructor
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
      createdAt: json[Constants.createdAt] != null
          ? DateTime.fromMillisecondsSinceEpoch(json[Constants.createdAt])
          : null,
    );
  }

  // To JSON method
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

  // empty organization
  factory OrganisationModel.empty() {
    return OrganisationModel();
  }
}
