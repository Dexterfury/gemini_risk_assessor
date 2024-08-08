import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_pagination/firebase_pagination.dart';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/enums/enums.dart';
import 'package:gemini_risk_assessor/models/assessment_model.dart';
import 'package:gemini_risk_assessor/tools/tool_model.dart';
import 'package:gemini_risk_assessor/auth/authentication_provider.dart';
import 'package:gemini_risk_assessor/providers/tab_provider.dart';
import 'package:gemini_risk_assessor/firebase/firebase_methods.dart';
import 'package:gemini_risk_assessor/tools/tool_item.dart';
import 'package:gemini_risk_assessor/widgets/list_item.dart';
import 'package:provider/provider.dart';

class MyDataStream extends StatelessWidget {
  const MyDataStream({
    Key? key,
    required this.generationType,
    this.groupID = '',
  }) : super(key: key);

  final GenerationType generationType;
  final String groupID;

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthenticationProvider>().userModel!.uid;
    final query = getQuery(uid, groupID, generationType);
    final title = getAppBarTitle(generationType);
    final int limit = 20;

    return Consumer<TabProvider>(
      builder: (context, tabProvider, child) {
        final searchQuery = getSearchQuery(tabProvider, generationType);

        return FirestorePagination(
          query: query,
          limit: limit, // query limit
          isLive: true,
          viewType: ViewType.list,
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
            final data = documentSnapshot[index].data() as Map<String, dynamic>;

            // Apply search filter
            if (!data[Constants.title]
                .toString()
                .toLowerCase()
                .contains(searchQuery.toLowerCase())) {
              return const SizedBox.shrink();
            }

            if (generationType == GenerationType.tool) {
              final tool = ToolModel.fromJson(data);
              return ToolItem(
                isAdmin: true,
                toolModel: tool,
                groupID: groupID,
              );
            } else {
              final assessment = AssessmentModel.fromJson(data);
              return ListItem(
                docTitle: title,
                groupID: '',
                data: assessment,
                isAdmin: true,
              );
            }
          },
        );
      },
    );
  }

  Query getQuery(
    String uid,
    String groupID,
    GenerationType generationType,
  ) {
    final collection = groupID.isNotEmpty
        ? FirebaseMethods.groupsCollection
            .doc(groupID)
            .collection(getCollectionName(generationType))
        : FirebaseMethods.usersCollection
            .doc(uid)
            .collection(getCollectionName(generationType));

    return collection.orderBy(Constants.createdAt, descending: true);
  }

  String getCollectionName(GenerationType generationType) {
    switch (generationType) {
      case GenerationType.riskAssessment:
        return Constants.assessmentCollection;
      case GenerationType.tool:
        return Constants.toolsCollection;
      default:
        return Constants.assessmentCollection;
    }
  }

  String getSearchQuery(
    TabProvider tabProvider,
    GenerationType generationType,
  ) {
    switch (generationType) {
      case GenerationType.riskAssessment:
        return tabProvider.assessmentSearchQuery;
      case GenerationType.tool:
        return tabProvider.toolsSearchQuery;
      default:
        return tabProvider.assessmentSearchQuery;
    }
  }

  String getAppBarTitle(GenerationType generationType) {
    if (generationType == GenerationType.riskAssessment) {
      return Constants.riskAssessment;
    } else {
      return Constants.toolsExplainer;
    }
  }
}

// class MyDataStream extends StatelessWidget {
//   const MyDataStream({
//     super.key,
//     required this.generationType,
//     this.groupID = '',
//   });

//   final GenerationType generationType;
//   final String groupID;

//   @override
//   Widget build(BuildContext context) {
//     final uid = context.read<AuthenticationProvider>().userModel!.uid;
//     final stream = getStream(
//       uid,
//       groupID,
//       generationType,
//     );

//     final title = getAppBarTitle(generationType);

