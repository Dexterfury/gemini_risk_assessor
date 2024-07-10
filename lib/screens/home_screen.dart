import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/providers/auth_provider.dart';
import 'package:gemini_risk_assessor/providers/tab_provider.dart';
import 'package:gemini_risk_assessor/screens/dsti_screen.dart';
import 'package:gemini_risk_assessor/screens/tools_screen.dart';
import 'package:gemini_risk_assessor/search/assessments_search_stream.dart';
import 'package:gemini_risk_assessor/utilities/navigation.dart';
import 'package:gemini_risk_assessor/widgets/display_user_image.dart';
import 'package:gemini_risk_assessor/appBars/my_app_bar.dart';
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
    final tabProvider = context.read<TabProvider>();
    // Implement your search logic here
    tabProvider.setSearchQuery(query);
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

  List<Tab> _buildTabs() {
    return const [
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
    ];
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
              tabs: _buildTabs(),
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildTabContent(tabProvider, 0, const DSTIScreen()),
              _buildTabContent(tabProvider, 1, const RiskAssessmentsScreen()),
              _buildTabContent(tabProvider, 2, const ToolsScreen()),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabContent(
    TabProvider tabProvider,
    int tabIndex,
    Widget defaultScreen,
  ) {
    return tabProvider.searchQuery.isEmpty &&
            tabProvider.currentTabIndex == tabIndex
        ? defaultScreen
        : const AssessmentsSearchStream();
  }
}
