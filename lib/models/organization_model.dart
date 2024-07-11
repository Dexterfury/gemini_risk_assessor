import 'package:gemini_risk_assessor/constants.dart';

class OrganizationModel {
  String creatorUID;
  String organizationID;
  String name;
  String? imageUrl;
  String aboutOrganization;
  String address;
  String phoneNumber;
  String emailAddress;
  String websiteURL;
  String organizationTerms;
  List<String> awaitingApprovalUIDs;
  List<String> membersUIDs;
  List<String> adminsUIDs;
  DateTime createdAt;

  // Constructor with default values
  OrganizationModel({
    this.creatorUID = '',
    this.organizationID = '',
    this.name = '',
    this.imageUrl,
    this.aboutOrganization = '',
    this.address = '',
    this.phoneNumber = '',
    this.emailAddress = '',
    this.websiteURL = '',
    this.organizationTerms = '',
    List<String>? awaitingApprovalUIDs,
    List<String>? membersUIDs,
    List<String>? adminsUIDs,
    DateTime? createdAt,
  })  : awaitingApprovalUIDs = awaitingApprovalUIDs ?? [],
        membersUIDs = membersUIDs ?? [],
        adminsUIDs = adminsUIDs ?? [],
        createdAt = createdAt ?? DateTime.now();

  // Factory constructor
  factory OrganizationModel.fromJson(Map<String, dynamic> json) {
    return OrganizationModel(
      creatorUID: json[Constants.creatorUID] ?? '',
      organizationID: json[Constants.organizationID] ?? '',
      name: json[Constants.name] ?? '',
      imageUrl: json[Constants.imageUrl],
      aboutOrganization: json[Constants.aboutOrganization] ?? '',
      address: json[Constants.address] ?? '',
      phoneNumber: json[Constants.phoneNumber] ?? '',
      emailAddress: json[Constants.emailAddress] ?? '',
      websiteURL: json[Constants.websiteURL] ?? '',
      organizationTerms: json[Constants.organizationTerms] ?? '',
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
      Constants.organizationID: organizationID,
      Constants.name: name,
      Constants.imageUrl: imageUrl,
      Constants.aboutOrganization: aboutOrganization,
      Constants.address: address,
      Constants.phoneNumber: phoneNumber,
      Constants.emailAddress: emailAddress,
      Constants.websiteURL: websiteURL,
      Constants.organizationTerms: organizationTerms,
      Constants.awaitingApprovalUIDs: awaitingApprovalUIDs,
      Constants.membersUIDs: membersUIDs,
      Constants.adminsUIDs: adminsUIDs,
      Constants.createdAt: createdAt.millisecondsSinceEpoch,
    };
  }

  // empty organization
  factory OrganizationModel.empty() {
    return OrganizationModel();
  }
}
