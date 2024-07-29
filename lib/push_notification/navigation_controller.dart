import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/discussions/chat_discussion_screen.dart';
import 'package:gemini_risk_assessor/enums/enums.dart';
import 'package:gemini_risk_assessor/firebase_methods/firebase_methods.dart';
import 'package:gemini_risk_assessor/groups/group_provider.dart';
import 'package:gemini_risk_assessor/groups/group_details.dart';
import 'package:provider/provider.dart';

navigationControler({
  required BuildContext context,
  required RemoteMessage message,
}) {
  //if (context == null) return;

  switch (message.data[Constants.notificationType]) {
    case Constants.groupInvitation:
      log('getting data for: ${message.data[Constants.groupID]}');
      // navigate to groups tab
      // get group model and navigate to group details page
      FirebaseMethods.getGroupData(
        groupID: message.data[Constants.groupID],
      ).then((groupModel) {
        context
            .read<GroupProvider>()
            .setGroupModel(groupModel: groupModel)
            .whenComplete(() {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const GroupDetails(),
            ),
          );
        });
      });
      break;
    case Constants.dstiNotification:
      break;
    case Constants.assessmentNotification:
      // navigate to friend requests screen

      break;
    case Constants.toolsNotification:
      break;

    case Constants.chatNotification:
      final String groupID = message.data[Constants.groupID];
      final String itemID = message.data[Constants.itemID];
      final String collectionPath = message.data[Constants.collectionPath];

      switch (collectionPath) {
        case Constants.assessmentCollection:
        case Constants.dstiCollections:
          FirebaseMethods.getAssessmentData(
            groupID: groupID,
            assessmentID: itemID,
          ).then((assessmentModel) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatDiscussionScreen(
                  groupID: groupID,
                  assessment: assessmentModel,
                  generationType: getGenerationTypeFromString(collectionPath),
                ),
              ),
            );
          });
          break;
        case Constants.toolsCollection:
          FirebaseMethods.getToolData(
            groupID: groupID,
            toolID: itemID,
          ).then((toolModel) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatDiscussionScreen(
                  groupID: groupID,
                  tool: toolModel,
                  generationType: GenerationType.tool,
                ),
              ),
            );
          });
          break;
        default:
          print('Unknown collection path: $collectionPath');
      }

      break;
    default:
      print('No Notification');
  }
}

// Function to transform the complex structure into a simple map
Map<String, dynamic> flattenGroupModelMap(Map<String, dynamic> complexMap) {
  Map<String, dynamic> flatMap = {};

  complexMap['_fieldsProto'].forEach((key, value) {
    switch (value['valueType']) {
      case 'stringValue':
        flatMap[key] = value['stringValue'];
        break;
      case 'booleanValue':
        flatMap[key] = value['booleanValue'];
        break;
      case 'integerValue':
        flatMap[key] = int.parse(value['integerValue']);
        break;
      case 'arrayValue':
        flatMap[key] = value['arrayValue']['values']
            .map<String>((item) => item['stringValue'] as String)
            .toList();
        break;
      // Add other cases if necessary
      default:
        // Handle unknown types
        flatMap[key] = null;
    }
  });

  return flatMap;
}
