import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/appBars/my_app_bar.dart';
import 'package:gemini_risk_assessor/firebase_methods/notifications_stream.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _isAll = true;

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
                    _isAll
                        ? null
                        : setState(() {
                            _isAll = true;
                          });
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
                    !_isAll
                        ? null
                        : setState(() {
                            _isAll = false;
                          });
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
      body: NotificationsStream(isAll: _isAll),
    );
  }
}
