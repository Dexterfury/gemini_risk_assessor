import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/appBars/my_app_bar.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: MyAppBar(
        leading: BackButton(),
        title: 'Notifications',
        bottom: Row(children: [
          ElevatedButton(onPressed: (){}, child: Text('All'),
          ElevatedButton(onPressed: (){}, child: Text('Unread'),)
        ],),),
    );
  }
}
