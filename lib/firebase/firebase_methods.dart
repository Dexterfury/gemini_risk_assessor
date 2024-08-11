import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/enums/enums.dart';
import 'package:gemini_risk_assessor/firebase/analytics_helper.dart';
import 'package:gemini_risk_assessor/firebase/error_handler.dart';
import 'package:gemini_risk_assessor/models/assessment_model.dart';
import 'package:gemini_risk_assessor/discussions/discussion_message.dart';
import 'package:gemini_risk_assessor/groups/group_model.dart';
import 'package:gemini_risk_assessor/nearmiss/near_miss_model.dart';
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

  static Stream<QuerySnapshot> paginatedToolStream({
    required String userId,
    required String groupID,
    required int limit,
  }) {
    if (groupID.isNotEmpty) {
      return groupsCollection
          .doc(groupID)
          .collection(Constants.toolsCollection)
          .orderBy(Constants.createdAt, descending: true)
          .limit(limit)
          .snapshots();
    } else {
      return usersCollection
          .doc(userId)
          .collection(Constants.toolsCollection)
          .orderBy(Constants.createdAt, descending: true)
          .limit(limit)
          .snapshots();
    }
  }

  static Query toolsQuery({
    required String userId,
    required String groupID,
  }) {
    if (groupID.isNotEmpty) {
      return groupsCollection
          .doc(groupID)
          .collection(Constants.toolsCollection)
          .orderBy(Constants.createdAt, descending: true);
    } else {
      return usersCollection
          .doc(userId)
          .collection(Constants.toolsCollection)
          .orderBy(Constants.createdAt, descending: true);
    }
  }

  static Stream<QuerySnapshot> allUsersStream({String? searchQuery}) {
    if (searchQuery != null && searchQuery.isNotEmpty) {
      // Use startAt and endAt for prefix search
      return usersCollection
          .where(Constants.name,
              isGreaterThanOrEqualTo: searchQuery.toLowerCase())
          .where(Constants.name,
              isLessThan: searchQuery.toLowerCase() +
                  'z') // 'z' is for lexicographic ordering
          .snapshots();
    } else {
      return usersCollection.snapshots();
    }
  }

  static Stream<QuerySnapshot> paginatedAssessmentStream({
    required String userId,
    required String groupID,
    required int limit,
  }) {
    if (groupID.isNotEmpty) {
      return groupsCollection
          .doc(groupID)
          .collection(Constants.assessmentCollection)
          .orderBy(Constants.createdAt, descending: true)
          .limit(limit)
          .snapshots();
    } else {
      return usersCollection
          .doc(userId)
          .collection(Constants.assessmentCollection)
          .orderBy(Constants.createdAt, descending: true)
          .limit(limit)
          .snapshots();
    }
  }

  static Stream<QuerySnapshot> paginatedNearMissStream({
    required String groupID,
    required int limit,
  }) {
    return groupsCollection
        .doc(groupID)
        .collection(Constants.nearMissesCollection)
        .orderBy(Constants.createdAt, descending: true)
        .limit(limit)
        .snapshots();
  }

  static Query assessmentQuery({
    required String userId,
    required String groupID,
  }) {
    if (groupID.isNotEmpty) {
      return groupsCollection
          .doc(groupID)
          .collection(Constants.assessmentCollection)
          .orderBy(Constants.createdAt, descending: true);
    } else {
      return usersCollection
          .doc(userId)
          .collection(Constants.assessmentCollection)
          .orderBy(Constants.createdAt, descending: true);
    }
  }

  // stream groups from firestore
  static Query groupsQuery(
      {required String userId,
      required String groupID,
      required bool fromShare}) {
    Query query = groupsCollection
        .where(Constants.membersUIDs, arrayContains: userId)
        .orderBy(Constants.createdAt, descending: true);

    if (fromShare && groupID.isNotEmpty) {
      query = query.where(Constants.groupID, isNotEqualTo: groupID);
    }

    return query;
  }

  static Stream<QuerySnapshot> groupsStream({
    required String userId,
    required String groupID,
    required bool fromShare,
  }) {
    var snapshot = groupsCollection
        .where(Constants.membersUIDs, arrayContains: userId)
        .orderBy(
          Constants.createdAt,
          descending: true,
        );

    if (fromShare && groupID.isNotEmpty) {
      snapshot = snapshot.where(Constants.groupID, isNotEqualTo: groupID);
    }

    return snapshot.snapshots();
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
          .orderBy(Constants.createdAt, descending: true)
          .snapshots();
    } else {
      return usersCollection
          .doc(userId)
          .collection(Constants.notificationsCollection)
          .where(Constants.wasClicked, isEqualTo: false)
          .orderBy(Constants.createdAt, descending: true)
          .snapshots();
    }
  }

  // save near miss to forestore
  static Future<void> saveNearMiss({
    required NearMissModel nearMiss,
  }) async {
    await groupsCollection
        .doc(nearMiss.groupID)
        .collection(Constants.nearMissesCollection)
        .doc(nearMiss.id)
        .set(nearMiss.toJson());
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
    } catch (e, stack) {
      ErrorHandler.recordError(
        e,
        stack,
        reason: 'Error fetching creator name',
        severity: ErrorSeverity.low,
      );
      return 'Unknown Creator';
    }
  }

  // get user stream
  static Stream<DocumentSnapshot> userStream({required String userID}) {
    return usersCollection.doc(userID).snapshots();
  }

  static Future<void> shareWithGroup({
    required String uid,
    required AssessmentModel itemModel,
    required String groupID,
  }) async {
    final groupRef = groupsCollection
        .doc(groupID)
        .collection(Constants.assessmentCollection)
        .doc(itemModel.id);
    final userRef = usersCollection
        .doc(uid)
        .collection(Constants.assessmentCollection)
        .doc(itemModel.id);

    // we create a new assessment object with updated sharedWith list and group ID
    final updatedAssessment = itemModel.copyWith(
      sharedWith: [...itemModel.sharedWith, groupID],
      groupID: groupID,
      createdAt: DateTime.now(),
    );

    // we perform both operations in parallel
    await Future.wait([
      groupRef.set(updatedAssessment.toJson()),
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
        .collection(Constants.toolsCollection)
        .doc(toolModel.id);
    final userRef = usersCollection
        .doc(uid)
        .collection(Constants.toolsCollection)
        .doc(toolModel.id);

    // we create a new assessment object with updated sharedWith list
    final updatedTool = toolModel.copyWith(
      sharedWith: [...toolModel.sharedWith, groupID],
      groupID: groupID,
      createdAt: DateTime.now(),
    );

    // we perform both operations in parallel
    await Future.wait([
      orgRef.set(updatedTool.toJson()),
      userRef.update({
        Constants.sharedWith: FieldValue.arrayUnion([groupID])
      }),
    ]);
  }

  // get assessment data
  static Future<AssessmentModel> getAssessmentData({
    required String groupID,
    required String assessmentID,
  }) async {
    try {
      DocumentSnapshot docSnapshot = await groupsCollection
          .doc(groupID)
          .collection(Constants.assessmentCollection)
          .doc(assessmentID)
          .get();

      if (docSnapshot.exists) {
        return AssessmentModel.fromJson(
            docSnapshot.data() as Map<String, dynamic>);
      } else {
        throw Exception('Document does not exist');
      }
    } catch (e, stack) {
      ErrorHandler.recordError(
        e,
        stack,
        reason: 'Error fetching item data',
        severity: ErrorSeverity.critical,
      );
      rethrow;
    }
  }

  // get tool data
  static Future<ToolModel> getToolData({
    required String groupID,
    required String toolID,
  }) async {
    try {
      DocumentSnapshot docSnapshot = await groupsCollection
          .doc(groupID)
          .collection(Constants.toolsCollection)
          .doc(toolID)
          .get();
      if (docSnapshot.exists) {
        return ToolModel.fromJson(docSnapshot.data() as Map<String, dynamic>);
      } else {
        throw Exception('Document does not exist');
      }
    } catch (e, stack) {
      ErrorHandler.recordError(
        e,
        stack,
        reason: 'Error fetching item data',
        severity: ErrorSeverity.critical,
      );
      rethrow;
    }
  }

  static Future<void> deleteAssessment({
    required String currentUserID,
    required String groupID,
    required AssessmentModel assessment,
    required Function() onSuccess,
    required Function(String) onError,
  }) async {
    final String rootCollection = groupID.isNotEmpty
        ? Constants.groupsCollection
        : Constants.usersCollection;
    final String parentDocID = groupID.isNotEmpty ? groupID : currentUserID;

    try {
      // Get doc ref
      final docRef = firestore
          .collection(rootCollection)
          .doc(parentDocID)
          .collection(Constants.assessmentCollection)
          .doc(assessment.id);

      if (groupID.isEmpty && assessment.sharedWith.isEmpty) {
        // If it's a personal assessment and not shared, delete images from storage
        await Future.wait(
          assessment.images.map(
            (url) => _deleteImage(
              imageUrl: url,
              onError: onError,
            ),
          ),
        );
      }

      // Delete the document
      await docRef.delete();

      AnalyticsHelper.logDeletingAssessment();
      onSuccess();
    } catch (e, stack) {
      onError(e.toString());
      ErrorHandler.recordError(
        e,
        stack,
        reason: 'Error deleting assessment',
        severity: ErrorSeverity.medium,
      );
    }
  }

  static Future<void> deleteNearMissReport({
    required String currentUserID,
    required String groupID,
    required NearMissModel nearMiss,
    required Function() onSuccess,
    required Function(String) onError,
  }) async {
    final String rootCollection = groupID.isNotEmpty
        ? Constants.groupsCollection
        : Constants.usersCollection;
    final String parentDocID = groupID.isNotEmpty ? groupID : currentUserID;

    try {
      // Get doc ref
      final docRef = firestore
          .collection(rootCollection)
          .doc(parentDocID)
          .collection(Constants.nearMissesCollection)
          .doc(nearMiss.id);

      // Delete the document
      await docRef.delete();

      AnalyticsHelper.logDeletingNearMiss();
      onSuccess();
    } catch (e, stack) {
      onError(e.toString());
      ErrorHandler.recordError(
        e,
        stack,
        reason: 'Error deleting near miss',
        severity: ErrorSeverity.medium,
      );
    }
  }

  static Future<void> deleteTool({
    required String currentUserID,
    required String groupID,
    required ToolModel tool,
    required Function() onSuccess,
    required Function(String) onError,
  }) async {
    final String rootCollection = groupID.isNotEmpty
        ? Constants.groupsCollection
        : Constants.usersCollection;
    final String parentDocID = groupID.isNotEmpty ? groupID : currentUserID;

    try {
      // Get doc ref
      final docRef = firestore
          .collection(rootCollection)
          .doc(parentDocID)
          .collection(Constants.toolsCollection)
          .doc(tool.id);

      if (groupID.isEmpty && tool.sharedWith.isEmpty) {
        // If it's a personal assessment and not shared, delete images from storage
        await Future.wait(
          tool.images.map(
            (url) => _deleteImage(
              imageUrl: url,
              onError: onError,
            ),
          ),
        );
      }

      // Delete the document
      await docRef.delete();

      AnalyticsHelper.logDeletingAssessment();
      onSuccess();
    } catch (e, stack) {
      onError(e.toString());
      ErrorHandler.recordError(
        e,
        stack,
        reason: 'Error deleting tool',
        severity: ErrorSeverity.medium,
      );
    }
  }

  static Future<void> _deleteImage({
    required String imageUrl,
    required Function(String) onError,
  }) async {
    try {
      final ref = storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e, stack) {
      onError(e.toString());
      ErrorHandler.recordError(
        e,
        stack,
        reason: 'Error deleting image',
        severity: ErrorSeverity.critical,
      );
    }
  }

  // get quiz cout
  static Future<int> getQuizCount({
    required String groupID,
    required String itemID,
    required String collection,
  }) async {
    // count the message where message type is quiz
    final snapshot = await groupsCollection
        .doc(groupID)
        .collection(collection)
        .doc(itemID)
        .collection(Constants.chatMessagesCollection)
        .where(Constants.messageType, isEqualTo: MessageType.quiz.name)
        .get();
    return snapshot.docs.length;
  }

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
  static Future<GroupModel?> getGroupData({
    required String groupID,
  }) async {
    try {
      DocumentSnapshot groupDoc = await groupsCollection.doc(groupID).get();
      return GroupModel.fromJson(groupDoc.data()! as Map<String, dynamic>);
    } catch (e, stack) {
      ErrorHandler.recordError(
        e,
        stack,
        reason: 'Error fetching group data',
        severity: ErrorSeverity.medium,
      );

      return null;
    }
  }

  // near miss query
  static Query nearMissessQuery({
    required String groupID,
  }) {
    return groupsCollection
        .doc(groupID)
        .collection(Constants.nearMissesCollection)
        .orderBy(Constants.createdAt, descending: true);
  }

  static Query<Map<String, dynamic>> getMessagesQuery({
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
        .orderBy(Constants.timeSent, descending: true);
  }

  static Stream<QuerySnapshot> getMessagesStream({
    required String groupID,
    required String itemID,
    required GenerationType generationType,
    required int limit,
  }) {
    final collection = getCollectionRef(generationType);
    return groupsCollection
        .doc(groupID)
        .collection(collection)
        .doc(itemID)
        .collection(Constants.chatMessagesCollection)
        .orderBy(Constants.timeSent, descending: true)
        .limit(limit)
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
    } catch (e, stack) {
      ErrorHandler.recordError(
        e,
        stack,
        reason: 'Error loading messages',
        severity: ErrorSeverity.medium,
      );

      asStream ? Stream.empty() : Future.value([]);
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

  // send reaction to message
  static Future<void> addReactionToMessage({
    required String senderUID,
    required String reaction,
    required String groupID,
    required String itemID,
    required DiscussionMessage message,
    required GenerationType generationType,
  }) async {
    // a reaction is saved as senderUID=reaction
    String reactionToAdd = '$senderUID=$reaction';

    try {
      // 1. check if its a group message
      if (groupID.isNotEmpty) {
        // 2. check if the reaction list is empty
        if (message.reactions.isEmpty) {
          // 3. add the reaction to the message
          await groupsCollection
              .doc(groupID)
              .collection(getCollectionRef(generationType))
              .doc(itemID)
              .collection(Constants.chatMessagesCollection)
              .doc(message.messageID)
              .update({
            Constants.reactions: FieldValue.arrayUnion([reactionToAdd]),
          });
        } else {
          // 4. get UIDs list from reactions list
          final uids = message.reactions.map((e) => e.split('=')[0]).toList();

          // 5. check if this user has already reacted so we replace it
          if (uids.contains(senderUID)) {
            // 6. get the index of the reaction
            final index = uids.indexOf(senderUID);
            // 7. replace the reaction
            message.reactions[index] = reactionToAdd;
            // 8. update the message
            await groupsCollection
                .doc(groupID)
                .collection(getCollectionRef(generationType))
                .doc(itemID)
                .collection(Constants.chatMessagesCollection)
                .doc(message.messageID)
                .update({
              Constants.reactions: message.reactions,
            });
          } else {
            // 7. add the reaction to the message
            await groupsCollection
                .doc(groupID)
                .collection(getCollectionRef(generationType))
                .doc(itemID)
                .collection(Constants.chatMessagesCollection)
                .doc(message.messageID)
                .update({
              Constants.reactions: FieldValue.arrayUnion([reactionToAdd]),
            });
          }
        }
      } else {
        // handle one to one message coming soon
      }
    } catch (e, stack) {
      ErrorHandler.recordError(
        e,
        stack,
        reason: 'Error adding reaction to message',
        severity: ErrorSeverity.medium,
      );
    }
  }

  static Future<bool> checkIsAdmin(String groupID, String currentUID) async {
    try {
      // Reference to the group document
      DocumentReference groupRef = groupsCollection.doc(groupID);

      // Get the group document
      DocumentSnapshot groupDoc = await groupRef.get();

      if (groupDoc.exists) {
        // Check if the currentUID is in the adminsUIDs list
        List<dynamic> adminsUIDs = groupDoc[Constants.adminsUIDs] ?? [];
        return adminsUIDs.contains(currentUID);
      } else {
        // If the document does not exist, return false
        return false;
      }
    } catch (e, stack) {
      ErrorHandler.recordError(
        e,
        stack,
        reason: 'Error loading messages',
        severity: ErrorSeverity.medium,
      );

      return false;
    }
  }

  static Future<void> saveSafetyFile({
    required String collectionID,
    required bool isUser,
    required String safetyFileUrl,
    required String safetyFileContent,
  }) async {
    final collection = isUser ? usersCollection : groupsCollection;
    await collection.doc(collectionID).update({
      Constants.safetyFileUrl: safetyFileUrl,
      Constants.safetyFileContent: safetyFileContent,
    });
  }

  static Future<void> ToggleUseSafetyFileInFirestore({
    required String collectionID,
    required bool isUser,
    required bool value,
  }) async {
    final collection = isUser ? usersCollection : groupsCollection;
    await collection.doc(collectionID).update({
      Constants.useSafetyFile: value,
    });
  }

  static Future<void> updateGroupData({
    required String groupID,
  }) async {
    await groupsCollection.doc(groupID).update({
      Constants.safetyFileUrl: '',
      Constants.safetyFileContent: '',
      Constants.useSafetyFile: false,
    });
  }
}
