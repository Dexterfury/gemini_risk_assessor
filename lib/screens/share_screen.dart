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
import 'package:gemini_risk_assessor/providers/authentication_provider.dart';
import 'package:gemini_risk_assessor/search/my_search_bar.dart';
import 'package:gemini_risk_assessor/themes/my_themes.dart';
import 'package:gemini_risk_assessor/utilities/global.dart';
import 'package:gemini_risk_assessor/utilities/my_image_cache_manager.dart';
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

  void _handleSharing(OrganizationModel org, String uid) {
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
        message: 'Already sharing this item with this organization',
      );

      return;
    }

    _showSharingDialog(
      org,
      uid,
    );
  }

  void _showSharingDialog(OrganizationModel org, String uid) {
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
            Navigator.pop(context);
            await _performSharing(org, uid);
          },
          child: const Text('Yes'),
        ),
      ],
    );
  }

  Future<void> _performSharing(OrganizationModel org, String uid) async {
    if (widget.generationType == GenerationType.tool) {
      await FirebaseMethods.shareToolWithOrganization(
        uid: uid,
        toolModel: widget.toolModel!,
        orgID: org.organizationID,
      );
    } else {
      await FirebaseMethods.shareWithOrganization(
        uid: uid,
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
    final uid = context.read<AuthenticationProvider>().userModel!.uid;
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
                  title: Constants.shareWithTitle,
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
                      (element) => element[Constants.name]
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

                                    return shareGridItem(org, uid);
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

  shareGridItem(OrganizationModel org, String uid) {
    return Card(
      child: GestureDetector(
        onTap: () {
          _handleSharing(org, uid);
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            final imageHeight = constraints.maxHeight * 0.8;
            final textHeight = constraints.maxHeight * 0.2;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: imageHeight,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10.0),
                      topRight: Radius.circular(10.0),
                    ),
                    child: MyImageCacheManager.showImage(
                      imageUrl: org.imageUrl!,
                      isTool: false,
                    ),
                  ),
                ),
                SizedBox(
                  height: textHeight * 0.1,
                ), // Spacing between image and text
                SizedBox(
                  height: textHeight * 0.9,
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(
                      org.name,
                      style: textStyle16w600,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
