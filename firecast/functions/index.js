/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const functions = require("firebase-functions");
const admin = require("firebase-admin");
const {log} = require("firebase-functions/logger");
admin.initializeApp();

const db = admin.firestore();

// oncreate group
exports.onCreateGroup = functions.firestore
    .document("groups/{groupID}")
    .onCreate(async (snapshot, context) => {
      try {
        const groupData = snapshot.data();
        const creatorUID = groupData.creatorUID;
        const groupName = groupData.name;
        const groupID = context.params.groupID;
        const aboutGroup = groupData.aboutGroup;
        const groupTerms = groupData.groupTerms;
        const awaitingApprovalUIDs = groupData.awaitingApprovalUIDs;
        let groupImage = groupData.groupImage;

        if (!groupImage) {
          const defaultImageUrl = "https://firebasestorage.googleapis.com/v0/b/gemini-risk-assessor.appspot.com/o/images%2FdefaultImages%2Fgroup_icon.png?alt=media&token=657685ea-507c-4a4b-a05b-2d825ac2fc9f";
          groupImage = defaultImageUrl;
        }

        const notificationBatch = db.batch();
        const notificationPromises = [];

        for (const uid of awaitingApprovalUIDs) {
          const notificationId = admin.firestore().collection("users").doc().id;
          const notificationRef = db.collection("users").doc(uid).collection("notifications").doc(notificationId);

          const notificationData = {
            creatorUID: creatorUID,
            recieverUID: uid,
            groupID: groupID,
            notificationID: notificationId,
            title: "New Group Invitation",
            description: `You've been invited to join ${groupName}`,
            imageUrl: groupImage,
            aboutGroup: aboutGroup,
            notificationType: "GROUP_INVITATION",
            groupTerms: groupTerms,
            wasClicked: false,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            notificationDate: admin.firestore.FieldValue.serverTimestamp(),
          };

          notificationBatch.set(notificationRef, notificationData);

          try {
            const userDoc = await db.collection("users").doc(uid).get();
            const userToken = userDoc.data().token;

            log(`User token for ${uid}: ${userToken ? "Found" : "Not found"}`);

            if (userToken) {
              const message = {
                notification: {
                  title: "New Group Invitation",
                  body: `You've been invited to join ${groupName}`,
                  image: groupImage,
                },
                android: {
                  notification: {
                    channel_id: "low_importance_channel",
                  },
                },
                data: {
                  groupID: groupID,
                  notificationID: notificationId,
                  notificationType: "GROUP_INVITATION",
                },
                token: userToken,
              };

              notificationPromises.push(admin.messaging().send(message));
            }
          } catch (userError) {
            log(`Error processing user ${uid}:`, userError);
          }
        }

        await notificationBatch.commit();
        await Promise.all(notificationPromises);

        log(`Notifications created and sent for new group: ${groupID}`);
      } catch (e) {
        log(`Error in onCreateGroup for ${context.params.groupID}:`, e);
        throw e; // Re-throw the error to ensure the function fails
      }
    });

