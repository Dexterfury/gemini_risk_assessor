import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/models/assessment_model.dart';
import 'package:gemini_risk_assessor/models/organization_model.dart';
import 'package:gemini_risk_assessor/models/tool_model.dart';

class FirebaseMethods {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  static final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection(Constants.usersCollection);
  static final CollectionReference _organizationsCollection =
      FirebaseFirestore.instance.collection(Constants.organizationCollection);
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
      return _usersCollection
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
      return _usersCollection
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
      return _usersCollection
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

  static Future<void> shareWithOrganization({
    required String uid,
    required AssessmentModel itemModel,
    required String orgID,
    required bool isDSTI,
  }) async {
    // we get the database referrence for the organization and the user
    final String collectionName =
        isDSTI ? Constants.dstiCollections : Constants.assessmentCollection;
    final orgRef = _organizationsCollection
        .doc(orgID)
        .collection(collectionName)
        .doc(itemModel.id);
    final userRef =
        _usersCollection.doc(uid).collection(collectionName).doc(itemModel.id);

    // we create a new assessment object with updated sharedWith list
    final updatedAssessment = itemModel.copyWith(
      sharedWith: [...itemModel.sharedWith, orgID],
    );

    // we perform both operations in parallel
    await Future.wait([
      orgRef.set(updatedAssessment.toJson()),
      userRef.update({
        Constants.sharedWith: FieldValue.arrayUnion([orgID])
      }),
    ]);
  }

  // shares tool to organization
  static Future<void> shareToolWithOrganization({
    required String uid,
    required ToolModel toolModel,
    required String orgID,
  }) async {
    // we get the database referrence for the organization and the user
    final orgRef = _organizationsCollection
        .doc(orgID)
        .collection(Constants.tools)
        .doc(toolModel.id);
    final userRef =
        _usersCollection.doc(uid).collection(Constants.tools).doc(toolModel.id);

    // we create a new assessment object with updated sharedWith list
    final updatedTool = toolModel.copyWith(
      sharedWith: [...toolModel.sharedWith, orgID],
    );

    // we perform both operations in parallel
    await Future.wait([
      orgRef.set(updatedTool.toJson()),
      userRef.update({
        Constants.sharedWith: FieldValue.arrayUnion([orgID])
      }),
    ]);
  }

  static Future<void> deleteAssessment({
    required String docID,
    required bool isDSTI,
    required String ownerID,
    required bool isOrganization,
    required AssessmentModel assessment,
    required Function() onSuccess,
    required Function(String) onError,
  }) async {
    final String collectionName =
        isDSTI ? Constants.dstiCollections : Constants.assessmentCollection;
    final String rootCollection = isOrganization
        ? Constants.organizationCollection
        : Constants.usersCollection;

    try {
      final docRef = _firestore
          .collection(rootCollection)
          .doc(ownerID)
          .collection(collectionName)
          .doc(docID);

      // Start a batch write
      final WriteBatch batch = _firestore.batch();

      if (isOrganization) {
        // If it's an organization deleting a shared document, remove org from user's sharedWith
        if (assessment.sharedWith.contains(ownerID)) {
          final userRef = _usersCollection
              .doc(assessment.createdBy)
              .collection(collectionName)
              .doc(docID);
          batch.update(userRef, {
            Constants.sharedWith: FieldValue.arrayRemove([ownerID])
          });
        }
      } else {
        // If it's a user deleting their own document
        if (assessment.sharedWith.isEmpty) {
          // If not shared, delete images from storage
          await Future.wait(
            assessment.images.map(
              (url) => _deleteImage(
                imageUrl: url,
                onError: onError,
              ),
            ),
          );
        }
        // Note: We're not removing the document from shared organizations so they can still see it
      }

      // Delete the document
      batch.delete(docRef);

      // Commit the batch
      await batch.commit();

      print('Assessment successfully deleted and related documents updated');
      onSuccess();
    } catch (e) {
      print('Error deleting assessment: $e');
      onError(e.toString());
    }
  }

  static Future<void> _deleteImage({
    required String imageUrl,
    required Function(String) onError,
  }) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      print('Deleted image: $imageUrl');
    } catch (e) {
      print('Error deleting image: $e');
      // You might want to handle this error according to your app's requirements
      onError(
        e.toString(),
      );
    }
  }

  // // delete assessment from o rganization and user
  // static Future<void> deleteAssessment({
  //   required String uid,
  //   required String orgID,
  //   required String assessmentID,
  //   required bool isDSTI,
  // }) async {
  //   // we get the database referrence for the organization and the user
  //   final String collectionName =
  //       isDSTI ? Constants.dstiCollections : Constants.assessmentCollection;
  //   final orgRef = _organizationsCollection
  //       .doc(orgID)
  //       .collection(collectionName)
  //       .doc(assessmentID);
  //   final userRef = _usersCollection
  //       .doc(uid)
  //       .collection(collectionName)
  //       .doc(assessmentID);

  //   // delete the assessment from both the organization and user collections
  //   await Future.wait([
  //     orgRef.delete(),
  //     // remove this assessment from sharedWith list
  //   ]);
  // }

  // set notification was clicked to true
  static Future<void> setNotificationClicked({
    required String uid,
    required String notificationID,
  }) async {
    await _usersCollection
        .doc(uid)
        .collection(Constants.notificationsCollection)
        .doc(notificationID)
        .update({
      Constants.wasClicked: true,
    });
  }

  // get is admin
  static Future<DocumentSnapshot> getOrgData({
    required String orgID,
  }) {
    return _organizationsCollection.doc(orgID).get();
  }
}
