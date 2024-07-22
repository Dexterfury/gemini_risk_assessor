import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gemini_risk_assessor/appBars/my_app_bar.dart';
import 'package:gemini_risk_assessor/buttons/main_app_button.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/dialogs/my_dialogs.dart';
import 'package:gemini_risk_assessor/firebase_methods/firebase_methods.dart';
import 'package:gemini_risk_assessor/models/near_miss_model.dart';
import 'package:gemini_risk_assessor/screens/dsti_screen.dart';
import 'package:gemini_risk_assessor/screens/risk_assessments_screen.dart';
import 'package:gemini_risk_assessor/screens/tools_screen.dart';
import 'package:gemini_risk_assessor/search/my_search_bar.dart';
import 'package:gemini_risk_assessor/themes/my_themes.dart';
import 'package:gemini_risk_assessor/utilities/global.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

// class DiscussionScreen extends StatefulWidget {
//   const DiscussionScreen({
//     super.key,
//     required this.orgID,
//     required this.isAdmin,
//   });
//   final String orgID;
//   final bool isAdmin;

//   @override
//   State<DiscussionScreen> createState() => _DiscussionScreenState();
// }

// class _DiscussionScreenState extends State<DiscussionScreen> {
//   final TextEditingController _searchController = TextEditingController();
//   String _searchQuery = '';

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: StreamBuilder<QuerySnapshot>(
//           stream: FirebaseMethods.discussionStream(
//             orgID: widget.orgID,
//           ),
//           builder:
//               (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
//             if (snapshot.hasError) {
//               return const Center(child: Text('Something went wrong'));
//             }

//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return const Center(child: CircularProgressIndicator());
//             }

//             if (snapshot.data!.docs.isEmpty) {
//               return Scaffold(
//                 appBar: widget.orgID.isNotEmpty
//                     ? const MyAppBar(
//                         leading: BackButton(),
//                         title: Constants.discussions,
//                       )
//                     : null,
//                 body: Center(
//                   child: Padding(
//                     padding: const EdgeInsets.all(20.0),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         const Text(
//                           'No Discussions Yet!',
//                           textAlign: TextAlign.center,
//                           style: textStyle18w500,
//                         ),
//                         const SizedBox(
//                           height: 10,
//                         ),
//                         SizedBox(
//                           height: 50.0,
//                           child: MainAppButton(
//                             label: ' Start a Discussion ',
//                             borderRadius: 15.0,
//                             onTap: () async {
//                               Map<String, bool> results = {
//                                 Constants.hasAssessments: true,
//                                 Constants.hasDSTI: true,
//                                 Constants.hasTools: true,
//                               };
//                               // If there's data, show a dialog
//                               MyDialogs.showMyDiscussionsDialog(
//                                 context: context,
//                                 title: 'Start a Discussion for a?',
//                                 results: results,
//                                 tapAction: (value) {
//                                   switch (value) {
//                                     case Constants.riskAssessment:
//                                       Future.delayed(const Duration(seconds: 1))
//                                           .whenComplete(() {
//                                         Navigator.push(
//                                           context,
//                                           MaterialPageRoute(
//                                             builder: (context) =>
//                                                 RiskAssessmentsScreen(
//                                               orgID: widget.orgID,
//                                               isDiscussion: true,
//                                             ),
//                                           ),
//                                         );
//                                       });

//                                       break;
//                                     case Constants.dailySafetyTaskInstructions:
//                                       Future.delayed(const Duration(seconds: 1))
//                                           .whenComplete(() {
//                                         Navigator.push(
//                                           context,
//                                           MaterialPageRoute(
//                                             builder: (context) => DSTIScreen(
//                                               orgID: widget.orgID,
//                                               isDiscussion: true,
//                                             ),
//                                           ),
//                                         );
//                                       });
//                                       break;
//                                     case Constants.tools:
//                                       Future.delayed(const Duration(seconds: 1))
//                                           .whenComplete(() {
//                                         Navigator.push(
//                                           context,
//                                           MaterialPageRoute(
//                                             builder: (context) => ToolsScreen(
//                                               orgID: widget.orgID,
//                                               isDiscussion: true,
//                                             ),
//                                           ),
//                                         );
//                                       });
//                                       break;
//                                   }
//                                 },
//                               );
//                               // MyDialogs.showMyAnimatedDialog(
//                               //   context: context,
//                               //   title: 'Please wait...',
//                               //   loadingIndicator: const SizedBox(
//                               //     height: 100,
//                               //     width: 100,
//                               //     child: LoadingPPEIcons(),
//                               //   ),
//                               // );
//                               // await FirebaseMethods.checkOrganizationData(
//                               //   orgID: widget.orgID,
//                               // ).then((results) {
//                               //   Navigator.pop(context);
//                               //   if (!results.values.any((value) => value)) {
//                               //     if (mounted) {
//                               //       // If no data is available, show a SnackBar
//                               //       showSnackBar(
//                               //         context: context,
//                               //         message:
//                               //             'No data available for this organization.',
//                               //       );
//                               //     }
//                               //   } else {
//                               //     // If there's data, show a dialog
//                               //     MyDialogs.showMyDiscussionsDialog(
//                               //       context: context,
//                               //       title: 'Start a Discussion for a?',
//                               //       results: results,
//                               //       tapAction: (value) {
//                               //         log('Clicked on $value');
//                               //       },
//                               //     );
//                               //   }
//                               //   return results;
//                               // });
//                             },
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               );
//             }

