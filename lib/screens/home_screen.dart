import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/providers/tool_provider.dart';
import 'package:gemini_risk_assessor/screens/dsti_screen.dart';
import 'package:gemini_risk_assessor/screens/tools_screen.dart';
import 'package:gemini_risk_assessor/widgets/display_user_image.dart';
import 'package:gemini_risk_assessor/widgets/my_app_bar.dart';
import 'package:gemini_risk_assessor/widgets/risk_assessments_list.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: MyAppBar(
          title: 'Home',
          leading: IconButton(
            onPressed: () {
              // TODO remove this later
              //context.read<ToolProvider>().setMacTestToolsList();
              context.read<ToolProvider>().setWindowsTestToolsList();
            },
            icon: const Icon(Icons.search),
          ),
          actions: DisplayUserImage(
            radius: 20,
            isViewOnly: true,
            onPressed: () {},
          ),
          bottom: const TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.assignment_add),
                text: Constants.dailyTaskInstructions,
              ),
              Tab(
                icon: Icon(Icons.assignment_late_outlined),
                text: Constants.riskAssessments,
              ),
              Tab(
                icon: Icon(Icons.handyman),
                text: Constants.tools,
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            DSTIScreen(),
            RistAssessmentsList(),
            ToolsScreen(),
          ],
        ),
      ),
    );
  }
}
