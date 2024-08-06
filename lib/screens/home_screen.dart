import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/authentication/authentication_provider.dart';
import 'package:gemini_risk_assessor/firebase_methods/analytics_helper.dart';
import 'package:gemini_risk_assessor/providers/tab_provider.dart';
import 'package:gemini_risk_assessor/push_notification/navigation_controller.dart';
import 'package:gemini_risk_assessor/push_notification/notification_services.dart';
import 'package:gemini_risk_assessor/screens/profile_screen.dart';
import 'package:gemini_risk_assessor/tools/tools_screen.dart';
import 'package:gemini_risk_assessor/firebase_methods/logger.dart';
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
    AnalyticsHelper.logScreenView(
      screenName: 'Home Screen',
      screenClass: 'HomeScreen',
    );
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
    requestNotificationPermissions();
    NotificationServices.createNotificationChannelAndInitialize();
    initCloudMessaging();
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
    bool isAnonymous = context.read<AuthenticationProvider>().isUserAnonymous();
    if (!isAnonymous) {
      final tabProvider = context.read<TabProvider>();
      // Implement your search logic here
      tabProvider.setSearchQuery(query);
    }
  }

  GestureDetector _buildUserImage(
    BuildContext context,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfileScreen(
              uid: context.read<AuthenticationProvider>().userModel!.uid,
            ),
          ),
        );
      },
      child: DisplayUserImage(
        radius: 20,
        isViewOnly: true,
        imageUrl:
            context.watch<AuthenticationProvider>().userModel?.imageUrl ?? '',
        onPressed: () {},
      ),
    );
  }

  List<Tab> _buildTabs() {
    return const [
      Tab(
        icon: Icon(Icons.assignment_late_outlined),
        text: Constants.riskAssessments,
      ),
      Tab(
        icon: Icon(Icons.handyman),
        text: Constants.toolsExplainer,
      ),
    ];
  }

  // request notification permissions
  void requestNotificationPermissions() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    if (Platform.isIOS) {
      await messaging.requestPermission(
        alert: true,
        announcement: true,
        //badge: true,
        carPlay: true,
        criticalAlert: true,
        provisional: true,
        sound: true,
      );
    }

    NotificationSettings notificationSettings =
        await messaging.requestPermission(
      alert: true,
      announcement: true,
      //badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );

    if (notificationSettings.authorizationStatus ==
        AuthorizationStatus.authorized) {
      Logger.log('User granted permission', tag: 'NOTIFICATIONS');
    } else if (notificationSettings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      Logger.log('User granted provisional permission', tag: 'NOTIFICATIONS');
    } else {
      Logger.log('User declined or has not accepted permission',
          tag: 'NOTIFICATIONS');
    }
  }

  // initialize cloud messaging
  void initCloudMessaging() async {
    // make sure widget is initialized before initializing cloud messaging
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      // 1. generate a new token
      await context.read<AuthenticationProvider>().generateNewToken();

      // 2. initialize firebase messaging
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (message.notification != null) {
          NotificationServices.displayNotification(message);
        }
      });

      // 3. setup onMessage handler
      setupInteractedMessage();
    });
  }

  // It is assumed that all messages contain a data field with the key 'type'
  Future<void> setupInteractedMessage() async {
    // Get any messages which caused the application to open from
    // a terminated state.
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    // If the message also contains a data property with a "type" of "chat",
    // navigate to a chat screen
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    // Also handle any interaction when the app is in the background via a
    // Stream listener
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  void _handleMessage(RemoteMessage message) {
    navigationControler(context: context, message: message);
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
              _buildTabContent(tabProvider, 0, const RiskAssessmentsScreen()),
              _buildTabContent(tabProvider, 1, const ToolsScreen()),
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
    return defaultScreen;
  }
}
