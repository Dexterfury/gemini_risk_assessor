import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/firebase_methods/firebase_methods.dart';
import 'package:gemini_risk_assessor/models/notification_model.dart';
import 'package:gemini_risk_assessor/authentication/authentication_provider.dart';
import 'package:gemini_risk_assessor/groups/group_provider.dart';
import 'package:gemini_risk_assessor/groups/group_details.dart';
import 'package:gemini_risk_assessor/groups/groups_screen.dart';
import 'package:gemini_risk_assessor/screens/risk_assessments_screen.dart';
import 'package:gemini_risk_assessor/tools/tools_screen.dart';
import 'package:gemini_risk_assessor/utilities/global.dart';
import 'package:gemini_risk_assessor/utilities/my_image_cache_manager.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class PaginatedNotificationsStream extends StatefulWidget {
  const PaginatedNotificationsStream({
    Key? key,
    required this.isAll,
  }) : super(key: key);

  final bool isAll;

  @override
  _PaginatedNotificationsStreamState createState() =>
      _PaginatedNotificationsStreamState();
}

class _PaginatedNotificationsStreamState
    extends State<PaginatedNotificationsStream> {
  final int _limit = 20;
  bool _hasMore = true;
  bool _isLoading = false;
  List<DocumentSnapshot> _notifications = [];
  DocumentSnapshot? _lastDocument;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  int _retryCount = 0;
  static const int _maxRetries = 3;

  @override
  void initState() {
    super.initState();
    _getNotifications();
  }

  Future<void> _getNotifications({bool isRefresh = false}) async {
    if (!_hasMore && !isRefresh) return;
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final uid = context.read<AuthenticationProvider>().userModel!.uid;
      QuerySnapshot querySnapshot;

      if (isRefresh) {
        querySnapshot = await _getQuery(uid).limit(_limit).get();
        _notifications.clear();
        _lastDocument = null;
        _hasMore = true;
      } else {
        if (_lastDocument == null) {
          querySnapshot = await _getQuery(uid).limit(_limit).get();
        } else {
          querySnapshot = await _getQuery(uid)
              .startAfterDocument(_lastDocument!)
              .limit(_limit)
              .get();
        }
      }

      if (querySnapshot.docs.length < _limit) {
        _hasMore = false;
      }

      if (querySnapshot.docs.isNotEmpty) {
        _lastDocument = querySnapshot.docs.last;
        _notifications.addAll(querySnapshot.docs);
      }

      _retryCount = 0; // Reset retry count on successful fetch
    } catch (e) {
      if (_retryCount < _maxRetries) {
        _retryCount++;
        await Future.delayed(Duration(seconds: 2 * _retryCount));
        return _getNotifications(isRefresh: isRefresh);
      } else {
        // Show error to user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Failed to load notifications. Please try again later.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _refreshController.refreshCompleted();
        _refreshController.loadComplete();
      }
    }
  }

  Query _getQuery(String uid) {
    if (widget.isAll) {
      return FirebaseMethods.usersCollection
          .doc(uid)
          .collection(Constants.notificationsCollection)
          .orderBy(Constants.createdAt, descending: true);
    } else {
      return FirebaseMethods.usersCollection
          .doc(uid)
          .collection(Constants.notificationsCollection)
          .where(Constants.wasClicked, isEqualTo: false)
          .orderBy(Constants.createdAt, descending: true);
    }
  }

  void _onRefresh() async {
    await _getNotifications(isRefresh: true);
  }

  void _onLoading() async {
    await _getNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: _hasMore,
      header: WaterDropHeader(),
      footer: CustomFooter(
        builder: (BuildContext context, LoadStatus? mode) {
          Widget body;
          if (mode == LoadStatus.idle) {
            body = Text("pull up load");
          } else if (mode == LoadStatus.loading) {
            body = CircularProgressIndicator();
          } else if (mode == LoadStatus.failed) {
            body = Text("Load Failed! Click retry!");
          } else if (mode == LoadStatus.canLoading) {
            body = Text("release to load more");
          } else {
            body = Text("No more Data");
          }
          return Container(
            height: 55.0,
            child: Center(child: body),
          );
        },
      ),
      controller: _refreshController,
      onRefresh: _onRefresh,
      onLoading: _onLoading,
      child: ListView.builder(
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final doc = _notifications[index];
          final data = doc.data() as Map<String, dynamic>;
          final notification = NotificationModel.fromJson(data);
          return NotificationItem(
            uid: context.read<AuthenticationProvider>().userModel!.uid,
            notification: notification,
          );
        },
      ),
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
