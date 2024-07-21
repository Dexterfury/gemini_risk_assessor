import 'dart:convert';
import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/firebase_methods/firebase_methods.dart';
import 'package:gemini_risk_assessor/providers/organization_provider.dart';
import 'package:gemini_risk_assessor/screens/organization_details.dart';
import 'package:provider/provider.dart';

navigationControler({
  required BuildContext context,
  required RemoteMessage message,
}) {
  //if (context == null) return;

  switch (message.data[Constants.notificationType]) {
    case Constants.organizationInvitation:
      log('getting data for: ${message.data[Constants.organizationID]}');
      // navigate to organizations tab
      // get organization model and navigate to organization details page
      FirebaseMethods.getOrganizationData(
        orgID: message.data[Constants.organizationID],
      ).then((orgModel) {
        context
            .read<OrganizationProvider>()
            .setOrganizationModel(orgModel: orgModel)
            .whenComplete(() {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const OrganizationDetails(),
            ),
          );
        });
      });
      break;
    case Constants.dstiNotification:
      // navigate to organizations dsti tab
      // Navigator.pushNamed(
      //   context,
      //   Constants.friendRequestsScreen,
      // );
      break;
    case Constants.assessmentNotification:
      // navigate to friend requests screen

      break;
    case Constants.toolsNotification:
      // navigate to friend requests screen
      // Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      //   return FriendRequestScreen(
      //     groupId: message.data[Constants.groupId],
      //   );
      // }));
      break;

    case Constants.descussNotification:
      // parse the JSON string to a map
      // Map<String, dynamic> jsonMap =
      //     jsonDecode(message.data[Constants.groupModel]);
      // // transform the map to a simple GroupModel object
      // final Map<String, dynamic> flatGroupModelMap =
      //     flattenGroupModelMap(jsonMap);

      // final groupModel = GroupModel.fromMap(flatGroupModelMap);
      // log('JSON: $jsonMap');
      // log('Flat Map: $flatGroupModelMap');
      // log('Group Model: $groupModel');
      // // navigate to group screen
      // context
      //     .read<GroupProvider>()
      //     .setGroupModel(groupModel: groupModel)
      //     .whenComplete(() {
      //   Navigator.pushNamed(
      //     context,
      //     Constants.chatScreen,
      //     arguments: {
      //       Constants.contactUID: groupModel.groupId,
      //       Constants.contactName: groupModel.groupName,
      //       Constants.contactImage: groupModel.groupImage,
      //       Constants.groupId: groupModel.groupId,
      //     },
      //   );
      // });
      break;
    // case Constants.friendRequestNotification:
    //   // navigate to friend requests screen
    //         Navigator.pushNamed(
    //           context,
    //           Constants.friendRequestsScreen,
    //         );
    // break;
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
