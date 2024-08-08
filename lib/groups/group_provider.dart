import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/firebase/firebase_methods.dart';
import 'package:gemini_risk_assessor/models/data_settings.dart';
import 'package:gemini_risk_assessor/groups/group_model.dart';
import 'package:gemini_risk_assessor/models/user_model.dart';
import 'package:gemini_risk_assessor/utilities/file_upload_handler.dart';
import 'package:uuid/uuid.dart';

class GroupProvider extends ChangeNotifier {
  bool _isLoading = false;
  String _searchQuery = '';
  List<UserModel> _groupMembersList = [];
  List<UserModel> _groupAdminsList = [];
  List<String> _awaitApprovalList = [];

  List<UserModel> _tempWaitingApprovalMembersList = [];

  List<String> _tempGroupMemberUIDs = [];

  List<String> _initialMemberUIDs = [];
  List<String> _initialAwaitingApprovalUIDs = [];

  GroupModel _groupModel = GroupModel.empty();

  // getters
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  List<UserModel> get groupMembersList => _groupMembersList;
  List<UserModel> get groupAdminsList => _groupAdminsList;
  List<String> get awaitApprovalsList => _awaitApprovalList;
  GroupModel get groupModel => _groupModel;
  List<String> get tempGroupMemberUIDs => _tempGroupMemberUIDs;

  final Map<String, ValueNotifier<bool>> _awaitingApprovalValueNotifiers = {};
  final Map<String, ValueNotifier<bool>> _tempMemberValueNotifiers = {};

  // Update these methods to use ValueNotifiers
  void addToWaitingApproval({required UserModel groupMember}) {
    _awaitApprovalList.add(groupMember.uid);
    _groupModel.awaitingApprovalUIDs.add(groupMember.uid);
    _tempWaitingApprovalMembersList.add(groupMember);
    _awaitingApprovalValueNotifiers[groupMember.uid]?.value = true;
    _tempMemberValueNotifiers[groupMember.uid]?.value = true;
    notifyListeners();
  }

  void removeWaitingApproval({required UserModel groupMember}) {
    _awaitApprovalList.remove(groupMember.uid);
    _groupModel.awaitingApprovalUIDs.remove(groupMember.uid);
    _tempWaitingApprovalMembersList
        .removeWhere((member) => member.uid == groupMember.uid);
    _awaitingApprovalValueNotifiers[groupMember.uid]?.value = false;
    _tempMemberValueNotifiers[groupMember.uid]?.value = false;
    notifyListeners();
  }

  void addMemberToTempGroup({required String memberUID}) {
    if (!_tempGroupMemberUIDs.contains(memberUID)) {
      _tempGroupMemberUIDs.add(memberUID);
      _tempMemberValueNotifiers[memberUID]?.value = true;
      notifyListeners();
    }
  }

  void removeMemberFromTempGroup({required String memberUID}) {
    _tempGroupMemberUIDs.remove(memberUID);
    _tempMemberValueNotifiers[memberUID]?.value = false;
    notifyListeners();
  }

  void setInitialMemberState() {
    _initialMemberUIDs = List.from(_groupModel.membersUIDs);
    _initialAwaitingApprovalUIDs = List.from(_groupModel.awaitingApprovalUIDs);
  }

