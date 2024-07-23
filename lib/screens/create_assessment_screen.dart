import 'dart:developer';
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/buttons/gemini_button.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/dialogs/my_dialogs.dart';
import 'package:gemini_risk_assessor/providers/assessment_provider.dart';
import 'package:gemini_risk_assessor/providers/authentication_provider.dart';
import 'package:gemini_risk_assessor/screens/assessment_details_screen.dart';
import 'package:gemini_risk_assessor/themes/my_themes.dart';
import 'package:gemini_risk_assessor/utilities/global.dart';
import 'package:gemini_risk_assessor/widgets/images_display.dart';
import 'package:gemini_risk_assessor/appBars/my_app_bar.dart';
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
    final groupID = args[Constants.groupArg] as String;
    final assessmentProvider = context.watch<AssessmentProvider>();

    final String docTitle = Constants.getDoctTitle(title);

    return Scaffold(
      appBar: MyAppBar(
        leading: const BackButton(),
        title: title,
        actions: [
          resetIcon(assessmentProvider),
        ],
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
              WeatherButtons(
                assessmentProvider: assessmentProvider,
              ),
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
                    return GeminiButton(
                      label: 'Generate',
                      borderRadius: 15.0,
                      onTap: () async {
                        final desc = _descriptionController.text;

                        log('here');
                        // if both images and description is empty return
                        if (desc.isEmpty || desc.length < 10) {
                          showSnackBar(
                            context: context,
                            message:
                                'Please add a description of at least 10 characters',
                          );
                          return;
                        }

                        final authProvider =
                            context.read<AuthenticationProvider>();
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

                        await assessmentProvider.submitPrompt(
                          creatorID: creatorID,
                          groupID: groupID,
                          description: _descriptionController.text,
                          docTitle: docTitle,
                          onSuccess: () {
                            // pop the loading dialog
                            Navigator.pop(context);
                            Future.delayed(const Duration(milliseconds: 500))
                                .whenComplete(action);
                          },
                          onError: (error) {
                            showSnackBar(
                              context: context,
                              message: error,
                            );
                          },
                        );
                      },
                    );
                  },
                  openBuilder: (context, action) {
                    // navigate to screen depending on the clicked icon
                    return AssessmentDetailsScreen(
                      appBarTitle: docTitle,
                      groupID: groupID,
                    );
                  },
                  closedShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  transitionType: ContainerTransitionType.fadeThrough,
                  transitionDuration: const Duration(milliseconds: 500),
                  closedElevation: cardElevation,
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

  resetIcon(
    AssessmentProvider assessmentProvider,
  ) {
    // of images or ppe or weather is not sunny or number of people is not 1
    // or description is not empty
    // show the reset iscon button else dont show it
    bool isResetIconVisible = assessmentProvider.shouldShowResetIcon();
    if (isResetIconVisible || _descriptionController.text.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.all(4.0),
        child: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: IconButton(
            onPressed: () {
              MyDialogs.showMyAnimatedDialog(
                  context: context,
                  title: 'Clear data',
                  content: 'Are you sure to clear?',
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('No'),
                    ),
                    TextButton(
                        onPressed: () {
                          // reset data
                          assessmentProvider.resetCreationData();
                          // reset description
                          _descriptionController.clear();

                          Navigator.pop(context);
                        },
                        child: const Text('Yes'))
                  ]);
            },
            icon: const Icon(
              Icons.refresh,
              color: Colors.white,
            ),
          ),
        ),
      );
    } else {
      return const SizedBox();
    }
  }
}
