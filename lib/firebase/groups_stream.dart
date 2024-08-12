import 'package:firebase_pagination/firebase_pagination.dart';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/groups/group_model.dart';
import 'package:gemini_risk_assessor/auth/authentication_provider.dart';
import 'package:gemini_risk_assessor/firebase/firebase_methods.dart';
import 'package:gemini_risk_assessor/groups/group_grid_item.dart';
import 'package:gemini_risk_assessor/responsive/responsive_layout_helper.dart';
import 'package:provider/provider.dart';

class GroupsStream extends StatelessWidget {
  const GroupsStream({super.key, this.onGroupTap});

  final Function(GroupModel)? onGroupTap;

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthenticationProvider>().userModel!.uid;
    final limit = 20;
    final query = FirebaseMethods.groupsQuery(
      userId: uid,
      groupID: '',
      fromShare: false,
    );
    return FirestorePagination(
      query: query,
      limit: limit,
      isLive: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: ResponsiveLayoutHelper.getColumnCount(context),
        childAspectRatio: 1,
      ),
      viewType: ViewType.grid,
      onEmpty: const Center(
        child: Text('You have no groups'),
      ),
      bottomLoader: const Center(
        child: CircularProgressIndicator(),
      ),
      initialLoader: const Center(
        child: CircularProgressIndicator(),
      ),
      itemBuilder: (context, documentSnapshot, index) {
        final doc = documentSnapshot[index].data();
        final groupData = doc as Map<String, dynamic>;
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
      },
    );
  }
}

// class GroupsStream extends StatelessWidget {
//   const GroupsStream({
//     super.key,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final uid = context.read<AuthenticationProvider>().userModel!.uid;
//     final limit = 20;
//     final query = FirebaseMethods.groupsQuery(
//       userId: uid,
//       groupID: '',
//       fromShare: false,
//     );
//     return FirestorePagination(
//       query: query,
//       limit: limit, // query limit
//       isLive: true,
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 2,
//         childAspectRatio: 1,
//       ),
//       viewType: ViewType.grid,
//       onEmpty: const Center(
//         child: Text('You have no groups'),
//       ),
//       bottomLoader: const Center(
//         child: CircularProgressIndicator(),
//       ),
//       initialLoader: const Center(
//         child: CircularProgressIndicator(),
//       ),
//       itemBuilder: (context, documentSnapshot, index) {
//         final doc = documentSnapshot[index].data();
//         final groupData = doc as Map<String, dynamic>;
//         // updates group data if not present - new updates to group data
//         if (!groupData.containsKey(Constants.safetyFileUrl) ||
//             !groupData.containsKey(Constants.safetyFileContent) ||
//             !groupData.containsKey(Constants.useSafetyFile)) {
//           FirebaseMethods.updateGroupData(
//               groupID: groupData[Constants.groupID]);
//         }
//         final group = GroupModel.fromJson(groupData);
//         return GroupGridItem(
//           groupModel: group,
//         );
//       },
//     );
//   }
// }
