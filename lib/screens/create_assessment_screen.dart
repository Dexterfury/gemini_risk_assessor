import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/widgets/assessment_images.dart';
import 'package:gemini_risk_assessor/widgets/my_app_bar.dart';
import 'package:gemini_risk_assessor/widgets/number_of_people.dart';
import 'package:gemini_risk_assessor/widgets/ppe_gridview_widget.dart';
import 'package:gemini_risk_assessor/widgets/project_discription_field.dart';

class CreateAssessmentScreen extends StatefulWidget {
  const CreateAssessmentScreen({super.key});

  @override
  State<CreateAssessmentScreen> createState() => _CreateAssessmentScreenState();
}

class _CreateAssessmentScreenState extends State<CreateAssessmentScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: MyAppBar(
        title: Constants.createAssessment,
      ),
      body: SafeArea(
          child: Padding(
        padding: EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add Project images'),
              SizedBox(
                height: 10,
              ),
              AssessmentImages(),
              SizedBox(
                height: 20,
              ),
              Text('Select Personal Protective Equipment'),
              SizedBox(
                height: 10,
              ),
              PpeGridViewWidget(),
              SizedBox(
                height: 20,
              ),
              NumberOfPeople(),
              SizedBox(
                height: 20,
              ),
              Text('What do you want to do?'),
              SizedBox(
                height: 10,
              ),
              ProjectDiscriptionField()
            ],
          ),
        ),
      )),
    );
  }
}
