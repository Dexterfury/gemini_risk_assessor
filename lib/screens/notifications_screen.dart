import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/app_bars/my_app_bar.dart';
import 'package:gemini_risk_assessor/firebase/analytics_helper.dart';
import 'package:gemini_risk_assessor/firebase/notifications_stream.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _isAll = true;
  Key _paginatedStreamKey = UniqueKey();

  void _resetStream() {
    setState(() {
      _paginatedStreamKey = UniqueKey();
    });
  }

  @override
  void initState() {
    AnalyticsHelper.logScreenView(
      screenName: 'Notifications Screen',
      screenClass: 'NotificationsScreen',
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        leading: const BackButton(),
        title: 'Notifications',
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (!_isAll) {
                      setState(() {
                        _isAll = true;
                      });
                      _resetStream();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _isAll ? Theme.of(context).primaryColor : null,
                    foregroundColor: _isAll ? Colors.white : null,
                  ),
                  child: const Text('All'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    if (_isAll) {
                      setState(() {
                        _isAll = false;
                      });
                      _resetStream();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        !_isAll ? Theme.of(context).primaryColor : null,
                    foregroundColor: !_isAll ? Colors.white : null,
                  ),
                  child: const Text('Unread'),
                ),
              ],
            ),
          ),
        ),
      ),
      body: PaginatedNotificationsStream(
        key: _paginatedStreamKey,
        isAll: _isAll,
      ),
    );
  }
}
