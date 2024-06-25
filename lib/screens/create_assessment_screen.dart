import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/providers/assessment_provider.dart';
import 'package:gemini_risk_assessor/providers/auth_provider.dart';
import 'package:gemini_risk_assessor/screens/assessment_details_screen.dart';
import 'package:gemini_risk_assessor/utilities/global.dart';
import 'package:gemini_risk_assessor/widgets/images_display.dart';
import 'package:gemini_risk_assessor/widgets/main_app_button.dart';
import 'package:gemini_risk_assessor/widgets/my_app_bar.dart';
import 'package:gemini_risk_assessor/widgets/number_of_people.dart';
import 'package:gemini_risk_assessor/widgets/ppe_gridview_widget.dart';
import 'package:gemini_risk_assessor/widgets/input_field.dart';
import 'package:gemini_risk_assessor/widgets/title_widget.dart';
import 'package:gemini_risk_assessor/widgets/weather_buttons.dart';
import 'package:provider/provider.dart';

class CreateAssessmentScreen extends StatefulWidget {
  const CreateAssessmentScreen({super.key});

  @override
  State<CreateAssessmentScreen> createState() => _CreateAssessmentScreenState();
}

class _CreateAssessmentScreenState extends State<CreateAssessmentScreen> {
  // description controller
  final TextEditingController _descriptionController = TextEditingController();

  @override
  dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // get the arguments
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    final title = args[Constants.title] as String;
    final assessmentProvider = context.watch<AssessmentProvider>();
    return Scaffold(
      appBar: MyAppBar(
        leading: const BackButton(),
        title: title,
      ),
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
              ImagesDisplay(
                assessmentProvider: assessmentProvider,
              ),

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
              const HeadingTitleWidget(
                title: 'Select the weather',
              ),
              const SizedBox(
                height: 10,
              ),
              WeatherButtons(assessmentProvider: assessmentProvider),
              const SizedBox(
                height: 20,
              ),
              const NumberOfPeople(),
              const SizedBox(
                height: 20,
              ),

              // assessment description field
              InputField(
                labelText: Constants.enterDescription,
                hintText: Constants.enterDescription,
                controller: _descriptionController,
              ),
              const SizedBox(
                height: 30,
              ),
              // create assessment button
              Align(
                alignment: Alignment.centerRight,
                child: MainAppButton(
                  widget: const Icon(
                    Icons.create,
                    color: Colors.white,
                  ),
                  label: 'Generate Assessment',
                  onTap: () async {
                    // check if description field is not empty and description length is more 10 characters or more
                    if (_descriptionController.text.isEmpty ||
                        _descriptionController.text.length < 10) {
                      showSnackBar(
                          context: context,
                          message: 'Description must be atleast 10 characters');
                      return;
                    }

                    // check if atleast 3 ppe is selected
                    if (assessmentProvider.ppeModelList.length < 3) {
                      showSnackBar(
                          context: context,
                          message: 'Please select atleast 3 PPE');
                      return;
                    }

                    final authProvider = context.read<AuthProvider>();
                    final creatorID = authProvider.userModel!.uid;

                    log('creatorID: $creatorID');

                    // show my alert dialog for loading
                    showMyAnimatedDialog(
                      context: context,
                      title: 'Generating',
                      content: 'Please wait while we generate your assessment',
                      loadingIndicator: const SizedBox(
                          height: 40,
                          width: 40,
                          child: CircularProgressIndicator()),
                    );
                    await assessmentProvider
                        .submitTestAssessment(
                      creatorID: creatorID,
                      docTitle: title,
                    )
                        .then((_) async {
                      // pop the the dialog
                      Navigator.pop(context);
                      if (!context.mounted) return;
                      if (assessmentProvider.assessmentModel != null) {
                        // display the risk assessment details screen
                        PageRouteBuilder pageRouteBuilder = PageRouteBuilder(
                          opaque: false,
                          pageBuilder: (BuildContext context, animation,
                                  secondaryAnimation) =>
                              AssessmentDetailsScreen(
                            animation: animation,
                          ),
                        );
                        bool shouldSave =
                            await Navigator.of(context).push(pageRouteBuilder);
                        if (shouldSave) {
                          // TODO save the risk assessment to database
                        }
                      }
                    });

                    // await assessmentProvider
                    //     .submitPrompt(
                    //   creatorID: creatorID,
                    //   description: _descriptionController.text,
                    // )
                    //     .then((_) async {
                    //   // pop the the dialog
                    //   Navigator.pop(context);
                    //   if (!context.mounted) return;
                    //   // display the results
                    //   if (assessmentProvider.assessmentModel != null) {
                    //     // display the risk assessment details screen
                    //     PageRouteBuilder pageRouteBuilder = PageRouteBuilder(
                    //       opaque: false,
                    //       pageBuilder: (BuildContext context, animation,
                    //               secondaryAnimation) =>
                    //           AssessmentDetailsScreen(
                    //         animation: animation,
                    //       ),
                    //     );
                    //     bool shouldSave =
                    //         await Navigator.of(context).push(pageRouteBuilder);
                    //     if (shouldSave) {
                    //       // TODO save the risk assessment to database
                    //     }
                    //   }
                    // });
                  },
                ),
              ),

              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      )),
    );
  }
}
