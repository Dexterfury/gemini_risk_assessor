import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/models/assessment_model.dart';
import 'package:gemini_risk_assessor/providers/assessment_provider.dart';
import 'package:gemini_risk_assessor/providers/auth_provider.dart';
import 'package:gemini_risk_assessor/themes/my_themes.dart';
import 'package:gemini_risk_assessor/widgets/list_item.dart';
import 'package:gemini_risk_assessor/widgets/my_app_bar.dart';
import 'package:provider/provider.dart';

class DSTIScreen extends StatelessWidget {
  const DSTIScreen({
    super.key,
    this.orgID = '',
  });

  final String orgID;

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthProvider>().userModel!.uid;
    final assessmentProvider = context.read<AssessmentProvider>();
    return Scaffold(
      appBar: orgID.isNotEmpty
          ? MyAppBar(
              leading: const BackButton(),
              title: '',
              onSearch: _handleSearch,
            )
          : null,
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: assessmentProvider.dstiStream(
            userId: uid,
            orgID: orgID,
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
                  child: Text('No Daily Safety Tast Intructions found',
                      textAlign: TextAlign.center, style: textStyle18w500),
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final doc = snapshot.data!.docs[index];
                  final data = doc.data() as Map<String, dynamic>;
                  final dsti = AssessmentModel.fromJson(data);
                  return ListItem(
                    data: dsti,
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  void _handleSearch(String query) {
    print('Searching for "$query" in tab: ');
    // Implement your search logic here
  }
}
