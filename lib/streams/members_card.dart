import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/enums/enums.dart';
import 'package:gemini_risk_assessor/models/organisation_model.dart';
import 'package:gemini_risk_assessor/models/user_model.dart';
import 'package:gemini_risk_assessor/providers/organisation_provider.dart';
import 'package:gemini_risk_assessor/widgets/user_widget.dart';
import 'package:provider/provider.dart';

class MembersCard extends StatelessWidget {
  const MembersCard({
    super.key,
    required this.orgModel,
    required this.isAdmin,
  });

  final OrganisationModel orgModel;
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Column(
        children: [
          FutureBuilder<List<UserModel>>(
            future: context
                .read<OrganisationProvider>()
                .getMembersDataFromFirestore(
                  orgID: orgModel.organisationID,
                ),
            // builder: (context, snapshot)
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (snapshot.hasError) {
                return const Center(
                  child: Text('Something went wrong'),
                );
              }
              if (snapshot.data!.isEmpty) {
                return const Center(
                  child: Text('No members'),
                );
              }
              return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final member = snapshot.data![index];
                    final isAdmin = orgModel.adminsUIDs.contains(member.uid);
                    return UserWidget(
                      userData: member,
                      isAdminView: isAdmin,
                      showCheckMark: false,
                      viewType: UserViewType.user,
                    );
                  });
            },
          ),
        ],
      ),
    );
  }
}
