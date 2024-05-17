import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/widgets/my_app_bar.dart';
import 'package:gemini_risk_assessor/widgets/risk_assessments_list.dart';
import 'package:gemini_risk_assessor/widgets/search_field.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const MyAppBar(title: Constants.riskAssessments),
        body: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            children: [
              SearchField(),
              Expanded(
                child:
                    RistAssessmentsList(), // list view view of risk assessments
              ),
            ],
          ),
        ),
        // float action button to add new risk assessment
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // navigate to create new risk assessment screen
            //Navigator.pushNamed(context, Constants.createRiskAssessmentRoute);
          },
          child: const Icon(Icons.add),
        ));
  }
}
