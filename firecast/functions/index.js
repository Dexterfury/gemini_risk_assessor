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

// oncreate organization
exports.onCreateOrganization = functions.firestore
    .document("organizations/{orgId}")
    .onCreate(async (snapshot, context) => {
      try {
        const orgData = snapshot.data();
        const creatorUID = orgData.creatorUID;
        const orgName = orgData.name;
        const orgID = context.params.orgId;
        const aboutOrg = orgData.aboutOrganization;
        const orgTerms = orgData.organizationTerms;
        const awaitingApprovalUIDs = orgData.awaitingApprovalUIDs || [];
        let orgImage = orgData.imageUrl;

        if (!orgImage) {
          const defaultImageUrl = "https://firebasestorage.googleapis.com/v0/b/gemini-risk-assessor.appspot.com/o/images%2FdefaultImages%2Fgroup_icon.png?alt=media&token=657685ea-507c-4a4b-a05b-2d825ac2fc9f";
          orgImage = defaultImageUrl;
        }

        const notificationBatch = db.batch();
        const notificationPromises = [];

        for (const uid of awaitingApprovalUIDs) {
          const notificationId = admin.firestore().collection("users").doc().id;
          const notificationRef = db.collection("users").doc(uid).collection("notifications").doc(notificationId);

          const notificationData = {
            creatorUID: creatorUID,
            recieverUID: uid,
            organizationID: orgID,
            notificationID: notificationId,
            title: "New Organization Invitation",
            description: `You've been invited to join ${orgName}`,
            imageUrl: orgImage,
            aboutOrganization: aboutOrg,
            notificationType: "ORGANIZATION_INVITATION",
            organizationTerms: orgTerms,
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
                  body: `You've been invited to join ${orgName}`,
                  image: orgImage,
                },
                android: {
                  notification: {
                    channel_id: "low_importance_channel",
                  },
                },
                data: {
                  organizationID: orgID,
                  notificationID: notificationId,
                  notificationType: "ORGANIZATION_INVITATION",
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

        log(`Notifications created and sent for new organization: ${orgID}`);
      } catch (e) {
        log(`Error in onCreateOrganization for ${context.params.orgId}:`, e);
        throw e; // Re-throw the error to ensure the function fails
      }
    });

exports.onUpdateOrganization = functions.firestore
    .document("organizations/{orgId}")
    .onUpdate(async (change, context) => {
      try {
        const newData = change.after.data();
        const previousData = change.before.data();
        const orgID = context.params.orgId;

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
        const orgName = newData.name;
        let orgImage = newData.imageUrl;

        if (!orgImage) {
          orgImage = "https://firebasestorage.googleapis.com/v0/b/gemini-risk-assessor.appspot.com/o/images%2FdefaultImages%2Fgroup_icon.png?alt=media&token=657685ea-507c-4a4b-a05b-2d825ac2fc9f";
        }

        const notificationBatch = db.batch();
        const notificationPromises = [];

        for (const uid of newUIDs) {
          const notificationId = admin.firestore().collection("users").doc().id;
          const notificationRef = db.collection("users").doc(uid).collection("notifications").doc(notificationId);

          const notificationData = {
            creatorUID: creatorUID,
            recieverUID: uid,
            organizationID: orgID,
            notificationID: notificationId,
            title: "New Organization Invitation",
            description: `You've been invited to join ${orgName}`,
            imageUrl: orgImage,
            aboutOrganization: newData.aboutOrganization,
            notificationType: "ORGANIZATION_INVITATION",
            organizationTerms: newData.organizationTerms,
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
                  body: `You've been invited to join ${orgName}`,
                  image: orgImage,
                },
                android: {
                  notification: {
                    channel_id: "low_importance_channel",
                  },
                },
                data: {
                  organizationID: orgID,
                  notificationID: notificationId,
                  notificationType: "ORGANIZATION_INVITATION",
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

        log(`Notifications created and sent for updated organization: ${orgID}. New UIDs: ${newUIDs.join(", ")}`);
      } catch (e) {
        log(`Error in onUpdateOrganization for ${context.params.orgId}:`, e);
        throw e;
      }
    });
