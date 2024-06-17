import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/providers/assessment_provider.dart';
import 'package:gemini_risk_assessor/providers/auth_provider.dart';
import 'package:gemini_risk_assessor/screens/assessment_details_screen.dart';
import 'package:gemini_risk_assessor/utilities/global.dart';
import 'package:gemini_risk_assessor/widgets/assessment_images.dart';
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
  // name controller
  final TextEditingController _nameController = TextEditingController();
  // description controller
  final TextEditingController _descriptionController = TextEditingController();

  String _creatorID = '';

  @override
  void initState() {
    getUsersDataFromProvider();
    super.initState();
  }

  getUsersDataFromProvider() {
    // wait for until screen build
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      final authProvider = context.read<AuthProvider>();
      final userName = authProvider.userModel!.name;
      final creatorID = authProvider.userModel!.uid;
      setState(() {
        // set name controller
        _nameController.text = userName;
        _creatorID = creatorID;
      });
    });
  }

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
              const SizedBox(
                height: 10,
              ),
              // creator name field
              InputField(
                labelText: Constants.enterYourName,
                hintText: Constants.enterYourName,
                controller: _nameController,
              ),
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
                  widget: const Icon(Icons.create),
                  label: 'Generate Assessment',
                  onTap: () async {
                    // check if name field is not empty and name length is more 3 characters or more

                    if (_nameController.text.isEmpty ||
                        _nameController.text.length < 3) {
                      showSnackBar(
                          context: context,
                          message: 'Name must be atleast 3 characters');
                      return;
                    }
                    // check if description field is not empty and description length is more 10 characters or more
                    if (_descriptionController.text.isEmpty ||
                        _descriptionController.text.length < 10) {
                      showSnackBar(
                          context: context,
                          message: 'Description must be atleast 10 characters');
                      return;
                    }

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
                    // await assessmentProvider
                    //     .submitTestAssessment(creatorID: _creatorID)
                    //     .then((_) async {
                    //   // pop the the dialog
                    //   Navigator.pop(context);
                    //   if (!context.mounted) return;
                    //   if (assessmentProvider.assessmentModel != null) {
                    //     // display the risk assessment details screen
                    //     PageRouteBuilder pageRouteBuilder = PageRouteBuilder(
                    //       opaque: false,
                    //       pageBuilder: (BuildContext context, animation,
                    //               secondaryAnimation) =>
                    //           RiskAssessmentDetailsScreen(
                    //         assessmentModel:
                    //             assessmentProvider.assessmentModel!,
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

                    await assessmentProvider
                        .submitPrompt(
                      creatorID: _creatorID,
                      description: _descriptionController.text,
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
                            assessmentModel:
                                assessmentProvider.assessmentModel!,
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
