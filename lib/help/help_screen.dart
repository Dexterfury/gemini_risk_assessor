import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/app_bars/my_app_bar.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/firebase/analytics_helper.dart';
import 'package:gemini_risk_assessor/help/help_item_card.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    AnalyticsHelper.logScreenView(
      screenName: 'Help Screen',
      screenClass: 'HelpScreen',
    );
    return Scaffold(
      appBar: const MyAppBar(
        leading: BackButton(),
        title: 'Help Center',
      ),
      body: SafeArea(
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1,
          ),
          itemCount: Constants.helpItems.length,
          itemBuilder: (context, index) {
            return HelpItemCard(helpItem: Constants.helpItems[index]);
          },
        ),
      ),
    );
  }
}
