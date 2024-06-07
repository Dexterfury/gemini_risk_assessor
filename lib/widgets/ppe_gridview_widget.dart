import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/utilities/global.dart';
import 'package:gemini_risk_assessor/widgets/ppe_item.dart';

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
        borderRadius: BorderRadius.circular(5),
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
          itemCount: ppeIcons().length,
          itemBuilder: (context, index) {
            // get the first word of the game time
            final ppeItem = ppeIcons()[index];

            return PpeItem(ppeItem: ppeItem);
          }),
    );
  }
}
