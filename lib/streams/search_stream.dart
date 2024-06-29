import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/models/user_model.dart';
import 'package:gemini_risk_assessor/providers/organisation_provider.dart';
import 'package:gemini_risk_assessor/widgets/user_widget.dart';
import 'package:provider/provider.dart';

class SearchStream extends StatelessWidget {
  const SearchStream({
    super.key,
    required this.uid,
    this.organisationID = '',
  });

  final String uid;
  final String organisationID;

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
                  final userData = UserModel.fromJson(
                      results.elementAt(index).data() as Map<String, dynamic>);
                  return UserWidget(
                    userData: userData,
                    showCheckMark: true,
                  );
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
