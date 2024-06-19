import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/utilities/global.dart';
import 'package:intl/intl.dart';
import '../models/tool_model.dart';
import '../widgets/assessment_images.dart';
import '../widgets/my_app_bar.dart';

class ExplainerDetailsScreen extends StatelessWidget {
  ExplainerDetailsScreen({super.key,
    required this.toolModel,
    required this.animation,
  }) : _scrollController = ScrollController();


  final ToolModel toolModel;
  final Animation<double> animation;
  final ScrollController _scrollController;

  @override
  Widget build(BuildContext context) {
    // Format the datetime using Intl package
    String formattedTime =
    DateFormat.yMMMEd().format(toolModel.createdAt);
    return SafeArea(
        child: ScaleTransition(
          scale: Tween(begin: 3.0, end: 1.0).animate(animation),
          child: Scaffold(
            appBar: MyAppBar(
              title: toolModel.name,
              leading: backIcon(context),
            ),
            body: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AssessmentImages(
                    isViewOnly: true,
                  ),
                ],
              ),
            ),
          ),
        ),);
  }
}
