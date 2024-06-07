import 'package:flutter/material.dart';

class DataListWidget extends StatelessWidget {
  const DataListWidget({
    super.key,
    required this.dataList,
  });

  final List<String> dataList;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: dataList.length,
          itemBuilder: (context, index) {
            return Text(dataList[index]);
          },
        ),
      ),
    );
  }
}
