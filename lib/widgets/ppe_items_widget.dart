import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/models/ppe_model.dart';
import 'package:gemini_risk_assessor/widgets/ppe_item.dart';

class PpeItemsWidget extends StatelessWidget {
  const PpeItemsWidget({
    super.key,
    required this.label,
    required this.ppeModelList,
  });
  final String label;
  final List<PpeModel> ppeModelList;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      //width: MediaQuery.of(context).size.width * 0.45,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
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

                return SizedBox(width: 80, child: PpeItem(ppeItem: ppeItem));
              },
            ),
          ),
          // Card(
          //   child: SizedBox(
          //     height: 180,
          //     // decoration: BoxDecoration(
          //     //   color: Theme.of(context).dialogBackgroundColor,
          //     //   borderRadius: BorderRadius.circular(5),
          //     //   border: Border.all(
          //     //     width: 1,
          //     //     color: Colors.grey,
          //     //   ),
          //     // ),
          //     child: GridView.builder(
          //         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          //           crossAxisCount: 2,
          //           childAspectRatio: 1,
          //         ),
          //         itemCount: ppeModelList.length,
          //         itemBuilder: (context, index) {
          //           // get the first word of the game time
          //           final ppeItem = ppeModelList[index];

          //           return PpeItem(ppeItem: ppeItem);
          //         }),
          //   ),
          // ),
        ],
      ),
    );
  }
}
