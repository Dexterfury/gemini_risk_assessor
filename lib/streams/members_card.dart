import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/enums/enums.dart';
import 'package:gemini_risk_assessor/models/user_model.dart';
import 'package:gemini_risk_assessor/providers/organisation_provider.dart';
import 'package:gemini_risk_assessor/widgets/user_widget.dart';
import 'package:provider/provider.dart';

class MembersCard extends StatefulWidget {
  const MembersCard({
    super.key,
    required this.orgID,
    required this.isAdmin,
  });

  final String orgID;
  final bool isAdmin;

  @override
  State<MembersCard> createState() => _MembersCardState();
}

class _MembersCardState extends State<MembersCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Column(
        children: [
          FutureBuilder<List<UserModel>>(
            future: context
                .read<OrganisationProvider>()
                .getMembersDataFromFirestore(orgID: widget.orgID),
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
                    return UserWidget(
                      userData: member,
                      showCheckMark: false,
                      viewType: UserViewType.user,
                    );

                    // ListTile(
                    //   contentPadding: EdgeInsets.zero,
                    //   leading: userImageWidget(
                    //       imageUrl: member.image, radius: 40, onTap: () {}),
                    //   title: Text(member.name),
                    //   subtitle: Text(member.aboutMe),
                    //   trailing: widget.groupProvider.groupModel.adminsUIDs
                    //           .contains(member.uid)
                    //       ? const Icon(
                    //           Icons.admin_panel_settings,
                    //           color: Colors.orangeAccent,
                    //         )
                    //       : const SizedBox(),
                    //   onTap: !widget.isAdmin
                    //       ? null
                    //       : () {
                    //           // show dialog to remove member
                    //           showMyAnimatedDialog(
                    //             context: context,
                    //             title: 'Remove Member',
                    //             content:
                    //                 'Are you sure you want to remove ${member.name} from the group?',
                    //             textAction: 'Remove',
                    //             onActionTap: (value, updatedText) async {
                    //               if (value) {
                    //                 //remove member from group
                    //                 await widget.groupProvider
                    //                     .removeGroupMember(
                    //                   groupMember: member,
                    //                 );

                    //                 setState(() {});
                    //               }
                    //             },
                    //           );
                    //        },
                    // );
                  });
            },
          ),
        ],
      ),
    );
  }
}
