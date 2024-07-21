import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/appBars/my_app_bar.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/enums/enums.dart';
import 'package:gemini_risk_assessor/models/tool_model.dart';
import 'package:gemini_risk_assessor/providers/authentication_provider.dart';
import 'package:gemini_risk_assessor/search/my_data_stream.dart';
import 'package:gemini_risk_assessor/search/my_search_bar.dart';
import 'package:gemini_risk_assessor/firebase_methods/firebase_methods.dart';
import 'package:gemini_risk_assessor/themes/my_themes.dart';
import 'package:gemini_risk_assessor/widgets/grid_item.dart';
import 'package:provider/provider.dart';

class ToolsScreen extends StatefulWidget {
  const ToolsScreen({
    super.key,
    this.orgID = '',
    this.isDiscussion = false,
  });

  final String orgID;
  final bool isDiscussion;

  @override
  State<ToolsScreen> createState() => _ToolsScreenState();
}

class _ToolsScreenState extends State<ToolsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthenticationProvider>().userModel!.uid;

    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseMethods.toolsStream(
            userId: uid,
            orgID: widget.orgID,
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
              return Scaffold(
                appBar: widget.orgID.isNotEmpty
                    ? const MyAppBar(
                        leading: BackButton(),
                        title: Constants.tools,
                      )
                    : null,
                body: const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'You have not saved any tools',
                      textAlign: TextAlign.center,
                      style: textStyle18w500,
                    ),
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
                return widget.orgID.isNotEmpty
                    ? CustomScrollView(
                        slivers: [
                          SliverAppBar(
                            leading: const BackButton(),
                            title: const FittedBox(
                              child: Text(
                                Constants.tools,
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
                                      child: Center(
                                          child: Text('No matching results')),
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
                                          final data = doc.data()
                                              as Map<String, dynamic>;

                                          final tool = ToolModel.fromJson(data);
                                          return ToolGridItem(
                                            toolModel: tool,
                                            isDiscussion: widget.isDiscussion,
                                          );
                                        },
                                        childCount: results.length,
                                      ),
                                    )),
                        ],
                      )
                    : const MyDataStream(
                        generationType: GenerationType.tool,
                      );
              },
            );
          },
        ),
      ),
    );
  }
}
