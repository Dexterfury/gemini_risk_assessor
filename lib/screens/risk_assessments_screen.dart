import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/models/assessment_model.dart';
import 'package:gemini_risk_assessor/providers/assessment_provider.dart';
import 'package:gemini_risk_assessor/providers/auth_provider.dart';
import 'package:gemini_risk_assessor/themes/my_themes.dart';
import 'package:gemini_risk_assessor/widgets/list_item.dart';
import 'package:provider/provider.dart';

class RistAssessmentsScreen extends StatelessWidget {
  const RistAssessmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthProvider>().userModel!.uid;
    final assessmentProvider = context.read<AssessmentProvider>();
    return SafeArea(
      child: StreamBuilder<QuerySnapshot>(
        stream: assessmentProvider.ristAssessmentsStream(
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
                child: Text('No Daily Safety Tast Intructions found',
                    textAlign: TextAlign.center, style: textStyle18w500),
              ),
            );
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final assessment = AssessmentModel.fromJson(
                  snapshot.data!.docs[index] as Map<String, dynamic>);
              return ListItem(
                data: assessment,
              );
            },
          );
        },
      ),
    );
  }
}
