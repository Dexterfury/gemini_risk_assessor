import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/appBars/my_app_bar.dart';
import 'package:gemini_risk_assessor/appBars/my_sliver_app_bar.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/models/assessment_model.dart';
import 'package:gemini_risk_assessor/providers/auth_provider.dart';
import 'package:gemini_risk_assessor/providers/tab_provider.dart';
import 'package:gemini_risk_assessor/streams/data_stream.dart';
import 'package:gemini_risk_assessor/themes/my_themes.dart';
import 'package:gemini_risk_assessor/widgets/list_item.dart';
import 'package:provider/provider.dart';

class AssessmentsSearchStream extends StatelessWidget {
  const AssessmentsSearchStream({
    super.key,
    this.orgID = '',
  });

  final String orgID; // Optional organization ID for filtering results

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthProvider>().userModel!.uid;
    return Scaffold(
      body: Consumer<TabProvider>(
        builder: (context, tabProvider, child) {
          return SafeArea(
            child: StreamBuilder<QuerySnapshot>(
              stream: DataStream.dstiStream(
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

                final results = snapshot.data!.docs.where((element) =>
                    element[Constants.title]
                        .toString()
                        .toLowerCase()
                        .contains(tabProvider.searchQuery.toLowerCase()));

                if (results.isEmpty) {
                  return const Center(child: Text('No matching results'));
                }

                if (snapshot.data!.docs.isEmpty) {
                  return Scaffold(
                    appBar: orgID.isNotEmpty
                        ? const MyAppBar(
                            leading: BackButton(),
                            title: Constants.dailySafetyTaskInstructions,
                          )
                        : null,
                    body: const Center(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('No matching results',
                            textAlign: TextAlign.center,
                            style: textStyle18w500),
                      ),
                    ),
                  );
                }
                return orgID.isNotEmpty
                    ? MySliverAppBar(
                        snapshot: snapshot,
                        title: Constants.dailySafetyTaskInstructions,
                        onSearch: (handleSearch) {},
                      )
                    : Padding(
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
          );
        },
      ),
    );
  }
}
