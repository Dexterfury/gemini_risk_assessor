import 'dart:developer';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gemini_risk_assessor/buttons/animated_chat_button.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/dialogs/my_dialogs.dart';
import 'package:gemini_risk_assessor/enums/enums.dart';
import 'package:gemini_risk_assessor/firebase_methods/firebase_methods.dart';
import 'package:gemini_risk_assessor/models/assessment_model.dart';
import 'package:gemini_risk_assessor/models/ppe_model.dart';
import 'package:gemini_risk_assessor/providers/assessment_provider.dart';
import 'package:gemini_risk_assessor/providers/auth_provider.dart';
import 'package:gemini_risk_assessor/providers/chat_provider.dart';
import 'package:gemini_risk_assessor/screens/chat_screen.dart';
import 'package:gemini_risk_assessor/screens/share_screen.dart';
import 'package:gemini_risk_assessor/utilities/assessment_grid_items.dart';
import 'package:gemini_risk_assessor/utilities/global.dart';
import 'package:gemini_risk_assessor/widgets/images_display.dart';
import 'package:gemini_risk_assessor/buttons/bottom_buttons_field.dart';
import 'package:gemini_risk_assessor/appBars/my_app_bar.dart';
import 'package:gemini_risk_assessor/widgets/ppe_items_widget.dart';
import 'package:gemini_risk_assessor/widgets/weather_button.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AssessmentDetailsScreen extends StatelessWidget {
  const AssessmentDetailsScreen({
    super.key,
    required this.appBarTitle,
    this.currentModel,
  });

  final String appBarTitle;
  final AssessmentModel? currentModel;

  @override
  Widget build(BuildContext context) {
    // assessment provider de pendency injection
    final assessmentProvider = getProvider(
      context,
      currentModel,
    );

    // get assessment model depending on current model or from provider
    final assessmentModel = getModel(
      context,
      currentModel,
    );
    // get time
    final time = assessmentModel.createdAt;
    // get title
    final title = assessmentModel.title;
    // weather
    final weather = assessmentModel.weather;
    // task to archieve
    final task = assessmentModel.taskToAchieve;
    // equipments
    final equipments = assessmentModel.equipments;
    // hazards
    final hazards = assessmentModel.hazards;
    // risks
    final risks = assessmentModel.risks;
    // control
    final control = assessmentModel.control;
    // summary
    final summary = assessmentModel.summary;
    // pdf
    final pdfUrl = assessmentModel.pdfUrl;
    // id
    final id = assessmentModel.id;

    // get generationType
    final generationType = getGenerationType(appBarTitle);

    // ppe list
    final ppeList = getPPEList(
      context,
      currentModel,
    );

    // Format the datetime using Intl package
    String formattedTime = DateFormat.yMMMEd().format(time);

    return Scaffold(
      appBar: MyAppBar(
        title: appBarTitle,
        leading: const BackButton(),
        actions: [
          currentModel != null
              ? Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: AnimatedChatButton(
                    onPressed: () async {
                      // Open chat or navigate to chat screen
                      final uid = context.read<AuthProvider>().userModel!.uid;
                      final chatProvider = context.read<ChatProvider>();
                      await chatProvider
                          .getChatHistoryFromFirebase(
                        uid: uid,
                        generationType: generationType,
                        assessmentModel: assessmentModel,
                      )
                          .whenComplete(() {
                        // Navigate to the chat screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(
                              assesmentModel: assessmentModel,
                              generationType: generationType,
                            ),
                          ),
                        );
                      });
                    },
                    size: ChatButtonSize.small,
                    iconColor: Colors.white,
                  ),
                )
              : const SizedBox()
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          //controller: _scrollController,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                child: Text(
                  title,
                  maxLines: 1,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Task to Achieve:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: SizedBox(
                      width: 100,
                      child: WeatherButton(
                          title: weather,
                          value: true,
                          iconData: getWeatherIcon(
                            WeatherExtension.fromString(
                              weather,
                            ),
                          ),
                          onChanged: () {}),
                    ),
                  ),
                ],
              ),
              Text(task),
              const SizedBox(height: 10),
              ImagesDisplay(
                isViewOnly: true,
                assessmentProvider: assessmentProvider,
                currentAssessmentModel: currentModel,
              ),
              const SizedBox(height: 10),
              AssessmentGridItems(
                equipments: equipments,
                hazards: hazards,
                risks: risks,
                controlMeasures: control,
              ),
              const SizedBox(height: 10),
              ppeList.isNotEmpty
                  ? PpeItemsWidget(
                      label: ListHeader.ppe,
                      ppeModelList: ppeList,
                    )
                  : const SizedBox.shrink(),
              const SizedBox(height: 10),
              const Text(
                'Summary:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(summary),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.50,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        getCreatedBy(
                          context,
                          currentModel,
                        ),
                        Text(formattedTime),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      currentModel == null
                          ? const SizedBox()
                          :
                          // pdf icon
                          IconButton(
                              onPressed: () async {
                                // show my alert dialog for loading
                                MyDialogs.showMyAnimatedDialog(
                                  context: context,
                                  title: 'Processing',
                                  loadingIndicator: const SizedBox(
                                      height: 100,
                                      width: 100,
                                      child: LoadingPPEIcons()),
                                );
                                // open pdf
                                await context
                                    .read<AssessmentProvider>()
                                    .openPdf(
                                      pdfUrl: pdfUrl,
                                      fileName: '$id.pdf',
                                      onSuccess: () {
                                        //pop loading dialog
                                        Navigator.of(context).pop();
                                      },
                                      onError: (error) {
                                        //pop loading dialog
                                        Navigator.of(context).pop();
                                        showSnackBar(
                                          context: context,
                                          message: 'Error loading PDF file',
                                        );
                                      },
                                    );
                              },
                              icon: const Icon(
                                FontAwesomeIcons.filePdf,
                              ),
                            ),
                      const SizedBox(width: 10),
                      OpenContainer(
                        closedBuilder: (context, action) {
                          return IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              FontAwesomeIcons.share,
                            ),
                          );
                        },
                        openBuilder: (context, action) {
                          // navigate to screen depending on the clicked icon
                          return ShareScreen(
                            itemModel: assessmentModel,
                            generationType: generationType,
                          );
                        },
                        transitionType: ContainerTransitionType.fadeThrough,
                        transitionDuration: const Duration(milliseconds: 500),
                        closedShape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        closedElevation: 4,
                        openElevation: 4,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              currentModel == null
                  ? const BottonButtonsField()
                  : const SizedBox(
                      height: 20,
                    ),
            ],
          ),
        ),
      ),
    );
  }

  AssessmentModel getModel(
    BuildContext context,
    AssessmentModel? currentModel,
  ) {
    if (currentModel != null) {
      return currentModel;
    } else {
      final assessmentProvider = context.watch<AssessmentProvider>();
      return assessmentProvider.assessmentModel;
    }
  }

  getCreatedBy(
    BuildContext context,
    AssessmentModel? currentModel,
  ) {
    if (currentModel != null) {
      return FutureBuilder<String>(
        future: FirebaseMethods.getCreatorName(currentModel.createdBy),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
              width: 100,
              child: LinearProgressIndicator(),
            );
          } else {
            String creatorName = snapshot.data ?? '';
            return Row(
              children: [
                const Icon(
                  FontAwesomeIcons.user,
                  size: 16.0,
                ),
                Text(
                  ' $creatorName',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            );
          }
        },
      );
    } else {
      String creatorName = context.read<AuthProvider>().userModel!.name;
      return Text(
        creatorName,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      );
    }
  }

  getProvider(
    BuildContext context,
    AssessmentModel? currentModel,
  ) {
    if (currentModel != null) {
      return null;
    } else {
      return context.watch<AssessmentProvider>();
    }
  }

  List<PpeModel> getPPEList(
      BuildContext context, AssessmentModel? currentModel) {
    // Check if we have a current assessment model
    if (currentModel != null) {
      // Get the full list of PPE icons
      List<PpeModel> allPpeIcons = Constants.getPPEIcons();
      // Initialize an empty list to store selected PPE items
      List<PpeModel> selectedPpeList = [];

      // Iterate through each selected PPE label in the current model
      for (var selectedLabel in currentModel.ppe) {
        // Find the matching PpeModel in the full list of PPE icons
        var matchingPpe = allPpeIcons.firstWhere(
          (ppe) => ppe.label == selectedLabel,
          // If no match is found, return a default PpeModel
          orElse: () =>
              PpeModel(id: 0, label: 'Not Found', icon: const CircleAvatar()),
        );

        // If a matching PPE item was found (id != 0), add it to the selected list
        if (matchingPpe.id != 0) {
          selectedPpeList.add(matchingPpe);
        }
      }

      // Return the list of selected PPE items
      return selectedPpeList;
    } else {
      // If no current model is available, return the default PPE list from the provider
      return context.watch<AssessmentProvider>().ppeModelList;
    }
  }

  getGenerationType(String appBarTitle) {
    if (appBarTitle == Constants.dailySafetyTaskInstructions) {
      return GenerationType.dsti;
    } else {
      return GenerationType.riskAssessment;
    }
  }
}
