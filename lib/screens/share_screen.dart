import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/appBars/my_app_bar.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/dialogs/my_dialogs.dart';
import 'package:gemini_risk_assessor/enums/enums.dart';
import 'package:gemini_risk_assessor/firebase_methods/firebase_methods.dart';
import 'package:gemini_risk_assessor/models/assessment_model.dart';
import 'package:gemini_risk_assessor/models/organization_model.dart';
import 'package:gemini_risk_assessor/models/tool_model.dart';
import 'package:gemini_risk_assessor/providers/auth_provider.dart';
import 'package:gemini_risk_assessor/search/my_search_bar.dart';
import 'package:gemini_risk_assessor/themes/my_themes.dart';
import 'package:gemini_risk_assessor/utilities/global.dart';
import 'package:gemini_risk_assessor/widgets/grid_item.dart';
import 'package:provider/provider.dart';

class ShareScreen extends StatefulWidget {
  const ShareScreen({
    super.key,
    this.itemModel,
    this.toolModel,
    required this.generationType,
  });

  final AssessmentModel? itemModel;
  final ToolModel? toolModel;
  final GenerationType generationType;

  @override
  State<ShareScreen> createState() => _ShareScreenState();
}

class _ShareScreenState extends State<ShareScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleSharing(OrganizationModel org) {
    if (!org.allowSharing) {
      showSnackBar(
        context: context,
        message: 'Sharing not allowed for this organization',
      );
      return;
    }

    final isAlreadyShared = widget.generationType == GenerationType.tool
        ? widget.toolModel!.sharedWith.contains(org.organizationID)
        : widget.itemModel!.sharedWith.contains(org.organizationID);

    if (isAlreadyShared) {
      showSnackBar(
        context: context,
        message: 'You are already sharing this item with this organization',
      );

      return;
    }

