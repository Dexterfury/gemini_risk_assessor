import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/providers/authentication_provider.dart';
import 'package:gemini_risk_assessor/providers/organization_provider.dart';
import 'package:gemini_risk_assessor/search/org_search_stream.dart';
import 'package:gemini_risk_assessor/firebase_methods/organizations_stream.dart';
import 'package:gemini_risk_assessor/utilities/navigation.dart';
import 'package:gemini_risk_assessor/widgets/anonymouse_view.dart';
import 'package:gemini_risk_assessor/widgets/display_user_image.dart';
import 'package:gemini_risk_assessor/appBars/my_app_bar.dart';
import 'package:provider/provider.dart';

class OrganizationsScreen extends StatelessWidget {
  const OrganizationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool isAnonymous = context.read<AuthenticationProvider>().isUserAnonymous();
    return Consumer<OrganizationProvider>(
        builder: (context, organizationProvider, child) {
      handleSearch(String query) {
        if (!isAnonymous) {
          organizationProvider.setSearchQuery(query);
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
                message: 'Please Sign In to view organizations',
              )
            : organizationProvider.searchQuery.isEmpty
                ? const OrganizationsStream()
                : const OrgSearchStream(),
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
