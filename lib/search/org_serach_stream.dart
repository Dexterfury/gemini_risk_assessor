import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/models/organization_model.dart';
import 'package:gemini_risk_assessor/providers/auth_provider.dart';
import 'package:gemini_risk_assessor/providers/organization_provider.dart';
import 'package:gemini_risk_assessor/firebase_methods/firebase_methods.dart';
import 'package:gemini_risk_assessor/themes/my_themes.dart';
import 'package:gemini_risk_assessor/widgets/grid_item.dart';
import 'package:provider/provider.dart';

class OrgSearchStream extends StatelessWidget {
  const OrgSearchStream({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthProvider>().userModel!.uid;
    return Consumer<OrganizationProvider>(
        builder: (context, organizationProvider, child) {
      return StreamBuilder<QuerySnapshot>(
        stream: FirebaseMethods.organizationsStream(
          userId: uid,
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
                padding: EdgeInsets.all(8.0),
                child: Text('You are not part of any organizations yet!',
                    textAlign: TextAlign.center, style: textStyle18w500),
              ),
            );
          }

          final results = snapshot.data!.docs
              .where(
                (element) => element[Constants.organizationName]
                    .toString()
                    .toLowerCase()
                    .contains(
                      organizationProvider.searchQuery.toLowerCase(),
                    ),
              )
              .toList();

          if (results.isEmpty) {
            return const Center(child: Text('No matching results'));
          }

          return GridView.builder(
              itemCount: results.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, index) {
                final doc = results[index];
                final orgData = doc.data() as Map<String, dynamic>;
                final org = OrganizationModel.fromJson(orgData);
                return GridItem(orgModel: org);
              });
        },
      );
    });
  }
}
