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

  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection(Constants.usersCollection);

  final CollectionReference _organizationCollection =
      FirebaseFirestore.instance.collection(Constants.organizationCollection);

  final Map<String, ValueNotifier<bool>> _adminValueNotifiers = {};
  final Map<String, ValueNotifier<bool>> _awaitingApprovalValueNotifiers = {};
  final Map<String, ValueNotifier<bool>> _tempMemberValueNotifiers = {};
  final Map<String, ValueNotifier<bool>> _memberValueNotifiers = {};

  ValueNotifier<bool> getAdminValueNotifier(String uid) {
    return _adminValueNotifiers.putIfAbsent(
      uid,
      () => ValueNotifier(_orgAdminsList.any((admin) => admin.uid == uid)),
    );
  }

  ValueNotifier<bool> getAwaitingApprovalValueNotifier(String uid) {
    return _awaitingApprovalValueNotifiers.putIfAbsent(
      uid,
      () => ValueNotifier(_awaitApprovalList.contains(uid)),
    );
  }

  ValueNotifier<bool> getTempMemberValueNotifier(String uid) {
    return _tempMemberValueNotifiers.putIfAbsent(
      uid,
      () => ValueNotifier(
          _tempOrgMemberUIDs.contains(uid) || _awaitApprovalList.contains(uid)),
    );
  }

  ValueNotifier<bool> getMemberValueNotifier(String uid) {
    return _memberValueNotifiers.putIfAbsent(
      uid,
      () => ValueNotifier(_orgMembersList.any((member) => member.uid == uid)),
    );
  }

  // Update these methods to use ValueNotifiers
  void addToWaitingApproval({required UserModel groupMember}) {
    _awaitApprovalList.add(groupMember.uid);
    _organizationModel.awaitingApprovalUIDs.add(groupMember.uid);
    _tempWaitingApprovalMembersList.add(groupMember);
    _awaitingApprovalValueNotifiers[groupMember.uid]?.value = true;
    _tempMemberValueNotifiers[groupMember.uid]?.value = true;
    notifyListeners();
  }

  void removeWaitingApproval({required UserModel orgMember}) {
    _awaitApprovalList.remove(orgMember.uid);
    _organizationModel.awaitingApprovalUIDs.remove(orgMember.uid);
    _tempWaitingApprovalMembersList
        .removeWhere((member) => member.uid == orgMember.uid);
    _awaitingApprovalValueNotifiers[orgMember.uid]?.value = false;
    _tempMemberValueNotifiers[orgMember.uid]?.value = false;
    notifyListeners();
  }

  void addMemberToTempOrg({required String memberUID}) {
    if (!_tempOrgMemberUIDs.contains(memberUID)) {
      _tempOrgMemberUIDs.add(memberUID);
      _tempMemberValueNotifiers[memberUID]?.value = true;
      notifyListeners();
    }
  }

  void removeMemberFromTempOrg({required String memberUID}) {
    _tempOrgMemberUIDs.remove(memberUID);
    _tempMemberValueNotifiers[memberUID]?.value = false;
    notifyListeners();
  }

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

  Future<void> handleMemberChanges({
    required UserModel memberData,
    required String orgID,
    required bool isAdding,
  }) async {
    // update the member data in firebase
    if (isAdding) {
      // add the member to admins list in firebase
      await addMemberAsAdmin(
        memberData: memberData,
        orgID: orgID,
      );
    } else {
      // remove the member from admins list in firebase
      await removeMemberAsAdmin(
        memberData: memberData,
        orgID: orgID,
      );
    }
  }

  // add member as admin
  Future<void> addMemberAsAdmin({
    required UserModel memberData,
    required String orgID,
  }) async {
    // add the membeer to adminslist
    await _organizationCollection.doc(orgID).update({
      Constants.adminsUIDs: FieldValue.arrayUnion([memberData.uid]),
    });
    // to to locally update the list
    _organizationModel.adminsUIDs.add(memberData.uid);
    notifyListeners();
  }

  // remove member as admin
  Future<void> removeMemberAsAdmin({
    required UserModel memberData,
    required String orgID,
  }) async {
    // remove the member from adminslist
    await _organizationCollection.doc(orgID).update({
      Constants.adminsUIDs: FieldValue.arrayRemove([memberData.uid]),
    });
    // to update the local list
    _organizationModel.adminsUIDs.remove(memberData.uid);
    notifyListeners();
  }

  // clear awaiting approval list
  void clearAwaitingApprovalList() {
    _awaitApprovalList.clear();
    notifyListeners();
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

  Future<bool> updateOrganizationDataInFireStore() async {
    if (!hasChanges()) {
      return false;
    }
    _isLoading = true;
    notifyListeners();

    try {
      final removedMembers =
          _initialMemberUIDs.where((uid) => !_tempOrgMemberUIDs.contains(uid));
      final addedMembers =
          _tempOrgMemberUIDs.where((uid) => !_initialMemberUIDs.contains(uid));

      await _organizationCollection
          .doc(_organizationModel.organizationID)
          .update({
        Constants.membersUIDs: FieldValue.arrayRemove(removedMembers.toList()),
        Constants.awaitingApprovalUIDs:
            FieldValue.arrayUnion(addedMembers.toList()),
      });

      _organizationModel.membersUIDs = _tempOrgMemberUIDs;
      _organizationModel.awaitingApprovalUIDs = _awaitApprovalList;

      setInitialMemberState();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print(e.toString());
      return false;
    }
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

  // update the organization image
  Future<void> setImageUrl(String imageUrl) async {
    _organizationModel.imageUrl = imageUrl;
    notifyListeners();
  }

  // up date the organization name
  Future<void> setName(String name) async {
    _organizationModel.name = name;
    notifyListeners();
  }

  // up date the organization description
  Future<void> setDescription(String description) async {
    _organizationModel.aboutOrganization = description;
    notifyListeners();
  }

  // add a organization member
  // void addToWaitingApproval({required UserModel groupMember}) {
  //   _awaitApprovalList.add(groupMember.uid);
  //   _organizationModel.awaitingApprovalUIDs.add(groupMember.uid);
  //   // add data to temp lists
  //   _tempWaitingApprovalMembersList.add(groupMember);
  //   notifyListeners();
  // }

  // add member to organization
  Future<void> addMemberToOrganization({
    required String uid,
  }) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final DocumentReference orgRef =
        _organizationCollection.doc(organizationModel.organizationID);

    return firestore.runTransaction((transaction) async {
      _isLoading = true;
      notifyListeners();
      final DocumentSnapshot orgSnapshot = await transaction.get(orgRef);

      if (!orgSnapshot.exists) {
        _isLoading = false;
        notifyListeners();
        throw Exception('Organization does not exist');
      }

      final OrganizationModel org = OrganizationModel.fromJson(
          orgSnapshot.data() as Map<String, dynamic>);

      if (!org.awaitingApprovalUIDs.contains(uid)) {
        _isLoading = false;
        notifyListeners();
        throw Exception('User is not in the awaiting approval list');
      }

      if (org.membersUIDs.contains(uid)) {
        _isLoading = false;
        notifyListeners();
        throw Exception('User is already a member');
      }

      // Remove UID from awaiting approval list
      final List<String> updatedAwaitingApproval =
          List.from(org.awaitingApprovalUIDs)..remove(uid);

      // remove uid from awaiting approval local list
      _organizationModel.awaitingApprovalUIDs
          .removeWhere((element) => element == uid);

      // Add UID to members list
      final List<String> updatedMembers = List.from(org.membersUIDs)..add(uid);

      // update local temp list
      _organizationModel.membersUIDs.add(uid);

      notifyListeners();

      // Update the document
      transaction.update(orgRef, {
        Constants.awaitingApprovalUIDs: updatedAwaitingApproval,
        Constants.membersUIDs: updatedMembers,
      });
      _isLoading = false;
      notifyListeners();
    });
  }

  // // add member to temp list for saving changes later
  // void addMemberToTempOrg({
  //   required String memberUID,
  // }) {
  //   _tempOrgMemberUIDs.add(memberUID);
  //   notifyListeners();
  // }

  // remove member from temp list for saving changes later
  // void removeMemberFromTempOrg({
  //   required String memberUID,
  // }) {
  //   _tempOrgMemberUIDs.removeWhere((element) => element == memberUID);
  //   notifyListeners();
  // }

  // Future<void> removeWaitingApproval({required UserModel orgMember}) async {
  //   _awaitApprovalList.remove(orgMember.uid);
  //   // also remove this member from organization model
  //   _organizationModel.awaitingApprovalUIDs.remove(orgMember.uid);

  //   // remove from temp lists
  //   _tempWaitingApprovalMembersList.remove(orgMember);

  //   // add  this member to the list of removed members
  //   _tempRemovedWaitingApprovalMembersList.add(orgMember);
  //   _tempRemovedWaitingApprovalMemberUIDs.add(orgMember.uid);

  //   notifyListeners();
  // }

  // update group settings in firestore
  // Future<bool> updateOrganizationDataInFireStore() async {
  //   if (_tempOrgMemberUIDs == _organizationModel.membersUIDs) {
  //     return false;
  //   }

  //   // remove all membersUIDs who are already in the organizationModel.membersUIDs list
  //   _tempOrgMemberUIDs.removeWhere(
  //       (element) => _organizationModel.membersUIDs.contains(element));

  //   try {
  //     await _organizationCollection
  //         .doc(_organizationModel.organizationID)
  //         .update({
  //       Constants.awaitingApprovalUIDs: _tempOrgMemberUIDs,
  //     });
  //     notifyListeners();
  //     return true;
  //   } catch (e) {
  //     print(e.toString());
  //     return false;
  //   }
  // }

  // get a list of goup members data from firestore
  Future<List<UserModel>> getMembersDataFromFirestore({
    required String orgID,
  }) async {
    try {
      List<UserModel> membersData = [];

      // get the list of membersUIDs
      List<String> membersUIDs = [];
      await _organizationCollection.doc(orgID).get().then((value) {
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

  // exit organization
  Future<String> exitOrganization({
    required bool isAdmin,
    required String uid,
    required String orgID,
  }) async {
    try {
      if (isAdmin) {
        // get organization data from firestore
        DocumentSnapshot doc = await _organizationCollection.doc(orgID).get();
        OrganizationModel organizationModel =
            OrganizationModel.fromJson(doc.data() as Map<String, dynamic>);
        // check if there are other admins left
        if (organizationModel.adminsUIDs.length > 1) {
          // remove the admin from admins list
          await _organizationCollection.doc(orgID).update({
            Constants.adminsUIDs: FieldValue.arrayRemove([uid]),
          });
          // remove the admin from group members list
          await _organizationCollection.doc(orgID).update({
            Constants.membersUIDs: FieldValue.arrayRemove([uid]),
          });

          return Constants.exitSuccessful;
        } else {
          // if there are no other admins check if there are other members left
          if (organizationModel.membersUIDs.length > 1) {
            await _organizationCollection.doc(orgID).update({
              Constants.adminsUIDs: FieldValue.arrayRemove([uid]),
            });

            // remove the admin from group members list
            await _organizationCollection.doc(orgID).update({
              Constants.membersUIDs: FieldValue.arrayRemove([uid]),
            });
            // pick up a new admin, get one member and make him admin
            String newAdminUID = organizationModel.membersUIDs[0];
            await _organizationCollection.doc(orgID).update({
              Constants.adminsUIDs: FieldValue.arrayUnion([newAdminUID]),
            });
            return Constants.exitSuccessful;
          } else {
            // If there are no other admins and members left, delete the group from firestore
            await _organizationCollection.doc(orgID).delete();

            return Constants.deletedSuccessfully;
          }
        }
      } else {
        await _organizationCollection.doc(orgID).update({
          Constants.membersUIDs: FieldValue.arrayRemove([uid]),
        });

        return Constants.exitSuccessful;
      }
    } catch (e) {
      return Constants.exitFailed;
    }
  }
}
