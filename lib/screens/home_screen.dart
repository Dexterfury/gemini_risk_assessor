import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/widgets/display_user_image.dart';
import 'package:gemini_risk_assessor/widgets/my_app_bar.dart';
import 'package:gemini_risk_assessor/widgets/risk_assessments_list.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: MyAppBar(
          title: 'Home',
          leading: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
          ),
          actions: const DisplayUserImage(),
          bottom: const TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.assignment_add),
                text: Constants.dailyTaskInstructions,
              ),
              Tab(
                icon: Icon(Icons.assignment_late_outlined),
                text: Constants.riskAssessments,
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text('DSTI'),
              ),
            ),
            RistAssessmentsList(),
          ],
        ),
      ),
    );
  }
}
