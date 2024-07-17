import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/enums/enums.dart';
import 'package:gemini_risk_assessor/models/assessment_model.dart';
import 'package:gemini_risk_assessor/models/tool_model.dart';
import 'package:gemini_risk_assessor/providers/authentication_provider.dart';
import 'package:gemini_risk_assessor/providers/tab_provider.dart';
import 'package:gemini_risk_assessor/firebase_methods/firebase_methods.dart';
import 'package:gemini_risk_assessor/themes/my_themes.dart';
import 'package:gemini_risk_assessor/widgets/grid_item.dart';
import 'package:gemini_risk_assessor/widgets/list_item.dart';
import 'package:provider/provider.dart';

class MyDataStream extends StatelessWidget {
  const MyDataStream({
    super.key,
    required this.generationType,
    this.orgID = '',
  });

  final GenerationType generationType;
  final String orgID;

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthenticationProvider>().userModel!.uid;
    final stream = getStream(
      uid,
      orgID,
      generationType,
    );

    final title = getAppBarTitle(generationType);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Consumer<TabProvider>(
        builder: (context, tabProvider, child) {
          final searchQuery = getSearchQuery(
            tabProvider,
            generationType,
          );
          return StreamBuilder<QuerySnapshot>(
            stream: stream,
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

              final results = snapshot.data!.docs
                  .where(
                    (element) => element[Constants.title]
                        .toString()
                        .toLowerCase()
                        .contains(
                          searchQuery.toLowerCase(),
                        ),
                  )
                  .toList();

              if (results.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('No matching results',
                        textAlign: TextAlign.center, style: textStyle18w500),
                  ),
                );
              }

              return generationType == GenerationType.tool
                  ? searchQuery.isNotEmpty
                      ? GridView.builder(
                          itemCount: results.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1,
                          ),
                          itemBuilder: (context, index) {
                            final doc = results[index];
                            final data = doc.data() as Map<String, dynamic>;

                            final tool = ToolModel.fromJson(data);
                            return GridItem(toolModel: tool);
                          },
                        )
                      : GridView.builder(
                          itemCount: snapshot.data!.docs.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1,
                          ),
                          itemBuilder: (context, index) {
                            final doc = snapshot.data!.docs[index];
                            final data = doc.data() as Map<String, dynamic>;

                            final tool = ToolModel.fromJson(data);
                            return GridItem(toolModel: tool);
                          },
                        )
                  : searchQuery.isNotEmpty
                      ? ListView.builder(
                          itemCount: results.length,
                          itemBuilder: (context, index) {
                            final doc = results.elementAt(index);
                            final data = doc.data() as Map<String, dynamic>;
                            final assessment = AssessmentModel.fromJson(data);
                            return ListItem(
                              docTitle: title,
                              orgID: '',
                              data: assessment,
                            );
                          },
                        )
                      : ListView.builder(
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            final doc = snapshot.data!.docs.elementAt(index);
                            final data = doc.data() as Map<String, dynamic>;
                            final item = AssessmentModel.fromJson(data);
                            return ListItem(
                              docTitle: title,
                              orgID: '',
                              data: item,
                            );
                          },
                        );
            },
          );
        },
      ),
    );
  }

  getStream(
    String uid,
    String orgID,
    GenerationType generationType,
  ) {
    switch (generationType) {
      case GenerationType.dsti:
        return FirebaseMethods.dstiStream(
          userId: uid,
          orgID: orgID,
        );
      case GenerationType.riskAssessment:
        return FirebaseMethods.ristAssessmentsStream(
          userId: uid,
          orgID: orgID,
        );
      case GenerationType.tool:
        return FirebaseMethods.toolsStream(
          userId: uid,
          orgID: orgID,
        );
      default:
        return FirebaseMethods.dstiStream(
          userId: uid,
          orgID: orgID,
        );
    }
  }

  getSearchQuery(
    TabProvider tabProvider,
    GenerationType generationType,
  ) {
    switch (generationType) {
      case GenerationType.dsti:
        return tabProvider.dstiSearchQuery;
      case GenerationType.riskAssessment:
        return tabProvider.assessmentSearchQuery;
      case GenerationType.tool:
        return tabProvider.toolsSearchQuery;
      default:
        return tabProvider.dstiSearchQuery;
    }
  }

  getAppBarTitle(GenerationType generationType) {
    if (generationType == GenerationType.dsti) {
      return Constants.dailySafetyTaskInstructions;
    }
    if (generationType == GenerationType.riskAssessment) {
      return Constants.riskAssessment;
    }
    if (generationType == GenerationType.tool) {
      return Constants.tools;
    }
  }
}
