import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/groups/group_details.dart';
import 'package:gemini_risk_assessor/groups/group_model.dart';
import 'package:gemini_risk_assessor/themes/app_theme.dart';

class RightSideContent extends StatefulWidget {
  final GroupModel? initialGroup;

  const RightSideContent({Key? key, this.initialGroup}) : super(key: key);

  @override
  _RightSideContentState createState() => _RightSideContentState();
}

class _RightSideContentState extends State<RightSideContent> {
  Widget? _currentContent;

  @override
  void initState() {
    super.initState();
    _currentContent = widget.initialGroup != null
        ? GroupDetails(
            groupModel: widget.initialGroup!,
            onNavigate: _handleNavigation,
          )
        : Center(
            child: Text(
              'Select a group to view details',
              style: AppTheme.textStyle18w500,
            ),
          );
  }

  void _handleNavigation(Widget newContent) {
    setState(() {
      _currentContent = newContent;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _currentContent!;
  }
}