    _showSharingDialog(org);
  }

  void _showSharingDialog(OrganizationModel org) {
    MyDialogs.showMyAnimatedDialog(
      context: context,
      title: 'Share',
      content: 'Share with ${org.name}',
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            await _performSharing(org);
          },
          child: const Text('Yes'),
        ),
      ],
    );
  }

  Future<void> _performSharing(OrganizationModel org) async {
    if (widget.generationType == GenerationType.tool) {
      await FirebaseMethods.shareToolWithOrganization(
        toolModel: widget.toolModel!,
        orgID: org.organizationID,
      );
    } else {
      await FirebaseMethods.shareWithOrganization(
        itemModel: widget.itemModel!,
        orgID: org.organizationID,
        isDSTI: widget.generationType == GenerationType.dsti,
      ).whenComplete(() {
        showSnackBar(
          context: context,
          message: 'Shared Successfully',
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthProvider>().userModel!.uid;
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseMethods.organizationsStream(
            userId: uid,
          ),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text('Something went wrong'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.data!.docs.isEmpty) {
              return const Scaffold(
                appBar: MyAppBar(
                  leading: BackButton(),
                  title: Constants.sharedWith,
                ),
                body: Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text('No Organizations Found!',
                        textAlign: TextAlign.center, style: textStyle18w500),
                  ),
                ),
              );
            }

            return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                final results = snapshot.data!.docs
                    .where(
                      (element) => element[Constants.title]
                          .toString()
                          .toLowerCase()
                          .contains(
                            _searchQuery.toLowerCase(),
                          ),
                    )
                    .toList();

                return CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      leading: const BackButton(),
                      title: const FittedBox(
                        child: Text(
                          Constants.sharedWith,
                        ),
                      ),
                      pinned: true,
                      floating: true,
                      snap: true,
                      expandedHeight: 120.0,
                      flexibleSpace: FlexibleSpaceBar(
                        background: Padding(
                          padding: const EdgeInsets.only(top: 56.0),
                          child: MySearchBar(
                            controller: _searchController,
                            onChanged: (value) {
                              setState(() {
                                _searchQuery = value;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    SliverPadding(
                        padding: const EdgeInsets.all(8.0),
                        sliver: results.isEmpty
                            ? const SliverFillRemaining(
                                child:
                                    Center(child: Text('No matching results')),
                              )
                            : SliverGrid(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 1,
                                ),
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    final doc = results[index];
                                    final data =
                                        doc.data() as Map<String, dynamic>;

                                    final org =
                                        OrganizationModel.fromJson(data);
                                    return GestureDetector(
                                        onTap: () {
                                          _handleSharing(org);

                                          // if (widget.generationType ==
                                          //     GenerationType.tool) {
                                          //   // handle too sharing
                                          //   if (!org.allowSharing) {
                                          //     showSnackBar(
                                          //       context: context,
                                          //       message:
                                          //           'Sharing not allowed for this organization',
                                          //     );
                                          //     return;
                                          //   }

                                          //   if (widget.toolModel!.sharedWith
                                          //       .contains(org.organizationID)) {
                                          //     // already shared with this org
                                          //     showSnackBar(
                                          //       context: context,
                                          //       message:
                                          //           'You are already sharing this item with this organization',
                                          //     );
                                          //     return;
                                          //   }

                                          //   // show dialog to share with this org
                                          //   MyDialogs.showMyAnimatedDialog(
                                          //       context: context,
                                          //       title: 'Share',
                                          //       content:
                                          //           'Share with ${org.name}',
                                          //       actions: [
                                          //         TextButton(
                                          //           onPressed: () {
                                          //             // pop dialog
                                          //             Navigator.pop(context);
                                          //           },
                                          //           child: const Text('Cancel'),
                                          //         ),
                                          //         TextButton(
                                          //           onPressed: () async {
                                          //             await FirebaseMethods
                                          //                 .shareToolWithOrganization(
                                          //               toolModel:
                                          //                   widget.toolModel!,
                                          //               orgID:
                                          //                   org.organizationID,
                                          //             ).whenComplete(() {
                                          //               showSnackBar(
                                          //                 context: context,
                                          //                 message:
                                          //                     'Shared Successfull',
                                          //               );
                                          //             });
                                          //           },
                                          //           child: const Text('Yes'),
                                          //         ),
                                          //       ]);
                                          // } else {
                                          //   if (!org.allowSharing) {
                                          //     showSnackBar(
                                          //       context: context,
                                          //       message:
                                          //           'Sharing not allowed for this organization',
                                          //     );
                                          //     return;
                                          //   }

                                          //   if (widget.itemModel!.sharedWith
                                          //       .contains(org.organizationID)) {
                                          //     // already shared with this org
                                          //     showSnackBar(
                                          //       context: context,
                                          //       message:
                                          //           'You are already sharing this item with this organization',
                                          //     );
                                          //     return;
                                          //   }
                                          //   // share with this org
                                          //   log('share with id: ${org.organizationID}');
                                          //   // show dialog to share with this org
                                          //   MyDialogs.showMyAnimatedDialog(
                                          //       context: context,
                                          //       title: 'Share',
                                          //       content:
                                          //           'Share with ${org.name}',
                                          //       actions: [
                                          //         TextButton(
                                          //           onPressed: () {
                                          //             // pop dialog
                                          //             Navigator.pop(context);
                                          //           },
                                          //           child: const Text('Cancel'),
                                          //         ),
                                          //         TextButton(
                                          //           onPressed: () async {
                                          //             await FirebaseMethods
                                          //                 .shareWithOrganization(
                                          //               itemModel:
                                          //                   widget.itemModel!,
                                          //               orgID:
                                          //                   org.organizationID,
                                          //               isDSTI: widget
                                          //                       .generationType ==
                                          //                   GenerationType.dsti,
                                          //             ).whenComplete(() {
                                          //               showSnackBar(
                                          //                 context: context,
                                          //                 message:
                                          //                     'Shared Successfull',
                                          //               );
                                          //             });
                                          //           },
                                          //           child: const Text('Yes'),
                                          //         ),
                                          //       ]);
                                          // }
                                        },
                                        child: GridItem(orgModel: org));
                                  },
                                  childCount: results.length,
                                ),
                              )),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
