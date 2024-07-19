import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gemini_risk_assessor/appBars/my_app_bar.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/enums/enums.dart';
import 'package:gemini_risk_assessor/firebase_methods/firebase_methods.dart';
import 'package:gemini_risk_assessor/models/user_model.dart';
import 'package:gemini_risk_assessor/providers/authentication_provider.dart';
import 'package:gemini_risk_assessor/providers/organization_provider.dart';
import 'package:gemini_risk_assessor/search/my_search_bar.dart';
import 'package:gemini_risk_assessor/themes/my_themes.dart';
import 'package:gemini_risk_assessor/utilities/global.dart';
import 'package:gemini_risk_assessor/widgets/user_widget.dart';
import 'package:provider/provider.dart';

class PeopleScreen extends StatefulWidget {
  const PeopleScreen({
    super.key,
    required this.userViewType,
  });

  final UserViewType userViewType;

  @override
  State<PeopleScreen> createState() => _PeopleScreenState();
}

class _PeopleScreenState extends State<PeopleScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrganizationProvider>().setInitialMemberState();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _updateHasChanges() {
    final orgProvider = context.read<OrganizationProvider>();
    setState(() {
      _hasChanges = orgProvider.hasChanges();
    });
  }

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthenticationProvider>().userModel!.uid;
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseMethods.allUsersStream(),
          builder: (context, snapshot) {
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
                  title: Constants.people,
                ),
                body: Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text('No data found',
                        textAlign: TextAlign.center, style: textStyle18w500),
                  ),
                ),
              );
            }

            return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                final Iterable<
                    QueryDocumentSnapshot<Object?>> results = _searchQuery
                        .isNotEmpty
                    ? snapshot.data!.docs.where(
                        (element) => element[Constants.name]
                            .toString()
                            .toLowerCase()
                            .contains(
                              _searchQuery.toLowerCase(),
                            ),
                      )
                    : const Iterable<QueryDocumentSnapshot<Object?>>.empty();

                return CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      leading: const BackButton(),
                      title: const FittedBox(
                        child: Text(
                          Constants.people,
                        ),
                      ),
                      actions: [
                        if (widget.userViewType == UserViewType.tempPlus &&
                            _hasChanges)
                          IconButton(
                            onPressed: () async {
                              final orgProvider =
                                  context.read<OrganizationProvider>();
                              if (orgProvider.isLoading) {
                                return;
                              }
                              await context
                                  .read<OrganizationProvider>()
                                  .updateOrganizationDataInFireStore()
                                  .whenComplete(() {
                                showSnackBar(
                                  context: context,
                                  message: 'Requests sent to added members',
                                );
                              });
                            },
                            icon: const Icon(
                              FontAwesomeIcons.check,
                            ),
                          )
                      ],
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
                      sliver: _searchQuery.isEmpty
                          ? const SliverFillRemaining(
                              child: Center(
                                child: Text(
                                  'Search for people',
                                  style: textStyle18w500,
                                ),
                              ),
                            )
                          : results.isEmpty
                              ? const SliverFillRemaining(
                                  child: Center(
                                    child: Text('No matching results'),
                                  ),
                                )
                              : SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) {
                                      final doc = results.elementAt(index);
                                      final data =
                                          doc.data() as Map<String, dynamic>;
                                      final user = UserModel.fromJson(data);
                                      if (user.uid == uid) {
                                        return const SizedBox();
                                      }
                                      return UserWidget(
                                        userData: user,
                                        showCheckMark: true,
                                        viewType: widget.userViewType,
                                        onChanged: _updateHasChanges,
                                      );
                                    },
                                    childCount: results.length,
                                  ),
                                ),
                    ),
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