exports.onUpdateGroup = functions.firestore
    .document("groups/{groupID}")
    .onUpdate(async (change, context) => {
      try {
        const newData = change.after.data();
        const previousData = change.before.data();
        const groupID = context.params.groupID;

        // Check if awaitingApprovalUIDs has changed
        if (JSON.stringify(newData.awaitingApprovalUIDs) === JSON.stringify(previousData.awaitingApprovalUIDs)) {
          log("No changes in awaitingApprovalUIDs. Skipping processing.");
          return null;
        }

        const newUIDs = newData.awaitingApprovalUIDs.filter((uid) => !previousData.awaitingApprovalUIDs.includes(uid));

        if (newUIDs.length === 0) {
          log("No new UIDs added to awaitingApprovalUIDs. Skipping processing.");
          return null;
        }

        const creatorUID = newData.creatorUID;
        const groupName = newData.name;
        let groupImage = newData.groupImage;

        if (!groupImage) {
          groupImage = "https://firebasestorage.googleapis.com/v0/b/gemini-risk-assessor.appspot.com/o/images%2FdefaultImages%2Fgroup_icon.png?alt=media&token=657685ea-507c-4a4b-a05b-2d825ac2fc9f";
        }

        const notificationBatch = db.batch();
        const notificationPromises = [];

        for (const uid of newUIDs) {
          const notificationId = admin.firestore().collection("users").doc().id;
          const notificationRef = db.collection("users").doc(uid).collection("notifications").doc(notificationId);

          const notificationData = {
            creatorUID: creatorUID,
            recieverUID: uid,
            groupID: groupID,
            notificationID: notificationId,
            title: "New Organization Invitation",
            description: `You've been invited to join ${groupName}`,
            imageUrl: groupImage,
            aboutGroup: newData.aboutGroup,
            notificationType: "GROUP_INVITATION",
            groupTerms: newData.groupTerms,
            wasClicked: false,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            notificationDate: admin.firestore.FieldValue.serverTimestamp(),
          };

          notificationBatch.set(notificationRef, notificationData);

          try {
            const userDoc = await db.collection("users").doc(uid).get();
            const userToken = userDoc.data().token;

            log(`User token for ${uid}: ${userToken ? "Found" : "Not found"}`);

            if (userToken) {
              const message = {
                notification: {
                  title: "New Organization Invitation",
                  body: `You've been invited to join ${groupName}`,
                  image: groupImage,
                },
                android: {
                  notification: {
                    channel_id: "low_importance_channel",
                  },
                },
                data: {
                  groupID: groupID,
                  notificationID: notificationId,
                  notificationType: "GROUP_INVITATION",
                },
                token: userToken,
              };

              notificationPromises.push(admin.messaging().send(message));
            }
          } catch (userError) {
            log(`Error processing user ${uid}:`, userError);
          }
        }

        await notificationBatch.commit();
        await Promise.all(notificationPromises);

        log(`Notifications created and sent for updated group: ${groupID}. New UIDs: ${newUIDs.join(", ")}`);
      } catch (e) {
        log(`Error in onUpdateGroup for ${context.params.groupID}:`, e);
        throw e;
      }
    });

/**
 * Helper function to create and send notifications.
 * @param {string} groupID - The organization ID.
 * @param {string} itemID - The ID of the created item.
 * @param {string} itemType - The type of the created item.
 * @param {string} itemTitle - The title of the created item.
 * @param {string} senderUID - The UID of the sender.
 * @return {Promise<void>}
 */
async function createAndSendNotifications(groupID, itemID, itemType, itemTitle, senderUID) {
  const orgDoc = await admin.firestore().doc(`groups/${groupID}`).get();
  const groupData = orgDoc.data();
  const membersUIDs = groupData.membersUIDs || [];

  // Batch get user data
  const userRefs = membersUIDs.map((uid) => admin.firestore().doc(`users/${uid}`));
  const userDocs = await admin.firestore().getAll(...userRefs);

  const notificationPromises = userDocs
      .filter((userDoc) => userDoc.exists && userDoc.id !== senderUID)
      .map((userDoc) => {
        const userData = userDoc.data();
        if (userData.token) {
          const notificationMessage = {
            notification: {
              title: `New ${itemType} Created`,
              body: `A new ${itemType} "${itemTitle}" has been created.`,
            },
            android: {
              notification: {
                channel_id: "low_importance_channel",
              },
            },
            data: {
              [`${itemType.toLowerCase()}ID`]: itemID,
              groupID: groupID,
              notificationType: `${itemType.toUpperCase()}_NOTIFICATION`,
            },
            token: userData.token,
          };
          return admin.messaging().send(notificationMessage);
        }
        return null;
      })
      .filter(Boolean); // Remove null promises

  try {
    await Promise.all(notificationPromises);
    console.log(`${itemType} notifications sent successfully`);
  } catch (error) {
    console.error(`Error sending ${itemType} notifications:`, error);
  }
}

/**
 * Creates a notification function for different types of items.
 * @param {string} itemType - The type of the item.
 * @param {string} collectionPath - The Firestore collection path.
 * @return {functions.CloudFunction<functions.firestore.DocumentSnapshot>}
 */
