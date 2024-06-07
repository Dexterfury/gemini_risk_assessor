import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/widgets/data_list_widget.dart';

class DataItemsWidget extends StatelessWidget {
  const DataItemsWidget({
    super.key,
    required this.label,
    required this.dataList,
  });
  final String label;
  final List<String> dataList;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.45,
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          // list of items
          DataListWidget(
            dataList: dataList,
          ),
        ],
      ),
    );
  }
}
