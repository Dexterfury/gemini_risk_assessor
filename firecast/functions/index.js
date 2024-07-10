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
const { log } = require("firebase-functions/logger");
admin.initializeApp();

const db = admin.firestore();

// oncreate organisation
exports.onCreateOrganisation = functions.firestore.document(
  'organisations/{orgId}').onCreate(async (snapshot, context) => {
    const orgData = snapshot.data();
    const creatorUID = orgData.creatorUID;
    const orgName = orgData.name;
    const orgID = context.params.orgId;
    let orgImage = orgData.imageUrl;

    if(!orgImage) {
      // get the default image url from storage
      //const defaultImageUrl = await storageRef.child('defaultImages/user_icon.png').getDownloadURL();
      const defaultImageUrl = 'https://firebasestorage.googleapis.com/v0/b/gemini-risk-assessor.appspot.com/o/images%2FdefaultImages%2Fgroup_icon.png?alt=media&token=657685ea-507c-4a4b-a05b-2d825ac2fc9f';
      orgImage = defaultImageUrl;
     }
  });