function createNotificationFunction(itemType, collectionPath) {
  return functions.firestore
      .document(`groups/{groupID}/${collectionPath}/{itemID}`)
      .onCreate(async (snapshot, context) => {
        const itemData = snapshot.data();
        const groupID = context.params.groupID;
        const itemID = context.params.itemID;
        const senderUID = itemData.createdBy;

        await createAndSendNotifications(groupID, itemID, itemType, itemData.title, senderUID);
      });
}

// Create notification functions for different types
exports.onCreateAssessment = createNotificationFunction("Assessment", "assessments");
exports.onCreateDsti = createNotificationFunction("DSTI", "dsti");
exports.onCreateTool = createNotificationFunction("Tool", "tools");
exports.onCreateNearMiss = createNotificationFunction("Near Miss", "nearMisses");

exports.onCreateChatMessage = functions.firestore
    .document("groups/{groupID}/{collectionPath}/{itemID}/chatMessages/{messageID}")
    .onCreate(async (snapshot, context) => {
      const messageData = snapshot.data();
      const groupID = context.params.groupID;
      const senderUID = messageData.senderUID;

      // Get group members
      const groupDoc = await admin.firestore().doc(`groups/${groupID}`).get();
      const groupData = groupDoc.data();
      const membersUIDs = groupData.membersUIDs || [];

      // Handle different message types
      if (messageData.isAIMessage) {
        if (messageData.messageType === "quiz") {
          await sendNotifications(
              "New Quiz Available",
              "A new quiz has been posted in the group chat.",
              {messageType: "quiz", ...context.params},
              membersUIDs,
              senderUID,
          );
        } else if (messageData.messageType === "additional") {
          await sendNotifications(
              "New Additional Data",
              "New additional data has been posted in the group chat.",
              {messageType: "additional", ...context.params},
              membersUIDs,
              senderUID,
          );
        }
      } else if (messageData.messageType === "quizAnswer") {
        await sendNotifications(
            "Quiz Answer Submitted",
            `${messageData.senderName} has submitted their quiz answers.`,
            {messageType: "quizAnswer", ...context.params},
            membersUIDs,
            senderUID,
        );

        // Handle points system for quiz answers
        await handleQuizPoints(senderUID, messageData.quizData, messageData.quizResults);

        // Clean up old quiz results
        await cleanupQuizResults(snapshot, context);
      } else {
      // Normal chat message
        await sendNotifications(
            "New Chat Message",
            `${messageData.senderName} sent a message in the group chat.`,
            {messageType: "chat", ...context.params},
            membersUIDs,
            senderUID,
        );
      }
    });


/**
     * Sends a notification to all users in the group chat with the given title and body.
     * @param {*} userUID The UID of the sender.
     * @param {*} quizData The quiz data.
     * @param {*} quizResults The results of the quiz.
     */
async function handleQuizPoints(userUID, quizData, quizResults) {
  const userRef = admin.firestore().doc(`users/${userUID}`);

  // Get the user's answers and the correct answers
  const userAnswers = quizResults[userUID].answers;
  const correctAnswers = quizData.questions.map((q) => q.correctAnswer);

  // Calculate points
  let pointsEarned = 0;
  let correctCount = 0;

  for (let i = 0; i < correctAnswers.length; i++) {
    if (userAnswers[i] === correctAnswers[i]) {
      pointsEarned += 10; // 10 points per correct answer
      correctCount++;
    }
  }

  // Bonus points for all correct
  if (correctCount === correctAnswers.length) {
    pointsEarned += 20; // 20 bonus points for all correct
  }

  // Update user's safety points
  await admin.firestore().runTransaction(async (transaction) => {
    const userDoc = await transaction.get(userRef);
    const userData = userDoc.data();
    const currentPoints = userData.safetyPoints || 0;
    const newPoints = currentPoints + pointsEarned;

    transaction.update(userRef, {safetyPoints: newPoints});
  });

  console.log(`User ${userUID} earned ${pointsEarned} safety points.`);
}
/**
 * @param {*} snap The snapshot of the document that triggered the function.
 * @param {*} context The context of the event that triggered the function.
 */
