import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/models/assessment_model.dart';
import 'package:gemini_risk_assessor/providers/auth_provider.dart';
import 'package:gemini_risk_assessor/search/my_search_bar.dart';
import 'package:gemini_risk_assessor/firebase_methods/firebase_methods.dart';
import 'package:gemini_risk_assessor/themes/my_themes.dart';
import 'package:gemini_risk_assessor/widgets/list_item.dart';
import 'package:gemini_risk_assessor/appBars/my_app_bar.dart';
import 'package:provider/provider.dart';

class DSTIScreen extends StatefulWidget {
  const DSTIScreen({
    super.key,
    this.orgID = '',
  });

  final String orgID;

  @override
  State<DSTIScreen> createState() => _DSTIScreenState();
}

class _DSTIScreenState extends State<DSTIScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthProvider>().userModel!.uid;

    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseMethods.dstiStream(
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
                        title: Constants.dailySafetyTaskInstructions,
                      )
                    : null,
                body: const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('No Daily Safety Tast Intructions found',
                        textAlign: TextAlign.center, style: textStyle18w500),
                  ),
                ),
              );
            }
            return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                final results = snapshot.data!.docs.where(
                  (element) => element[Constants.title]
                      .toString()
                      .toLowerCase()
                      .contains(
                        _searchQuery.toLowerCase(),
                      ),
                );
                return widget.orgID.isNotEmpty
                    ? CustomScrollView(
                        slivers: [
                          SliverAppBar(
                            leading: const BackButton(),
                            title: const FittedBox(
                              child: Text(
                                Constants.dailySafetyTaskInstructions,
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
                                : SliverList(
                                    delegate: SliverChildBuilderDelegate(
                                      (context, index) {
                                        final doc = results.elementAt(index);
                                        final data =
                                            doc.data() as Map<String, dynamic>;
                                        final item =
                                            AssessmentModel.fromJson(data);
                                        return ListItem(
                                          docTitle: Constants
                                              .dailySafetyTaskInstructions,
                                          data: item,
                                        );
                                      },
                                      childCount: results.length,
                                    ),
                                  ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        itemCount: results.length,
                        itemBuilder: (context, index) {
                          final doc = results.elementAt(index);
                          final data = doc.data() as Map<String, dynamic>;
                          final assessment = AssessmentModel.fromJson(data);
                          return ListItem(
                            docTitle: Constants.dailySafetyTaskInstructions,
                            data: assessment,
                          );
                        },
                      );
              },
            );
          },
        ),
      ),
    );
  }
}
