import 'package:gemini_risk_assessor/constants.dart';

class GroupModel {
  String creatorUID;
  String groupID;
  String name;
  String? groupImage;
  String aboutGroup;
  String address;
  String phoneNumber;
  String emailAddress;
  String websiteURL;
  String groupTerms;
  String safetyFileContent;
  String safetyFileUrl;
  List<String> awaitingApprovalUIDs;
  List<String> membersUIDs;
  List<String> adminsUIDs;
  bool requestToReadTerms;
  bool allowSharing;
  bool allowCreate;
  bool useSafetyFile;
  DateTime createdAt;

  // Constructor with default values
  GroupModel({
    this.creatorUID = '',
    this.groupID = '',
    this.name = '',
    this.groupImage,
    this.aboutGroup = '',
    this.address = '',
    this.phoneNumber = '',
    this.emailAddress = '',
    this.websiteURL = '',
    this.groupTerms = '',
    this.safetyFileContent = '',
    this.safetyFileUrl = '',
    List<String>? awaitingApprovalUIDs,
    List<String>? membersUIDs,
    List<String>? adminsUIDs,
    this.requestToReadTerms = false,
    this.allowSharing = false,
    this.allowCreate = false,
    this.useSafetyFile = false,
    DateTime? createdAt,
  })  : awaitingApprovalUIDs = awaitingApprovalUIDs ?? [],
        membersUIDs = membersUIDs ?? [],
        adminsUIDs = adminsUIDs ?? [],
        createdAt = createdAt ?? DateTime.now();

  // Factory constructor
  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      creatorUID: json[Constants.creatorUID] ?? '',
      groupID: json[Constants.groupID] ?? '',
      name: json[Constants.name] ?? '',
      groupImage: json[Constants.groupImage],
      aboutGroup: json[Constants.aboutGroup] ?? '',
      address: json[Constants.address] ?? '',
      phoneNumber: json[Constants.phoneNumber] ?? '',
      emailAddress: json[Constants.emailAddress] ?? '',
      websiteURL: json[Constants.websiteURL] ?? '',
      groupTerms: json[Constants.groupTerms] ?? '',
      safetyFileContent: json[Constants.safetyFileContent] ?? '',
      safetyFileUrl: json[Constants.safetyFileUrl] ?? '',
      awaitingApprovalUIDs:
          List<String>.from(json[Constants.awaitingApprovalUIDs] ?? []),
      membersUIDs: List<String>.from(json[Constants.membersUIDs] ?? []),
      adminsUIDs: List<String>.from(json[Constants.adminsUIDs] ?? []),
      requestToReadTerms: json[Constants.requestToReadTerms] ?? false,
      allowSharing: json[Constants.allowSharing] ?? false,
      allowCreate: json[Constants.allowCreate] ?? false,
      useSafetyFile: json[Constants.useSafetyFile] ?? false,
      createdAt: json[Constants.createdAt] != null
          ? DateTime.fromMillisecondsSinceEpoch(json[Constants.createdAt])
          : null,
    );
  }

  // To JSON method
  Map<String, dynamic> toJson() {
    return {
      Constants.creatorUID: creatorUID,
      Constants.groupID: groupID,
      Constants.name: name,
      Constants.groupImage: groupImage,
      Constants.aboutGroup: aboutGroup,
      Constants.address: address,
      Constants.phoneNumber: phoneNumber,
      Constants.emailAddress: emailAddress,
      Constants.websiteURL: websiteURL,
      Constants.groupTerms: groupTerms,
      Constants.safetyFileContent: safetyFileContent,
      Constants.safetyFileUrl: safetyFileUrl,
      Constants.awaitingApprovalUIDs: awaitingApprovalUIDs,
      Constants.membersUIDs: membersUIDs,
      Constants.adminsUIDs: adminsUIDs,
      Constants.requestToReadTerms: requestToReadTerms,
      Constants.allowSharing: allowSharing,
      Constants.allowCreate: allowCreate,
      Constants.useSafetyFile: useSafetyFile,
      Constants.createdAt: createdAt.millisecondsSinceEpoch,
    };
  }

  // empty group
  factory GroupModel.empty() {
    return GroupModel();
  }
}
