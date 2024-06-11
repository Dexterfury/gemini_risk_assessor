import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/utilities/global.dart';

class DataListWidget extends StatelessWidget {
  const DataListWidget({
    super.key,
    required this.dataList,
  });

  final List<String> dataList;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
          border: Border.all(), borderRadius: BorderRadius.circular(5)),
      child: Padding(
        padding: const EdgeInsets.only(
          left: 8.0,
          right: 8.0,
        ),
        child: ListView.builder(
          //physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: dataList.length,
          itemBuilder: (context, index) {
            final capitalizedFirstLetter =
                dataList[index][0].toUpperCase() + dataList[index].substring(1);
            return InkWell(
              onLongPress: () {
                // show animated dialog and to remove item
                showMyAnimatedDialog(
                    context: context,
                    title: 'Remove item',
                    content:
                        'Are you sure tor remove \n $capitalizedFirstLetter',
                    actions: []);
              },
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Text(
                  '${index + 1}.  $capitalizedFirstLetter',
                  maxLines: 3,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
