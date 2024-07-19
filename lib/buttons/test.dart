import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/models/data_settings.dart';
import 'package:gemini_risk_assessor/models/organization_model.dart';
import 'package:gemini_risk_assessor/models/user_model.dart';
import 'package:gemini_risk_assessor/utilities/file_upload_handler.dart';
import 'package:uuid/uuid.dart';

class OrganizationProvider extends ChangeNotifier {
  bool _isLoading = false;
  String _searchQuery = '';
  List<UserModel> _orgMembersList = [];
  List<UserModel> _orgAdminsList = [];
  List<String> _awaitApprovalList = [];

  List<UserModel> _tempWaitingApprovalMembersList = [];

  List<String> _tempOrgMemberUIDs = [];

  List<UserModel> _tempRemovedWaitingApprovalMembersList = [];
  List<String> _tempRemovedWaitingApprovalMemberUIDs = [];

  List<String> _initialMemberUIDs = [];
  List<String> _initialAwaitingApprovalUIDs = [];

  OrganizationModel _organizationModel = OrganizationModel.empty();

  // getters
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  List<UserModel> get orgMembersList => _orgMembersList;
  List<UserModel> get orgAdminsList => _orgAdminsList;
  List<String> get awaitApprovalsList => _awaitApprovalList;
  OrganizationModel get organizationModel => _organizationModel;
  List<String> get tempOrgMemberUIDs => _tempOrgMemberUIDs;

  final CollectionReference _organizationCollection =
      FirebaseFirestore.instance.collection(Constants.organizationCollection);

  void setInitialMemberState() {
    _initialMemberUIDs = List.from(_organizationModel.membersUIDs);
    _initialAwaitingApprovalUIDs =
        List.from(_organizationModel.awaitingApprovalUIDs);
  }

  bool hasChanges() {
    final currentMembers = Set.from(_tempOrgMemberUIDs);
    final initialMembers = Set.from(_initialMemberUIDs);
    final currentAwaiting = Set.from(_awaitApprovalList);
    final initialAwaiting = Set.from(_initialAwaitingApprovalUIDs);

    return currentMembers.difference(initialMembers).isNotEmpty ||
        initialMembers.difference(currentMembers).isNotEmpty ||
        currentAwaiting.difference(initialAwaiting).isNotEmpty ||
        initialAwaiting.difference(currentAwaiting).isNotEmpty;
  }

  Future<void> setSearchQuery(String value) async {
    _searchQuery = value;
    notifyListeners();
  }

  // set loading
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // get a list UIDs from group members list
  List<String> getAwaitingApprovalUIDs() {
    return _awaitApprovalList;
  }

  // get a list UIDs from group members list
  List<String> getOrgMembersUIDs() {
    return _orgMembersList.map((e) => e.uid).toList();
  }

  // get a list UIDs from group admins list
  List<String> getOrgAdminsUIDs() {
    return _orgAdminsList.map((e) => e.uid).toList();
  }

  Future<void> setOrganizationModel({
    required OrganizationModel orgModel,
  }) async {
    _organizationModel = orgModel;
    // set temp members
    _tempOrgMemberUIDs = List<String>.from(orgModel.membersUIDs);
    _awaitApprovalList = List<String>.from(orgModel.awaitingApprovalUIDs);
    notifyListeners();
  }

  Future<void> updateOrganizationSettings(DataSettings settings) async {
    // updates settings in firestore
    await _organizationCollection
        .doc(_organizationModel.organizationID)
        .update({
      Constants.organizationTerms: settings.organizationTerms,
      Constants.allowSharing: settings.allowSharing,
      Constants.requestToReadTerms: settings.requestToReadTerms,
    });
    // update in provider
    _organizationModel.organizationTerms = settings.organizationTerms;
    _organizationModel.allowSharing = settings.allowSharing;
    _organizationModel.requestToReadTerms = settings.requestToReadTerms;
    notifyListeners();
  }

  // set the temp lists to empty
  Future<void> setEmptyTemps() async {
    _tempOrgMemberUIDs = [];
    _tempWaitingApprovalMembersList = [];

    notifyListeners();
  }

  // set empty lists
  Future<void> setEmptyLists() async {
    _orgMembersList = [];
    _orgAdminsList = [];
    _awaitApprovalList = [];
    notifyListeners();
  }

  // add a organization member
  void addToWaitingApproval({required UserModel groupMember}) {
    _awaitApprovalList.add(groupMember.uid);
    _organizationModel.awaitingApprovalUIDs.add(groupMember.uid);
    // add data to temp lists
    _tempWaitingApprovalMembersList.add(groupMember);
    notifyListeners();
  }

  // create organization
  Future<void> createOrganization({
    required File? fileImage,
    required OrganizationModel newOrganizationModel,
    required Function() onSuccess,
    required Function(String) onError,
  }) async {
    setLoading(true);
    try {
      var organizationID = const Uuid().v4();
      newOrganizationModel.organizationID = organizationID;

      // check if we have the organization image
      if (fileImage != null) {
        // upload the image to firestore
        String imageUrl = await FileUploadHandler.uploadFileAndGetUrl(
          file: fileImage,
          reference: '${Constants.organizationImage}/$organizationID.jpg',
        );
        newOrganizationModel.imageUrl = imageUrl;
      }

      _organizationModel.createdAt = DateTime.now();

      newOrganizationModel.awaitingApprovalUIDs = [
        ...getAwaitingApprovalUIDs()
      ];

      // add the group admins
      newOrganizationModel.adminsUIDs = [
        newOrganizationModel.creatorUID,
        //...getOrgAdminsUIDs()
      ];

      // add the group members
      newOrganizationModel.membersUIDs = [
        newOrganizationModel.creatorUID,
        //...getOrgMembersUIDs()
      ];

      // update the global groupModel
      setOrganizationModel(orgModel: newOrganizationModel);

      // add group to firebase
      await _organizationCollection
          .doc(organizationID)
          .set(organizationModel.toJson());

      // reset the lists
      await setEmptyLists();
      await setEmptyTemps();
      // set onSuccess
      onSuccess();
      setLoading(false);
    } catch (e) {
      setLoading(false);
      onError(e.toString());
    }
  }
}
