import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/dialogs/my_dialogs.dart';
import 'package:gemini_risk_assessor/enums/enums.dart';
import 'package:gemini_risk_assessor/firebase_methods/firebase_methods.dart';
import 'package:gemini_risk_assessor/models/user_model.dart';
import 'package:gemini_risk_assessor/providers/authentication_provider.dart';
import 'package:gemini_risk_assessor/groups/group_provider.dart';
import 'package:gemini_risk_assessor/search/people_search_bar.dart';
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
  final ValueNotifier<String> _searchQuery = ValueNotifier('');
  final ValueNotifier<bool> _hasChanges = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GroupProvider>().setInitialMemberState();
    });
  }

  @override
  void dispose() {
    _searchQuery.dispose();
    _hasChanges.dispose();
    super.dispose();
  }

  void _updateHasChanges() {
    final groupProvider = context.read<GroupProvider>();
    _hasChanges.value = groupProvider.hasChanges();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseMethods.allUsersStream(),
          builder: (context, snapshot) {
            return CustomScrollView(
              slivers: [
                _buildSliverAppBar(context),
                SliverPadding(
                  padding: const EdgeInsets.all(8.0),
                  sliver: SliverToBoxAdapter(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _buildContent(snapshot),
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

  Widget _buildContent(AsyncSnapshot<QuerySnapshot> snapshot) {
    if (snapshot.hasError) {
      return const Center(child: Text('Something went wrong'));
    }
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }
    if (snapshot.data!.docs.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            'No data found',
            textAlign: TextAlign.center,
            style: textStyle18w500,
          ),
        ),
      );
    }

    final allUsers = snapshot.data!.docs
        .map((doc) => UserModel.fromJson(doc.data() as Map<String, dynamic>))
        .where((user) =>
            user.uid != context.read<AuthenticationProvider>().userModel!.uid)
        .toList();

    return ValueListenableBuilder<String>(
      valueListenable: _searchQuery,
      builder: (context, query, _) {
        final filteredUsers = query.isEmpty
            ? allUsers
            : allUsers
                .where(
                  (user) => user.name.toLowerCase().contains(
                        query.toLowerCase(),
                      ),
                )
                .toList();

        if (query.isEmpty) {
          return const Center(
            child: Text(
              'Search for people',
              style: textStyle18w500,
            ),
          );
        }

        if (filteredUsers.isEmpty) {
          return const Center(
            child: Text(
              'No matching results',
              style: textStyle18w500,
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filteredUsers.length,
          itemBuilder: (context, index) {
            return UserWidget(
              userData: filteredUsers[index],
              showCheckMark: true,
              viewType: widget.userViewType,
              onChanged: _updateHasChanges,
            );
          },
        );
      },
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    final groupProvider = context.watch<GroupProvider>();
    final isCreation = widget.userViewType == UserViewType.creator;
    final listNotEmpty = groupProvider.awaitApprovalsList.isNotEmpty;
    return SliverAppBar(
      leading: const BackButton(),
      title: const FittedBox(
        child: Text(Constants.people),
      ),
      actions: [
        ValueListenableBuilder<bool>(
          valueListenable: _hasChanges,
          builder: (context, hasChanges, _) {
            if (widget.userViewType == UserViewType.tempPlus && hasChanges) {
              return IconButton(
                onPressed: () async {
                  if (groupProvider.isLoading) return;
                  await groupProvider
                      .updateGroupDataInFireStore()
                      .whenComplete(() {
                    showSnackBar(
                      context: context,
                      message: 'Requests sent to added members',
                    );
                  });
                },
                icon: const Icon(FontAwesomeIcons.check),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        isCreation && listNotEmpty
            ? IconButton(
                onPressed: () async {
                  // show dialog to clear the list
                  MyDialogs.showMyAnimatedDialog(
                      context: context,
                      title: 'Clear List',
                      content: 'Are you sure to clear all selected?',
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              color: Colors.red,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            groupProvider.clearAwaitingApprovalList();
                            Navigator.pop(context);
                          },
                          child: const Text('Yes'),
                        ),
                      ]);
                },
                icon: const Icon(FontAwesomeIcons.trashCan),
              )
            : const SizedBox.shrink()
      ],
      pinned: true,
      floating: true,
      snap: true,
      expandedHeight: 120.0,
      flexibleSpace: FlexibleSpaceBar(
        background: Padding(
          padding: const EdgeInsets.only(top: 56.0),
          child: PeopleSearchBar(
            searchQuery: _searchQuery,
            onChanged: (value) {
              _searchQuery.value = value;
            },
          ),
        ),
      ),
    );
  }
}
