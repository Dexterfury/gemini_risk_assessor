import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/providers/auth_provider.dart';
import 'package:gemini_risk_assessor/providers/organisation_provider.dart';
import 'package:gemini_risk_assessor/search/org_serach_stream.dart';
import 'package:gemini_risk_assessor/streams/organisations_stream.dart';
import 'package:gemini_risk_assessor/utilities/navigation.dart';
import 'package:gemini_risk_assessor/widgets/anonymouse_view.dart';
import 'package:gemini_risk_assessor/widgets/display_user_image.dart';
import 'package:gemini_risk_assessor/appBars/my_app_bar.dart';
import 'package:provider/provider.dart';

class OrganisationsScreen extends StatelessWidget {
  const OrganisationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool isAnonymous = context.watch<AuthProvider>().isUserAnonymous();
    return Consumer<OrganisationProvider>(
        builder: (context, organisationProvider, child) {
      handleSearch(String query) {
        print('Searching for "$query" ');
        if (!isAnonymous) {
          organisationProvider.setSearchQuery(query);
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
            ? const AnonymouseView()
            : organisationProvider.searchQuery.isEmpty
                ? const OrganisationsStream()
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
}
