import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/models/organisation_model.dart';
import 'package:gemini_risk_assessor/models/user_model.dart';
import 'package:gemini_risk_assessor/utilities/file_upload_handler.dart';
import 'package:gemini_risk_assessor/utilities/global.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:uuid/uuid.dart';

class OrganisationProvider extends ChangeNotifier {
  bool _isLoading = false;
  String _searchQuery = '';
  List<UserModel> _orgMembersList = [];
  List<UserModel> _orgAdminsList = [];

  List<UserModel> _tempOrgMembersList = [];
  List<UserModel> _tempOrgAdminsList = [];

  List<String> _tempOrgMemberUIDs = [];
  List<String> _tempOrgAdminUIDs = [];

  List<UserModel> _tempRemovedAdminsList = [];
  List<UserModel> _tempRemovedMembersList = [];

  List<String> _tempRemovedMemberUIDs = [];
  List<String> _tempRemovedAdminsUIDs = [];

  bool _isSaved = false;
  OrganisationModel _organisationModel = OrganisationModel.empty();

  // getters
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  List<UserModel> get orgMembersList => _orgMembersList;
  List<UserModel> get orgAdminsList => _orgAdminsList;
  OrganisationModel get organisationModel => _organisationModel;

  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection(Constants.usersCollection);

  final CollectionReference _organisationCollection =
      FirebaseFirestore.instance.collection(Constants.organisationCollection);

  // set loading
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // get all users stream
  Stream<QuerySnapshot> allUsersStream() {
    return _usersCollection.snapshots();
  }

  // get a list UIDs from group members list
  List<String> getOrgMembersUIDs() {
    return _orgMembersList.map((e) => e.uid).toList();
  }

  // get a list UIDs from group admins list
  List<String> getOrgAdminsUIDs() {
    return _orgAdminsList.map((e) => e.uid).toList();
  }

  Future<void> setOrganisationModel({
    required OrganisationModel orgModel,
  }) async {
    _organisationModel = orgModel;
    notifyListeners();
  }

  // set the temp lists to empty
  Future<void> setEmptyTemps() async {
    _isSaved = false;
    _tempOrgAdminsList = [];
    _tempOrgMembersList = [];
    _tempOrgMembersList = [];
    _tempOrgMembersList = [];
    _tempOrgMemberUIDs = [];
    _tempOrgAdminUIDs = [];
    _tempRemovedMemberUIDs = [];
    _tempRemovedAdminsUIDs = [];
    _tempRemovedMembersList = [];
    _tempRemovedAdminsList = [];

    notifyListeners();
  }

  // check if there was a change in group members - if there was a member added or removed
  Future<void> updateGroupDataInFireStoreIfNeeded() async {
    _isSaved = true;
    notifyListeners();
    await updateOrganisationDataInFireStore();
  }

  // add a organisation member
  void addMemberToOrganisation({required UserModel groupMember}) {
    _orgMembersList.add(groupMember);
    _organisationModel.membersUIDs.add(groupMember.uid);
    // add data to temp lists
    _tempOrgMembersList.add(groupMember);
    _tempOrgMemberUIDs.add(groupMember.uid);
    notifyListeners();
  }

  // add a member as an admin
  void addMemberToAdmins({required UserModel groupAdmin}) {
    _orgAdminsList.add(groupAdmin);
    _organisationModel.adminsUIDs.add(groupAdmin.uid);
    //  add data to temp lists
    _tempOrgAdminsList.add(groupAdmin);
    _tempOrgAdminUIDs.add(groupAdmin.uid);
    notifyListeners();
  }

  // remove member from group
  Future<void> removeOrgMember({required UserModel orgMember}) async {
    _orgMembersList.remove(orgMember);
    // also remove this member from admins list if he is an admin
    _orgAdminsList.remove(orgMember);
    _organisationModel.membersUIDs.remove(orgMember.uid);

    // remove from temp lists
    _tempOrgMembersList.remove(orgMember);
    _tempOrgAdminUIDs.remove(orgMember.uid);

    // add  this member to the list of removed members
    _tempRemovedMembersList.add(orgMember);
    _tempRemovedMemberUIDs.add(orgMember.uid);

    notifyListeners();

    // return if groupID is empty - meaning we are creating a new group
    if (_organisationModel.organisationID.isEmpty) return;
    updateOrganisationDataInFireStore();
  }

