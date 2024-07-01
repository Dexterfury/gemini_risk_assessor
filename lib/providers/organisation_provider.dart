import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/models/organisation_model.dart';
import 'package:gemini_risk_assessor/models/user_model.dart';
import 'package:gemini_risk_assessor/utilities/file_upload_handler.dart';
import 'package:uuid/uuid.dart';

class OrganisationProvider extends ChangeNotifier {
  bool _isLoading = false;
  String _searchQuery = '';
  List<UserModel> _orgMembersList = [];
  List<UserModel> _orgAdminsList = [];
  List<UserModel> _awaitApprovalList = [];

  List<UserModel> _tempOrgMembersList = [];
  List<UserModel> _tempOrgAdminsList = [];
  List<UserModel> _tempWaitingApprovalMembersList = [];

  List<String> _tempOrgMemberUIDs = [];
  List<String> _tempOrgAdminUIDs = [];

  List<UserModel> _tempRemovedAdminsList = [];
  List<UserModel> _tempRemovedMembersList = [];

  List<UserModel> _tempRemovedWaitingApprovalMembersList = [];
  List<String> _tempRemovedWaitingApprovalMemberUIDs = [];

  List<String> _tempRemovedMemberUIDs = [];
  List<String> _tempRemovedAdminsUIDs = [];

  bool _isSaved = false;
  OrganisationModel _organisationModel = OrganisationModel.empty();

  // getters
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  List<UserModel> get orgMembersList => _orgMembersList;
  List<UserModel> get orgAdminsList => _orgAdminsList;
  List<UserModel> get awaitApprovalsList => _awaitApprovalList;
  OrganisationModel get organisationModel => _organisationModel;
  List<String> get tempOrgMemberUIDs => _tempOrgMemberUIDs;

  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection(Constants.usersCollection);

  final CollectionReference _organisationCollection =
      FirebaseFirestore.instance.collection(Constants.organisationCollection);

  void setSearchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

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
  List<String> getAwaitingApprovalUIDs() {
    return _awaitApprovalList.map((e) => e.uid).toList();
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
    // set temp members
    _tempOrgMemberUIDs = orgModel.membersUIDs;
    notifyListeners();
  }

  // stream organisations from firestore
  Stream<QuerySnapshot> organisationsStream({
    required String userId,
  }) {
    return _organisationCollection
        .where(
          Constants.membersUIDs,
          arrayContains: userId,
        )
        .snapshots();
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
    _tempWaitingApprovalMembersList = [];

    notifyListeners();
  }

  // set empty lists
  Future<void> setEmptyLists() async {
    _isSaved = false;
    _orgMembersList = [];
    _orgAdminsList = [];
    _awaitApprovalList = [];
    notifyListeners();
  }

  // check if there was a change in group members - if there was a member added or removed
  // Future<void> updateOrgMembersInFirestore({
  //   required OrganisationModel orgModel,
  // }) async {
  //   _isSaved = true;
  //   notifyListeners();
  //   await updateOrganisationDataInFireStore();
  // }

  // update the organisation image
  Future<void> setImageUrl(String imageUrl) async {
    _organisationModel.imageUrl = imageUrl;
    notifyListeners();
  }

  // up date the organisation name
  Future<void> setName(String name) async {
    _organisationModel.organisationName = name;
    notifyListeners();
  }

  // up date the organisation description
  Future<void> setDescription(String description) async {
    _organisationModel.aboutOrganisation = description;
    notifyListeners();
  }

  // add a organisation member
  void addToWaitingApproval({required UserModel groupMember}) {
    _awaitApprovalList.add(groupMember);
    _organisationModel.awaitingApprovalUIDs.add(groupMember.uid);
    // add data to temp lists
    _tempWaitingApprovalMembersList.add(groupMember);
    notifyListeners();
  }

  // add member to temp list for saving changes later
  void addMemberToTempOrg({
    required String memberUID,
  }) {
    _tempOrgMemberUIDs.add(memberUID);
    notifyListeners();
  }

