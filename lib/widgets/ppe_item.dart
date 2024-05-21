import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/models/ppe_model.dart';
import 'package:gemini_risk_assessor/providers/assessment_provider.dart';
import 'package:provider/provider.dart';

class PpeItem extends StatelessWidget {
  const PpeItem({
    super.key,
    required this.ppeItem,
  });

  final PpeModel ppeItem;

  @override
  Widget build(BuildContext context) {
    return Consumer<AssessmentProvider>(
      builder: (
        context,
        assessmentProvider,
        child,
      ) {
        // check if ppeModelList contains ppItem
        bool isAdded = assessmentProvider.ppeModelList.contains(ppeItem);
        return InkWell(
          onTap: () {
            assessmentProvider.addOrRemovePpeModelItem(
              ppeItem: ppeItem,
            );
          },
          child: Card(
            color: isAdded ? Theme.of(context).highlightColor : null,
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ppeItem.icon,
                      Text(
                        ppeItem.label,
                        style: const TextStyle(
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                isAdded
                    ? const Positioned(
                        top: 5.0,
                        right: 5.0,
                        child: Icon(
                          Icons.check,
                        ),
                      )
                    : const SizedBox.shrink(),
              ],
            ),
          ),
        );
      },
    );
  }
}
