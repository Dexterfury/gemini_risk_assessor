import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/firebase_methods/firebase_methods.dart';
import 'package:gemini_risk_assessor/models/notification_model.dart';
import 'package:gemini_risk_assessor/authentication/authentication_provider.dart';
import 'package:gemini_risk_assessor/groups/group_provider.dart';
import 'package:gemini_risk_assessor/screens/dsti_screen.dart';
import 'package:gemini_risk_assessor/groups/group_details.dart';
import 'package:gemini_risk_assessor/groups/groups_screen.dart';
import 'package:gemini_risk_assessor/screens/risk_assessments_screen.dart';
import 'package:gemini_risk_assessor/themes/app_theme.dart';
import 'package:gemini_risk_assessor/tools/tools_screen.dart';
import 'package:gemini_risk_assessor/utilities/global.dart';
import 'package:gemini_risk_assessor/utilities/my_image_cache_manager.dart';
import 'package:provider/provider.dart';

class NotificationsStream extends StatelessWidget {
  const NotificationsStream({
    super.key,
    required this.isAll,
  });

  final bool isAll;

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthenticationProvider>().userModel!.uid;
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseMethods.notificationsStream(
        userId: uid,
        isAll: isAll,
      ),
      builder: (
        BuildContext context,
        AsyncSnapshot<QuerySnapshot> snapshot,
      ) {
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'No Notifications',
                textAlign: TextAlign.center,
                style: AppTheme.textStyle18w500,
              ),
            ),
          );
        }
        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final data = doc.data() as Map<String, dynamic>;
            final notification = NotificationModel.fromJson(data);
            return NotificationItem(
              uid: uid,
              notification: notification,
            );
          },
        );
      },
    );
  }
}

class NotificationItem extends StatelessWidget {
  const NotificationItem({
    super.key,
    required this.uid,
    required this.notification,
  });

  final String uid;
  final NotificationModel notification;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: SizedBox(
          width: 80,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CachedNetworkImage(
              imageUrl: notification.imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) =>
                  const Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) => const Center(
                  child: Icon(
                Icons.error,
                color: Colors.red,
              )),
              cacheManager: MyImageCacheManager.itemsCacheManager,
            ),
          ),
        ),
        title: Text(
          notification.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          notification.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),

        //trailing: // show indicator if not clicked
        onTap: () async {
          // set was clicked to true
          await FirebaseMethods.setNotificationClicked(
            uid: uid,
            notificationID: notification.notificationID,
          ).whenComplete(() {
            // navigate to notification details page
            navigateToNotificationDetailsPage(
              context,
              notification,
            );
          });
        },
        trailing: notification.wasClicked
            ? null
            : const CircleAvatar(
                radius: 5,
                backgroundColor: Colors.blue,
              ),
      ),
    );
  }

  void navigateToNotificationDetailsPage(
    BuildContext context,
    NotificationModel notification,
  ) async {
    switch (notification.notificationType) {
      case Constants.dstiCollections:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DSTIScreen(
              groupID: notification.groupID,
            ),
          ),
        );
        break;
      case Constants.assessmentNotification:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RiskAssessmentsScreen(
              groupID: notification.groupID,
            ),
          ),
        );
        break;
      case Constants.toolsNotification:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ToolsScreen(
              groupID: notification.groupID,
            ),
          ),
        );
        break;
      case Constants.groupInvitation:
        // get group model and navigate to group details page

        final groupModel = await FirebaseMethods.getGroupData(
          groupID: notification.groupID,
        );

        if (groupModel != null) {
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
        } else {
          showSnackBar(context: context, message: 'This group was deleted');
        }

        break;
      default:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const GroupsScreen(),
          ),
        );
        break;
    }
  }
}