  // remove member from temp list for saving changes later
  void removeMemberFromTempOrg({
    required String memberUID,
  }) {
    _tempOrgMemberUIDs.removeWhere((element) => element == memberUID);
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

  Future<void> removeWaitingApproval({required UserModel orgMember}) async {
    _awaitApprovalList.remove(orgMember);
    // also remove this member from organisation model
    _organisationModel.awaitingApprovalUIDs.remove(orgMember.uid);

    // remove from temp lists
    _tempWaitingApprovalMembersList.remove(orgMember);

    // add  this member to the list of removed members
    _tempRemovedWaitingApprovalMembersList.add(orgMember);
    _tempRemovedWaitingApprovalMemberUIDs.add(orgMember.uid);

    notifyListeners();
  }

  // // remove member from group
  // Future<void> removeOrgMember({required UserModel orgMember}) async {
  //   _orgMembersList.remove(orgMember);
  //   // also remove this member from admins list if he is an admin
  //   _orgAdminsList.remove(orgMember);
  //   _organisationModel.membersUIDs.remove(orgMember.uid);

  //   // remove from temp lists
  //   _tempOrgMembersList.remove(orgMember);
  //   _tempOrgAdminUIDs.remove(orgMember.uid);

  //   // add  this member to the list of removed members
  //   _tempRemovedMembersList.add(orgMember);
  //   _tempRemovedMemberUIDs.add(orgMember.uid);

  //   notifyListeners();

  //   // return if groupID is empty - meaning we are creating a new group
  //   if (_organisationModel.organisationID.isEmpty) return;
  //   updateOrganisationDataInFireStore();
  // }

  // // remove admin from group
  // void removeOrgAdmin({required UserModel orgAdmin}) {
  //   _orgAdminsList.remove(orgAdmin);
  //   _organisationModel.adminsUIDs.remove(orgAdmin.uid);
  //   // remo from temp lists
  //   _tempOrgAdminUIDs.remove(orgAdmin.uid);
  //   _organisationModel.adminsUIDs.remove(orgAdmin.uid);

  //   // add the removed admins to temp removed lists
  //   _tempRemovedAdminsList.add(orgAdmin);
  //   _tempRemovedAdminsUIDs.add(orgAdmin.uid);
  //   notifyListeners();

  //   // return if groupID is empty - meaning we are creating a new group
  //   if (_organisationModel.organisationID.isEmpty) return;
  //   updateOrganisationDataInFireStore();
  // }

  // update group settings in firestore
  Future<bool> updateOrganisationDataInFireStore() async {
    if (_tempOrgMembersList.isEmpty) {
      return false;
    }
    // add temp members to awaiting approval list
    _organisationModel.awaitingApprovalUIDs
        .addAll(_tempOrgMembersList.map((e) => e.uid));
    try {
      await _organisationCollection
          .doc(_organisationModel.organisationID)
          .update(organisationModel.toJson());
      return true;
    } catch (e) {
      print(e.toString());
      return false;
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

  // get a list of goup members data from firestore
  Future<List<UserModel>> getMembersDataFromFirestore({
    required String orgID,
  }) async {
    try {
      List<UserModel> membersData = [];

      // get the list of membersUIDs
      List<String> membersUIDs = [];
      await _organisationCollection.doc(orgID).get().then((value) {
        if (value.exists) {
          membersUIDs = List<String>.from(value[Constants.membersUIDs]);
        }
      });

      for (var uid in membersUIDs) {
        var user = await _usersCollection.doc(uid).get();
        membersData
            .add(UserModel.fromJson(user.data()! as Map<String, dynamic>));
      }

      return membersData;
    } catch (e) {
      return [];
    }
  }

  // create organisation
  Future<void> createOrganisation({
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

      _organisationModel.createdAt = DateTime.now();

      newOrganisationModel.awaitingApprovalUIDs = [
        ...getAwaitingApprovalUIDs()
      ];

      // add the group admins
      newOrganisationModel.adminsUIDs = [
        newOrganisationModel.creatorUID,
        //...getOrgAdminsUIDs()
      ];

      // add the group members
      newOrganisationModel.membersUIDs = [
        newOrganisationModel.creatorUID,
        //...getOrgMembersUIDs()
      ];

      // update the global groupModel
      setOrganisationModel(orgModel: newOrganisationModel);

      // add group to firebase
      await _organisationCollection
          .doc(organisationID)
          .set(organisationModel.toJson());

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

  // exit organisation
  Future<String> exitOrganisation({
    required bool isAdmin,
    required String uid,
    required String orgID,
  }) async {
    try {
      if (isAdmin) {
        // get organisation data from firestore
        DocumentSnapshot doc = await _organisationCollection.doc(orgID).get();
        OrganisationModel organisationModel =
            OrganisationModel.fromJson(doc.data() as Map<String, dynamic>);
        // check if there are other admins left
        if (organisationModel.adminsUIDs.length > 1) {
          // remove the admin from admins list
          await _organisationCollection.doc(orgID).update({
            Constants.adminsUIDs: FieldValue.arrayRemove([uid]),
          });
          // remove the admin from group members list
          await _organisationCollection.doc(orgID).update({
            Constants.membersUIDs: FieldValue.arrayRemove([uid]),
          });

          return Constants.exitSuccessful;
        } else {
          // if there are no other admins check if there are other members left
          if (organisationModel.membersUIDs.length > 1) {
            await _organisationCollection.doc(orgID).update({
              Constants.adminsUIDs: FieldValue.arrayRemove([uid]),
            });

            // remove the admin from group members list
            await _organisationCollection.doc(orgID).update({
              Constants.membersUIDs: FieldValue.arrayRemove([uid]),
            });
            // pick up a new admin, get one member and make him admin
            String newAdminUID = organisationModel.membersUIDs[0];
            await _organisationCollection.doc(orgID).update({
              Constants.adminsUIDs: FieldValue.arrayUnion([newAdminUID]),
            });
            return Constants.exitSuccessful;
          } else {
            // If there are no other admins and members left, delete the group from firestore
            await _organisationCollection.doc(orgID).delete();

            return Constants.deletedSuccessfully;
          }
        }
      } else {
        await _organisationCollection.doc(orgID).update({
          Constants.membersUIDs: FieldValue.arrayRemove([uid]),
        });

        return Constants.exitSuccessful;
      }
    } catch (e) {
      return Constants.exitFailed;
    }
  }
}
