import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/enums/enums.dart';
import 'package:gemini_risk_assessor/providers/assessment_provider.dart';
import 'package:gemini_risk_assessor/providers/auth_provider.dart';
import 'package:gemini_risk_assessor/utilities/global.dart';
import 'package:gemini_risk_assessor/widgets/images_display.dart';
import 'package:gemini_risk_assessor/widgets/bottom_buttons_field.dart';
import 'package:gemini_risk_assessor/widgets/data_items_widget.dart';
import 'package:gemini_risk_assessor/widgets/my_app_bar.dart';
import 'package:gemini_risk_assessor/widgets/ppe_items_widget.dart';
import 'package:gemini_risk_assessor/widgets/weather_button.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AssessmentDetailsScreen extends StatelessWidget {
  AssessmentDetailsScreen({
    super.key,
    required this.animation,
  }) : _scrollController = ScrollController();

  final Animation<double> animation;
  final ScrollController _scrollController;

  @override
  Widget build(BuildContext context) {
    // assessment provider
    final assessmentProvider = context.watch<AssessmentProvider>();
    // get time
    final time = assessmentProvider.assessmentModel.createdAt;
    // get title
    final title = assessmentProvider.assessmentModel.title;
    // weather
    final weather = assessmentProvider.assessmentModel.weather;
    // task to archieve
    final task = assessmentProvider.assessmentModel.taskToAchieve;
    // equipments
    final equipments = assessmentProvider.assessmentModel.equipments;
    // hazards
    final hazards = assessmentProvider.assessmentModel.hazards;
    // risks
    final risks = assessmentProvider.assessmentModel.risks;
    // control
    final control = assessmentProvider.assessmentModel.control;
    // summary
    final summary = assessmentProvider.assessmentModel.summary;
    // createdBy
    final createdBy = context.read<AuthProvider>().userModel!.name;

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
            actions: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () {
                  _scrollController.animateTo(
                    _scrollController.position.maxScrollExtent,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(width: 0.5),
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.blue[100],
                  ),
                  child: const Icon(
                    Icons.arrow_downward_rounded,
                  ),
                ),
              ),
            ),
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
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    DataItemsWidget(
                      label: ListHeader.equipments,
                      dataList: equipments,
                    ),
                    DataItemsWidget(
                      label: ListHeader.hazards,
                      dataList: hazards,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                DataItemsWidget(
                  label: ListHeader.risks,
                  dataList: risks,
                  width: 100,
                ),
                const SizedBox(height: 10),
                DataItemsWidget(
                  label: ListHeader.control,
                  dataList: control,
                  width: 100,
                ),
                const SizedBox(height: 10),
                PpeItemsWidget(
                  label: ListHeader.ppe,
                  ppeModelList:
                      context.watch<AssessmentProvider>().ppeModelList,
                ),
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
}
