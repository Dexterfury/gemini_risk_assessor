import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/models/organization_model.dart';

class FirebaseMethods {
  static final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection(Constants.usersCollection);
  static final CollectionReference _organizationsCollection =
      FirebaseFirestore.instance.collection(Constants.organizationCollection);
  static final CollectionReference _dstiCollection =
      FirebaseFirestore.instance.collection(Constants.dstiCollections);
  static final CollectionReference _assessementsCollection =
      FirebaseFirestore.instance.collection(Constants.assessmentCollection);
  static final CollectionReference _toolsCollection =
      FirebaseFirestore.instance.collection(Constants.toolsCollection);

  // stream my tools from firestore
  static Stream<QuerySnapshot> toolsStream({
    required String userId,
    required String orgID,
  }) {
    if (orgID.isNotEmpty) {
      return _toolsCollection
          .doc(orgID)
          .collection(Constants.toolsCollection)
          .snapshots();
    } else {
      return _toolsCollection
          .doc(userId)
          .collection(Constants.toolsCollection)
          .snapshots();
    }
  }

  // stream dsti's from firestore
  static Stream<QuerySnapshot> dstiStream({
    required String userId,
    required String orgID,
  }) {
    if (orgID.isNotEmpty) {
      return _organizationsCollection
          .doc(orgID)
          .collection(Constants.dstiCollections)
          .snapshots();
    } else {
      return _dstiCollection
          .doc(userId)
          .collection(Constants.dstiCollections)
          .snapshots();
    }
  }

  // stream risk assessments from firestore
  static Stream<QuerySnapshot> ristAssessmentsStream({
    required String userId,
    required String orgID,
  }) {
    if (orgID.isNotEmpty) {
      return _organizationsCollection
          .doc(orgID)
          .collection(Constants.assessmentCollection)
          .snapshots();
    } else {
      return _assessementsCollection
          .doc(userId)
          .collection(Constants.assessmentCollection)
          .snapshots();
    }
  }

  // discussion stream from firestore
  static Stream<QuerySnapshot> discussionStream({required String orgID}) {
    return _organizationsCollection
        .doc(orgID)
        .collection(Constants.discussionsCollection)
        .snapshots();
  }

  // stream organizations from firestore
  static Stream<QuerySnapshot> organizationsStream({
    required String userId,
  }) {
    return _organizationsCollection
        .where(
          Constants.membersUIDs,
          arrayContains: userId,
        )
        .snapshots();
  }

  // stream notifications from firestore
  static Stream<QuerySnapshot> notificationsStream({
    required String userId,
    required bool isAll,
  }) {
    if (isAll) {
      return _usersCollection
          .doc(userId)
          .collection(Constants.notificationsCollection)
          .snapshots();
    } else {
      return _usersCollection
          .doc(userId)
          .collection(Constants.notificationsCollection)
          .where(Constants.wasClicked, isEqualTo: false)
          .snapshots();
    }
  }

  // update groupName
  static Future<void> updateOrgName(String id, String newName) async {
    await _organizationsCollection.doc(id).update({
      Constants.organizationName: newName,
    });
  }

  // update userName
  static Future<void> updateUserName(String id, String newName) async {
    await _usersCollection.doc(id).update({
      Constants.name: newName,
    });
  }

  // update aboutMe
  static Future<void> updateAboutMe(String id, String newDesc) async {
    await _usersCollection.doc(id).update({Constants.aboutMe: newDesc});
  }

  // update group desc
  static Future<void> updateOrgDesc(String id, String newDesc) async {
    await _organizationsCollection
        .doc(id)
        .update({Constants.aboutOrganization: newDesc});
  }

  static Future<String> getCreatorName(String creatorUid) async {
    try {
      DocumentSnapshot userDoc = await _usersCollection.doc(creatorUid).get();
      return userDoc.get(Constants.name) as String;
    } catch (e) {
      print('Error fetching creator name: $e');
      return 'Unknown Creator';
    }
  }

  // get user stream
  static Stream<DocumentSnapshot> userStream({required String userID}) {
    return _usersCollection.doc(userID).snapshots();
  }

  // get organizations stream
  static Stream<DocumentSnapshot> organizationStream({required String orgID}) {
    return _organizationsCollection.doc(orgID).snapshots();
  }

  // get organization data from firestore
  static Future<OrganizationModel> getOrganizationData({
    required String orgID,
  }) async {
    try {
      DocumentSnapshot orgDoc = await _organizationsCollection.doc(orgID).get();
      return OrganizationModel.fromJson(orgDoc.data()! as Map<String, dynamic>);
    } catch (e) {
      print('Error fetching organization data: $e');
      return OrganizationModel();
    }
  }
}
