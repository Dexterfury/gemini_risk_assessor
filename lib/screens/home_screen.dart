import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/providers/auth_provider.dart';
import 'package:gemini_risk_assessor/providers/tab_provider.dart';
import 'package:gemini_risk_assessor/providers/tool_provider.dart';
import 'package:gemini_risk_assessor/screens/dsti_screen.dart';
import 'package:gemini_risk_assessor/screens/tools_screen.dart';
import 'package:gemini_risk_assessor/utilities/animated_search_bar.dart';
import 'package:gemini_risk_assessor/utilities/navigation.dart';
import 'package:gemini_risk_assessor/widgets/display_user_image.dart';
import 'package:gemini_risk_assessor/widgets/my_app_bar.dart';
import 'package:gemini_risk_assessor/screens/risk_assessments_screen.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<TabProvider>().setCurrentTabIndex(_tabController.index);
      }
    });
  }

  void _handleSearch(String query) {
    int currentTab = context.read<TabProvider>().currentTabIndex;
    print('Searching for "$query" in tab: $currentTab');
    // Implement your search logic here
  }

  GestureDetector _buildUserImage(
    BuildContext context,
  ) {
    return GestureDetector(
      onTap: () {
        navigationController(
          context: context,
          route: Constants.profileRoute,
          titleArg: context.read<AuthProvider>().userModel!.uid,
        );
      },
      child: DisplayUserImage(
        radius: 20,
        isViewOnly: true,
        imageUrl: context.watch<AuthProvider>().userModel?.imageUrl ?? '',
        onPressed: () {},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TabProvider>(
      builder: (context, tabProvider, _) {
        return Scaffold(
          appBar: MyAppBar(
            title: '',
            onSearch: _handleSearch, // Pass the search function
            actions: [
              _buildUserImage(context),
            ],
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
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
          body: TabBarView(
            controller: _tabController,
            children: const [
              DSTIScreen(),
              RistAssessmentsScreen(),
              ToolsScreen(),
            ],
          ),
        );
      },
    );
  }
}
