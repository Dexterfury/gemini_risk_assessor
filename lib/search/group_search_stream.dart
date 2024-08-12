import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/groups/group_model.dart';
import 'package:gemini_risk_assessor/auth/authentication_provider.dart';
import 'package:gemini_risk_assessor/groups/group_provider.dart';
import 'package:gemini_risk_assessor/firebase/firebase_methods.dart';
import 'package:gemini_risk_assessor/groups/group_grid_item.dart';
import 'package:gemini_risk_assessor/themes/app_theme.dart';
import 'package:gemini_risk_assessor/responsive/responsive_layout_helper.dart';
import 'package:provider/provider.dart';

class GroupsSearchStream extends StatelessWidget {
  const GroupsSearchStream({super.key, this.onGroupTap});

  final Function(GroupModel)? onGroupTap;

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthenticationProvider>().userModel!.uid;
    return Consumer<GroupProvider>(builder: (context, groupProvider, child) {
      final searchQuery = groupProvider.searchQuery.toLowerCase();
      return StreamBuilder<QuerySnapshot>(
        stream: FirebaseMethods.groupsStream(
          userId: uid,
          groupID: '',
          fromShare: false,
        ),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  'You are not part of \n any groups yet!',
                  textAlign: TextAlign.center,
                  style: AppTheme.textStyle18w500,
                ),
              ),
            );
          }

          final results = snapshot.data!.docs
              .where(
                (element) =>
                    element[Constants.name].toString().toLowerCase().contains(
                          searchQuery,
                        ),
              )
              .toList();

          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            child: results.isEmpty
                ? const Center(
                    child: Text(
                    'No matching results',
                    style: AppTheme.textStyle18Bold,
                  ))
                : GridView.builder(
                    itemCount: results.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount:
                          ResponsiveLayoutHelper.getColumnCount(context),
                      childAspectRatio: 1,
                    ),
                    itemBuilder: (context, index) {
                      final doc = results[index];
                      final groupData = doc.data() as Map<String, dynamic>;
                      if (!groupData.containsKey(Constants.safetyFileUrl) ||
                          !groupData.containsKey(Constants.safetyFileContent) ||
                          !groupData.containsKey(Constants.useSafetyFile)) {
                        FirebaseMethods.updateGroupData(
                            groupID: groupData[Constants.groupID]);
                      }
                      final group = GroupModel.fromJson(groupData);
                      return GroupGridItem(
                        groupModel: group,
                        onTap: () {
                          if (onGroupTap != null) {
                            onGroupTap!(group);
                          }
                        },
                      );
                    }),
          );
        },
      );
    });
  }
}

// class GroupsSearchStream extends StatelessWidget {
//   const GroupsSearchStream({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final uid = context.read<AuthenticationProvider>().userModel!.uid;
//     return Consumer<GroupProvider>(builder: (context, groupProvider, child) {
//       final searchQuery = groupProvider.searchQuery.toLowerCase();
//       return StreamBuilder<QuerySnapshot>(
//         stream: FirebaseMethods.groupsStream(
//           userId: uid,
//           groupID: '',
//           fromShare: false,
//         ),
//         builder: (
//           BuildContext context,
//           AsyncSnapshot<QuerySnapshot> snapshot,
//         ) {
//           if (snapshot.hasError) {
//             return const Center(child: Text('Something went wrong'));
//           }

//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (snapshot.data!.docs.isEmpty) {
//             return const Center(
//               child: Padding(
//                 padding: EdgeInsets.all(20.0),
//                 child: Text(
//                   'You are not part of \n any groups yet!',
//                   textAlign: TextAlign.center,
//                   style: AppTheme.textStyle18w500,
//                 ),
//               ),
//             );
//           }

//           final results = snapshot.data!.docs
//               .where(
//                 (element) =>
//                     element[Constants.name].toString().toLowerCase().contains(
//                           searchQuery,
//                         ),
//               )
//               .toList();

//           return AnimatedSwitcher(
//             duration: const Duration(milliseconds: 500),
//             transitionBuilder: (child, animation) {
//               return FadeTransition(
//                 opacity: animation,
//                 child: child,
//               );
//             },
//             child: results.isEmpty
//                 ? const Center(
//                     child: Text(
//                     'No matching results',
//                     style: AppTheme.textStyle18Bold,
//                   ))
//                 : GridView.builder(
//                     itemCount: results.length,
//                     gridDelegate:
//                         const SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: 2,
//                       childAspectRatio: 1,
//                     ),
//                     itemBuilder: (context, index) {
//                       final doc = results[index];
//                       final groupData = doc.data() as Map<String, dynamic>;
//                       // updates group data if not present - new updates
//                       if (!groupData.containsKey(Constants.safetyFileUrl) ||
//                           !groupData.containsKey(Constants.safetyFileContent) ||
//                           !groupData.containsKey(Constants.useSafetyFile)) {
//                         FirebaseMethods.updateGroupData(
//                             groupID: groupData[Constants.groupID]);
//                       }
//                       final group = GroupModel.fromJson(groupData);
//                       return GroupGridItem(
//                         groupModel: group,
//                       );
//                     }),
//           );
//         },
//       );
//     });
//   }
// }
