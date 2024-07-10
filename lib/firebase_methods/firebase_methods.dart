import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gemini_risk_assessor/constants.dart';

class FirebaseMethods {
  static final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection(Constants.usersCollection);
  static final CollectionReference _organisationsCollection =
      FirebaseFirestore.instance.collection(Constants.organisationCollection);
  static final CollectionReference _dstiCollection =
      FirebaseFirestore.instance.collection(Constants.dstiCollections);
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
      return _organisationsCollection
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
      return _organisationsCollection
          .doc(orgID)
          .collection(Constants.assessmentCollection)
          .snapshots();
    } else {
      return _usersCollection
          .doc(userId)
          .collection(Constants.assessmentCollection)
          .snapshots();
    }
  }

  // stream organisations from firestore
  static Stream<QuerySnapshot> organisationsStream({
    required String userId,
  }) {
    return _organisationsCollection
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
    await _organisationsCollection.doc(id).update({
      Constants.organisationName: newName,
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
    await _organisationsCollection
        .doc(id)
        .update({Constants.aboutOrganisation: newDesc});
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

  // get organisations stream
  static Stream<DocumentSnapshot> organisationStream({required String orgID}) {
    return _organisationsCollection.doc(orgID).snapshots();
  }
}
