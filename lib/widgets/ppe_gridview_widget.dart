import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/providers/assessment_provider.dart';
import 'package:gemini_risk_assessor/widgets/ppe_item.dart';
import 'package:provider/provider.dart';

class PpeGridViewWidget extends StatelessWidget {
  const PpeGridViewWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Theme.of(context).dialogBackgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          width: 1,
          color: Colors.grey,
        ),
      ),
      child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1.5,
          ),
          itemCount: Constants.getPPEIcons().length,
          itemBuilder: (context, index) {
            final ppeItem = Constants.getPPEIcons()[index];

            return Consumer<AssessmentProvider>(
              builder: (context, assessmentProvider, child) {
                final isAdded =
                    assessmentProvider.ppeModelList.contains(ppeItem);
                return PpeItem(
                  ppeItem: ppeItem,
                  isAdded: isAdded,
                  onTap: () {
                    assessmentProvider.addOrRemovePpeModelItem(
                      ppeItem: ppeItem,
                    );
                  },
                );
              },
            );
          }),
    );
  }
}
