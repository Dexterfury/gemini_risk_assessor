import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/providers/assessment_provider.dart';
import 'package:gemini_risk_assessor/themes/my_themes.dart';
import 'package:provider/provider.dart';

class DSTIScreen extends StatelessWidget {
  const DSTIScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final assessmentProvider = context.read<AssessmentProvider>();
    return SafeArea(
      child: StreamBuilder<QuerySnapshot>(
        stream: assessmentProvider.dstiStream(),
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
              final dsti = snapshot.data!.docs[index];
              return ListTile(
                title: Text(dsti['name']),
                subtitle: Text(dsti['description']),
              );
            },
          );
        },
      ),
    );
  }
}
