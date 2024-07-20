import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/models/tool_model.dart';
import 'package:gemini_risk_assessor/providers/tool_provider.dart';
import 'package:gemini_risk_assessor/firebase_methods/firebase_methods.dart';
import 'package:gemini_risk_assessor/themes/my_themes.dart';
import 'package:gemini_risk_assessor/widgets/grid_item.dart';

// class ToolsStream extends StatelessWidget {
//   const ToolsStream({
//     super.key,
//     required this.toolProvider,
//     required this.uid,
//     required this.orgID,
//   });

//   final ToolsProvider toolProvider;
//   final String uid;
//   final String orgID;

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<QuerySnapshot>(
//       stream: FirebaseMethods.toolsStream(
//         userId: uid,
//         orgID: orgID,
//       ),
//       builder: (
//         BuildContext context,
//         AsyncSnapshot<QuerySnapshot> snapshot,
//       ) {
//         if (snapshot.hasError) {
//           return const Center(child: Text('Something went wrong'));
//         }

//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         if (snapshot.data!.docs.isEmpty) {
//           return const Center(
//             child: Padding(
//               padding: EdgeInsets.all(8.0),
//               child: Text('You have not saved any tools',
//                   textAlign: TextAlign.center, style: textStyle18w500),
//             ),
//           );
//         }
//         return GridView.builder(
//             itemCount: snapshot.data!.docs.length,
//             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 2,
//               childAspectRatio: 1,
//             ),
//             itemBuilder: (context, index) {
//               final tool = ToolModel.fromJson(
//                   snapshot.data!.docs[index] as Map<String, dynamic>);
//               return GridItem(toolModel: tool);
//             });
//       },
//     );
//   }
// }
