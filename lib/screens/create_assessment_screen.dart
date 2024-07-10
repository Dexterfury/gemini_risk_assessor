import 'dart:developer';
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/buttons/main_app_button.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/dialogs/my_dialogs.dart';
import 'package:gemini_risk_assessor/providers/assessment_provider.dart';
import 'package:gemini_risk_assessor/providers/auth_provider.dart';
import 'package:gemini_risk_assessor/screens/assessment_details_screen.dart';
import 'package:gemini_risk_assessor/utilities/global.dart';
import 'package:gemini_risk_assessor/widgets/images_display.dart';
import 'package:gemini_risk_assessor/appBars/my_app_bar.dart';
import 'package:gemini_risk_assessor/widgets/number_of_people.dart';
import 'package:gemini_risk_assessor/widgets/ppe_gridview_widget.dart';
import 'package:gemini_risk_assessor/widgets/input_field.dart';
import 'package:gemini_risk_assessor/widgets/title_widget.dart';
import 'package:gemini_risk_assessor/widgets/weather_buttons.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
    final orgID = args[Constants.orgArg] as String;
    final assessmentProvider = context.watch<AssessmentProvider>();

    final String docTitle = Constants.getDoctTitle(title);

    log('$title: $orgID');
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
                child: OpenContainer(
                  closedBuilder: (context, action) {
                    return MainAppButton(
                      icon: FontAwesomeIcons.wandMagicSparkles,
                      label: 'Generate Assessment',
                      onTap: () async {
                        final authProvider = context.read<AuthProvider>();
                        final creatorID = authProvider.userModel!.uid;

                        // show my alert dialog for loading
                        MyDialogs.showMyAnimatedDialog(
                          context: context,
                          title: 'Generating',
                          loadingIndicator: const SizedBox(
                              height: 100,
                              width: 100,
                              child: LoadingPPEIcons()),
                        );

                        await assessmentProvider
                            .submitPrompt(
                          creatorID: creatorID,
                          orgID: orgID,
                          description: _descriptionController.text,
                          docTitle: docTitle,
                        )
                            .then((value) async {
                          // pop the the dialog
                          Navigator.pop(context);
                          if (value) {
                            action();
                          } else {
                            showSnackBar(
                              context: context,
                              message: AssessmentProvider.noRiskFound,
                            );
                          }
                        });
                      },
                    );
                  },
                  openBuilder: (context, action) {
                    // navigate to screen depending on the clicked icon
                    return AssessmentDetailsScreen(
                      appBarTitle: docTitle,
                    );
                  },
                  transitionType: ContainerTransitionType.fadeThrough,
                  transitionDuration: const Duration(milliseconds: 500),
                  closedElevation: 0,
                  openElevation: 4,
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
