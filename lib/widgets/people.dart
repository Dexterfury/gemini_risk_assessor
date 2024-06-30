import 'package:flutter/cupertino.dart';
import 'package:gemini_risk_assessor/providers/auth_provider.dart';
import 'package:gemini_risk_assessor/providers/organisation_provider.dart';
import 'package:gemini_risk_assessor/streams/search_stream.dart';
import 'package:gemini_risk_assessor/themes/my_themes.dart';
import 'package:gemini_risk_assessor/widgets/main_app_button.dart';
import 'package:provider/provider.dart';

class People extends StatelessWidget {
  const People({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthProvider>().userModel!.uid;
    final orgProvider = context.read<OrganisationProvider>();
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: CupertinoSearchTextField(
                    onChanged: (value) {
                      // search for users
                      orgProvider.setSearchQuery(value);
                    },
                    onSuffixTap: () {
                      // clear search query
                      orgProvider.setSearchQuery('');
                    },
                  ),
                ),
                const SizedBox(width: 10),
                MainAppButton(
                  label: 'Done',
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
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
                  return SearchStream(uid: uid);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