async function cleanupQuizResults(snap, context) {
  const newMessage = snap.data();
  const {groupID, collectionPath, itemID} = context.params;

  try {
    const chatMessagesRef = admin.firestore().collection("groups").doc(groupID)
        .collection(collectionPath).doc(itemID)
        .collection("chatMessages");

    // Query for previous quiz results with the same title
    const query = chatMessagesRef
        .where("messageType", "==", "quizAnswer")
        .where("quizData.title", "==", newMessage.quizData.title)
        .where("messageID", "!=", snap.id)
        .orderBy("messageID")
        .orderBy("timeSent", "desc");

    const querySnapshot = await query.get();

    // Delete all but the most recent (which is the one we just added)
    const deletePromises = querySnapshot.docs.map((doc) => doc.ref.delete());
    await Promise.all(deletePromises);

    console.log(`Deleted ${deletePromises.length} outdated quiz results for quiz: ${newMessage.quizData.title}`);
  } catch (error) {
    console.error("Error cleaning up quiz results:", error);
  }
}

/**
 * @param {*} title The title of the quiz.
 * @param {*} body The message to be sent.
 * @param {*} data The data to be sent with the notification.
 * @param {*} membersUIDs The UIDs of the members to be notified.
 * @param {*} senderUID The UID of the sender.
 */
async function sendNotifications(title, body, data, membersUIDs, senderUID) {
  const db = admin.firestore();
  const batch = db.batch();

  // Get user documents for all members except the sender
  const userRefs = membersUIDs
      .filter((uid) => uid !== senderUID)
      .map((uid) => db.doc(`users/${uid}`));

  const userDocs = await db.getAll(...userRefs);

  const notificationPromises = userDocs
      .filter((userDoc) => userDoc.exists && userDoc.data().token)
      .map(async (userDoc) => {
        const userData = userDoc.data();
        const notificationMessage = {
          notification: {title, body},
          android: {notification: {channel_id: "high_importance_channel"}},
          data: {
            ...data,
            notificationType: "CHAT_NOTIFICATION",
          },
          token: userData.token,
        };

        try {
          await admin.messaging().send(notificationMessage);
          return {success: true, uid: userDoc.id};
        } catch (error) {
          console.error(`Failed to send notification to user ${userDoc.id}:`, error);

          if (error.code === "messaging/invalid-registration-token" ||
            error.code === "messaging/registration-token-not-registered") {
          // Token is invalid or not registered, remove it
            batch.update(userDoc.ref, {token: admin.firestore.FieldValue.delete()});
          }

          return {success: false, uid: userDoc.id, error};
        }
      });

  const results = await Promise.all(notificationPromises);

  // Commit the batch to remove invalid tokens
  await batch.commit();

  // Log results
  const successCount = results.filter((r) => r.success).length;
  console.log(`Successfully sent ${successCount} out of ${results.length} notifications`);

  return results;
}

exports.onDeleteGroupAssessment = functions.firestore
    .document("groups/{groupId}/assessments/{assessmentId}")
    .onDelete(async (snapshot, context) => {
      const deletedAssessment = snapshot.data();
      const {groupId, assessmentId} = context.params;

      // Get all users
      const usersSnapshot = await admin.firestore().collection("users").get();

      const batch = admin.firestore().batch();

      for (const userDoc of usersSnapshot.docs) {
        const userAssessmentRef = userDoc.ref.collection("assessments").doc(assessmentId);
        const userAssessmentDoc = await userAssessmentRef.get();

        if (userAssessmentDoc.exists) {
          const userData = userAssessmentDoc.data();
          if (userData.sharedWith && userData.sharedWith.includes(groupId)) {
            // Remove the groupId from the sharedWith array
            batch.update(userAssessmentRef, {
              sharedWith: admin.firestore.FieldValue.arrayRemove(groupId),
            });
          }
        }
      }

      // If the assessment was created in the group (not shared from a user),
      // we should delete it entirely and clean up any associated resources
      if (deletedAssessment.createdBy === groupId) {
        // Delete images if any
        if (deletedAssessment.images && deletedAssessment.images.length > 0) {
          const deletePromises = deletedAssessment.images.map((imageUrl) => {
            const decodedUrl = decodeURIComponent(imageUrl);
            const startIndex = decodedUrl.indexOf("/o/") + 3;
            const endIndex = decodedUrl.indexOf("?");
            const filePath = decodedUrl.substring(startIndex, endIndex);
            return admin.storage().bucket().file(filePath).delete();
          });
          await Promise.all(deletePromises);
        }

        // Delete the assessment from all users who have it shared
        for (const userDoc of usersSnapshot.docs) {
          const userAssessmentRef = userDoc.ref.collection("assessments").doc(assessmentId);
          batch.delete(userAssessmentRef);
        }
      }

      // Commit all the batched writes
      await batch.commit();

      console.log(`Cleaned up assessment ${assessmentId} from group ${groupId}`);
    });


