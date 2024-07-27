import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/groups/group_model.dart';
import 'package:gemini_risk_assessor/authentication/authentication_provider.dart';
import 'package:gemini_risk_assessor/firebase_methods/firebase_methods.dart';
import 'package:gemini_risk_assessor/groups/group_grid_item.dart';
import 'package:gemini_risk_assessor/themes/app_theme.dart';
import 'package:provider/provider.dart';

class GroupsStream extends StatelessWidget {
  const GroupsStream({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthenticationProvider>().userModel!.uid;
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseMethods.groupsStream(
        userId: uid,
        groupID: '',
        fromShare: false,
      ),
      builder: (
        BuildContext context,
        AsyncSnapshot<QuerySnapshot> snapshot,
      ) {
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
                'You are not part of \n any group yet!',
                textAlign: TextAlign.center,
                style: AppTheme.textStyle18w500,
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: GridView.builder(
              itemCount: snapshot.data!.docs.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, index) {
                final doc = snapshot.data!.docs[index];
                final orgData = doc.data() as Map<String, dynamic>;
                final org = GroupModel.fromJson(orgData);
                return GroupGridItem(
                  groupModel: org,
                );
              }),
        );
      },
    );
  }
}