//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Consumer<TabProvider>(
//         builder: (context, tabProvider, child) {
//           final searchQuery = getSearchQuery(
//             tabProvider,
//             generationType,
//           );
//           return StreamBuilder<QuerySnapshot>(
//             stream: stream,
//             builder: (
//               BuildContext context,
//               AsyncSnapshot<QuerySnapshot> snapshot,
//             ) {
//               if (snapshot.hasError) {
//                 return const Center(child: Text('Something went wrong'));
//               }

//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return const Center(child: CircularProgressIndicator());
//               }

//               final results = snapshot.data!.docs
//                   .where(
//                     (element) => element[Constants.title]
//                         .toString()
//                         .toLowerCase()
//                         .contains(
//                           searchQuery.toLowerCase(),
//                         ),
//                   )
//                   .toList();

//               if (results.isEmpty) {
//                 return const Center(
//                   child: Padding(
//                     padding: EdgeInsets.all(8.0),
//                     child: Text('No matching results',
//                         textAlign: TextAlign.center,
//                         style: AppTheme.textStyle18w500),
//                   ),
//                 );
//               }

//               return generationType == GenerationType.tool
//                   ? searchQuery.isNotEmpty
//                       ? ListView.builder(
//                           itemCount: results.length,
//                           itemBuilder: (context, index) {
//                             final doc = results[index];
//                             final data = doc.data() as Map<String, dynamic>;

//                             final tool = ToolModel.fromJson(data);
//                             return ToolItem(
//                               toolModel: tool,
//                               groupID: groupID,
//                             );
//                           },
//                         )
//                       : ListView.builder(
//                           itemCount: snapshot.data!.docs.length,
//                           itemBuilder: (context, index) {
//                             final doc = snapshot.data!.docs[index];
//                             final data = doc.data() as Map<String, dynamic>;

//                             final tool = ToolModel.fromJson(data);
//                             return ToolItem(
//                               toolModel: tool,
//                               groupID: groupID,
//                             );
//                           },
//                         )
//                   : searchQuery.isNotEmpty
//                       ? ListView.builder(
//                           itemCount: results.length,
//                           itemBuilder: (context, index) {
//                             final doc = results.elementAt(index);
//                             final data = doc.data() as Map<String, dynamic>;
//                             final assessment = AssessmentModel.fromJson(data);
//                             return ListItem(
//                               docTitle: title,
//                               groupID: '',
//                               data: assessment,
//                             );
//                           },
//                         )
//                       : ListView.builder(
//                           itemCount: snapshot.data!.docs.length,
//                           itemBuilder: (context, index) {
//                             final doc = snapshot.data!.docs.elementAt(index);
//                             final data = doc.data() as Map<String, dynamic>;
//                             final item = AssessmentModel.fromJson(data);
//                             return ListItem(
//                               docTitle: title,
//                               groupID: '',
//                               data: item,
//                             );
//                           },
//                         );
//             },
//           );
//         },
//       ),
//     );
//   }

//   getStream(
//     String uid,
//     String groupID,
//     GenerationType generationType,
//   ) {
//     switch (generationType) {
//       case GenerationType.riskAssessment:
//         return FirebaseMethods.ristAssessmentsStream(
//           userId: uid,
//           groupID: groupID,
//         );
//       case GenerationType.tool:
//         return FirebaseMethods.toolsStream(
//           userId: uid,
//           groupID: groupID,
//         );
//       default:
//         return FirebaseMethods.ristAssessmentsStream(
//           userId: uid,
//           groupID: groupID,
//         );
//     }
//   }

//   getSearchQuery(
//     TabProvider tabProvider,
//     GenerationType generationType,
//   ) {
//     switch (generationType) {
//       case GenerationType.riskAssessment:
//         return tabProvider.assessmentSearchQuery;
//       case GenerationType.tool:
//         return tabProvider.toolsSearchQuery;
//       default:
//         return tabProvider.assessmentSearchQuery;
//     }
//   }

//   getAppBarTitle(GenerationType generationType) {
//     if (generationType == GenerationType.riskAssessment) {
//       return Constants.riskAssessment;
//     } else {
//       return Constants.toolsExplainer;
//     }
//   }
// }
