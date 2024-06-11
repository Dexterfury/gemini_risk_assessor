import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/enums/enums.dart';
import 'package:gemini_risk_assessor/utilities/global.dart';
import 'package:gemini_risk_assessor/widgets/data_list_widget.dart';

class DataItemsWidget extends StatelessWidget {
  const DataItemsWidget(
      {super.key,
      required this.label,
      required this.dataList,
      this.width = 0.45});
  final ListHeader label;
  final List<String> dataList;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            getLabel(label),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          // list of items
          DataListWidget(
            label: label,
            dataList: dataList,
          ),
        ],
      ),
    );
  }
}
