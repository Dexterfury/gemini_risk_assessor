import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/enums/enums.dart';
import 'package:gemini_risk_assessor/models/assessment_model.dart';
import 'package:gemini_risk_assessor/models/ppe_model.dart';
import 'package:gemini_risk_assessor/providers/assessment_provider.dart';
import 'package:gemini_risk_assessor/providers/auth_provider.dart';
import 'package:gemini_risk_assessor/utilities/assessment_grid_items.dart';
import 'package:gemini_risk_assessor/utilities/global.dart';
import 'package:gemini_risk_assessor/widgets/images_display.dart';
import 'package:gemini_risk_assessor/widgets/bottom_buttons_field.dart';
import 'package:gemini_risk_assessor/appBars/my_app_bar.dart';
import 'package:gemini_risk_assessor/widgets/ppe_items_widget.dart';
import 'package:gemini_risk_assessor/widgets/weather_button.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AssessmentDetailsScreen extends StatelessWidget {
  AssessmentDetailsScreen({
    super.key,
    required this.animation,
    this.currentModel,
  }) : _scrollController = ScrollController();

  final Animation<double> animation;
  final ScrollController _scrollController;
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
    // createdBy
    final createdBy = getCreatedBy(context, currentModel);
    // ppe list
    final ppeList = getPPEList(
      context,
      currentModel,
    );

    // Format the datetime using Intl package
    String formattedTime = DateFormat.yMMMEd().format(time);

    return SafeArea(
      child: ScaleTransition(
        scale: Tween(begin: 3.0, end: 1.0).animate(animation),
        child: Scaffold(
          appBar: MyAppBar(
            title: title,
            leading: BackButton(
              onPressed: () {
                // pop the screen with save as false
                Navigator.of(context).pop(false);
              },
            ),
            actions: [
              IconButton(
                onPressed: () {
                  _scrollController.animateTo(
                    _scrollController.position.maxScrollExtent,
                    duration: const Duration(
                      milliseconds: 500,
                    ),
                    curve: Curves.easeInOut,
                  );
                },
                icon: const Icon(
                  Icons.keyboard_double_arrow_down,
                ),
              ),
              //   Padding(
              //   padding: const EdgeInsets.all(8.0),
              //   child: GestureDetector(
              //     onTap: () {
              //       _scrollController.animateTo(
              //         _scrollController.position.maxScrollExtent,
              //         duration: const Duration(milliseconds: 500),
              //         curve: Curves.easeInOut,
              //       );
              //     },
              //     child: Container(
              //       decoration: BoxDecoration(
              //         border: Border.all(width: 0.5),
              //         borderRadius: BorderRadius.circular(30),
              //         color: Colors.blue[100],
              //       ),
              //       child: const Icon(
              //         Icons.arrow_downward_rounded,
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
          body: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                  assessmentModel: currentModel,
                ),
                const SizedBox(height: 10),

                // PUT THE GRID HERE

                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   children: [
                //     DataItemsWidget(
                //       label: ListHeader.equipments,
                //       dataList: equipments,
                //     ),
                //     DataItemsWidget(
                //       label: ListHeader.hazards,
                //       dataList: hazards,
                //     ),
                //   ],
                // ),
                // const SizedBox(height: 10),
                // DataItemsWidget(
                //   label: ListHeader.risks,
                //   dataList: risks,
                //   width: 100,
                // ),
                // const SizedBox(height: 10),
                // DataItemsWidget(
                //   label: ListHeader.control,
                //   dataList: control,
                //   width: 100,
                // ),
                AssessmentGridItems(
                  equipments: equipments,
                  hazards: hazards,
                  risks: risks,
                  controlMeasures: control,
                ),

                const SizedBox(height: 10),

                // GRID ABOVE HERE

                // ANIMATED CARD OF LIST HERE BELOW THE GRID

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
                Text(
                  createdBy,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text('Created at: $formattedTime'),
                const SizedBox(height: 10),
                const BottonButtonsField(),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  getModel(
    BuildContext context,
    AssessmentModel? currentModel,
  ) {
    if (currentModel != null) {
      return currentModel;
    } else {
      final assessmentProvider = context.watch()<AssessmentProvider>();
      return assessmentProvider.assessmentModel;
    }
  }

  getCreatedBy(
    BuildContext context,
    AssessmentModel? currentModel,
  ) {
    if (currentModel != null) {
      return currentModel.createdBy;
    } else {
      return context.read<AuthProvider>().userModel!.name;
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
}