exports.onDeleteGroupTool = functions.firestore
    .document("groups/{groupId}/tools/{toolId}")
    .onDelete(async (snapshot, context) => {
      const deletedTool = snapshot.data();
      const {groupId, assessmentId: toolId} = context.params;

      // Get all users
      const usersSnapshot = await admin.firestore().collection("users").get();

      const batch = admin.firestore().batch();

      for (const userDoc of usersSnapshot.docs) {
        const userToolRef = userDoc.ref.collection("tools").doc(toolId);
        const userToolDoc = await userToolRef.get();

        if (userToolDoc.exists) {
          const userData = userToolDoc.data();
          if (userData.sharedWith && userData.sharedWith.includes(groupId)) {
            // Remove the groupId from the sharedWith array
            batch.update(userToolRef, {
              sharedWith: admin.firestore.FieldValue.arrayRemove(groupId),
            });
          }
        }
      }

      // If the assessment was created in the group (not shared from a user),
      // we should delete it entirely and clean up any associated resources
      if (deletedTool.createdBy === groupId) {
        // Delete images if any
        if (deletedTool.images && deletedTool.images.length > 0) {
          const deletePromises = deletedTool.images.map((imageUrl) => {
            const decodedUrl = decodeURIComponent(imageUrl);
            const startIndex = decodedUrl.indexOf("/o/") + 3;
            const endIndex = decodedUrl.indexOf("?");
            const filePath = decodedUrl.substring(startIndex, endIndex);
            return admin.storage().bucket().file(filePath).delete();
          });
          await Promise.all(deletePromises);
        }

        // Delete the assessment from all users who have it shared
        for (const userDoc of usersSnapshot.docs) {
          const userToolRef = userDoc.ref.collection("assessments").doc(toolId);
          batch.delete(userToolRef);
        }
      }

      // Commit all the batched writes
      await batch.commit();

      console.log(`Cleaned up tool ${toolId} from group ${groupId}`);
    });

    exports.updateUserMessages = functions.firestore
    .document('users/{userId}')
    .onUpdate(async (change, context) => {
        const userId = context.params.userId;
        const newData = change.after.data();
        const oldData = change.before.data();

        // Check if name or image has changed
        if (newData.name === oldData.name && newData.imageUrl === oldData.imageUrl) {
            log('No relevant changes detected. Exiting function.');
            return null;
        }

        const db = admin.firestore();
        const batch = db.batch();

        // Function to update messages in a specific collection
        const updateMessagesInCollection = async (collectionPath) => {
            const snapshot = await db.collectionGroup('chatMessages')
                .where('senderUID', '==', userId)
                .get();

            snapshot.docs.forEach((doc) => {
                const docRef = db.doc(doc.ref.path);
                batch.update(docRef, {
                    senderName: newData.name,
                    senderImage: newData.imageUrl
                });
            });
        };

        // Update messages in both collections
        await updateMessagesInCollection('groups/{groupId}/assessments/{assessmentId}/chatMessages');
        await updateMessagesInCollection('groups/{groupId}/tools/{toolId}/chatMessages');

        // Commit the batch
        await batch.commit();

        log(`Updated ${batch.size} messages for user ${userId}`);
        return null;
    });
