import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/enums/enums.dart';
import 'package:gemini_risk_assessor/models/user_model.dart';
import 'package:gemini_risk_assessor/providers/organisation_provider.dart';
import 'package:gemini_risk_assessor/widgets/user_widget.dart';
import 'package:provider/provider.dart';

class UsersSearchStream extends StatelessWidget {
  const UsersSearchStream({
    super.key,
    required this.uid,
    this.organisationID = '',
    required this.userViewType,
  });

  final String uid;
  final String organisationID;
  final UserViewType userViewType;

  @override
  Widget build(BuildContext context) {
    return Consumer<OrganisationProvider>(
      builder: (context, organisationProvider, _) {
        return StreamBuilder<QuerySnapshot>(
          stream: organisationProvider.allUsersStream(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text('Something went wrong'));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No data found'));
            }

            final results = snapshot.data!.docs.where((element) =>
                element[Constants.name]
                    .toString()
                    .toLowerCase()
                    .contains(organisationProvider.searchQuery.toLowerCase()));

            if (results.isEmpty) {
              return const Center(child: Text('No matching results'));
            }

            return ListView.builder(
              itemCount: results.length,
              itemBuilder: (context, index) {
                final userData = UserModel.fromJson(
                    results.elementAt(index).data() as Map<String, dynamic>);

                if (userData.uid == uid) {
                  return Container();
                } else {
                  return UserWidget(
                    userData: userData,
                    showCheckMark: true,
                    viewType: UserViewType.creator,
                  );
                }
              },
            );
          },
        );
      },
    );
  }
}
