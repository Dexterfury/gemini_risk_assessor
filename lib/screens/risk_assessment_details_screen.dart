import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/models/assessment_model.dart';
import 'package:gemini_risk_assessor/providers/assessment_provider.dart';
import 'package:gemini_risk_assessor/widgets/action_button.dart';
import 'package:gemini_risk_assessor/widgets/data_items_widget.dart';
import 'package:gemini_risk_assessor/widgets/data_list_widget.dart';
import 'package:gemini_risk_assessor/widgets/my_app_bar.dart';
import 'package:gemini_risk_assessor/widgets/ppe_items_widget.dart';
import 'package:gemini_risk_assessor/widgets/title_widget.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class RiskAssessmentDetailsScreen extends StatelessWidget {
  const RiskAssessmentDetailsScreen({
    super.key,
    required this.assessmentModel,
    required this.animation,
  });

  final AssessmentModel assessmentModel;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    // Format the datetime using Intl package
    String formattedTime =
        DateFormat('yyyy-MM-dd HH:mm').format(assessmentModel.createdAt);
    return SafeArea(
      child: ScaleTransition(
        scale: Tween(begin: 3.0, end: 1.0).animate(animation),
        child: Scaffold(
          appBar: MyAppBar(
            title: assessmentModel.title,
            leading: IconButton(
              icon: Icon(
                Platform.isIOS ? Icons.arrow_back_ios_new : Icons.arrow_back,
              ),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Task to Achieve:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(assessmentModel.taskToAchieve),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    DataItemsWidget(
                      label: 'Equipments:',
                      dataList: assessmentModel.equipments,
                    ),
                    DataItemsWidget(
                      label: 'Hazards:',
                      dataList: assessmentModel.hazards,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                DataItemsWidget(
                  label: 'Risks:',
                  dataList: assessmentModel.risks,
                  width: 100,
                ),
                const SizedBox(height: 10),
                DataItemsWidget(
                  label: 'Control Measures:',
                  dataList: assessmentModel.control,
                  width: 100,
                ),
                const SizedBox(height: 10),
                PpeItemsWidget(
                  label: 'Personal Protective Equipment (PPE):',
                  ppeModelList:
                      context.watch<AssessmentProvider>().ppeModelList,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Summary:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(assessmentModel.summary),
                const SizedBox(height: 10),
                Text(
                  'Created by: ${assessmentModel.createdBy}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text('Created at: $formattedTime'),
                const SizedBox(height: 10),
                const Text(
                  'Approvers:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                ...assessmentModel.approvers.map((approver) => Text(approver)),
                const SizedBox(height: 10),
                const Text(
                  'Add Signature:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Container(
                  height: 100,
                  decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border.all(
                        width: 0.1,
                      ),
                      borderRadius: BorderRadius.circular(10)),
                  child: const Center(
                    child: Text('Signature Box'),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ActionButton(
                      label: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                    ),
                    ActionButton(
                      label: const Text(
                        'Save Accessment',
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
