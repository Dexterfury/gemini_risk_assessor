import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/appBars/my_app_bar.dart';
import 'package:gemini_risk_assessor/firebase_methods/notifications_stream.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        leading: const BackButton(),
        title: 'Notifications',
        bottom: PreferredSize(
          preferredSize:
              const Size.fromHeight(56.0), // Adjust the height as needed
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ElevatedButton(onPressed: () {}, child: Text('All')),
                const SizedBox(width: 8), // Add some space between buttons
                ElevatedButton(onPressed: () {}, child: Text('Unread')),
              ],
            ),
          ),
        ),
      ),
      body: const NotificationsStream(isAll: true),
    );
  }
}
