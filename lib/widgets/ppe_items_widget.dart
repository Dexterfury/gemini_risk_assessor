import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/dialogs/my_dialogs.dart';
import 'package:gemini_risk_assessor/enums/enums.dart';
import 'package:gemini_risk_assessor/models/ppe_model.dart';
import 'package:gemini_risk_assessor/providers/assessment_provider.dart';
import 'package:gemini_risk_assessor/utilities/global.dart';
import 'package:gemini_risk_assessor/widgets/ppe_item.dart';
import 'package:provider/provider.dart';

class PpeItemsWidget extends StatelessWidget {
  const PpeItemsWidget({
    super.key,
    required this.label,
    required this.ppeModelList,
    required this.isInteractable,
  });
  final ListHeader label;
  final List<PpeModel> ppeModelList;
  final bool isInteractable;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          getLabel(label),
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            itemCount: ppeModelList.length,
            itemBuilder: (context, index) {
              final ppeItem = ppeModelList[index];

              return SizedBox(
                width: 80,
                child: isInteractable
                    ? Consumer<AssessmentProvider>(
                        builder: (context, assessmentProvider, child) {
                          final isAdded =
                              assessmentProvider.ppeModelList.contains(ppeItem);
                          return PpeItem(
                            ppeItem: ppeItem,
                            isAdded: isAdded,
                            onTap: () => _handlePpeItemTap(
                                context, assessmentProvider, ppeItem, isAdded),
                          );
                        },
                      )
                    : PpeItem(
                        ppeItem: ppeItem,
                        isAdded: false,
                        onTap: null,
                      ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _handlePpeItemTap(BuildContext context,
      AssessmentProvider assessmentProvider, PpeModel ppeItem, bool isAdded) {
    if (isAdded) {
      MyDialogs.showMyAnimatedDialog(
        context: context,
        title: 'Remove PPE',
        content: 'Are you sure to remove\n ${ppeItem.label} ?',
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () {
              assessmentProvider.addOrRemovePpeModelItem(ppeItem: ppeItem);
              Navigator.of(context).pop();
            },
            child: const Text('Yes'),
          ),
        ],
      );
    } else {
      assessmentProvider.addOrRemovePpeModelItem(ppeItem: ppeItem);
    }
  }
}
