import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gemini_risk_assessor/constants.dart';

class DataStream {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final CollectionReference _usersCollections =
      FirebaseFirestore.instance.collection(Constants.usersCollection);
  static final CollectionReference _organisationCollection =
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
      return _organisationCollection
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
      return _organisationCollection
          .doc(orgID)
          .collection(Constants.assessmentCollection)
          .snapshots();
    } else {
      return _usersCollections
          .doc(userId)
          .collection(Constants.assessmentCollection)
          .snapshots();
    }
  }

  // stream organisations from firestore
  static Stream<QuerySnapshot> organisationsStream({
    required String userId,
  }) {
    return _organisationCollection
        .where(
          Constants.membersUIDs,
          arrayContains: userId,
        )
        .snapshots();
  }
}
