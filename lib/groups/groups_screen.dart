import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/providers/authentication_provider.dart';
import 'package:gemini_risk_assessor/groups/group_provider.dart';
import 'package:gemini_risk_assessor/search/group_search_stream.dart';
import 'package:gemini_risk_assessor/firebase_methods/groups_stream.dart';
import 'package:gemini_risk_assessor/utilities/navigation.dart';
import 'package:gemini_risk_assessor/widgets/anonymouse_view.dart';
import 'package:gemini_risk_assessor/widgets/display_user_image.dart';
import 'package:gemini_risk_assessor/appBars/my_app_bar.dart';
import 'package:provider/provider.dart';

class GroupsScreen extends StatelessWidget {
  const GroupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
          actions: [
            _buildUserImage(context),
          ],
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

  GestureDetector _buildUserImage(
    BuildContext context,
  ) {
    return GestureDetector(
      onTap: () {
        navigationController(
          context: context,
          route: Constants.profileRoute,
          titleArg: context.read<AuthenticationProvider>().userModel!.uid,
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
}
