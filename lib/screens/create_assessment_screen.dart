import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/models/assessment_model.dart';
import 'package:gemini_risk_assessor/providers/assessment_provider.dart';
import 'package:gemini_risk_assessor/widgets/assessment_images.dart';
import 'package:gemini_risk_assessor/widgets/generate_button.dart';
import 'package:gemini_risk_assessor/widgets/gradient_orb.dart';
import 'package:gemini_risk_assessor/widgets/my_app_bar.dart';
import 'package:gemini_risk_assessor/widgets/number_of_people.dart';
import 'package:gemini_risk_assessor/widgets/ppe_gridview_widget.dart';
import 'package:gemini_risk_assessor/widgets/input_field.dart';
import 'package:gemini_risk_assessor/widgets/title_widget.dart';
import 'package:provider/provider.dart';

class CreateAssessmentScreen extends StatefulWidget {
  const CreateAssessmentScreen({super.key});

  @override
  State<CreateAssessmentScreen> createState() => _CreateAssessmentScreenState();
}

class _CreateAssessmentScreenState extends State<CreateAssessmentScreen> {
  @override
  Widget build(BuildContext context) {
    final assessmentProvider = context.watch<AssessmentProvider>();
    return Scaffold(
      appBar: const MyAppBar(
        title: Constants.createAssessment,
      ),
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const HeadingTitleWidget(
                title: 'Add Project images',
              ),
              const SizedBox(
                height: 10,
              ),
              // assessment images
              const AssessmentImages(),
              const SizedBox(
                height: 20,
              ),
              const HeadingTitleWidget(
                title: 'Select Personal Protective Equipment',
              ),
              const SizedBox(
                height: 10,
              ),
              // assessment ppe
              const PpeGridViewWidget(),
              const SizedBox(
                height: 20,
              ),
              const NumberOfPeople(),
              const SizedBox(
                height: 20,
              ),
              const HeadingTitleWidget(
                title: 'What do you want to do?',
              ),
              const SizedBox(
                height: 10,
              ),
              // creator name field
              const InputField(
                labelText: Constants.enterYourName,
                hintText: Constants.enterYourName,
              ),
              const SizedBox(
                height: 10,
              ),
              // assessment description field
              const InputField(
                labelText: Constants.enterDescription,
                hintText: Constants.enterDescription,
              ),
              const SizedBox(
                height: 30,
              ),
              // create assessment button
              Align(
                alignment: Alignment.centerRight,
                child: GenerateButton(
                  widget: const Icon(Icons.create),
                  label: 'Generate Assessment',
                  onTap: () async {
                    await assessmentProvider.submitPrompt().then((_) async {
                      if (!context.mounted) return;
                      if (assessmentProvider.assessmentModel != null) {
                        // display the risk assessment details screen
                        PageRouteBuilder pageRouteBuilder = PageRouteBuilder(
                          opaque: false,
                          pageBuilder: (BuildContext context, animation,
                                  secondaryAnimation) =>
                              AssessmentDetailsScreen(
                            assessmentModel:
                                assessmentProvider.assessmentModel!,
                          ),
                        );
                        bool shouldSave =
                            await Navigator.of(context).push(pageRouteBuilder);
                        if (shouldSave) {
                          // TODO save the risk assessment to database
                        }
                      }
                    });
                  },
                ),
              )
            ],
          ),
        ),
      )),
    );
  }
}

class AssessmentDetailsScreen extends StatelessWidget {
  const AssessmentDetailsScreen({
    super.key,
    required this.assessmentModel,
  });

  final AssessmentModel assessmentModel;

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
