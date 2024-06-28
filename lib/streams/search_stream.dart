import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/providers/auth_provider.dart';
import 'package:gemini_risk_assessor/providers/organisation_provider.dart';
import 'package:provider/provider.dart';

class SearchStream extends StatelessWidget {
  const SearchStream({
    super.key,
    required this.uid,
    this.groupId = '',
  });

  final String uid;
  final String groupId;

  @override
  Widget build(BuildContext context) {
    return Consumer<OrganisationProvider>(builder: ((
      context,
      organisationProvider,
      child,
    ) {
      return StreamBuilder<QuerySnapshot>(
          stream: organisationProvider.allUsersStream(),
          builder: (builderContext, snapshot) {
            if (snapshot.hasError) {
              return const Center(
                child: Text('Something went wrong'),
              );
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final results = snapshot.data!.docs.where((element) =>
                element[Constants.name]
                    .toString()
                    .toLowerCase()
                    .contains(organisationProvider.searchQuery.toLowerCase()));

            if (results.isEmpty) {
              return const Center(
                child: Text('No data found'),
              );
            }

            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: results.length,
                itemBuilder: (context, index) {
                  // final chat = LastMessageModel.fromMap(
                  //     results.elementAt(index).data() as Map<String, dynamic>);
                  return const SizedBox();

                  // ChatWidget(
                  //   chat: chat,
                  //   isGroup: false,
                  //   onTap: () {
                  //     Navigator.pushNamed(
                  //       context,
                  //       Constants.chatScreen,
                  //       arguments: {
                  //         Constants.contactUID: chat.contactUID,
                  //         Constants.contactName: chat.contactName,
                  //         Constants.contactImage: chat.contactImage,
                  //         Constants.groupId: groupId.isEmpty ? '' : groupId,
                  //       },
                  //     );
                  //   },
                  // );
                },
              );
            }
            return const Center(
              child: Text('No data found'),
            );
          });
    }));
  }
}
