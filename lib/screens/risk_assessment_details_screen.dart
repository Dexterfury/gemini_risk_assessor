import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/models/assessment_model.dart';
import 'package:gemini_risk_assessor/providers/assessment_provider.dart';
import 'package:gemini_risk_assessor/widgets/data_items_widget.dart';
import 'package:gemini_risk_assessor/widgets/data_list_widget.dart';
import 'package:gemini_risk_assessor/widgets/ppe_items_widget.dart';
import 'package:gemini_risk_assessor/widgets/title_widget.dart';
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
    return SafeArea(
      child: ScaleTransition(
        scale: Tween(begin: 3.0, end: 1.0).animate(animation),
        child: Scaffold(
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // title
                  HeadingTitleWidget(
                    title: assessmentModel.title,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  // tast to archieve
                  Row(
                    children: [
                      const Text(
                        'Tast: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(assessmentModel.taskToAchieve),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),

                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        DataItemsWidget(
                          label: 'Equipments',
                          dataList: assessmentModel.equipments,
                        ),
                        DataItemsWidget(
                          label: 'Hazards',
                          dataList: assessmentModel.hazards,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        DataItemsWidget(
                          label: 'Risks',
                          dataList: assessmentModel.risks,
                        ),
                        PpeItemsWidget(
                          label: 'Personal Protective Equipment',
                          ppeModelList:
                              context.watch<AssessmentProvider>().ppeModelList,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),

                  Column(
                    children: [
                      const Text(
                        'Control Messueres',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      DataListWidget(dataList: assessmentModel.control),
                    ],
                  ),

                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    child: Text('Close'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
