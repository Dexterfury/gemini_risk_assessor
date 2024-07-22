import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/enums/enums.dart';
import 'package:gemini_risk_assessor/models/assessment_model.dart';
import 'package:gemini_risk_assessor/models/discussion_message.dart';
import 'package:gemini_risk_assessor/models/organization_model.dart';
import 'package:gemini_risk_assessor/models/tool_model.dart';
import 'package:gemini_risk_assessor/utilities/global.dart';

class FirebaseMethods {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  static final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection(Constants.usersCollection);
  static final CollectionReference _organizationsCollection =
      FirebaseFirestore.instance.collection(Constants.organizationCollection);

  // stream my tools from firestore
  static Stream<QuerySnapshot> toolsStream({
    required String userId,
    required String orgID,
  }) {
    if (orgID.isNotEmpty) {
      return _organizationsCollection
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

  // get all users stream
  static Stream<QuerySnapshot> allUsersStream() {
    return _usersCollection
        .where(Constants.isAnonymous, isEqualTo: false)
        .snapshots();
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

  // check if the organisation has any assessments, dsti or tools saved in firestore
  static Future<Map<String, bool>> checkOrganizationData(
      {required String orgID}) async {
    final orgRef = _organizationsCollection.doc(orgID);

    Map<String, bool> results = {
      Constants.hasAssessments: false,
      Constants.hasDSTI: false,
      Constants.hasTools: false,
    };

    // Check for assessments
    final assessmentsQuery =
        await orgRef.collection(Constants.assessmentCollection).limit(1).get();
    results[Constants.hasAssessments] = assessmentsQuery.docs.isNotEmpty;

    // Check for DSTI
    final dstiQuery =
        await orgRef.collection(Constants.dstiCollections).limit(1).get();
    results[Constants.hasDSTI] = dstiQuery.docs.isNotEmpty;

    // Check for tools
    final toolsQuery =
        await orgRef.collection(Constants.toolsCollection).limit(1).get();
    results[Constants.hasTools] = toolsQuery.docs.isNotEmpty;

    return results;
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
    await _auth.currentUser!.updateDisplayName(newName);
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
    required String orgID,
    required AssessmentModel assessment,
    required Function() onSuccess,
    required Function(String) onError,
  }) async {
    final String collectionName =
        isDSTI ? Constants.dstiCollections : Constants.assessmentCollection;
    final String rootCollection = orgID.isNotEmpty
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

      if (orgID.isNotEmpty) {
        // If it's an organization deleting a shared document, remove org from user's sharedWith
        if (assessment.sharedWith.contains(ownerID)) {
          final userRef = _usersCollection
              .doc(assessment.createdBy)
              .collection(collectionName)
              .doc(orgID);
          batch.update(userRef, {
            Constants.sharedWith: FieldValue.arrayRemove([orgID])
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

  // CHAT METHODS
  // discussion stream from firestore
  static Stream<QuerySnapshot> nearMissessStream({
    required String orgID,
  }) {
    return _organizationsCollection
        .doc(orgID)
        .collection(Constants.nearMissesCollection)
        .snapshots();
  }

  // stream messages from chat collection
  static Stream<List<DiscussionMessage>> getMessagesStream({
    required String orgID,
    required String itemID,
    required GenerationType generationType,
  }) {
    final collection = getCollectionRef(generationType);
    // handle group message
    return _organizationsCollection
        .doc(orgID)
        .collection(collection)
        .doc(itemID)
        .collection(Constants.chatMessagesCollection)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return DiscussionMessage.fromMap(doc.data());
      }).toList();
    });
  }

  // set message status
  static Future<void> setMessageStatus({
    required String currentUserId,
    required String orgID,
    required String messageID,
    required String itemID,
    required List<String> isSeenByList,
    required GenerationType generationType,
  }) async {
    // check if you have already seen this message
    if (isSeenByList.contains(currentUserId)) {
      return;
    } else {
      final collection = getCollectionRef(generationType);
      // add the current user to the seenByList in all messages
      await _organizationsCollection
          .doc(orgID)
          .collection(collection)
          .doc(itemID)
          .collection(Constants.chatMessagesCollection)
          .doc(messageID)
          .update({
        Constants.seenBy: FieldValue.arrayUnion([currentUserId]),
      });
    }
  }
}
