import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/dialogs/my_dialogs.dart';
import 'package:gemini_risk_assessor/enums/enums.dart';
import 'package:gemini_risk_assessor/models/ppe_model.dart';
import 'package:gemini_risk_assessor/providers/assessment_provider.dart';
import 'package:gemini_risk_assessor/utilities/global.dart';
import 'package:gemini_risk_assessor/widgets/action_button.dart';
import 'package:gemini_risk_assessor/widgets/ppe_item.dart';
import 'package:provider/provider.dart';

class PpeItemsWidget extends StatelessWidget {
  const PpeItemsWidget({
    super.key,
    required this.label,
    required this.ppeModelList,
  });
  final ListHeader label;
  final List<PpeModel> ppeModelList;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      //width: MediaQuery.of(context).size.width * 0.45,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            getLabel(label),
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          // list of items
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemCount: ppeModelList.length,
              itemBuilder: (context, index) {
                // get the first word of the game time
                final ppeItem = ppeModelList[index];

                return Consumer<AssessmentProvider>(
                  builder: (context, assessmentProvider, child) {
                    final isAdded =
                        assessmentProvider.ppeModelList.contains(ppeItem);
                    return SizedBox(
                        width: 80,
                        child: PpeItem(
                          ppeItem: ppeItem,
                          isAdded: isAdded,
                          onTap: () {
                            if (isAdded) {
                              // show my animated dialog to aske if user is sure to remove this ppe item
                              MyDialogs.showMyAnimatedDialog(
                                  context: context,
                                  title: 'Remove PPE',
                                  content:
                                      'Are you sure to remove\n ${ppeItem.label} ?',
                                  actions: [
                                    ActionButton(
                                      label: const Text(
                                        'Cancel',
                                        style: TextStyle(
                                          color: Colors.red,
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    ActionButton(
                                      label: const Text(
                                        'Yes',
                                      ),
                                      onPressed: () {
                                        assessmentProvider
                                            .addOrRemovePpeModelItem(
                                          ppeItem: ppeItem,
                                        );
                                      },
                                    ),
                                  ]);
                            }
                          },
                        ));
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
