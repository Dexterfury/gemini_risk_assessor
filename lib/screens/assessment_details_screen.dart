import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gemini_risk_assessor/buttons/animated_chat_button.dart';
import 'package:gemini_risk_assessor/buttons/delete_button.dart';
import 'package:gemini_risk_assessor/buttons/main_app_button.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/dialogs/my_dialogs.dart';
import 'package:gemini_risk_assessor/enums/enums.dart';
import 'package:gemini_risk_assessor/firebase/analytics_helper.dart';
import 'package:gemini_risk_assessor/firebase/firebase_methods.dart';
import 'package:gemini_risk_assessor/models/assessment_model.dart';
import 'package:gemini_risk_assessor/models/ppe_model.dart';
import 'package:gemini_risk_assessor/providers/assessment_provider.dart';
import 'package:gemini_risk_assessor/auth/authentication_provider.dart';
import 'package:gemini_risk_assessor/providers/chat_provider.dart';
import 'package:gemini_risk_assessor/screens/chat_screen.dart';
import 'package:gemini_risk_assessor/screens/share_screen.dart';
import 'package:gemini_risk_assessor/themes/app_theme.dart';
import 'package:gemini_risk_assessor/utilities/assessment_grid_items.dart';
import 'package:gemini_risk_assessor/utilities/global.dart';
import 'package:gemini_risk_assessor/widgets/images_display.dart';
import 'package:gemini_risk_assessor/app_bars/my_app_bar.dart';
import 'package:gemini_risk_assessor/widgets/ppe_items_widget.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AssessmentDetailsScreen extends StatelessWidget {
  const AssessmentDetailsScreen({
    super.key,
    required this.appBarTitle,
    required this.groupID,
    required this.isAdmin,
    this.currentModel,
  });

  final String appBarTitle;
  final String groupID;
  final bool isAdmin;
  final AssessmentModel? currentModel;

  @override
  Widget build(BuildContext context) {
    AnalyticsHelper.logScreenView(
      screenName: 'Assessment Details Screen',
      screenClass: 'AssessmentDetailsScreen',
    );
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

    // get generationType
    final generationType = GenerationType.riskAssessment;

    // ppe list
    final ppeList = getPPEList(
      context,
      currentModel,
    );

    // Format the datetime using Intl package
    String formattedTime = DateFormat.yMMMEd().format(time);

    var sizedBox = SizedBox(
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
    );
    return Scaffold(
      appBar: MyAppBar(
        title: appBarTitle,
        leading: const BackButton(),
        actions: [
          currentModel != null
              ? Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: GeminiFloatingChatButton(
                    onPressed: () async {
                      // Open chat or navigate to chat screen
                      final uid =
                          context.read<AuthenticationProvider>().userModel!.uid;
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
                              assessmentModel: assessmentModel,
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
              Text(
                title,
                maxLines: 1,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Task',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Icon(
                    getWeatherIcon(
                      WeatherExtension.fromString(
                        weather,
                      ),
                    ),
                  ),
                ],
              ),
              Text(task),
              const SizedBox(height: 10),
              if (assessmentModel.images.isNotEmpty)
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
                currentModel: currentModel,
              ),
              const SizedBox(height: 10),
              ppeList.isNotEmpty
                  ? PpeItemsWidget(
                      label: ListHeader.ppe,
                      ppeModelList: ppeList,
                      isInteractable: currentModel == null,
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
                  sizedBox,
                  pdfAndShareButtons(
                    context,
                    assessmentModel,
                    generationType,
                    isAdmin,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              currentModel == null
                  ? Align(
                      alignment: Alignment.centerRight,
                      child: MainAppButton(
                          icon: FontAwesomeIcons.floppyDisk,
                          label: "Save Document",
                          borderRadius: 15.0,
                          onTap: () async {
                            MyDialogs.showMyAnimatedDialog(
                              context: context,
                              title: 'Saving Document',
                              loadingIndicator: const SizedBox(
                                height: 100,
                                width: 100,
                                child: LoadingPPEIcons(),
                              ),
                            );
                            await context
                                .read<AssessmentProvider>()
                                .saveDataToFirestore()
                                .whenComplete(() {
                              // pop the dialog
                              Navigator.pop(context);

                              Future.delayed(const Duration(seconds: 1))
                                  .whenComplete(() {
                                showSnackBar(
                                  context: context,
                                  message: 'Successfully saved document',
                                );
                                // pop the screen
                                Navigator.pop(context);
                              });
                            });
                          }),
                    )
                  : const SizedBox(
                      height: 20,
                    ),
              currentModel == null || !isAdmin
                  ? const SizedBox()
                  : Align(
                      alignment: Alignment.center,
                      child: DeleteButton(
                        label: ' Delete Assessment ',
                        groupID: groupID,
                        generationType: generationType,
                        assessment: assessmentModel,
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  pdfAndShareButtons(
    BuildContext context,
    AssessmentModel assessmentModel,
    generationType,
    bool isAdminn,
  ) {
    return Row(
      children: [
        // pdf icon
        Card(
          elevation: AppTheme.cardElevation,
          color: Theme.of(context).cardColor,
          child: IconButton(
            onPressed: () async {
              // // show my alert dialog for loading
              MyDialogs.showMyAnimatedDialog(
                context: context,
                title: 'Generating PDF file',
                loadingIndicator: const SizedBox(
                  height: 100,
                  width: 100,
                  child: LoadingPPEIcons(),
                ),
              );

              // create the pdf file and save to local storage
              await context.read<AssessmentProvider>().createPdfAndSave(
                appBarTitle,
                currentModel,
                (error) {
                  showSnackBar(
                    context: context,
                    message: 'Error loading PDF file',
                  );
                  // close the loading dialog
                  Navigator.pop(context);
                },
              ).whenComplete(() async {
                // close the loading dialog
                Navigator.pop(context);
              });
            },
            icon: const Icon(
              FontAwesomeIcons.filePdf,
            ),
          ),
        ),
        const SizedBox(width: 10),
        currentModel == null || !isAdminn
            ? const SizedBox()
            : OpenContainer(
                closedBuilder: (context, action) {
                  return IconButton(
                    onPressed: action,
                    icon: const Icon(
                      FontAwesomeIcons.share,
                    ),
                  );
                },
                openBuilder: (context, action) {
                  // navigate to screen depending on the clicked icon
                  return ShareScreen(
                    itemModel: assessmentModel,
                    groupID: groupID,
                    generationType: generationType,
                  );
                },
                transitionType: ContainerTransitionType.fadeThrough,
                transitionDuration: const Duration(milliseconds: 500),
                closedShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                closedElevation: AppTheme.cardElevation,
                closedColor: Theme.of(context).cardColor,
                openElevation: 4,
              ),
      ],
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
      String creatorName =
          context.read<AuthenticationProvider>().userModel!.name;
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
    if (currentModel != null) {
      List<PpeModel> allPpeIcons = Constants.getPPEIcons();
      return allPpeIcons
          .where((ppe) => currentModel.ppe.contains(ppe.label))
          .toList();
    } else {
      return context.watch<AssessmentProvider>().ppeModelList;
    }
  }
}
