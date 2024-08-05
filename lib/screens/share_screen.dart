import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/appBars/my_app_bar.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/dialogs/my_dialogs.dart';
import 'package:gemini_risk_assessor/enums/enums.dart';
import 'package:gemini_risk_assessor/firebase_methods/analytics_helper.dart';
import 'package:gemini_risk_assessor/firebase_methods/firebase_methods.dart';
import 'package:gemini_risk_assessor/models/assessment_model.dart';
import 'package:gemini_risk_assessor/groups/group_model.dart';
import 'package:gemini_risk_assessor/themes/app_theme.dart';
import 'package:gemini_risk_assessor/tools/tool_model.dart';
import 'package:gemini_risk_assessor/authentication/authentication_provider.dart';
import 'package:gemini_risk_assessor/search/my_search_bar.dart';
import 'package:gemini_risk_assessor/utilities/global.dart';
import 'package:gemini_risk_assessor/utilities/my_image_cache_manager.dart';
import 'package:provider/provider.dart';

class ShareScreen extends StatefulWidget {
  const ShareScreen({
    super.key,
    this.itemModel,
    this.toolModel,
    this.groupID = '',
    required this.generationType,
  });

  final AssessmentModel? itemModel;
  final ToolModel? toolModel;
  final String groupID;
  final GenerationType generationType;

  @override
  State<ShareScreen> createState() => _ShareScreenState();
}

class _ShareScreenState extends State<ShareScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    AnalyticsHelper.logScreenView(
      screenName: 'Share Screen',
      screenClass: 'ShareScreen',
    );
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleSharing(GroupModel groupModel, String uid) {
    if (!groupModel.allowSharing) {
      showSnackBar(
        context: context,
        message: 'Sharing not allowed for this group',
      );
      return;
    }

    final isAlreadyShared = widget.generationType == GenerationType.tool
        ? widget.toolModel!.sharedWith.contains(groupModel.groupID)
        : widget.itemModel!.sharedWith.contains(groupModel.groupID);

    if (isAlreadyShared) {
      showSnackBar(
        context: context,
        message: 'Already sharing this item with this group',
      );

      return;
    }

    _showSharingDialog(
      groupModel,
      uid,
    );
  }

  void _showSharingDialog(GroupModel groupModel, String uid) {
    MyDialogs.showMyAnimatedDialog(
      context: context,
      title: 'Share',
      content: 'Share with ${groupModel.name}',
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Cancel',
            style: TextStyle(
              color: Colors.red,
            ),
          ),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(context);
            await _performSharing(groupModel, uid);
          },
          child: const Text('Yes'),
        ),
      ],
    );
  }

  Future<void> _performSharing(GroupModel groupModel, String uid) async {
    if (widget.generationType == GenerationType.tool) {
      await FirebaseMethods.shareToolWithGroup(
        uid: uid,
        toolModel: widget.toolModel!,
        groupID: groupModel.groupID,
      );
    } else {
      await FirebaseMethods.shareWithGroup(
        uid: uid,
        itemModel: widget.itemModel!,
        groupID: groupModel.groupID,
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
          stream: FirebaseMethods.groupsStream(
            userId: uid,
            groupID: widget.groupID,
            fromShare: true,
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
                    child: Text(
                      'No Groups Found!',
                      textAlign: TextAlign.center,
                      style: AppTheme.textStyle18w500,
                    ),
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
                          Constants.shareWithTitle,
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

                                    final group = GroupModel.fromJson(data);
                                    if (group.groupID == widget.groupID) {
                                      return const SizedBox.shrink();
                                    }

                                    return shareGridItem(group, uid);
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

  shareGridItem(GroupModel group, String uid) {
    return Card(
      color: Theme.of(context).cardColor,
      child: GestureDetector(
        onTap: () {
          _handleSharing(group, uid);
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
                      imageUrl: group.groupImage!,
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
                      group.name,
                      style: AppTheme.textStyle16w600,
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
