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

      // Function to send notifications
      const sendNotification = async (title, body, data) => {
        const userRefs = membersUIDs
            .filter((uid) => uid !== senderUID)
            .map((uid) => admin.firestore().doc(`users/${uid}`));
        const userDocs = await admin.firestore().getAll(...userRefs);

        const notificationPromises = userDocs
            .filter((userDoc) => userDoc.exists && userDoc.data().token)
            .map((userDoc) => {
              const userData = userDoc.data();
              const notificationMessage = {
                notification: {title, body},
                android: {notification: {channel_id: "high_importance_channel"}},
                data: {
                  ...data,
                  collectionPath: context.params.collectionPath,
                  groupID: context.params.groupID,
                  itemID: context.params.itemID,
                  notificationType: "CHAT_NOTIFICATION",
                },
                token: userData.token,
              };
              return admin.messaging().send(notificationMessage);
            });

        await Promise.all(notificationPromises);
      };

      // Handle different message types
      if (messageData.isAIMessage) {
        if (messageData.messageType === "quiz") {
          await sendNotification("New Quiz Available", "A new quiz has been posted in the group chat.", {messageType: "quiz"});
        } else if (messageData.messageType === "additional") {
          await sendNotification("New Additional Data", "New additional data has been posted in the group chat.", {messageType: "additional"});
        }
      } else if (messageData.messageType === "quizAnswer") {
        await sendNotification("Quiz Answer Submitted", `${messageData.senderName} has submitted their quiz answers.`, {messageType: "quizAnswer"});

        // Handle points system for quiz answers
  await handleQuizPoints(senderUID, messageData.quizData, messageData.quizResults);
      } else {
        // Normal chat message
        await sendNotification("New Chat Message", `${messageData.senderName} sent a message in the group chat.`, {messageType: "chat"});
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
  const correctAnswers = quizData.questions.map(q => q.correctAnswer);

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

exports.cleanupQuizResults = functions.firestore
    .document('groups/{groupId}/{collectionName}/{itemId}/chatMessages/{messageId}')
    .onCreate(async (snap, context) => {
        const newMessage = snap.data();
        const { groupId, collectionName, itemId } = context.params;

        // Check if the new message is a quiz result
        if (newMessage.messageType !== 'quizAnswer') {
            return null; // Exit if not a quiz result
        }

        try {
            const chatMessagesRef = db.collection('groups').doc(groupId)
                .collection(collectionName).doc(itemId)
                .collection('chatMessages');

            // Query for previous quiz results with the same title
            const query = chatMessagesRef
                .where('messageType', '==', 'quizAnswer')
                .where('quizData.title', '==', newMessage.quizData.title)
                .where('messageID', '!=', snap.id)
                .orderBy('messageID')
                .orderBy('timeSent', 'desc');

            const querySnapshot = await query.get();

            // Delete all but the most recent (which is the one we just added)
            const deletePromises = querySnapshot.docs.map(doc => doc.ref.delete());
            await Promise.all(deletePromises);

            log(`Deleted ${deletePromises.length} outdated quiz results for quiz: ${newMessage.quizData.title}`);
            return null;
        } catch (error) {
            log('Error cleaning up quiz results:', error);
            return null;
        }
    });


