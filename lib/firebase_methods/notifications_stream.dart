import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/firebase_methods/firebase_methods.dart';
import 'package:gemini_risk_assessor/models/notification_model.dart';
import 'package:gemini_risk_assessor/providers/auth_provider.dart';
import 'package:gemini_risk_assessor/screens/dsti_screen.dart';
import 'package:gemini_risk_assessor/screens/organisations_screen.dart';
import 'package:gemini_risk_assessor/screens/risk_assessments_screen.dart';
import 'package:gemini_risk_assessor/screens/tools_screen.dart';
import 'package:gemini_risk_assessor/themes/my_themes.dart';
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
    final uid = context.read<AuthProvider>().userModel!.uid;
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
              child: Text('No Notifications',
                  textAlign: TextAlign.center, style: textStyle18w500),
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
    required this.notification,
  });

  final NotificationModel notification;

  @override
  Widget build(BuildContext context) {
    return ListTile(
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
      onTap: () {
        // navigate to notification details page
        navigateToNotificationDetailsPage(context, notification);
      },
    );
  }

  void navigateToNotificationDetailsPage(
    BuildContext context,
    NotificationModel notification,
  ) {
    switch (notification.notificationType) {
      case Constants.dstiCollections:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DSTIScreen(
              orgID: notification.organisationID,
            ),
          ),
        );
        break;
      case Constants.assessmentNotification:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RiskAssessmentsScreen(
              orgID: notification.organisationID,
            ),
          ),
        );
        break;
      case Constants.toolsNotification:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ToolsScreen(
              orgID: notification.organisationID,
            ),
          ),
        );
        break;
      case Constants.newOrganisationNotification:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const OrganisationsScreen(),
          ),
        );
        break;
      default:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const OrganisationsScreen(),
          ),
        );
        break;
    }
  }
}
