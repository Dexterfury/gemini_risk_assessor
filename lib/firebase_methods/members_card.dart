import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/enums/enums.dart';
import 'package:gemini_risk_assessor/models/organization_model.dart';
import 'package:gemini_risk_assessor/models/user_model.dart';
import 'package:gemini_risk_assessor/providers/organization_provider.dart';
import 'package:gemini_risk_assessor/themes/my_themes.dart';
import 'package:gemini_risk_assessor/widgets/user_widget.dart';
import 'package:provider/provider.dart';

class MembersCard extends StatelessWidget {
  const MembersCard({
    super.key,
    required this.orgModel,
    required this.isAdmin,
  });

  final OrganizationModel orgModel;
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).cardColor,
      elevation: cardElevation,
      child: Column(
        children: [
          FutureBuilder<List<UserModel>>(
            future: context
                .read<OrganizationProvider>()
                .getMembersDataFromFirestore(
                  orgID: orgModel.organizationID,
                ),
            // builder: (context, snapshot)
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(),
                  ),
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
                    final isMemberAdmin =
                        orgModel.adminsUIDs.contains(member.uid);
                    return Padding(
                      padding: const EdgeInsets.only(
                        left: 8.0,
                        right: 8.0,
                      ),
                      child: UserWidget(
                        userData: member,
                        isAdminView: isMemberAdmin,
                        showCheckMark: false,
                        viewType: UserViewType.user,
                        onLongPress: !isAdmin
                            ? null
                            : () {
                                // show dialog for added member as admin
                              },
                      ),
                    );
                  });
            },
          ),
        ],
      ),
    );
  }
}
