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
