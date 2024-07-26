import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/enums/enums.dart';
import 'package:gemini_risk_assessor/models/assessment_model.dart';
import 'package:gemini_risk_assessor/discussions/discussion_message.dart';
import 'package:gemini_risk_assessor/groups/group_model.dart';
import 'package:gemini_risk_assessor/tools/tool_model.dart';
import 'package:gemini_risk_assessor/utilities/global.dart';

class FirebaseMethods {
  static final FirebaseAuth auth = FirebaseAuth.instance;
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;
  static final FirebaseStorage storage = FirebaseStorage.instance;

  static final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection(Constants.usersCollection);
  static final CollectionReference groupsCollection =
      FirebaseFirestore.instance.collection(Constants.groupsCollection);

  // stream my tools from firestore
  static Stream<QuerySnapshot> toolsStream({
    required String userId,
    required String groupID,
  }) {
    if (groupID.isNotEmpty) {
      return groupsCollection
          .doc(groupID)
          .collection(Constants.toolsCollection)
          .orderBy(
            Constants.createdAt,
            descending: true,
          )
          .snapshots();
    } else {
      return usersCollection
          .doc(userId)
          .collection(Constants.toolsCollection)
          .orderBy(
            Constants.createdAt,
            descending: true,
          )
          .snapshots();
    }
  }

  // stream dsti's from firestore
  static Stream<QuerySnapshot> dstiStream({
    required String userId,
    required String groupID,
  }) {
    if (groupID.isNotEmpty) {
      return groupsCollection
          .doc(groupID)
          .collection(Constants.dstiCollections)
          .orderBy(
            Constants.createdAt,
            descending: true,
          )
          .snapshots();
    } else {
      return usersCollection
          .doc(userId)
          .collection(Constants.dstiCollections)
          .orderBy(
            Constants.createdAt,
            descending: true,
          )
          .snapshots();
    }
  }

  // get all users stream
  static Stream<QuerySnapshot> allUsersStream() {
    return usersCollection
        .where(Constants.isAnonymous, isEqualTo: false)
        .snapshots();
  }

  // stream risk assessments from firestore
  static Stream<QuerySnapshot> ristAssessmentsStream({
    required String userId,
    required String groupID,
  }) {
    if (groupID.isNotEmpty) {
      return groupsCollection
          .doc(groupID)
          .collection(Constants.assessmentCollection)
          .orderBy(
            Constants.createdAt,
            descending: true,
          )
          .snapshots();
    } else {
      return usersCollection
          .doc(userId)
          .collection(Constants.assessmentCollection)
          .orderBy(
            Constants.createdAt,
            descending: true,
          )
          .snapshots();
    }
  }

  // stream groups from firestore
  static Stream<QuerySnapshot> groupsStream(
      {required String userId,
      required String groupID,
      required bool fromShare}) {
    if (fromShare) {
      if (groupID.isNotEmpty) {
        return groupsCollection
            .where(Constants.membersUIDs, arrayContains: userId)
            .where(Constants.groupID, isNotEqualTo: groupID)
            .orderBy(
              Constants.createdAt,
              descending: true,
            )
            .snapshots();
      } else {
        return groupsCollection
            .where(Constants.membersUIDs, arrayContains: userId)
            .orderBy(
              Constants.createdAt,
              descending: true,
            )
            .snapshots();
      }
    } else {
      return groupsCollection
          .where(Constants.membersUIDs, arrayContains: userId)
          .orderBy(
            Constants.createdAt,
            descending: true,
          )
          .snapshots();
    }
  }

