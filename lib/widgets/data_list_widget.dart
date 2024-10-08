import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/dialogs/my_dialogs.dart';
import 'package:gemini_risk_assessor/enums/enums.dart';
import 'package:gemini_risk_assessor/providers/assessment_provider.dart';
import 'package:provider/provider.dart';

class DataListWidget extends StatefulWidget {
  const DataListWidget({
    super.key,
    required this.label,
    required this.dataList,
  });
  final ListHeader label;
  final List<String> dataList;

  @override
  State<DataListWidget> createState() => _DataListWidgetState();
}

class _DataListWidgetState extends State<DataListWidget> {
  late ScrollController _scrollController;
  bool _isBottom = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    // Check if the user has scrolled to the bottom
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent) {
      setState(() {
        _isBottom = true;
      });
    } else {
      setState(() {
        _isBottom = false;
      });
    }
  }

  // scroll to the bottom of the list
  void _scrollToBottom() {
    _scrollController.animateTo(_scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500), curve: Curves.easeOut);
    setState(() {
      _isBottom = true;
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        border: Border.all(),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 8.0,
              right: 8.0,
            ),
            child: ListView.builder(
              shrinkWrap: true,
              controller: _scrollController,
              itemCount: widget.dataList.length,
              itemBuilder: (context, index) {
                final capitalizedFirstLetter =
                    widget.dataList[index][0].toUpperCase() +
                        widget.dataList[index].substring(1);
                return InkWell(
                  onLongPress: () {
                    // show animated dialog and to remove item
                    MyDialogs.showMyAnimatedDialog(
                        context: context,
                        title: 'Remove item',
                        content:
                            'Are you sure to remove\n $capitalizedFirstLetter',
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                color: Colors.red,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              context
                                  .read<AssessmentProvider>()
                                  .removeItem(
                                    label: widget.label,
                                    data: widget.dataList[index],
                                  )
                                  .whenComplete(
                                    () => Navigator.of(context).pop(),
                                  );
                            },
                            child: const Text(
                              'Yes',
                            ),
                          ),
                        ]);
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
          if (_isBottom == false && widget.dataList.length * 30 > 200)
            Positioned(
              bottom: 8,
              right: 8,
              child: GestureDetector(
                onTap: () {
                  // scroll to the bottom of teh list
                  _scrollToBottom();
                },
                child: const Icon(
                  Icons.arrow_downward_rounded,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