//             return StatefulBuilder(
//               builder: (BuildContext context, StateSetter setState) {
//                 final results = snapshot.data!.docs.where(
//                   (element) => element[Constants.title]
//                       .toString()
//                       .toLowerCase()
//                       .contains(
//                         _searchQuery.toLowerCase(),
//                       ),
//                 );

//                 return CustomScrollView(
//                   slivers: [
//                     SliverAppBar(
//                       leading: const BackButton(),
//                       title: const FittedBox(
//                         child: Text(
//                           Constants.discussions,
//                         ),
//                       ),
//                       actions: [
//                         if (widget.isAdmin)
//                           IconButton(
//                             onPressed: () async {
//                               MyDialogs.showMyAnimatedDialog(
//                                 context: context,
//                                 title: 'Please wait...',
//                                 loadingIndicator: const SizedBox(
//                                   height: 100,
//                                   width: 100,
//                                   child: LoadingPPEIcons(),
//                                 ),
//                               );
//                               await FirebaseMethods.checkOrganizationData(
//                                 orgID: widget.orgID,
//                               ).then((results) {
//                                 Navigator.pop(context);
//                                 if (!results.values.any((value) => value)) {
//                                   if (mounted) {
//                                     // If no data is available, show a SnackBar
//                                     showSnackBar(
//                                       context: context,
//                                       message:
//                                           'No data available for this organization.',
//                                     );
//                                   }
//                                 } else {
//                                   // If there's data, show a dialog
//                                   MyDialogs.showMyDiscussionsDialog(
//                                     context: context,
//                                     title: 'Start a Discussion for a?',
//                                     results: results,
//                                     tapAction: (value) {
//                                       log('Clicked on $value');
//                                     },
//                                   );
//                                 }
//                                 return results;
//                               });
//                             },
//                             icon: const Icon(FontAwesomeIcons.plus),
//                           )
//                       ],
//                       pinned: true,
//                       floating: true,
//                       snap: true,
//                       expandedHeight: 120.0,
//                       flexibleSpace: FlexibleSpaceBar(
//                         background: Padding(
//                           padding: const EdgeInsets.only(top: 56.0),
//                           child: MySearchBar(
//                             controller: _searchController,
//                             onChanged: (value) {
//                               setState(() {
//                                 _searchQuery = value;
//                               });
//                             },
//                           ),
//                         ),
//                       ),
//                     ),
//                     SliverPadding(
//                       padding: const EdgeInsets.all(8.0),
//                       sliver: results.isEmpty
//                           ? const SliverFillRemaining(
//                               child: Center(child: Text('No matching results')),
//                             )
//                           : SliverList(
//                               delegate: SliverChildBuilderDelegate(
//                                 (context, index) {
//                                   final doc = results.elementAt(index);
//                                   final data =
//                                       doc.data() as Map<String, dynamic>;
//                                   final item = DiscussionModel.fromJson(data);
//                                   return ListTile(
//                                     title: Text(item.title),
//                                     subtitle: Text(item.description),
//                                   );
//                                 },
//                                 childCount: results.length,
//                               ),
//                             ),
//                     ),
//                   ],
//                 );
//               },
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
