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
          appBar: AppBar(
            title: Text(assessmentModel.title),
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Task to Achieve:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(assessmentModel.taskToAchieve),
                SizedBox(height: 10),
                Text(
                  'Equipments:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                ...assessmentModel.equipments
                    .map((equipment) => Text(equipment)),
                SizedBox(height: 10),
                Text(
                  'Hazards:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                ...assessmentModel.hazards.map((hazard) => Text(hazard)),
                SizedBox(height: 10),
                Text(
                  'Risks:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                ...assessmentModel.risks.map((risk) => Text(risk)),
                SizedBox(height: 10),
                Text(
                  'Control Measures:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                ...assessmentModel.control
                    .map((controlMeasure) => Text(controlMeasure)),
                SizedBox(height: 10),
                Text(
                  'Personal Protective Equipment (PPE):',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: assessmentModel.ppe.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        Icon(Icons.security), // Replace with appropriate icons
                        Text(assessmentModel.ppe[index]),
                      ],
                    );
                  },
                ),
                SizedBox(height: 10),
                Text(
                  'Summary:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(assessmentModel.summary),
                SizedBox(height: 10),
                Text(
                  'Created by: ${assessmentModel.createdBy}',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text('Created at: ${assessmentModel.createdAt.toLocal()}'),
                SizedBox(height: 10),
                Text(
                  'Signatures:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                ...assessmentModel.signatures
                    .map((signature) => Text(signature)),
                SizedBox(height: 10),
                Text(
                  'Approvers:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                ...assessmentModel.approvers.map((approver) => Text(approver)),
                SizedBox(height: 10),
                Text(
                  'Add Signature:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(
                  height: 150,
                  child: Container(
                    color: Colors.grey[200],
                    child: Center(
                      child: Text('Signature Box'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Scaffold(
        //   body: SingleChildScrollView(
        //     child: Padding(
        //       padding: const EdgeInsets.all(8.0),
        //       child: Column(
        //         crossAxisAlignment: CrossAxisAlignment.start,
        //         children: [
        //           // title
        //           HeadingTitleWidget(
        //             title: assessmentModel.title,
        //           ),
        //           const SizedBox(
        //             height: 10,
        //           ),
        //           // tast to archieve
        //           Row(
        //             children: [
        //               const Text(
        //                 'Tast: ',
        //                 style: TextStyle(fontWeight: FontWeight.bold),
        //               ),
        //               Text(assessmentModel.taskToAchieve),
        //             ],
        //           ),
        //           const SizedBox(
        //             height: 10,
        //           ),

        //           SizedBox(
        //             width: MediaQuery.of(context).size.width,
        //             child: Row(
        //               crossAxisAlignment: CrossAxisAlignment.start,
        //               mainAxisAlignment: MainAxisAlignment.spaceAround,
        //               children: [
        //                 DataItemsWidget(
        //                   label: 'Equipments',
        //                   dataList: assessmentModel.equipments,
        //                 ),
        //                 DataItemsWidget(
        //                   label: 'Hazards',
        //                   dataList: assessmentModel.hazards,
        //                 ),
        //               ],
        //             ),
        //           ),

        //           const SizedBox(
        //             height: 10,
        //           ),

        //           SizedBox(
        //             width: MediaQuery.of(context).size.width,
        //             child: Row(
        //               crossAxisAlignment: CrossAxisAlignment.start,
        //               mainAxisAlignment: MainAxisAlignment.spaceAround,
        //               children: [
        //                 DataItemsWidget(
        //                   label: 'Risks',
        //                   dataList: assessmentModel.risks,
        //                 ),
        //                 PpeItemsWidget(
        //                   label: 'Personal Protective Equipment',
        //                   ppeModelList:
        //                       context.watch<AssessmentProvider>().ppeModelList,
        //                 ),
        //               ],
        //             ),
        //           ),
        //           const SizedBox(
        //             height: 10,
        //           ),

        //           Column(
        //             children: [
        //               const Text(
        //                 'Control Messueres',
        //                 style: TextStyle(fontWeight: FontWeight.bold),
        //               ),
        //               DataListWidget(dataList: assessmentModel.control),
        //             ],
        //           ),

        //           const SizedBox(
        //             height: 20,
        //           ),
        //           ElevatedButton(
        //             onPressed: () {
        //               Navigator.of(context).pop(false);
        //             },
        //             child: Text('Close'),
        //           ),
        //         ],
        //       ),
        //     ),
        //   ),
        // ),
      ),
    );
  }
}
