import 'package:flutter/cupertino.dart';
import 'package:gemini_risk_assessor/enums/enums.dart';
import 'package:gemini_risk_assessor/providers/auth_provider.dart';
import 'package:gemini_risk_assessor/providers/organisation_provider.dart';
import 'package:gemini_risk_assessor/search/users_search_stream.dart';
import 'package:gemini_risk_assessor/themes/my_themes.dart';
import 'package:provider/provider.dart';

class People extends StatelessWidget {
  const People({
    super.key,
    required this.userViewType,
  });

  final UserViewType userViewType;

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthProvider>().userModel!.uid;
    final orgProvider = context.read<OrganisationProvider>();
    final searchController = TextEditingController();
    return Column(
      children: [
        CupertinoSearchTextField(
          controller: searchController,
          onChanged: (value) {
            // search for users
            orgProvider.setSearchQuery(value);
          },
          onSuffixTap: () {
            // clear search query
            orgProvider.setSearchQuery('');
            // close keyboard
            FocusScope.of(context).unfocus();
            // remove text from search field
            searchController.clear();
          },
        ),
        const SizedBox(height: 10),
        Expanded(
          child: Consumer<OrganisationProvider>(
            builder: (context, orgProvider, _) {
              if (orgProvider.searchQuery.isEmpty) {
                return const Center(
                  child: Text(
                    'Search and add members',
                    style: textStyle18w500,
                  ),
                );
              } else {
                return UsersSearchStream(
                  uid: uid,
                  userViewType: userViewType,
                );
              }
            },
          ),
        ),
      ],
    );
  }
}
