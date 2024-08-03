import 'package:firebase_pagination/firebase_pagination.dart';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/groups/group_model.dart';
import 'package:gemini_risk_assessor/authentication/authentication_provider.dart';
import 'package:gemini_risk_assessor/firebase_methods/firebase_methods.dart';
import 'package:gemini_risk_assessor/groups/group_grid_item.dart';
import 'package:provider/provider.dart';

class GroupsStream extends StatelessWidget {
  const GroupsStream({
    super.key,
  });

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
      limit: limit, // query limit
      isLive: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1,
      ),
      viewType: ViewType.grid,
      onEmpty: const Center(
        child: Text('No data available'),
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
        final group = GroupModel.fromJson(groupData);
        return GroupGridItem(
          groupModel: group,
        );
      },
    );
  }
}