  // check if the group has any assessments, dsti or tools saved in firestore
  static Future<Map<String, bool>> checkGroupData(
      {required String groupID}) async {
    final orgRef = groupsCollection.doc(groupID);

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
      return usersCollection
          .doc(userId)
          .collection(Constants.notificationsCollection)
          .orderBy(Constants.createdAt)
          .snapshots();
    } else {
      return usersCollection
          .doc(userId)
          .collection(Constants.notificationsCollection)
          .where(Constants.wasClicked, isEqualTo: false)
          .orderBy(Constants.createdAt)
          .snapshots();
    }
  }

  // update groupName
  static Future<void> updateGroupName(String id, String newName) async {
    await groupsCollection.doc(id).update({
      Constants.groupName: newName,
    });
  }

  // update userName
  static Future<void> updateUserName(String id, String newName) async {
    await auth.currentUser!.updateDisplayName(newName);
    await usersCollection.doc(id).update({
      Constants.name: newName,
    });
  }

  // update aboutMe
  static Future<void> updateAboutMe(String id, String newDesc) async {
    await usersCollection.doc(id).update({Constants.aboutMe: newDesc});
  }

  // update group desc
  static Future<void> updateGroupDesc(String id, String newDesc) async {
    await groupsCollection.doc(id).update({Constants.aboutGroup: newDesc});
  }

  static Future<String> getCreatorName(String creatorUid) async {
    try {
      DocumentSnapshot userDoc = await usersCollection.doc(creatorUid).get();
      return userDoc.get(Constants.name) as String;
    } catch (e) {
      print('Error fetching creator name: $e');
      return 'Unknown Creator';
    }
  }

  // get user stream
  static Stream<DocumentSnapshot> userStream({required String userID}) {
    return usersCollection.doc(userID).snapshots();
  }

  // // get groups stream
  // static Stream<DocumentSnapshot> groupStream({required String groupID
  //}) {
  //   return _groupsCollection.doc(groupID
  // ).snapshots();
  // }

  static Future<void> shareWithGroup({
    required String uid,
    required AssessmentModel itemModel,
    required String groupID,
    required bool isDSTI,
  }) async {
    // we get the database referrence for the group and the user
    final String collectionName =
        isDSTI ? Constants.dstiCollections : Constants.assessmentCollection;
    final orgRef = groupsCollection
        .doc(groupID)
        .collection(collectionName)
        .doc(itemModel.id);
    final userRef =
        usersCollection.doc(uid).collection(collectionName).doc(itemModel.id);

    // we create a new assessment object with updated sharedWith list
    final updatedAssessment = itemModel.copyWith(
      sharedWith: [...itemModel.sharedWith, groupID],
    );

    // we perform both operations in parallel
    await Future.wait([
      orgRef.set(updatedAssessment.toJson()),
      userRef.update({
        Constants.sharedWith: FieldValue.arrayUnion([groupID])
      }),
    ]);
  }

  // shares tool to group
  static Future<void> shareToolWithGroup({
    required String uid,
    required ToolModel toolModel,
    required String groupID,
  }) async {
    // we get the database referrence for the group and the user
    final orgRef = groupsCollection
        .doc(groupID)
        .collection(Constants.tools)
        .doc(toolModel.id);
    final userRef =
        usersCollection.doc(uid).collection(Constants.tools).doc(toolModel.id);

    // we create a new assessment object with updated sharedWith list
    final updatedTool = toolModel.copyWith(
      sharedWith: [...toolModel.sharedWith, groupID],
    );

    // we perform both operations in parallel
    await Future.wait([
      orgRef.set(updatedTool.toJson()),
      userRef.update({
        Constants.sharedWith: FieldValue.arrayUnion([groupID])
      }),
    ]);
  }

  static Future<void> deleteAssessment({
    required String docID,
    required bool isDSTI,
    required String ownerID,
    required String groupID,
    required AssessmentModel assessment,
    required Function() onSuccess,
    required Function(String) onError,
  }) async {
    final String collectionName =
        isDSTI ? Constants.dstiCollections : Constants.assessmentCollection;
    final String rootCollection = groupID.isNotEmpty
        ? Constants.groupsCollection
        : Constants.usersCollection;

    try {
      final docRef = firestore
          .collection(rootCollection)
          .doc(ownerID)
          .collection(collectionName)
          .doc(docID);

      // Start a batch write
      final WriteBatch batch = firestore.batch();

      if (groupID.isNotEmpty) {
        // If it's an group deleting a shared document, remove org from user's sharedWith
        if (assessment.sharedWith.contains(ownerID)) {
          final userRef = usersCollection
              .doc(assessment.createdBy)
              .collection(collectionName)
              .doc(groupID);
          batch.update(userRef, {
            Constants.sharedWith: FieldValue.arrayRemove([groupID])
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
        // Note: We're not removing the document from shared group so they can still see it
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
      final ref = storage.refFromURL(imageUrl);
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
  //   required String groupID
  // ,
  //   required String assessmentID,
  //   required bool isDSTI,
  // }) async {
  //   // we get the database referrence for the group and the user
  //   final String collectionName =
  //       isDSTI ? Constants.dstiCollections : Constants.assessmentCollection;
  //   final orgRef = _groupsCollection
  //       .doc(groupID

  //       .collection(collectionName)
  //       .doc(assessmentID);
  //   final userRef = _usersCollection
  //       .doc(uid)
  //       .collection(collectionName)
  //       .doc(assessmentID);

  //   // delete the assessment from both the group and user collections
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
    await usersCollection
        .doc(uid)
        .collection(Constants.notificationsCollection)
        .doc(notificationID)
        .update({
      Constants.wasClicked: true,
    });
  }

  // get is admin
  static Future<DocumentSnapshot> getGroupSnapShot({
    required String groupID,
  }) {
    return groupsCollection.doc(groupID).get();
  }

  // get group data from firestore
  static Future<GroupModel> getGroupData({
    required String groupID,
  }) async {
    try {
      DocumentSnapshot groupDoc = await groupsCollection.doc(groupID).get();
      return GroupModel.fromJson(groupDoc.data()! as Map<String, dynamic>);
    } catch (e) {
      print('Error fetching group data: $e');
      return GroupModel();
    }
  }

  // CHAT METHODS
  // discussion stream from firestore
  static Stream<QuerySnapshot> nearMissessStream({
    required String groupID,
  }) {
    return groupsCollection
        .doc(groupID)
        .collection(Constants.nearMissesCollection)
        .orderBy(Constants.createdAt)
        .snapshots();
  }

  // get messages
  static dynamic getMessages({
    required String groupID,
    required String itemID,
    required GenerationType generationType,
    bool asStream = false,
  }) {
    try {
      final collection = getCollectionRef(generationType);
      final query = groupsCollection
          .doc(groupID)
          .collection(collection)
          .doc(itemID)
          .collection(Constants.chatMessagesCollection);

      if (asStream) {
        return query.snapshots().map((snapshot) {
          return snapshot.docs.map((doc) {
            return DiscussionMessage.fromMap(doc.data());
          }).toList();
        });
      } else {
        return query.get().then((snapshot) {
          return snapshot.docs.map((doc) {
            return DiscussionMessage.fromMap(doc.data());
          }).toList();
        });
      }
    } catch (e) {
      log('error loading messages: $e');
      return asStream ? Stream.empty() : Future.value([]);
    }
  }

  // set message status
  static Future<void> setMessageStatus({
    required String currentUserId,
    required String groupID,
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
      await groupsCollection
          .doc(groupID)
          .collection(collection)
          .doc(itemID)
          .collection(Constants.chatMessagesCollection)
          .doc(messageID)
          .update({
        Constants.seenBy: FieldValue.arrayUnion([currentUserId]),
      });
    }
  }

  static Stream<int> getMessageCountStream({
    required String groupID,
    required String itemID,
    required GenerationType generationType,
  }) {
    final collection = getCollectionRef(generationType);
    return groupsCollection
        .doc(groupID)
        .collection(collection)
        .doc(itemID)
        .collection(Constants.chatMessagesCollection)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
}
