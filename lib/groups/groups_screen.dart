import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/auth/authentication_provider.dart';
import 'package:gemini_risk_assessor/firebase/analytics_helper.dart';
import 'package:gemini_risk_assessor/groups/group_provider.dart';
import 'package:gemini_risk_assessor/search/group_search_stream.dart';
import 'package:gemini_risk_assessor/firebase/groups_stream.dart';
import 'package:gemini_risk_assessor/widgets/anonymouse_view.dart';
import 'package:gemini_risk_assessor/widgets/build_user_image.dart';
import 'package:gemini_risk_assessor/app_bars/my_app_bar.dart';
import 'package:provider/provider.dart';

class GroupsScreen extends StatelessWidget {
  const GroupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    AnalyticsHelper.logScreenView(
      screenName: 'Groups Screen',
      screenClass: 'GroupsScreen',
    );
    bool isAnonymous = context.read<AuthenticationProvider>().isUserAnonymous();
    return Consumer<GroupProvider>(builder: (context, groupProvider, child) {
      handleSearch(String query) {
        if (!isAnonymous) {
          groupProvider.setSearchQuery(query);
        }
      }

      return Scaffold(
        appBar: MyAppBar(
          title: '',
          onSearch: handleSearch, // Pass the search function
          actions: [BuildUserImage()],
        ),
        body: isAnonymous
            ? const AnonymouseView(
                message: 'Please Sign In to view groups',
              )
            : groupProvider.searchQuery.isEmpty
                ? const GroupsStream()
                : const GroupsSearchStream(),
      );
    });
  }
}