  // remove admin from group
  void removeOrgAdmin({required UserModel orgAdmin}) {
    _orgAdminsList.remove(orgAdmin);
    _organisationModel.adminsUIDs.remove(orgAdmin.uid);
    // remo from temp lists
    _tempOrgAdminUIDs.remove(orgAdmin.uid);
    _organisationModel.adminsUIDs.remove(orgAdmin.uid);

    // add the removed admins to temp removed lists
    _tempRemovedAdminsList.add(orgAdmin);
    _tempRemovedAdminsUIDs.add(orgAdmin.uid);
    notifyListeners();

    // return if groupID is empty - meaning we are creating a new group
    if (_organisationModel.organisationID.isEmpty) return;
    updateOrganisationDataInFireStore();
  }

  // update group settings in firestore
  Future<void> updateOrganisationDataInFireStore() async {
    try {
      await _organisationCollection
          .doc(_organisationModel.organisationID)
          .update(organisationModel.toJson());
    } catch (e) {
      print(e.toString());
    }
  }

  // remove temp lists members from members list
  Future<void> removeTempLists({required bool isAdmins}) async {
    if (_isSaved) return;
    if (isAdmins) {
      // check if the temp admins list is not empty
      if (_tempOrgAdminsList.isNotEmpty) {
        // remove the temp admins from the main list of admins
        _orgAdminsList.removeWhere((admin) =>
            _tempOrgAdminsList.any((tempAdmin) => tempAdmin.uid == admin.uid));
        _organisationModel.adminsUIDs.removeWhere((adminUid) =>
            _tempOrgAdminUIDs.any((tempUid) => tempUid == adminUid));
        notifyListeners();
      }

      //check  if the tempRemoves list is not empty
      if (_tempRemovedAdminsList.isNotEmpty) {
        // add  the temp admins to the main list of admins
        _orgAdminsList.addAll(_tempRemovedAdminsList);
        _organisationModel.adminsUIDs.addAll(_tempRemovedAdminsUIDs);
        notifyListeners();
      }
    } else {
      // check if the tem members list is not empty
      if (_tempOrgMembersList.isNotEmpty) {
        // remove the temp members from the main list of members
        _orgMembersList.removeWhere((member) => _tempOrgMembersList
            .any((tempMember) => tempMember.uid == member.uid));
        _organisationModel.membersUIDs.removeWhere((memberUid) =>
            _tempOrgMemberUIDs.any((tempUid) => tempUid == memberUid));
        notifyListeners();
      }

      //check if the tempRemoves list is not empty
      if (_tempRemovedMembersList.isNotEmpty) {
        // add the temp members to the main list of members
        _orgMembersList.addAll(_tempRemovedMembersList);
        _organisationModel.membersUIDs.addAll(_tempOrgMemberUIDs);
        notifyListeners();
      }
    }
  }

  // create organisation
  Future<void> createOrganisation({
    required String name,
    required String description,
    required File? fileImage,
    required OrganisationModel newOrganisationModel,
    required Function() onSuccess,
    required Function(String) onError,
  }) async {
    setLoading(true);
    try {
      var organisationID = const Uuid().v4();
      newOrganisationModel.organisationID = organisationID;

      // check if we have the organisation image
      if (fileImage != null) {
        // upload the image to firestore
        String imageUrl = await FileUploadHandler.uploadFileAndGetUrl(
          file: fileImage,
          reference: '${Constants.organisationImage}/$organisationID.jpg',
        );
        newOrganisationModel.imageUrl = imageUrl;
      }

      // add the group admins
      newOrganisationModel.adminsUIDs = [
        newOrganisationModel.creatorUID,
        ...getOrgAdminsUIDs()
      ];

      // add the group members
      newOrganisationModel.membersUIDs = [
        newOrganisationModel.creatorUID,
        ...getOrgMembersUIDs()
      ];

      // update the global groupModel
      setOrganisationModel(orgModel: newOrganisationModel);

      // add group to firebase
      await _organisationCollection
          .doc(organisationID)
          .set(organisationModel.toJson());

      // set loading
      setLoading(true);
      // set onSuccess
      onSuccess;
      setLoading(false);
    } catch (e) {
      setLoading(false);
      onError(e.toString());
    }
  }
}
