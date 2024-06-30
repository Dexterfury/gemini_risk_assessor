import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/models/organisation_model.dart';
import 'package:gemini_risk_assessor/providers/auth_provider.dart';
import 'package:gemini_risk_assessor/providers/organisation_provider.dart';
import 'package:gemini_risk_assessor/themes/my_themes.dart';
import 'package:gemini_risk_assessor/widgets/grid_item.dart';
import 'package:provider/provider.dart';

class OrganisationsStream extends StatelessWidget {
  const OrganisationsStream({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthProvider>().userModel!.uid;
    final orgProvider = context.read<OrganisationProvider>();
    return StreamBuilder<QuerySnapshot>(
      stream: orgProvider.organisationsStream(
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
              child: Text('You are not part of any organisations yet!',
                  textAlign: TextAlign.center, style: textStyle18w500),
            ),
          );
        }

        return GridView.builder(
            itemCount: snapshot.data!.docs.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1,
            ),
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final orgData = doc.data() as Map<String, dynamic>;
              final org = OrganisationModel.fromJson(orgData);
              return GridItem(orgModel: org);
            });
      },
    );
  }
}