  bool hasChanges() {
    final currentMembers = Set.from(_tempGroupMemberUIDs);
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
    required String groupID,
    required bool isAdding,
  }) async {
    // update the member data in firebase
    if (isAdding) {
      // add the member to admins list in firebase
      await addMemberAsAdmin(
        memberData: memberData,
        groupID: groupID,
      );
    } else {
      // remove the member from admins list in firebase
      await removeMemberAsAdmin(
        memberData: memberData,
        groupID: groupID,
      );
    }
  }

  // add member as admin
  Future<void> addMemberAsAdmin({
    required UserModel memberData,
    required String groupID,
  }) async {
    // add the membeer to adminslist
    await FirebaseMethods.groupsCollection.doc(groupID).update({
      Constants.adminsUIDs: FieldValue.arrayUnion([memberData.uid]),
    });
    // to to locally update the list
    _groupModel.adminsUIDs.add(memberData.uid);
    notifyListeners();
  }

  // remove member as admin
  Future<void> removeMemberAsAdmin({
    required UserModel memberData,
    required String groupID,
  }) async {
    // remove the member from adminslist
    await FirebaseMethods.groupsCollection.doc(groupID).update({
      Constants.adminsUIDs: FieldValue.arrayRemove([memberData.uid]),
    });
    // to update the local list
    _groupModel.adminsUIDs.remove(memberData.uid);
    notifyListeners();
  }

  // clear awaiting approval list
  Future<void> clearAwaitingApprovalList() async {
    _awaitApprovalList = [];
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
  List<String> getGroupMembersUIDs() {
    return _groupMembersList.map((e) => e.uid).toList();
  }

  // get a list UIDs from group admins list
  List<String> getGroupAdminsUIDs() {
    return _groupAdminsList.map((e) => e.uid).toList();
  }

  Future<void> setGroupModel({
    required GroupModel groupModel,
  }) async {
    _groupModel = groupModel;
    // set temp members
    _tempGroupMemberUIDs = List<String>.from(groupModel.membersUIDs);
    _awaitApprovalList = List<String>.from(groupModel.awaitingApprovalUIDs);
    notifyListeners();
  }

  Future<void> updateGroupSettings(DataSettings settings) async {
    // updates settings in firestore
    await FirebaseMethods.groupsCollection.doc(_groupModel.groupID).update({
      Constants.groupTerms: settings.groupTerms,
      Constants.allowSharing: settings.allowSharing,
      Constants.requestToReadTerms: settings.requestToReadTerms,
    });
    // update in provider
    _groupModel.groupTerms = settings.groupTerms;
    _groupModel.allowSharing = settings.allowSharing;
    _groupModel.requestToReadTerms = settings.requestToReadTerms;
    notifyListeners();
  }

  Future<bool> updateGroupDataInFireStore() async {
    if (!hasChanges()) {
      return false;
    }
    _isLoading = true;
    notifyListeners();

    try {
      final removedMembers = _initialMemberUIDs
          .where((uid) => !_tempGroupMemberUIDs.contains(uid));
      final addedMembers = _tempGroupMemberUIDs
          .where((uid) => !_initialMemberUIDs.contains(uid));

      await FirebaseMethods.groupsCollection.doc(_groupModel.groupID).update({
        Constants.membersUIDs: FieldValue.arrayRemove(removedMembers.toList()),
        Constants.awaitingApprovalUIDs:
            FieldValue.arrayUnion(addedMembers.toList()),
      });

      _groupModel.membersUIDs = _tempGroupMemberUIDs;
      _groupModel.awaitingApprovalUIDs = _awaitApprovalList;

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
    _tempGroupMemberUIDs = [];
    _tempWaitingApprovalMembersList = [];

    notifyListeners();
  }

  // set empty lists
  Future<void> setEmptyLists() async {
    _groupMembersList = [];
    _groupAdminsList = [];
    _awaitApprovalList = [];
    notifyListeners();
  }

  // update the group image
  Future<void> setImageUrl(String imageUrl) async {
    _groupModel.groupImage = imageUrl;
    notifyListeners();
  }

  // up date the group name
  Future<void> setName(String name) async {
    _groupModel.name = name;
    notifyListeners();
  }

  // up date the group description
  Future<void> setDescription(String description) async {
    _groupModel.aboutGroup = description;
    notifyListeners();
  }

  // add member to group
  Future<void> addMemberToGroup({
    required String uid,
  }) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final DocumentReference groupRef =
        FirebaseMethods.groupsCollection.doc(groupModel.groupID);

    return firestore.runTransaction((transaction) async {
      _isLoading = true;
      notifyListeners();
      final DocumentSnapshot groupSnapshot = await transaction.get(groupRef);

      if (!groupSnapshot.exists) {
        _isLoading = false;
        notifyListeners();
        throw Exception('group does not exist');
      }

      final GroupModel group =
          GroupModel.fromJson(groupSnapshot.data() as Map<String, dynamic>);

      if (!group.awaitingApprovalUIDs.contains(uid)) {
        _isLoading = false;
        notifyListeners();
        throw Exception('User is not in the awaiting approval list');
      }

      if (group.membersUIDs.contains(uid)) {
        _isLoading = false;
        notifyListeners();
        throw Exception('User is already a member');
      }

      // Remove UID from awaiting approval list
      final List<String> updatedAwaitingApproval =
          List.from(group.awaitingApprovalUIDs)..remove(uid);

      // remove uid from awaiting approval local list
      _groupModel.awaitingApprovalUIDs.removeWhere((element) => element == uid);

      // Add UID to members list
      final List<String> updatedMembers = List.from(group.membersUIDs)
        ..add(uid);

      // update local temp list
      _groupModel.membersUIDs.add(uid);

      notifyListeners();

      // Update the document
      transaction.update(groupRef, {
        Constants.awaitingApprovalUIDs: updatedAwaitingApproval,
        Constants.membersUIDs: updatedMembers,
      });
      _isLoading = false;
      notifyListeners();
    });
  }

  // get a list of goup members data from firestore
  Future<List<UserModel>> getMembersDataFromFirestore({
    required String groupID,
  }) async {
    try {
      List<UserModel> membersData = [];

      // get the list of membersUIDs
      List<String> membersUIDs = [];
      await FirebaseMethods.groupsCollection.doc(groupID).get().then((value) {
        if (value.exists) {
          membersUIDs = List<String>.from(value[Constants.membersUIDs]);
        }
      });

      for (var uid in membersUIDs) {
        var user = await FirebaseMethods.usersCollection.doc(uid).get();
        membersData
            .add(UserModel.fromJson(user.data()! as Map<String, dynamic>));
      }

      return membersData;
    } catch (e) {
      return [];
    }
  }

  // Stream<List<UserModel>> getMembersStream({required String groupID}) {
  //   return FirebaseMethods.groupsCollection
  //       .doc(groupID)
  //       .snapshots()
  //       .asyncMap((snapshot) async {
  //     final groupData = snapshot.data() as Map<String, dynamic>;
  //     final memberUIDs =
  //         List<String>.from(groupData[Constants.membersUIDs] ?? []);

  //     final membersData = await Future.wait(
  //       memberUIDs.map((uid) => FirebaseFirestore.instance
  //           .collection(Constants.usersCollection)
  //           .doc(uid)
  //           .get()
  //           .then((doc) => UserModel.fromJson(doc.data()!))),
  //     );

  //     return membersData;
  //   });
  // }

  // create group
  Future<void> createGroup({
    required File? fileImage,
    required GroupModel newgroupModel,
    required Function() onSuccess,
    required Function(String) onError,
  }) async {
    setLoading(true);
    try {
      var groupID = const Uuid().v4();
      newgroupModel.groupID = groupID;

      // check if we have the group image
      if (fileImage != null) {
        // upload the image to firestore
        String imageUrl = await FileUploadHandler.uploadFileAndGetUrl(
          file: fileImage,
          reference: '${Constants.groupImage}/$groupID.jpg',
        );
        newgroupModel.groupImage = imageUrl;
      }

      _groupModel.createdAt = DateTime.now();

      newgroupModel.awaitingApprovalUIDs = [...getAwaitingApprovalUIDs()];

      // add the group admins
      newgroupModel.adminsUIDs = [
        newgroupModel.creatorUID,
        //...getGroupAdminsUIDs()
      ];

      // add the group members
      newgroupModel.membersUIDs = [
        newgroupModel.creatorUID,
        //...getGroupMembersUIDs()
      ];

      // update the global groupModel
      setGroupModel(groupModel: newgroupModel);

      // add group to firebase
      await FirebaseMethods.groupsCollection
          .doc(groupID)
          .set(groupModel.toJson());

      // reset the lists
      await setEmptyLists();
      await setEmptyTemps();
      clearAwaitingApprovalList();
      // set onSuccess
      onSuccess();
      setLoading(false);
    } catch (e) {
      setLoading(false);
      onError(e.toString());
    }
  }

  // exit group
  Future<String> exitgroup({
    required bool isAdmin,
    required String uid,
    required String groupID,
  }) async {
    try {
      if (isAdmin) {
        // get group data from firestore
        DocumentSnapshot doc =
            await FirebaseMethods.groupsCollection.doc(groupID).get();
        GroupModel groupModel =
            GroupModel.fromJson(doc.data() as Map<String, dynamic>);
        // check if there are other admins left
        if (groupModel.adminsUIDs.length > 1) {
          // remove the admin from admins list
          await FirebaseMethods.groupsCollection.doc(groupID).update({
            Constants.adminsUIDs: FieldValue.arrayRemove([uid]),
          });
          // remove the admin from group members list
          await FirebaseMethods.groupsCollection.doc(groupID).update({
            Constants.membersUIDs: FieldValue.arrayRemove([uid]),
          });

          return Constants.exitSuccessful;
        } else {
          // if there are no other admins check if there are other members left
          if (groupModel.membersUIDs.length > 1) {
            await FirebaseMethods.groupsCollection.doc(groupID).update({
              Constants.adminsUIDs: FieldValue.arrayRemove([uid]),
            });

            // remove the admin from group members list
            await FirebaseMethods.groupsCollection.doc(groupID).update({
              Constants.membersUIDs: FieldValue.arrayRemove([uid]),
            });
            // pick up a new admin, get one member and make him admin
            String newAdminUID = groupModel.membersUIDs[0];
            await FirebaseMethods.groupsCollection.doc(groupID).update({
              Constants.adminsUIDs: FieldValue.arrayUnion([newAdminUID]),
            });
            return Constants.exitSuccessful;
          } else {
            // If there are no other admins and members left, delete the group from firestore
            await FirebaseMethods.groupsCollection.doc(groupID).delete();

            return Constants.deletedSuccessfully;
          }
        }
      } else {
        await FirebaseMethods.groupsCollection.doc(groupID).update({
          Constants.membersUIDs: FieldValue.arrayRemove([uid]),
        });

        return Constants.exitSuccessful;
      }
    } catch (e) {
      return Constants.exitFailed;
    }
  }
}
